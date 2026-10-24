// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_comment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ======================
/// 댓글 Repository
/// ======================

@ProviderFor(feedCommentRepo)
final feedCommentRepoProvider = FeedCommentRepoProvider._();

/// ======================
/// 댓글 Repository
/// ======================

final class FeedCommentRepoProvider
    extends
        $FunctionalProvider<FeedCommentRepo, FeedCommentRepo, FeedCommentRepo>
    with $Provider<FeedCommentRepo> {
  /// ======================
  /// 댓글 Repository
  /// ======================
  FeedCommentRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedCommentRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedCommentRepoHash();

  @$internal
  @override
  $ProviderElement<FeedCommentRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedCommentRepo create(Ref ref) {
    return feedCommentRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedCommentRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedCommentRepo>(value),
    );
  }
}

String _$feedCommentRepoHash() => r'c39115408f0ff4eef07179ffb0d26f30c1efd7e5';

/// ======================
/// 댓글 목록 실시간 조회
/// ======================
///
/// Firestore의
/// workoutFinish/{workoutFinishId}/comments
/// 하위 컬렉션을 실시간으로 감시합니다.

@ProviderFor(feedComments)
final feedCommentsProvider = FeedCommentsFamily._();

/// ======================
/// 댓글 목록 실시간 조회
/// ======================
///
/// Firestore의
/// workoutFinish/{workoutFinishId}/comments
/// 하위 컬렉션을 실시간으로 감시합니다.

