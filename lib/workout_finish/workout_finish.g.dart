// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_finish.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutFinish _$WorkoutFinishFromJson(Map<String, dynamic> json) =>
    _WorkoutFinish(
      workoutId: json['workoutId'] as String?,
      userId: json['userId'] as String,
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      seconds: (json['seconds'] as num).toInt(),
      speedKmh: (json['speedKmh'] as num).toDouble(),
      paceMinPerKm: (json['paceMinPerKm'] as num).toDouble(),
      workoutImagesUrl:
          (json['workoutImagesUrl'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
      routePoints: json['routePoints'] == null
          ? const <LatLng>[]
          : const LatLngListConverter().fromJson(json['routePoints'] as List),
      timestamp: const DateTimeConverter().fromJson(
        json['timestamp'] as Timestamp?,
      ),
      createdAt: const DateTimeConverter().fromJson(
        json['createdAt'] as Timestamp?,
      ),
      updatedAt: const DateTimeConverter().fromJson(
        json['updatedAt'] as Timestamp?,
      ),
    );

Map<String, dynamic> _$WorkoutFinishToJson(_WorkoutFinish instance) =>
    <String, dynamic>{
      'workoutId': instance.workoutId,
      'userId': instance.userId,
      'distanceMeters': instance.distanceMeters,
      'seconds': instance.seconds,
      'speedKmh': instance.speedKmh,
      'paceMinPerKm': instance.paceMinPerKm,
      'workoutImagesUrl': instance.workoutImagesUrl,
      'likesCount': instance.likesCount,
      'commentsCount': instance.commentsCount,
      'routePoints': const LatLngListConverter().toJson(instance.routePoints),
      'timestamp': const DateTimeConverter().toJson(instance.timestamp),
      'createdAt': const DateTimeConverter().toJson(instance.createdAt),
      'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
    };
