import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:home_function/core/firebase.dart';
import 'package:home_function/workout_finish/feed/widget/comment/feed_comment_model.dart';
import 'package:home_function/workout_finish/feed/widget/comment/feed_comment_repo.dart';

part 'feed_comment_provider.g.dart';

/// ======================
/// 댓글 Repository
/// ======================
@riverpod
FeedCommentRepo feedCommentRepo(Ref ref) {
  final db = ref.watch(firestoreProvider);

  final functions = FirebaseFunctions.instanceFor(
    region: 'asia-northeast3',
  );

  return FeedCommentRepoImpl(
    db: db,
    functions: functions,
  );
}

/// ======================
/// 댓글 목록 실시간 조회
/// ======================
///
/// Firestore의
/// workoutFinish/{workoutFinishId}/comments
/// 하위 컬렉션을 실시간으로 감시합니다.
@riverpod
Stream<List<FeedCommentModel>> feedComments(
  Ref ref, {
  required String workoutFinishId,
  int limit = 100,
}) {
  final id = workoutFinishId.trim();

  if (id.isEmpty) {
    return Stream<List<FeedCommentModel>>.value(
      const <FeedCommentModel>[],
    );
  }

  final repo = ref.watch(
    feedCommentRepoProvider,
  );

  return repo.watchComments(
    workoutFinishId: id,
    limit: limit,
  );
}

/// ======================
/// 댓글 작성
/// ======================
///
/// 댓글 작성 후 Cloud Function에서 반환한
/// 최신 commentsCount 값을 반환합니다.
///
/// keepAlive를 사용하지 않습니다.
/// 같은 게시글에 같은 댓글 내용을 다시 작성하더라도
/// 매번 Cloud Function이 실행되어야 하기 때문입니다.
@riverpod
Future<int> createFeedComment(
  Ref ref, {
  required String workoutFinishId,
  required String text,
}) async {
  final repo = ref.read(
    feedCommentRepoProvider,
  );

  return repo.createComment(
    workoutFinishId: workoutFinishId,
    text: text,
  );
}

/// ======================
/// 댓글 수정
/// ======================
@riverpod
Future<void> updateFeedComment(
  Ref ref, {
  required String workoutFinishId,
  required String commentId,
  required String text,
}) async {
  final repo = ref.read(
    feedCommentRepoProvider,
  );

  await repo.updateComment(
    workoutFinishId: workoutFinishId,
    commentId: commentId,
    text: text,
  );
}

/// ======================
/// 댓글 삭제
/// ======================
///
/// 댓글 삭제 후 Cloud Function에서 반환한
/// 최신 commentsCount 값을 반환합니다.
@riverpod
Future<int> deleteFeedComment(
  Ref ref, {
  required String workoutFinishId,
  required String commentId,
}) async {
  final repo = ref.read(
    feedCommentRepoProvider,
  );

  return repo.deleteComment(
    workoutFinishId: workoutFinishId,
    commentId: commentId,
  );
}