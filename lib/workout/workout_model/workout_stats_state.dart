import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'workout_stats_state.freezed.dart';
part 'workout_stats_state.g.dart';

enum WorkoutStatStatus {
  idle,
  running,
  paused,
  stopped,
}

@freezed
abstract class WorkoutStatsState with _$WorkoutStatsState {
  const factory WorkoutStatsState({
    @Default(WorkoutStatStatus.idle) WorkoutStatStatus status,
    @Default(0.0) double speedKmh,
    @Default(0.0) double paceMinPerKm,
    @Default(0.0) double distanceMeters,
    @Default(0) int seconds,
    @LatLngListConverter() @Default(<LatLng>[]) List<LatLng> routePoints,
  }) = _WorkoutStatsState;

  factory WorkoutStatsState.fromJson(Map<String, dynamic> json) =>
      _$WorkoutStatsStateFromJson(json);
}

class LatLngConverter implements JsonConverter<LatLng, Map<String, dynamic>> {
  const LatLngConverter();

  @override
  LatLng fromJson(Map<String, dynamic> json) {
    final lat = _toDouble(json['lat']);
    final lng = _toDouble(json['lng']);

    return LatLng(lat, lng);
  }

  @override
  Map<String, dynamic> toJson(LatLng object) {
    return {
      'lat': object.latitude,
      'lng': object.longitude,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }
}

class LatLngListConverter
    implements JsonConverter<List<LatLng>, List<dynamic>> {
  const LatLngListConverter();

  static const LatLngConverter _single = LatLngConverter();

  @override
  List<LatLng> fromJson(List<dynamic> json) {
    final points = <LatLng>[];

    for (final item in json) {
      if (item is! Map) continue;

      final map = Map<String, dynamic>.from(item);

      final hasLat = map.containsKey('lat');
      final hasLng = map.containsKey('lng');

      if (!hasLat || !hasLng) continue;

      final point = _single.fromJson(map);

      if (point.latitude.isNaN ||
          point.latitude.isInfinite ||
          point.longitude.isNaN ||
          point.longitude.isInfinite) {
        continue;
      }

      points.add(point);
    }

    return points;
  }

  @override
  List<dynamic> toJson(List<LatLng> object) {
    return object
        .where(
          (point) =>
              !point.latitude.isNaN &&
              !point.latitude.isInfinite &&
              !point.longitude.isNaN &&
              !point.longitude.isInfinite,
        )
        .map(_single.toJson)
        .toList();
  }
}