// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeedCommentModel _$FeedCommentModelFromJson(
  Map<String, dynamic> json,
) => _FeedCommentModel(
  commentId: json['commentId'] as String? ?? '',
  workoutFinishId: json['workoutFinishId'] as String? ?? '',
  userId: json['userId'] as String? ?? '',
  displayName: json['displayName'] as String? ?? '사용자',
  profileImageUrl: json['profileImageUrl'] as String? ?? '',
  text: json['text'] as String? ?? '',
  isEdited: json['isEdited'] as bool? ?? false,
  createdAt: const FeedCommentDateTimeConverter().fromJson(json['createdAt']),
  updatedAt: const FeedCommentDateTimeConverter().fromJson(json['updatedAt']),
);

Map<String, dynamic> _$FeedCommentModelToJson(
  _FeedCommentModel instance,
) => <String, dynamic>{
  'commentId': instance.commentId,
  'workoutFinishId': instance.workoutFinishId,
  'userId': instance.userId,
  'displayName': instance.displayName,
  'profileImageUrl': instance.profileImageUrl,
  'text': instance.text,
  'isEdited': instance.isEdited,
  'createdAt': const FeedCommentDateTimeConverter().toJson(instance.createdAt),
  'updatedAt': const FeedCommentDateTimeConverter().toJson(instance.updatedAt),
};
