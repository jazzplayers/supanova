import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed_comment_model.freezed.dart';
part 'feed_comment_model.g.dart';

@freezed
abstract class FeedCommentModel with _$FeedCommentModel {
  const factory FeedCommentModel({
    /// 댓글 문서 ID
    @Default('') String commentId,

    /// 댓글이 작성된 운동 게시글 ID
    @Default('') String workoutFinishId,

    /// 댓글 작성자 UID
    @Default('') String userId,

    /// 댓글 작성 당시 작성자 닉네임
    @Default('사용자') String displayName,

    /// 댓글 작성 당시 작성자 프로필 이미지
    @Default('') String profileImageUrl,

    /// 댓글 내용
    @Default('') String text,

    /// 댓글 수정 여부
    @Default(false) bool isEdited,

    /// 댓글 작성 시간
    @FeedCommentDateTimeConverter() DateTime? createdAt,

    /// 댓글 수정 시간
    @FeedCommentDateTimeConverter() DateTime? updatedAt,
  }) = _FeedCommentModel;

  factory FeedCommentModel.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$FeedCommentModelFromJson(json);
}

/// Firestore Timestamp와 Dart DateTime을 서로 변환합니다.
///
/// 아직 serverTimestamp가 반영되지 않은 문서는 null일 수 있습니다.
class FeedCommentDateTimeConverter
    implements JsonConverter<DateTime?, Object?> {
  const FeedCommentDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) {
      return null;
    }

    if (json is Timestamp) {
      return json.toDate();
    }

    if (json is DateTime) {
      return json;
    }

    if (json is String) {
      return DateTime.tryParse(json);
    }

    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) {
      return null;
    }

    return Timestamp.fromDate(object);
  }
}