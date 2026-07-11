import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:home_function/workout/workout_model/workout_stats_state.dart';
import 'package:home_function/workout/workout_stat_provider/workout_stat_notifier.dart';

class WorkoutTrackingMap extends ConsumerStatefulWidget {
  const WorkoutTrackingMap({super.key});

  @override
  ConsumerState<WorkoutTrackingMap> createState() => _WorkoutTrackingMapState();
}

class _WorkoutTrackingMapState extends ConsumerState<WorkoutTrackingMap> {
  final Completer<GoogleMapController> _controller = Completer();

  bool _followMe = true;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(35.8714, 128.6014), // 대구 기본 위치
    zoom: 16,
  );

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutProvider);

    ref.listen<WorkoutStatsState>(
      workoutProvider,
      (previous, next) async {
        if (!_followMe) return;

        final points = next.routePoints;
        if (points.isEmpty) return;

        final previousLength = previous?.routePoints.length ?? 0;
        if (points.length == previousLength) return;

        final controller = await _controller.future;
        final lastPoint = points.last;

        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: lastPoint,
              zoom: 17,
            ),
          ),
        );
      },
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: _initialPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
          onMapCreated: (controller) {
            if (!_controller.isCompleted) {
              _controller.complete(controller);
            }
          },
          onCameraMoveStarted: () {
            // 사용자가 지도를 직접 움직이면 자동 따라가기 잠깐 끔
            _followMe = false;
          },
          polylines: _buildPolylines(workout.routePoints),
          markers: _buildMarkers(workout.routePoints),
        ),

        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            mini: true,
            onPressed: () async {
              final points = workout.routePoints;
              if (points.isEmpty) return;

              setState(() {
                _followMe = true;
              });

              final controller = await _controller.future;

              await controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: points.last,
                    zoom: 17,
                  ),
                ),
              );
            },
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  Set<Polyline> _buildPolylines(List<LatLng> points) {
    if (points.length < 2) {
      return {};
    }

    return {
      Polyline(
        polylineId: const PolylineId('workout_route'),
        points: points,
        width: 6,
        color: Colors.orangeAccent,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  Set<Marker> _buildMarkers(List<LatLng> points) {
    if (points.isEmpty) {
      return {};
    }

    final markers = <Marker>{};

    markers.add(
      Marker(
        markerId: const MarkerId('start'),
        position: points.first,
        infoWindow: const InfoWindow(title: '시작'),
      ),
    );

    if (points.length >= 2) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: points.last,
          infoWindow: const InfoWindow(title: '현재 위치'),
        ),
      );
    }

    return markers;
  }
}