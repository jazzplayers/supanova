
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import 'package:home_function/workout_finish/feed/widget/comment/feed_comment_model.dart';

abstract class FeedCommentRepo {
  /// 최신 댓글을 최대 [limit]개 조회합니다.
  /// 화면에는 작성 시간 오름차순으로 전달합니다.
  ///
  /// 작성자의 최신 닉네임과 프로필 사진을
  /// users/{uid}에서 실시간으로 반영합니다.
  Stream<List<FeedCommentModel>> watchComments({
    required String workoutFinishId,
    int limit = 100,
  });

  /// 댓글 작성
  Future<int> createComment({
    required String workoutFinishId,
    required String text,
  });

  /// 댓글 수정
  Future<void> updateComment({
    required String workoutFinishId,
    required String commentId,
    required String text,
  });

  /// 댓글 삭제
  Future<int> deleteComment({
    required String workoutFinishId,
    required String commentId,
  });
}

class FeedCommentRepoImpl implements FeedCommentRepo {
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  FeedCommentRepoImpl({
    required FirebaseFirestore db,
    required FirebaseFunctions functions,
  })  : _db = db,
        _functions = functions;

  static const int _defaultCommentLimit = 100;
  static const int _maxCommentLimit = 200;
  static const int _maxCommentLength = 300;

  // ============================================================
  // Firestore 참조
  // ============================================================

  CollectionReference<Map<String, dynamic>> _commentsRef(
    String workoutFinishId,
  ) {
    return _db
        .collection('workoutFinish')
        .doc(workoutFinishId)
        .collection('comments');
  }

  DocumentReference<Map<String, dynamic>> _userRef(
    String uid,
  ) {
    return _db.collection('users').doc(uid);
  }

  // ============================================================
  // 입력 검증
  // ============================================================

  String _validateRequiredId({
    required String value,
    required String fieldName,
  }) {
    final result = value.trim();

    if (result.isEmpty) {
      throw FeedCommentException(
        '$fieldName 값이 비어 있습니다.',
        code: 'invalid-argument',
      );
    }

    return result;
  }

  String _validateCommentText(String text) {
    final result = text.trim();

    if (result.isEmpty) {
      throw const FeedCommentException(
        '댓글 내용을 입력해주세요.',
        code: 'invalid-argument',
      );
    }

    if (result.length > _maxCommentLength) {
      throw const FeedCommentException(
        '댓글은 300자 이하로 입력해주세요.',
        code: 'invalid-argument',
      );
    }

    return result;
  }

  int _safeLimit(int limit) {
    if (limit <= 0) {
      return _defaultCommentLimit;
    }

    return limit.clamp(1, _maxCommentLimit).toInt();
  }

  // ============================================================
  // 댓글 실시간 조회 + 작성자 정보 실시간 동기화
  // ============================================================

