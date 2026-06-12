import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:home_function/core/firebase.dart';
import 'package:home_function/map/map_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';
import 'package:home_function/workout/workout_UI/workout_Page_UI_StatsCard.dart';
import 'package:home_function/workout/workout_model/workout_stats_state.dart';
import 'package:home_function/workout/workout_stat_provider/workout_stat_notifier.dart';

class WorkoutPage extends ConsumerStatefulWidget {
  const WorkoutPage({super.key});

  @override
  ConsumerState<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends ConsumerState<WorkoutPage> {
  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

  bool _isMapSheetOpen = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final repo = ref.read(mapRepositoryProvider);

      try {
        final enabled = await repo.isServiceEnabled();

        if (!enabled) {
          throw Exception('위치 서비스가 꺼져 있어요.');
        }

        await repo.ensurePermission();
      } catch (e) {
        if (!mounted) return;

        showAppSnackBar(
          context,
          message: '$e',
          icon: Icons.location_off_rounded,
          isError: true,
        );

        context.go('/home');
      }
    });
  }

  Future<void> _showWorkoutMapSheet(BuildContext context) async {
    if (!mounted) return;

    setState(() {
      _isMapSheetOpen = true;
    });

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.68),
      builder: (context) {
        final height = MediaQuery.sizeOf(context).height;
        final isSmallHeight = height < 720;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: isSmallHeight ? 0.88 : 0.82,
          minChildSize: 0.55,
          maxChildSize: 0.96,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: _line,
                    width: 0.8,
                  ),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: const _WorkoutMapSheet(),
            );
          },
        );
      },
    );

    if (!mounted) return;

    setState(() {
      _isMapSheetOpen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final live = ref.watch(workoutProvider);
    final workout = ref.read(workoutProvider.notifier);
    final auth = ref.watch(firebaseAuthProvider);
    final uid = auth.currentUser?.uid;
    final media = MediaQuery.of(context);

    return WithForegroundTask(
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 52,
          automaticallyImplyLeading: false,
          title: const Text(
            'WORKOUT',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          actions: [
            IconButton(
              tooltip: '지도 보기',
              visualDensity: VisualDensity.compact,
              onPressed: () {
                _showWorkoutMapSheet(context);
              },
              icon: const Icon(
                Icons.map_outlined,
                color: _primaryText,
                size: 24,
              ),
            ),
            const SizedBox(width: 6),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(0.7),
            child: Divider(
              color: _line,
              height: 0.7,
              thickness: 0.7,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              0,
              12,
              0,
              130 + media.padding.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusBanner(status: live.status),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _WorkoutStatsGrid(),
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _WorkoutGuide(),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _isMapSheetOpen
            ? null
            : SafeArea(
                top: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  decoration: const BoxDecoration(
                    color: _bg,
                    border: Border(
                      top: BorderSide(
                        color: _line,
                        width: 0.7,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SmallActionButton(
                              label: live.status == WorkoutStatStatus.paused
                                  ? 'RESUME'
                                  : 'PAUSE',
                              icon: live.status == WorkoutStatStatus.paused
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              backgroundColor: _surfaceSoft,
                              foregroundColor: _primaryText,
                              onTap: () {
                                if (live.status == WorkoutStatStatus.running) {
                                  workout.pause();
                                } else if (live.status ==
                                    WorkoutStatStatus.paused) {
                                  workout.resume();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SmallActionButton(
                              label: 'RESET',
                              icon: Icons.refresh_rounded,
                              backgroundColor: _surfaceSoft,
                              foregroundColor: _primaryText,
                              onTap: () {
                                if (live.status != WorkoutStatStatus.idle) {
                                  workout.idle();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _MainActionButton(
                        label: live.status == WorkoutStatStatus.idle
                            ? 'START'
                            : 'STOP',
                        icon: live.status == WorkoutStatStatus.idle
                            ? Icons.play_arrow_rounded
                            : Icons.stop_rounded,
                        backgroundColor: live.status == WorkoutStatStatus.idle
                            ? _accent
                            : _danger,
                        onTap: () async {
                          if (live.status == WorkoutStatStatus.idle) {
                            try {
                              await workout.start();

                              if (!mounted) return;
                            } catch (e) {
                              if (!mounted) return;

                              showAppSnackBar(
                                context,
                                message: '$e',
                                icon: Icons.error_rounded,
                                isError: true,
                              );
                            }

                            return;
                          }

                          if (live.status == WorkoutStatStatus.paused) {
                            final stopOk = await _showStopDialog(context);

                            try {
                              if (stopOk == true) {
                                if (!mounted) return;

                                if (uid == null) {
                                  showAppSnackBar(
                                    context,
                                    message: '로그인이 필요합니다.',
                                    icon: Icons.lock_rounded,
                                    isError: true,
                                  );
                                  return;
                                }

                                final finish = workout.buildFinish(userId: uid);

                                await workout.stop();

                                if (!mounted) return;

                                context.go('/workfinish', extra: finish);
                              }
                            } catch (e) {
                              if (!mounted) return;

                              showAppSnackBar(
                                context,
                                message: '운동 종료 실패: $e',
                                icon: Icons.error_rounded,
                                isError: true,
                              );
                            }
                          } else if (live.status ==
                              WorkoutStatStatus.running) {
                            showAppSnackBar(
                              context,
                              message: '운동을 먼저 일시정지 해주세요.',
                              icon: Icons.pause_circle_rounded,
                              isError: true,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<bool> _showStopDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (dialogContext) {
            final media = MediaQuery.of(dialogContext);

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 380,
                  maxHeight: media.size.height * 0.86,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _line,
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: _danger.withOpacity(0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.stop_circle_outlined,
                            size: 34,
                            color: _danger,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          '운동 종료',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _primaryText,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '정말 운동을 종료하시겠어요?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _secondaryText,
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 22),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final narrow = constraints.maxWidth < 300;

                            final cancelButton = SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(false);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _primaryText,
                                  side: const BorderSide(
                                    color: _line,
                                    width: 0.8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '취소',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            );

                            final stopButton = SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _danger,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '종료',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            );

                            if (narrow) {
                              return Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: stopButton,
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: cancelButton,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: cancelButton),
                                const SizedBox(width: 10),
                                Expanded(child: stopButton),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }
}

class _WorkoutStatsGrid extends StatelessWidget {
  const _WorkoutStatsGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 350;

        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: compact ? 1.36 : 1.48,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatsCard(
              title: '이동 거리 (km)',
              child: Consumer(
                builder: (context, ref, _) {
                  final distance = ref.watch(
                    workoutProvider.select((s) => s.distanceMeters),
                  );
                  final km = (distance / 1000).toStringAsFixed(2);

                  return _MetricText(value: km);
                },
              ),
            ),
            StatsCard(
              title: '시간',
              child: Consumer(
                builder: (context, ref, _) {
                  final seconds = ref.watch(
                    workoutProvider.select((s) => s.seconds),
                  );

                  return _MetricText(
                    value:
                        '${(seconds ~/ 3600).toString().padLeft(2, '0')}:${((seconds ~/ 60) % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}',
                  );
                },
              ),
            ),
            StatsCard(
              title: '속력 (km/h)',
              child: Consumer(
                builder: (context, ref, _) {
                  final speed = ref.watch(
                    workoutProvider.select((s) => s.speedKmh),
                  );

                  return _MetricText(
                    value: speed.toStringAsFixed(1),
                  );
                },
              ),
            ),
            StatsCard(
              title: '페이스 (min/km)',
              child: Consumer(
                builder: (context, ref, _) {
                  final pace = ref.watch(
                    workoutProvider.select((s) => s.paceMinPerKm),
                  );

                  if (pace <= 0 || pace.isNaN || pace.isInfinite) {
                    return const _MetricText(value: '--:--');
                  }

                  final minutes = pace.floor();
                  final seconds = ((pace - minutes) * 60).round();

                  return _MetricText(
                    value:
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WorkoutGuide extends StatelessWidget {
  const _WorkoutGuide();

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 19,
                color: _accent,
              ),
              SizedBox(width: 8),
              Text(
                '운동 가이드',
                style: TextStyle(
                  color: _primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'START를 누르면 운동이 시작됩니다.\n운동 중에는 PAUSE로 일시정지하고, 종료하려면 먼저 일시정지 후 STOP을 눌러주세요.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: _secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutMapSheet extends ConsumerStatefulWidget {
  const _WorkoutMapSheet();

  @override
  ConsumerState<_WorkoutMapSheet> createState() => _WorkoutMapSheetState();
}

class _WorkoutMapSheetState extends ConsumerState<_WorkoutMapSheet> {
  GoogleMapController? _controller;
  StreamSubscription<Position>? _positionSub;

  LatLng? _target;

  bool _isLoading = true;
  bool _followMe = true;
  bool _isMovingByCode = false;

  String? _errorMessage;

  static const double _defaultZoom = 17;

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

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
        _isLoading = false;
        _followMe = true;
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
      // 지도 컨트롤러가 dispose 되었거나 페이지 전환 중이면 무시
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

  @override
  void dispose() {
    _positionSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: _accent,
          strokeWidth: 2,
        ),
      );
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _line,
                width: 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_off_outlined,
                  size: 42,
                  color: _accent,
                ),
                const SizedBox(height: 14),
                const Text(
                  '위치를 불러올 수 없습니다',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 14,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: _initLocation,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(
                      '다시 시도',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final target = _target;

    if (target == null) {
      return const Center(
        child: Text(
          '현재 위치 정보가 없습니다.',
          style: TextStyle(
            color: _primaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          gestureRecognizers: {
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
              markerId: const MarkerId('workout_current_location'),
              position: target,
              infoWindow: const InfoWindow(
                title: '현재 운동 위치',
              ),
            ),
          },
          circles: {
            Circle(
              circleId: const CircleId('workout_current_location_circle'),
              center: target,
              radius: 80,
              strokeWidth: 2,
              strokeColor: _accent,
              fillColor: _accent.withOpacity(0.15),
            ),
          },
        ),
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A40),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        Positioned(
          top: 26,
          left: 16,
          right: 16,
          child: _WorkoutMapHeader(
            followMe: _followMe,
            onClose: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Positioned(
          right: 16,
          bottom: 22,
          child: _WorkoutMapLocationButton(
            followMe: _followMe,
            onTap: _followMe ? _stopFollowing : _goToCurrentLocation,
          ),
        ),
      ],
    );
  }
}

class _WorkoutMapHeader extends StatelessWidget {
  const _WorkoutMapHeader({
    required this.followMe,
    required this.onClose,
  });

  final bool followMe;
  final VoidCallback onClose;

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: _surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 41,
            height: 41,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              followMe ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
              color: _accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '운동 위치',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  followMe
                      ? '현재 위치를 실시간으로 따라가는 중'
                      : '지도 이동됨 · 위치 버튼으로 복귀',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onClose,
            icon: const Icon(
              Icons.close_rounded,
              color: _primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutMapLocationButton extends StatelessWidget {
  const _WorkoutMapLocationButton({
    required this.followMe,
    required this.onTap,
  });

  final bool followMe;
  final VoidCallback onTap;

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
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
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: followMe ? _accent : _surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: followMe ? Colors.white.withOpacity(0.18) : _line,
              width: 0.8,
            ),
          ),
          child: Icon(
            followMe ? Icons.gps_fixed_rounded : Icons.my_location_rounded,
            color: followMe ? Colors.white : _primaryText,
            size: 25,
          ),
        ),
      ),
    );
  }
}

class _MetricText extends StatelessWidget {
  final String value;

  const _MetricText({
    required this.value,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        value,
        maxLines: 1,
        style: const TextStyle(
          color: _primaryText,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.status,
  });

  final WorkoutStatStatus status;

  static const Color _bg = Color(0xFF000000);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final title = switch (status) {
      WorkoutStatStatus.idle => '운동을 시작할 준비가 되었어요',
      WorkoutStatStatus.running => '운동 중입니다',
      WorkoutStatStatus.paused => '운동이 일시정지 되었어요',
      _ => '상태 확인',
    };

    final subtitle = switch (status) {
      WorkoutStatStatus.idle => 'START 버튼을 눌러 러닝을 시작해보세요.',
      WorkoutStatStatus.running => '현재 기록이 실시간으로 업데이트되고 있어요.',
      WorkoutStatStatus.paused => 'RESUME으로 다시 시작하거나 STOP으로 종료할 수 있어요.',
      _ => '상태를 확인해주세요.',
    };

    final icon = switch (status) {
      WorkoutStatStatus.idle => Icons.flag_outlined,
      WorkoutStatStatus.running => Icons.directions_run_rounded,
      WorkoutStatStatus.paused => Icons.pause_circle_outline_rounded,
      _ => Icons.info_outline_rounded,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(
          bottom: BorderSide(
            color: _line,
            width: 0.7,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _accent,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: _line,
              width: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}

class _MainActionButton extends StatelessWidget {
  const _MainActionButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.35,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}