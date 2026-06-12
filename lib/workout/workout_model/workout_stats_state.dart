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

/// LatLngConverter는 LatLng 객체를 JSON으로 변환하거나 JSON에서 LatLng 객체로 변환하는 역할을 합니다.
/// 좌표 하나를 반환하는것
class LatLngConverter implements JsonConverter<LatLng, Map<String, dynamic>> {
  const LatLngConverter();

  @override
  LatLng fromJson(Map<String, dynamic> json) {
    return LatLng(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson(LatLng object) => {
        'lat': object.latitude,
        'lng': object.longitude,
      };
}

///LatLngListConverter는 LatLng 객체의 리스트를 JSON으로 변환하거나 JSON에서 LatLng 객체의 리스트로 변환하는 역할을 합니다.
/// 내부적으로 LatLngConverter를 사용하여 각 LatLng 객체를 처리합니다.
/// List<LatLng>를 List<dynamic>으로 변환하거나 그 반대로 변환하는데 사용됩니다.
/// List<LatLng> routePoints = [LatLng(37.7749, -122.4194), LatLng(34.0522, -118.2437)];
/// List<dynamic> 
/// [
///  {'lat': 37.7749, 'lng': -122.4194},
///  {'lat': 34.0522, 'lng': -118.2437}
/// ]

class LatLngListConverter
    implements JsonConverter<List<LatLng>, List<dynamic>> {
  const LatLngListConverter();

  static const _single = LatLngConverter();

  @override
  List<LatLng> fromJson(List<dynamic> json) =>
      json.map((e) => _single.fromJson(Map<String, dynamic>.from(e as Map))).toList();

  @override
  List<dynamic> toJson(List<LatLng> object) =>
      object.map((e) => _single.toJson(e)).toList();
    }