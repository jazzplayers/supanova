import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_function/map/map_provider.dart';
import 'package:home_function/workout/workout_stat_provider/workout_stat_notifier.dart';

class WorkoutMapPage extends ConsumerStatefulWidget {
  const WorkoutMapPage({super.key});

  @override
  ConsumerState<WorkoutMapPage> createState() => _State();
}

class _State extends ConsumerState<WorkoutMapPage> {
  GoogleMapController? _controller;
  StreamSubscription<Position>? _sub;

  LatLng? _target;

  bool _followMe = true;
  // ✅ animateCamera 중 onCameraMoveStarted로 follow가 꺼지는 것 방지
  bool _isProgrammaticMove = false;

  // ✅ 너무 자주 animateCamera 호출되면 버벅임 → 스로틀
  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final repo = ref.read(mapRepositoryProvider);

    final pos = await repo.getCurrentLocation();
    if (!mounted) return;

    setState(() {
      _target = LatLng(pos.latitude, pos.longitude);
    });

    _sub = repo.streamPosition().listen((p) {
      final latLng = LatLng(p.latitude, p.longitude);

      if (!mounted) return;

      setState(() {
        _target = latLng;
      });

      if (_followMe) {
        _moveCameraThrottled(latLng);
      }
    });
  }

  Future<void> _moveCameraThrottled(LatLng target) async {
    final now = DateTime.now();
    if (now.difference(_lastCameraMove).inMilliseconds < 500) return;
    _lastCameraMove = now;

    await _moveCamera(target);
  }

  Future<void> _moveCamera(LatLng target) async {
    final c = _controller;
    if (c == null) return;

    _isProgrammaticMove = true;
    try {
      await c.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: target,
            zoom: 17,
          ),
        ),
      );
    } finally {
      _isProgrammaticMove = false;
    }
  }


  @override
  void dispose() {
    _sub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = ref.read(workoutProvider);
    final points = live.routePoints;

      final target = _target;
      if (target == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blue, fontWeight: FontWeight.bold,size: 36,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // title: const Text(
        //   'WORKOUT MAP',
        //   style: TextStyle(
        //     color: Colors.blue,
        //     fontSize: 24,
        //     fontWeight: FontWeight.bold,
        //   ),
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias, // ✅ 라운드 클립
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: target,
                  zoom: 17,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                onMapCreated: (c) async {
                  _controller = c;
                  if (_followMe) {
                    await _moveCamera(target);
                      }
                    },
                  
                    // ✅ 사용자가 지도를 움직이기 시작할 때 follow 해제
                    onCameraMoveStarted: () {
                      // ✅ 내가 animateCamera로 움직인 건 무시
                      if (_isProgrammaticMove) return;
                  
                      // ✅ 사용자가 손으로 움직이면 follow 해제
                      if (_followMe) {
                        setState(() => _followMe = false);
                      }
                    },
                  
                    // ✅ 현재 위치 마커
                    markers: {
                      Marker(
                        markerId: const MarkerId('current_location'),
                        position: target,
                      ),
                    },
                  
                    // ✅ 현재 위치 반경 원
                    circles: {
                      Circle(
                        circleId: const CircleId('current_location_circle'),
                        center: target,
                        radius: 100,
                        strokeWidth: 2,
                        strokeColor: Colors.blue,
                        fillColor: Colors.blue.withOpacity(0.15),
                      ),
                    },
                  
                    // ✅ 경로 폴리라인 (실제 경로 포인트로 교체 필요)
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('path'),
                        points: points, // ✅ 실제 경로 포인트로 교체
                        color: Colors.blueAccent,
                        width: 4,
                      ),
                    },
                  ),

              // ✅ follow 토글 버튼 (기본 myLocation 버튼 대신)
              Positioned(
                right: 16,
                bottom: 24,
                child: FloatingActionButton(
                  onPressed: () async {
                    setState(() => _followMe = !_followMe);
                    if (_followMe && _target != null) {
                      await _moveCamera(_target!);
                    }
                  },
                  child: Icon(
                    _followMe ? Icons.gps_fixed : Icons.gps_not_fixed,
                  ),
                ),
              ),

              // ✅ (선택) 상단 상태 뱃지
              // Positioned(
              //   left: 12,
              //   top: 12,
              //   child: Container(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              //     decoration: BoxDecoration(
              //       color: const Color.fromRGBO(0, 0, 0, 0.667),
              //       borderRadius: BorderRadius.circular(999),
              //       border: Border.all(color: Colors.white12),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(
              //           Icons.circle,
              //           size: 10,
              //           color:
              //               _followMe ? Colors.greenAccent : Colors.orangeAccent,
              //         ),
              //         const SizedBox(width: 8),
              //         Text(
              //           _followMe ? 'Follow ON' : 'Follow OFF',
              //           style:
              //               const TextStyle(color: Colors.white, fontSize: 12),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}