  @override
  Stream<List<FeedCommentModel>> watchComments({
    required String workoutFinishId,
    int limit = _defaultCommentLimit,
  }) {
    final id = _validateRequiredId(
      value: workoutFinishId,
      fieldName: 'workoutFinishId',
    );

    final safeLimit = _safeLimit(limit);

    // 각 구독마다 독립된 상태를 유지합니다.
    late final StreamController<List<FeedCommentModel>> controller;

    StreamSubscription<
        QuerySnapshot<Map<String, dynamic>>>? commentSubscription;

    // UID별 프로필 실시간 구독
    final Map<
      String,
      StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>
    > userSubscriptions = {};

    // UID별 최신 사용자 정보
    final Map<String, Map<String, dynamic>> users = {};

    // 프로필 데이터를 한 번 이상 수신했는지 확인
    final Set<String> resolvedUsers = {};

    // 현재 댓글 데이터
    final Map<String, Map<String, dynamic>> comments = {};

    // 댓글 출력 순서
    final List<String> commentIds = [];

    bool commentsLoaded = false;
    bool disposed = false;

    // ----------------------------------------------------------
    // 현재 댓글과 최신 사용자 정보를 결합
    // ----------------------------------------------------------

    void emitComments() {
      if (disposed ||
          controller.isClosed ||
          !commentsLoaded) {
        return;
      }

      try {
        // 아직 사용자 정보가 도착하지 않았다면
        // 기존 댓글 데이터를 임시로 표시합니다.
        final result = <FeedCommentModel>[];

        for (final commentId in commentIds) {
          final original = comments[commentId];

          if (original == null) {
            continue;
          }

          final merged = Map<String, dynamic>.from(original);

          final uid = (original['userId'] ?? '')
              .toString()
              .trim();

          final latestUser = users[uid];

          if (latestUser != null) {
            // Firestore Rules에서 확인된 실제 필드명
            final latestName = latestUser['displayName'];

            if (latestName is String &&
                latestName.trim().isNotEmpty) {
              merged['displayName'] = latestName.trim();
            }

            // 변경된 프로필 이미지 반영
            final latestImage =
                latestUser['profileImageUrl'];

            if (latestImage is String) {
              merged['profileImageUrl'] = latestImage;
            }
          }

          result.add(
            FeedCommentModel.fromJson(merged),
          );
        }

        if (!disposed && !controller.isClosed) {
          controller.add(
            List<FeedCommentModel>.unmodifiable(result),
          );
        }
      } catch (error, stackTrace) {
        if (!disposed && !controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    // ----------------------------------------------------------
    // 특정 댓글 작성자의 프로필 실시간 구독
    // ----------------------------------------------------------

    void subscribeUser(String uid) {
      if (uid.isEmpty ||
          disposed ||
          userSubscriptions.containsKey(uid)) {
        return;
      }

      final subscription = _userRef(uid)
          .snapshots()
          .listen(
        (snapshot) {
          if (disposed) {
            return;
          }

          resolvedUsers.add(uid);

          final data = snapshot.data();

          if (data != null) {
            users[uid] = data;
          } else {
            // 탈퇴 또는 삭제된 사용자
            users.remove(uid);
          }

          // 닉네임 / 프로필 변경 시
          // 해당 사용자의 기존 댓글까지 다시 표시
          emitComments();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (disposed) {
            return;
          }

          // 사용자 문서 조회에 실패해도
          // 댓글 자체는 유지합니다.
          resolvedUsers.add(uid);
          users.remove(uid);

          emitComments();
        },
      );

      userSubscriptions[uid] = subscription;
    }

    // ----------------------------------------------------------
    // 현재 댓글 목록에 맞춰 사용자 구독 관리
    // ----------------------------------------------------------

    void synchronizeUsers(Set<String> activeUids) {
      // 현재 댓글에 없는 작성자 구독 해제
      final removed = userSubscriptions.keys
          .where((uid) => !activeUids.contains(uid))
          .toList();

      for (final uid in removed) {
        final subscription = userSubscriptions.remove(uid);

        if (subscription != null) {
          unawaited(subscription.cancel());
        }

        users.remove(uid);
        resolvedUsers.remove(uid);
      }

      // 새롭게 등장한 댓글 작성자 구독
      for (final uid in activeUids) {
        subscribeUser(uid);
      }
    }

    // ----------------------------------------------------------
    // 댓글 Firestore 구독 시작
    // ----------------------------------------------------------

    void startListening() {
      commentSubscription = _commentsRef(id)
          .orderBy(
            'createdAt',
            descending: true,
          )
          .limit(safeLimit)
          .snapshots()
          .listen(
        (snapshot) {
          if (disposed) {
            return;
          }

          comments.clear();
          commentIds.clear();

          final activeUids = <String>{};

          // 최신 N개 댓글을 가져와
          // 오래된 댓글부터 화면에 표시합니다.
          for (final doc in snapshot.docs.reversed) {
            final data = <String, dynamic>{
              ...doc.data(),
              'commentId': doc.id,
              'workoutFinishId': id,
            };

            comments[doc.id] = data;
            commentIds.add(doc.id);

            final uid = (data['userId'] ?? '')
                .toString()
                .trim();

            if (uid.isNotEmpty) {
              activeUids.add(uid);
            }
          }

          commentsLoaded = true;

          // 중복 UID 구독 방지
          synchronizeUsers(activeUids);

          // 댓글 작성 / 수정 / 삭제 반영
          emitComments();
        },
        onError: (Object error, StackTrace stackTrace) {
          if (!disposed && !controller.isClosed) {
            controller.addError(error, stackTrace);
          }
        },
      );
    }

    // ----------------------------------------------------------
    // 화면 종료 시 모든 구독 정리
    // ----------------------------------------------------------

    Future<void> stopListening() async {
      if (disposed) {
        return;
      }

      disposed = true;

      await commentSubscription?.cancel();

      final subscriptions =
          userSubscriptions.values.toList();

      userSubscriptions.clear();
      users.clear();
      resolvedUsers.clear();
      comments.clear();
      commentIds.clear();

      await Future.wait(
        subscriptions.map(
          (subscription) => subscription.cancel(),
        ),
      );
    }

    controller = StreamController<List<FeedCommentModel>>(
      onListen: startListening,
      onCancel: stopListening,
    );

    return controller.stream;
  }

  // ============================================================
  // 댓글 작성 (기존 Cloud Functions 유지)
  // ============================================================

  @override
  Future<int> createComment({
    required String workoutFinishId,
    required String text,
  }) async {
    final id = _validateRequiredId(
      value: workoutFinishId,
      fieldName: 'workoutFinishId',
    );

    final commentText = _validateCommentText(text);

    try {
      final callable = _functions.httpsCallable(
        'feedCommentCreate',
      );

      final result =
          await callable.call<Map<String, dynamic>>({
        'workoutFinishId': id,
        'text': commentText,
      });

      return _readCommentsCount(result.data);
    } on FirebaseFunctionsException catch (error) {
      throw FeedCommentException(
        _functionsErrorMessage(error),
        code: error.code,
        originalError: error,
      );
    } catch (error) {
      if (error is FeedCommentException) {
        rethrow;
      }

      throw FeedCommentException(
        '댓글 작성 중 오류가 발생했습니다.',
        originalError: error,
      );
    }
  }

  // ============================================================
  // 댓글 수정 (기존 Cloud Functions 유지)
  // ============================================================

  @override
  Future<void> updateComment({
    required String workoutFinishId,
    required String commentId,
    required String text,
  }) async {
    final workoutId = _validateRequiredId(
      value: workoutFinishId,
      fieldName: 'workoutFinishId',
    );

    final targetCommentId = _validateRequiredId(
      value: commentId,
      fieldName: 'commentId',
    );

    final commentText = _validateCommentText(text);

    try {
      final callable = _functions.httpsCallable(
        'feedCommentUpdate',
      );

      await callable.call<Map<String, dynamic>>({
        'workoutFinishId': workoutId,
        'commentId': targetCommentId,
        'text': commentText,
      });
    } on FirebaseFunctionsException catch (error) {
      throw FeedCommentException(
        _functionsErrorMessage(error),
        code: error.code,
        originalError: error,
      );
    } catch (error) {
      if (error is FeedCommentException) {
        rethrow;
      }

      throw FeedCommentException(
        '댓글 수정 중 오류가 발생했습니다.',
        originalError: error,
      );
    }
  }

  // ============================================================
  // 댓글 삭제 (기존 Cloud Functions 유지)
  // ============================================================

  @override
  Future<int> deleteComment({
    required String workoutFinishId,
    required String commentId,
  }) async {
    final workoutId = _validateRequiredId(
      value: workoutFinishId,
      fieldName: 'workoutFinishId',
    );

    final targetCommentId = _validateRequiredId(
      value: commentId,
      fieldName: 'commentId',
    );

    try {
      final callable = _functions.httpsCallable(
        'feedCommentDelete',
      );

      final result =
          await callable.call<Map<String, dynamic>>({
        'workoutFinishId': workoutId,
        'commentId': targetCommentId,
      });

      return _readCommentsCount(result.data);
    } on FirebaseFunctionsException catch (error) {
      throw FeedCommentException(
        _functionsErrorMessage(error),
        code: error.code,
        originalError: error,
      );
    } catch (error) {
      if (error is FeedCommentException) {
        rethrow;
      }

      throw FeedCommentException(
        '댓글 삭제 중 오류가 발생했습니다.',
        originalError: error,
      );
    }
  }

  // ============================================================
  // 댓글 개수 응답 처리
  // ============================================================

  int _readCommentsCount(dynamic data) {
    if (data is! Map) {
      return 0;
    }

    final value = data['commentsCount'];

    if (value is! num) {
      return 0;
    }

    return value.toInt().clamp(0, 1 << 31).toInt();
  }

  // ============================================================
  // Firebase Functions 에러 처리
  // ============================================================

  String _functionsErrorMessage(
    FirebaseFunctionsException error,
  ) {
    final serverMessage = error.message?.trim();

    if (serverMessage != null &&
        serverMessage.isNotEmpty) {
      return serverMessage;
    }

    switch (error.code) {
      case 'unauthenticated':
        return '로그인이 필요합니다.';

      case 'invalid-argument':
        return '댓글 정보를 다시 확인해주세요.';

      case 'not-found':
        return '게시글 또는 댓글을 찾을 수 없습니다.';

      case 'permission-denied':
        return '이 댓글을 수정하거나 삭제할 권한이 없습니다.';

      case 'failed-precondition':
        return '현재 댓글 기능을 사용할 수 없습니다.';

      case 'resource-exhausted':
        return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';

      case 'deadline-exceeded':
      case 'unavailable':
        return '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.';

      case 'internal':
        return '서버 내부 오류가 발생했습니다.';

      default:
        return '댓글 처리 중 오류가 발생했습니다.';
    }
  }
}

// ============================================================
// 댓글 예외
// ============================================================

class FeedCommentException implements Exception {
  final String message;
  final String? code;
  final Object? originalError;

  const FeedCommentException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}
