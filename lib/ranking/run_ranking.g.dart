// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_ranking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RunRanking _$RunRankingFromJson(Map<String, dynamic> json) => _RunRanking(
  userId: json['userId'] as String,
  displayName: json['displayName'] as String? ?? 'Unknown',
  profileImageUrl: json['profileImageUrl'] as String?,
  distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0.0,
  workoutCount: (json['workoutCount'] as num?)?.toInt() ?? 0,
  seconds: (json['seconds'] as num?)?.toInt() ?? 0,
  updatedAt: const DateTimeConverter().fromJson(
    json['updatedAt'] as Timestamp?,
  ),
);

Map<String, dynamic> _$RunRankingToJson(_RunRanking instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'profileImageUrl': instance.profileImageUrl,
      'distanceMeters': instance.distanceMeters,
      'workoutCount': instance.workoutCount,
      'seconds': instance.seconds,
      'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
    };
