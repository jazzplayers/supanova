import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_provider.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  GoogleMapController? _controller;
  StreamSubscription<Position>? _positionSub;

  LatLng? _target;

  bool _isLoading = true;
  bool _followMe = true;
  bool _isMovingByCode = false;

  String? _errorMessage;

  static const double _defaultZoom = 17;

  static const Color _bg = Color(0xFF0B0F14);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _blue = Color(0xFF5DADEC);

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
          _moveCamera(latLng);
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

  Future<void> _moveCamera(LatLng target) async {
    final controller = _controller;

    if (controller == null) return;

    _isMovingByCode = true;

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
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        _isMovingByCode = false;
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    final target = _target;

    if (target == null) return;

    setState(() {
      _followMe = true;
    });

    await _moveCamera(target);
  }

  void _stopFollowing() {
    if (!_followMe) return;

    setState(() {
      _followMe = false;
    });
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              color: _blue,
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
              child: _LocationErrorCard(
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

    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
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
              if (_isMovingByCode) return;
              _stopFollowing();
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
                strokeColor: _blue,
                fillColor: _blue.withAlpha(38),
              ),
            },
          ),
          Positioned(
            top: topPadding + 14,
            left: 16,
            right: 16,
            child: _MapStatusCard(
              followMe: _followMe,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 18 + bottomPadding,
            child: _CurrentLocationButton(
              followMe: _followMe,
              onTap: _followMe ? _stopFollowing : _goToCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenAppSettings;
  final VoidCallback onOpenLocationSettings;

  const _LocationErrorCard({
    required this.message,
    required this.onRetry,
    required this.onOpenAppSettings,
    required this.onOpenLocationSettings,
  });

  static const Color _card = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _card,
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
              color: _blue.withAlpha(31),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              size: 34,
              color: _blue,
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
                backgroundColor: _blue,
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

class _MapStatusCard extends StatelessWidget {
  final bool followMe;

  const _MapStatusCard({
    required this.followMe,
  });

  static const Color _card = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: _card.withAlpha(235),
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
                color: _blue.withAlpha(36),
                shape: BoxShape.circle,
              ),
              child: Icon(
                followMe
                    ? Icons.gps_fixed_rounded
                    : Icons.gps_not_fixed_rounded,
                color: _blue,
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
                          followMe
                              ? '내 위치가 바뀌면 지도가 자동으로 이동합니다.'
                              : '오른쪽 아래 버튼을 누르면 현재 위치로 돌아갑니다.',
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

class _CurrentLocationButton extends StatelessWidget {
  final bool followMe;
  final VoidCallback onTap;

  const _CurrentLocationButton({
    required this.followMe,
    required this.onTap,
  });

  static const Color _card = Color(0xFF151B22);
  static const Color _blue = Color(0xFF5DADEC);

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
            color: followMe ? _blue : _card,
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