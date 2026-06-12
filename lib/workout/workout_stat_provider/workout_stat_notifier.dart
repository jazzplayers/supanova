import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:home_function/workout/workout_model/workout_stats_state.dart';
import 'package:home_function/workout_finish/workout_finish.dart';
import 'package:home_function/workout/workout_foreground/foreground_workout_service.dart';

part 'workout_stat_notifier.g.dart';

@Riverpod(keepAlive: true)
class Workout extends _$Workout {
  StreamSubscription<Position>? _sub;
  Timer? _timer;
  Position? _prev;

  double _totalDistance = 0;
  DateTime? _startTime;
  Duration _pausedAccumulated = Duration.zero;
  DateTime? _pauseStartTime;

  @override
  WorkoutStatsState build() {
    ref.onDispose(() {
      _sub?.cancel();
      _sub = null;

      _timer?.cancel();
      _timer = null;

      _prev = null;
      _totalDistance = 0;

      _startTime = null;
      _pausedAccumulated = Duration.zero;
      _pauseStartTime = null;
    });

    return const WorkoutStatsState();
  }

  // ---------------------------
  // Time 계산
  // ---------------------------

  int get elapsedSeconds {
    final start = _startTime;
    if (start == null) return 0;

    final now = DateTime.now();
    final base = now.difference(start);

    final extraPaused = _pauseStartTime != null
        ? now.difference(_pauseStartTime!)
        : Duration.zero;

    final elapsed = base - _pausedAccumulated - extraPaused;
    return elapsed.isNegative ? 0 : elapsed.inSeconds;
  }

  // ---------------------------
  // 속도/페이스 계산
  // ---------------------------

  double _calcSpeedKmh({
    required double meters,
    required int seconds,
  }) {
    if (seconds <= 0) return 0.0;
    return (meters / seconds) * 3.6;
  }

  double _calcPaceMinPerKm({
    required double meters,
    required int seconds,
  }) {
    if (meters <= 0) return 0.0;

    final km = meters / 1000.0;
    final minutes = seconds / 60.0;

    return minutes / km;
  }

  void _startTicker() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final sec = elapsedSeconds;
        final meters = _totalDistance;

