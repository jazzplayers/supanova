// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_stats_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutStatsState _$WorkoutStatsStateFromJson(Map<String, dynamic> json) =>
    _WorkoutStatsState(
      status:
          $enumDecodeNullable(_$WorkoutStatStatusEnumMap, json['status']) ??
          WorkoutStatStatus.idle,
      speedKmh: (json['speedKmh'] as num?)?.toDouble() ?? 0.0,
      paceMinPerKm: (json['paceMinPerKm'] as num?)?.toDouble() ?? 0.0,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      seconds: (json['seconds'] as num?)?.toInt() ?? 0,
      routePoints: json['routePoints'] == null
          ? const <LatLng>[]
          : const LatLngListConverter().fromJson(json['routePoints'] as List),
    );

Map<String, dynamic> _$WorkoutStatsStateToJson(_WorkoutStatsState instance) =>
    <String, dynamic>{
      'status': _$WorkoutStatStatusEnumMap[instance.status]!,
      'speedKmh': instance.speedKmh,
      'paceMinPerKm': instance.paceMinPerKm,
      'distanceMeters': instance.distanceMeters,
      'seconds': instance.seconds,
      'routePoints': const LatLngListConverter().toJson(instance.routePoints),
    };

const _$WorkoutStatStatusEnumMap = {
  WorkoutStatStatus.idle: 'idle',
  WorkoutStatStatus.running: 'running',
  WorkoutStatStatus.paused: 'paused',
  WorkoutStatStatus.stopped: 'stopped',
};
