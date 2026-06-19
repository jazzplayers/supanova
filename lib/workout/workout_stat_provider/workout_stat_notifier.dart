import 'dart:async';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:home_function/workout/workout_foreground/foreground_workout_service.dart';
import 'package:home_function/workout/workout_model/workout_stats_state.dart';
import 'package:home_function/workout_finish/workout_finish.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'workout_stat_notifier.g.dart';

@Riverpod(keepAlive: true)
class Workout extends _$Workout {
  StreamSubscription<Position>? _sub;
  Timer? _timer;
  Position? _prev;

  double _totalDistance = 0.0;
  DateTime? _startTime;
  Duration _pausedAccumulated = Duration.zero;
  DateTime? _pauseStartTime;

  static const double _minDistanceMeters = 1.0;

  // GPS 정확도가 너무 낮은 좌표는 무시
  static const double _maxAccuracyMeters = 30.0;

  // 1회 GPS 업데이트에서 너무 멀리 튀는 좌표 제거
  static const double _maxReasonableSegmentMeters = 150.0;

  // 실시간 GPS 튐 제거용
  // 10.0m/s = 36km/h
  // 러닝 중 순간 가속/내리막은 어느 정도 살리고,
  // 차량/자전거 수준의 비정상 이동은 1차로 걸러냄
  static const double _maxReasonableSpeedMps = 10.0;

  @override
  WorkoutStatsState build() {
    ref.onDispose(() {
      _sub?.cancel();
      _sub = null;

      _timer?.cancel();
      _timer = null;

      _prev = null;
      _totalDistance = 0.0;

      _startTime = null;
      _pausedAccumulated = Duration.zero;
      _pauseStartTime = null;

      unawaited(_stopForegroundServiceIfNeeded());
    });

    return const WorkoutStatsState();
  }

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

  double _calcSpeedKmh({
    required double meters,
    required int seconds,
  }) {
    if (meters <= 0 || seconds <= 0) return 0.0;

    final speed = (meters / seconds) * 3.6;

    if (speed.isNaN || speed.isInfinite || speed < 0) {
      return 0.0;
    }

    return speed;
  }

  double _calcPaceMinPerKm({
    required double meters,
    required int seconds,
  }) {
    if (meters <= 0 || seconds <= 0) return 0.0;

    final km = meters / 1000.0;
    final minutes = seconds / 60.0;
    final pace = minutes / km;

    if (pace.isNaN || pace.isInfinite || pace < 0) {
      return 0.0;
    }

    return pace;
  }

  void _startTicker() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (state.status != WorkoutStatStatus.running) return;

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

  Future<void> _ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('위치 서비스가 꺼져 있습니다. 기기 설정에서 GPS를 켜주세요.');
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('위치 권한이 거부되었습니다. 위치 권한을 허용해야 운동을 기록할 수 있습니다.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 위치 권한을 허용해주세요.');
    }

    if (permission == LocationPermission.unableToDetermine) {
      throw Exception('위치 권한 상태를 확인할 수 없습니다. 잠시 후 다시 시도해주세요.');
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
    if (!Platform.isAndroid) return;

    await startWorkoutForegroundService();
  }

  Future<void> _stopForegroundServiceIfNeeded() async {
    if (!Platform.isAndroid) return;

    await stopWorkoutForegroundService();
  }

  bool _isValidPosition(Position position) {
    final lat = position.latitude;
    final lng = position.longitude;
    final accuracy = position.accuracy;

    if (lat.isNaN || lat.isInfinite || lng.isNaN || lng.isInfinite) {
      return false;
    }

    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      return false;
    }

    if (accuracy.isNaN || accuracy.isInfinite) {
      return false;
    }

    if (accuracy > _maxAccuracyMeters) {
      return false;
    }

    return true;
  }

  bool _isValidSegment({
    required Position previous,
    required Position current,
    required double distance,
  }) {
    if (distance <= _minDistanceMeters) {
      return false;
    }

    if (distance > _maxReasonableSegmentMeters) {
      return false;
    }

    final previousTime = previous.timestamp;
    final currentTime = current.timestamp;

    if (previousTime == null || currentTime == null) {
      return false;
    }

    final diffSeconds =
        currentTime.difference(previousTime).inMilliseconds / 1000.0;

    if (diffSeconds <= 0) {
      return false;
    }

    final speedMps = distance / diffSeconds;

    if (speedMps.isNaN || speedMps.isInfinite) {
      return false;
    }

    if (speedMps > _maxReasonableSpeedMps) {
      return false;
    }

    return true;
  }

  Future<void> start() async {
    if (state.status == WorkoutStatStatus.running) return;

    if (state.status == WorkoutStatStatus.paused) {
      resume();
      return;
    }

    await _ensureLocationReady();

    await _startForegroundServiceIfNeeded();

    await _sub?.cancel();
    _sub = null;

    _timer?.cancel();
    _timer = null;

    _prev = null;
    _totalDistance = 0.0;

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
      _handlePosition,
      onError: (error) {
        unawaited(_handlePositionStreamError(error));
      },
      cancelOnError: false,
    );
  }

  void _handlePosition(Position position) {
    if (state.status != WorkoutStatStatus.running) return;

    if (!_isValidPosition(position)) {
      return;
    }

    final latLng = LatLng(
      position.latitude,
      position.longitude,
    );

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

    final previous = _prev!;

    final distance = Geolocator.distanceBetween(
      previous.latitude,
      previous.longitude,
      position.latitude,
      position.longitude,
    );

    if (!_isValidSegment(
      previous: previous,
      current: position,
      distance: distance,
    )) {
      // 비정상 구간은 거리/경로에 더하지 않음
      // 대신 다음 정상 좌표와 비교할 기준점은 최신 좌표로 교체
      _prev = position;
      return;
    }

    _totalDistance += distance;
    _prev = position;

    final sec = elapsedSeconds;

    state = state.copyWith(
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
      routePoints: [
        ...state.routePoints,
        latLng,
      ],
    );
  }

  Future<void> _handlePositionStreamError(Object error) async {
    if (state.status == WorkoutStatStatus.idle) return;

    await stop();
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

    // 재시작 직후 위치 튐 방지
    _prev = null;

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

    _prev = null;
    _totalDistance = meters;

    _pauseStartTime = null;
    _startTime = null;
    _pausedAccumulated = Duration.zero;
  }

  WorkoutFinish buildFinish({required String userId}) {
    final now = DateTime.now();

    return WorkoutFinish(
      userId: userId,
      distanceMeters: state.distanceMeters,
      seconds: state.seconds,
      speedKmh: state.speedKmh,
      paceMinPerKm: state.paceMinPerKm,
      routePoints: state.routePoints,
      updatedAt: now,
      createdAt: now,
      timestamp: now,
    );
  }

  Future<void> idle() async {
    await _sub?.cancel();
    _sub = null;

    _stopTicker();

    await _stopForegroundServiceIfNeeded();

    _prev = null;
    _totalDistance = 0.0;

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