        state = state.copyWith(
          seconds: sec,
          distanceMeters: meters,
          speedKmh: _calcSpeedKmh(
            meters: meters,
            seconds: sec,
          ),
          paceMinPerKm: _calcPaceMinPerKm(
            meters: meters,
            seconds: sec,
          ),
        );
      },
    );
  }

  void _stopTicker() {
    _timer?.cancel();
    _timer = null;
  }

  // ---------------------------
  // Permission / Service 체크
  // ---------------------------

  Future<void> _ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location service is disabled');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied forever');
    }
  }

  LocationSettings _getWorkoutLocationSettings() {
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        activityType: ActivityType.fitness,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }

    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: '운동 기록 중',
          notificationText: '거리와 시간이 기록되고 있습니다.',
          enableWakeLock: true,
        ),
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
  }

  Future<void> _startForegroundServiceIfNeeded() async {
    if (Platform.isAndroid) {
      await startWorkoutForegroundService();
    }
  }

  Future<void> _stopForegroundServiceIfNeeded() async {
    if (Platform.isAndroid) {
      await stopWorkoutForegroundService();
    }
  }

  // ---------------------------
  // Controls
  // ---------------------------

  Future<void> start() async {
    if (state.status == WorkoutStatStatus.running) return;

    try {
      await _ensureLocationReady();
    } catch (_) {
      return;
    }

    await _startForegroundServiceIfNeeded();

    await _sub?.cancel();
    _sub = null;

    _prev = null;
    _totalDistance = 0;

    _startTime = DateTime.now();
    _pausedAccumulated = Duration.zero;
    _pauseStartTime = null;

    state = state.copyWith(
      status: WorkoutStatStatus.running,
      routePoints: const <LatLng>[],
      distanceMeters: 0.0,
      seconds: 0,
      speedKmh: 0.0,
      paceMinPerKm: 0.0,
    );

    _startTicker();

    _sub = Geolocator.getPositionStream(
      locationSettings: _getWorkoutLocationSettings(),
    ).listen(
      (Position position) {
        if (state.status != WorkoutStatStatus.running) return;

        // 정확도 너무 안 좋은 GPS 값은 무시
        if (position.accuracy > 10) return;

        final latLng = LatLng(
          position.latitude,
          position.longitude,
        );

        // 첫 위치는 거리 계산 없이 저장만
        if (_prev == null) {
          _prev = position;

          state = state.copyWith(
            routePoints: [
              ...state.routePoints,
              latLng,
            ],
          );

          return;
        }

        final prev = _prev!;

        final distance = Geolocator.distanceBetween(
          prev.latitude,
          prev.longitude,
          position.latitude,
          position.longitude,
        );

        // 너무 작은 이동은 GPS 노이즈로 보고 무시
        if (distance <= 1) {
          _prev = position;
          return;
        }

        _totalDistance += distance;
        _prev = position;

        state = state.copyWith(
          distanceMeters: _totalDistance,
          routePoints: [
            ...state.routePoints,
            latLng,
          ],
        );
      },
      onError: (_) {
        stop();
      },
    );
  }

  void pause() {
    if (state.status != WorkoutStatStatus.running) return;

    _sub?.pause();
    _pauseStartTime = DateTime.now();

    // pause 중 이동한 거리 튐 방지
    _prev = null;

    _stopTicker();

    final sec = elapsedSeconds;

    state = state.copyWith(
      status: WorkoutStatStatus.paused,
      seconds: sec,
      distanceMeters: _totalDistance,
      speedKmh: _calcSpeedKmh(
        meters: _totalDistance,
        seconds: sec,
      ),
      paceMinPerKm: _calcPaceMinPerKm(
        meters: _totalDistance,
        seconds: sec,
      ),
    );
  }

  void resume() {
    if (state.status != WorkoutStatStatus.paused) return;

    if (_pauseStartTime != null) {
      _pausedAccumulated += DateTime.now().difference(_pauseStartTime!);
      _pauseStartTime = null;
    }

    _sub?.resume();
    _startTicker();

    final sec = elapsedSeconds;

    state = state.copyWith(
      status: WorkoutStatStatus.running,
      seconds: sec,
      distanceMeters: _totalDistance,
      speedKmh: _calcSpeedKmh(
        meters: _totalDistance,
        seconds: sec,
      ),
      paceMinPerKm: _calcPaceMinPerKm(
        meters: _totalDistance,
        seconds: sec,
      ),
    );
  }

  Future<void> stop() async {
    final sec = elapsedSeconds;
    final meters = _totalDistance;

    await _sub?.cancel();
    _sub = null;

    _stopTicker();

    await _stopForegroundServiceIfNeeded();

    state = state.copyWith(
      status: WorkoutStatStatus.stopped,
      seconds: sec,
      distanceMeters: meters,
      speedKmh: _calcSpeedKmh(
        meters: meters,
        seconds: sec,
      ),
      paceMinPerKm: _calcPaceMinPerKm(
        meters: meters,
        seconds: sec,
      ),
    );

    _pauseStartTime = null;
    _startTime = null;
    _pausedAccumulated = Duration.zero;

    // routePoints는 결과 페이지에서 쓸 수 있게 유지
  }

  WorkoutFinish buildFinish({required String userId}) {
    return WorkoutFinish(
      userId: userId,
      distanceMeters: state.distanceMeters,
      seconds: state.seconds,
      speedKmh: state.speedKmh,
      paceMinPerKm: state.paceMinPerKm,
      routePoints: state.routePoints,
      updatedAt: DateTime.now(),
      createdAt: DateTime.now(),
      timestamp: DateTime.now(),
    );
  }

  Future<void> idle() async {
    await _sub?.cancel();
    _sub = null;

    _stopTicker();

    await _stopForegroundServiceIfNeeded();

    _prev = null;
    _totalDistance = 0;

    _startTime = null;
    _pausedAccumulated = Duration.zero;
    _pauseStartTime = null;

    state = state.copyWith(
      status: WorkoutStatStatus.idle,
      seconds: 0,
      distanceMeters: 0.0,
      speedKmh: 0.0,
      paceMinPerKm: 0.0,
      routePoints: const <LatLng>[],
    );
  }
}