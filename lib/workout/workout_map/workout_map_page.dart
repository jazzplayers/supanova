import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:home_function/map/map_provider.dart';
import 'package:home_function/workout/workout_stat_provider/workout_stat_notifier.dart';

class WorkoutMapPage extends ConsumerStatefulWidget {
  const WorkoutMapPage({super.key});

  @override
  ConsumerState<WorkoutMapPage> createState() => _WorkoutMapPageState();
}

class _WorkoutMapPageState extends ConsumerState<WorkoutMapPage> {
  GoogleMapController? _controller;
  StreamSubscription<Position>? _positionSub;

  LatLng? _target;

  bool _isLoading = true;
  bool _followMe = true;
  bool _isProgrammaticMove = false;

  String? _errorMessage;

  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);

  static const double _defaultZoom = 17;

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF151B22);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(mapRepositoryProvider);
      final position = await repo.getCurrentLocation();

      if (!mounted) return;

      final latLng = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _target = latLng;
        _followMe = true;
        _isLoading = false;
      });

      await _startPositionStream();
      await _moveCamera(latLng);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _parseLocationError(e);
      });
    }
  }

  Future<void> _startPositionStream() async {
    final repo = ref.read(mapRepositoryProvider);

    await _positionSub?.cancel();

    _positionSub = repo.streamPosition().listen(
      (position) {
        if (!mounted) return;

        final latLng = LatLng(
          position.latitude,
          position.longitude,
        );

        setState(() {
          _target = latLng;
        });

        if (_followMe) {
          _moveCameraThrottled(latLng);
        }
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMessage = _parseLocationError(error);
        });
      },
    );
  }

  String _parseLocationError(Object error) {
    final message = error.toString();

    if (message.contains('영구적으로') ||
        message.contains('deniedForever') ||
        message.contains('denied forever')) {
      return '위치 권한이 영구적으로 거부되었습니다.\n설정에서 위치 권한을 허용해주세요.';
    }

    if (message.contains('거부') || message.contains('denied')) {
      return '위치 권한이 거부되었습니다.\n위치 권한을 허용해야 지도를 사용할 수 있습니다.';
    }

    if (message.contains('꺼져') ||
        message.contains('비활성화') ||
        message.contains('disabled')) {
      return '위치 서비스가 꺼져 있습니다.\n기기 설정에서 GPS를 켜주세요.';
    }

    return '현재 위치를 가져올 수 없습니다.\n위치 권한과 GPS 설정을 확인해주세요.';
  }

  Future<void> _moveCameraThrottled(LatLng target) async {
    final now = DateTime.now();

    if (now.difference(_lastCameraMove).inMilliseconds < 600) {
      return;
    }

    _lastCameraMove = now;
    await _moveCamera(target);
  }

  Future<void> _moveCamera(LatLng target) async {
    final controller = _controller;

    if (controller == null) return;

    _isProgrammaticMove = true;

    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: _defaultZoom,
            tilt: 0,
            bearing: 0,
          ),
        ),
      );
    } catch (_) {
      // 페이지 전환 중이거나 컨트롤러가 dispose 된 경우 무시
    } finally {
      Future<void>.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        _isProgrammaticMove = false;
      });
    }
  }

  Future<void> _toggleFollowMe() async {
    final nextFollowState = !_followMe;

    setState(() {
      _followMe = nextFollowState;
    });

    if (nextFollowState && _target != null) {
      await _moveCamera(_target!);
    }
  }

  Future<void> _openAppLocationSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> _openDeviceLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(workoutProvider);
    final points = live.routePoints;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              color: _accent,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: _WorkoutMapErrorCard(
                message: _errorMessage!,
                onRetry: _initLocation,
                onOpenAppSettings: _openAppLocationSettings,
                onOpenLocationSettings: _openDeviceLocationSettings,
              ),
            ),
          ),
        ),
      );
    }

    final target = _target;

    if (target == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Center(
            child: Text(
              '현재 위치 정보가 없습니다.',
              style: TextStyle(
                color: _primaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    final media = MediaQuery.of(context);
    final topPadding = media.padding.top;
    final bottomPadding = media.padding.bottom;

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 62,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: _RoundMapButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            8,
            8 + topPadding,
            8,
            8,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                GoogleMap(
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  initialCameraPosition: CameraPosition(
                    target: target,
                    zoom: _defaultZoom,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: true,
                  scrollGesturesEnabled: true,
                  tiltGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  onMapCreated: (controller) async {
                    _controller = controller;

                    if (_followMe && _target != null) {
                      await _moveCamera(_target!);
                    }
                  },
                  onCameraMoveStarted: () {
                    if (_isProgrammaticMove) return;

                    if (_followMe) {
                      setState(() {
                        _followMe = false;
                      });
                    }
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('current_location'),
                      position: target,
                      infoWindow: const InfoWindow(
                        title: '현재 위치',
                      ),
                    ),
                  },
                  circles: {
                    Circle(
                      circleId: const CircleId('current_location_circle'),
                      center: target,
                      radius: 100,
                      strokeWidth: 2,
                      strokeColor: _accent,
                      fillColor: _accent.withAlpha(38),
                    ),
                  },
                  polylines: {
                    if (points.length >= 2)
                      Polyline(
                        polylineId: const PolylineId('workout_path'),
                        points: points,
                        color: _accent,
                        width: 5,
                        startCap: Cap.roundCap,
                        endCap: Cap.roundCap,
                        jointType: JointType.round,
                      ),
                  },
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  right: 14,
                  child: _WorkoutMapStatusCard(
                    followMe: _followMe,
                    pointCount: points.length,
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 18 + bottomPadding,
                  child: _FollowLocationButton(
                    followMe: _followMe,
                    onTap: _toggleFollowMe,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkoutMapErrorCard extends StatelessWidget {
  const _WorkoutMapErrorCard({
    required this.message,
    required this.onRetry,
    required this.onOpenAppSettings,
    required this.onOpenLocationSettings,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenLocationSettings;

  static const Color _surface = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withAlpha(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: _accent.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: _accent,
              size: 34,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            '위치를 불러올 수 없습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                '다시 시도',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onOpenAppSettings,
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryText,
                side: const BorderSide(
                  color: Color(0xFF2A3340),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.settings_outlined, size: 20),
              label: const Text(
                '앱 위치 권한 설정',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: TextButton.icon(
              onPressed: onOpenLocationSettings,
              style: TextButton.styleFrom(
                foregroundColor: _secondaryText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.gps_fixed_rounded, size: 20),
              label: const Text(
                '기기 위치 서비스 설정',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutMapStatusCard extends StatelessWidget {
  const _WorkoutMapStatusCard({
    required this.followMe,
    required this.pointCount,
  });

  final bool followMe;
  final int pointCount;

  static const Color _surface = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: _surface.withAlpha(235),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withAlpha(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(41),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _accent.withAlpha(36),
                shape: BoxShape.circle,
              ),
              child: Icon(
                followMe
                    ? Icons.gps_fixed_rounded
                    : Icons.gps_not_fixed_rounded,
                color: _accent,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 260;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        followMe ? '현재 위치 따라가는 중' : '지도 이동됨',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 3),
                        Text(
                          pointCount >= 2
                              ? '운동 경로를 지도에 표시하고 있습니다.'
                              : '이동하면 운동 경로가 표시됩니다.',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowLocationButton extends StatelessWidget {
  const _FollowLocationButton({
    required this.followMe,
    required this.onTap,
  });

  final bool followMe;
  final VoidCallback onTap;

  static const Color _surface = Color(0xFF151B22);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: followMe ? _accent : _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: followMe
                  ? Colors.white.withAlpha(46)
                  : Colors.white.withAlpha(26),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(61),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            followMe ? Icons.gps_fixed_rounded : Icons.my_location_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  }
}

class _RoundMapButton extends StatelessWidget {
  const _RoundMapButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  static const Color _surface = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: _surface.withAlpha(235),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(20),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _primaryText,
              size: 25,
            ),
          ),
        ),
      ),
    );
  }
}