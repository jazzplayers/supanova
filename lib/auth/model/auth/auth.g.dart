// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Auth _$AuthFromJson(Map<String, dynamic> json) => _Auth(
  uid: json['uid'] as String,
  displayName: json['displayName'] as String? ?? '',
  email: json['email'] as String? ?? '',
  displayNameKey: json['displayNameKey'] as String? ?? '',
  workoutCount: (json['workoutCount'] as num?)?.toInt() ?? 0,
  followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
  followingsCount: (json['followingsCount'] as num?)?.toInt() ?? 0,
  totalDistance: (json['totalDistance'] as num?)?.toDouble() ?? 0.0,
  isPrivate: json['isPrivate'] as bool? ?? false,
  createdAt: const DateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const DateTimeConverter().fromJson(json['updatedAt']),
  bio: json['bio'] as String? ?? '',
  profileImageUrl: json['profileImageUrl'] as String? ?? '',
);

Map<String, dynamic> _$AuthToJson(_Auth instance) => <String, dynamic>{
  'uid': instance.uid,
  'displayName': instance.displayName,
  'email': instance.email,
  'displayNameKey': instance.displayNameKey,
  'workoutCount': instance.workoutCount,
  'followersCount': instance.followersCount,
  'followingsCount': instance.followingsCount,
  'totalDistance': instance.totalDistance,
  'isPrivate': instance.isPrivate,
  'createdAt': const DateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const DateTimeConverter().toJson(instance.updatedAt),
  'bio': instance.bio,
  'profileImageUrl': instance.profileImageUrl,
};