final class FeedCommentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FeedCommentModel>>,
          List<FeedCommentModel>,
          Stream<List<FeedCommentModel>>
        >
    with
        $FutureModifier<List<FeedCommentModel>>,
        $StreamProvider<List<FeedCommentModel>> {
  /// ======================
  /// 댓글 목록 실시간 조회
  /// ======================
  ///
  /// Firestore의
  /// workoutFinish/{workoutFinishId}/comments
  /// 하위 컬렉션을 실시간으로 감시합니다.
  FeedCommentsProvider._({
    required FeedCommentsFamily super.from,
    required ({String workoutFinishId, int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'feedCommentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$feedCommentsHash();

  @override
  String toString() {
    return r'feedCommentsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<FeedCommentModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<FeedCommentModel>> create(Ref ref) {
    final argument = this.argument as ({String workoutFinishId, int limit});
    return feedComments(
      ref,
      workoutFinishId: argument.workoutFinishId,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FeedCommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$feedCommentsHash() => r'ebe13bb66a46899ee36d8b717d37eb4ab11434ff';

/// ======================
/// 댓글 목록 실시간 조회
/// ======================
///
/// Firestore의
/// workoutFinish/{workoutFinishId}/comments
/// 하위 컬렉션을 실시간으로 감시합니다.

final class FeedCommentsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<FeedCommentModel>>,
          ({String workoutFinishId, int limit})
        > {
  FeedCommentsFamily._()
    : super(
        retry: null,
        name: r'feedCommentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ======================
  /// 댓글 목록 실시간 조회
  /// ======================
  ///
  /// Firestore의
  /// workoutFinish/{workoutFinishId}/comments
  /// 하위 컬렉션을 실시간으로 감시합니다.

  FeedCommentsProvider call({
    required String workoutFinishId,
    int limit = 100,
  }) => FeedCommentsProvider._(
    argument: (workoutFinishId: workoutFinishId, limit: limit),
    from: this,
  );

  @override
  String toString() => r'feedCommentsProvider';
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

@ProviderFor(createFeedComment)
final createFeedCommentProvider = CreateFeedCommentFamily._();

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

final class CreateFeedCommentProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
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
  CreateFeedCommentProvider._({
    required CreateFeedCommentFamily super.from,
    required ({String workoutFinishId, String text}) super.argument,
  }) : super(
         retry: null,
         name: r'createFeedCommentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createFeedCommentHash();

  @override
  String toString() {
    return r'createFeedCommentProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as ({String workoutFinishId, String text});
    return createFeedComment(
      ref,
      workoutFinishId: argument.workoutFinishId,
      text: argument.text,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CreateFeedCommentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createFeedCommentHash() => r'4c3eea9817c534f8fcd5ce33dcc0451fd7a3b30d';

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

final class CreateFeedCommentFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<int>,
          ({String workoutFinishId, String text})
        > {
  CreateFeedCommentFamily._()
    : super(
        retry: null,
        name: r'createFeedCommentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  CreateFeedCommentProvider call({
    required String workoutFinishId,
    required String text,
  }) => CreateFeedCommentProvider._(
    argument: (workoutFinishId: workoutFinishId, text: text),
    from: this,
  );

  @override
  String toString() => r'createFeedCommentProvider';
}

/// ======================
/// 댓글 수정
/// ======================

@ProviderFor(updateFeedComment)
final updateFeedCommentProvider = UpdateFeedCommentFamily._();

/// ======================
/// 댓글 수정
/// ======================

final class UpdateFeedCommentProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// ======================
  /// 댓글 수정
  /// ======================
  UpdateFeedCommentProvider._({
    required UpdateFeedCommentFamily super.from,
    required ({String workoutFinishId, String commentId, String text})
    super.argument,
  }) : super(
         retry: null,
         name: r'updateFeedCommentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateFeedCommentHash();

  @override
  String toString() {
    return r'updateFeedCommentProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument =
        this.argument
            as ({String workoutFinishId, String commentId, String text});
    return updateFeedComment(
      ref,
      workoutFinishId: argument.workoutFinishId,
      commentId: argument.commentId,
      text: argument.text,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateFeedCommentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateFeedCommentHash() => r'f4f4be6277099e46054f9faf0a67c04bff6fb46f';

/// ======================
/// 댓글 수정
/// ======================

final class UpdateFeedCommentFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({String workoutFinishId, String commentId, String text})
        > {
  UpdateFeedCommentFamily._()
    : super(
        retry: null,
        name: r'updateFeedCommentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ======================
  /// 댓글 수정
  /// ======================

  UpdateFeedCommentProvider call({
    required String workoutFinishId,
    required String commentId,
    required String text,
  }) => UpdateFeedCommentProvider._(
    argument: (
      workoutFinishId: workoutFinishId,
      commentId: commentId,
      text: text,
    ),
    from: this,
  );

  @override
  String toString() => r'updateFeedCommentProvider';
}

/// ======================
/// 댓글 삭제
/// ======================
///
/// 댓글 삭제 후 Cloud Function에서 반환한
/// 최신 commentsCount 값을 반환합니다.

@ProviderFor(deleteFeedComment)
final deleteFeedCommentProvider = DeleteFeedCommentFamily._();

/// ======================
/// 댓글 삭제
/// ======================
///
/// 댓글 삭제 후 Cloud Function에서 반환한
/// 최신 commentsCount 값을 반환합니다.

final class DeleteFeedCommentProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// ======================
  /// 댓글 삭제
  /// ======================
  ///
  /// 댓글 삭제 후 Cloud Function에서 반환한
  /// 최신 commentsCount 값을 반환합니다.
  DeleteFeedCommentProvider._({
    required DeleteFeedCommentFamily super.from,
    required ({String workoutFinishId, String commentId}) super.argument,
  }) : super(
         retry: null,
         name: r'deleteFeedCommentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteFeedCommentHash();

  @override
  String toString() {
    return r'deleteFeedCommentProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument =
        this.argument as ({String workoutFinishId, String commentId});
    return deleteFeedComment(
      ref,
      workoutFinishId: argument.workoutFinishId,
      commentId: argument.commentId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteFeedCommentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteFeedCommentHash() => r'1261dd8c722f8e3384172f9722d1b90d9b4e94b1';

/// ======================
/// 댓글 삭제
/// ======================
///
/// 댓글 삭제 후 Cloud Function에서 반환한
/// 최신 commentsCount 값을 반환합니다.

final class DeleteFeedCommentFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<int>,
          ({String workoutFinishId, String commentId})
        > {
  DeleteFeedCommentFamily._()
    : super(
        retry: null,
        name: r'deleteFeedCommentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ======================
  /// 댓글 삭제
  /// ======================
  ///
  /// 댓글 삭제 후 Cloud Function에서 반환한
  /// 최신 commentsCount 값을 반환합니다.

  DeleteFeedCommentProvider call({
    required String workoutFinishId,
    required String commentId,
  }) => DeleteFeedCommentProvider._(
    argument: (workoutFinishId: workoutFinishId, commentId: commentId),
    from: this,
  );

  @override
  String toString() => r'deleteFeedCommentProvider';
}
