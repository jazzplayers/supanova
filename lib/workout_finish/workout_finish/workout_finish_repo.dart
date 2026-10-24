import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:home_function/workout_finish/workout_finish/workout_finish.dart';

abstract class WorkoutFinishRepo {
  Future<void> uploadWorkoutFinish({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
    String? thumbnailUrl,
  });

  Future<void> deleteWorkoutFinish({
    required WorkoutFinish workoutFinish,
  });

  Future<void> updateWorkoutFinishImages({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
    String? thumbnailUrl,
  });

  Future<WorkoutFinish?> getTodayWorkoutRecord({
    required String userId,
  });

  Future<List<WorkoutFinish>> getWorkoutRecord({
    required String userId,
    String? viewerUid,
  });

  Future<WorkoutFinish> workoutFinish({
    required String workoutFinishId,
  });

  /// 좋아요 수, 댓글 수 등 게시글 변경을 실시간으로 감지한다.
  Stream<WorkoutFinish?> watchWorkoutFinish({
    required String workoutFinishId,
  });

  /// 특정 게시글의 전체 댓글 수를 실시간으로 감지한다.
  ///
  /// 댓글 목록 조회 개수와 관계없이 부모 workoutFinish 문서의
  /// commentsCount 값을 기준으로 반환한다.
  Stream<int> watchCommentsCount({
    required String workoutFinishId,
  });

  Future<List<WorkoutFinish>> getFeedWorkoutFinish({
    required String userId,
    String? viewerUid,
  });

  /// ======================
  /// 피드 리스트 화면용
  /// ======================
  ///
  /// 특정 운동 기록을 눌렀을 때 해당 사용자의 운동 기록을
  /// 세로 리스트로 연속해서 보여주기 위한 메서드입니다.
  Future<List<WorkoutFinish>> getFeedListWorkoutFinish({
    required String userId,
    String? viewerUid,
    int limit = 60,
  });

  Future<List<WorkoutFinish>> getProfileWorkoutGrid({
    required String userId,
    String? viewerUid,
    int limit = 60,
  });

  Future<int> getWorkoutCount({
    required String userId,
  });
}

class WorkoutFinishRepoImpl implements WorkoutFinishRepo {
  final FirebaseFirestore _db;

  WorkoutFinishRepoImpl(this._db);

  static const String _hiddenPendingReview = 'hidden_pending_review';

  CollectionReference<Map<String, dynamic>> get _workoutFinishCollection {
    return _db.collection('workoutFinish');
  }

  bool _isHiddenByModeration(Map<String, dynamic> data) {
    return data['moderationStatus'] == _hiddenPendingReview;
  }

  /// 기존 문서에 likesCount 또는 commentsCount가 없거나
  /// null로 저장돼 있어도 안전하게 0으로 변환한다.
  int _parseCount(dynamic value) {
    if (value is num) {
      return value
          .toInt()
          .clamp(0, 1 << 31)
          .toInt();
    }

    return 0;
  }

  WorkoutFinish _workoutFinishFromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    if (data == null) {
      throw StateError('WorkoutFinish document data is null');
    }

    return WorkoutFinish.fromJson({
      ...data,
      'workoutId': doc.id,
      'likesCount': _parseCount(data['likesCount']),
      'commentsCount': _parseCount(data['commentsCount']),
    });
  }

  List<String> _cleanImageUrls(List<String> imageUrls) {
    return imageUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
  }

  String? _cleanThumbnailUrl(String? thumbnailUrl) {
    final value = thumbnailUrl?.trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    return value;
  }

  Future<Set<String>> _getHiddenContentIds({
    required String viewerUid,
  }) async {
    final snap = await _db
        .collection('users')
        .doc(viewerUid)
        .collection('hiddenContent')
        .get();

    return snap.docs.map((doc) => doc.id).toSet();
  }

  bool _isHiddenByViewer({
    required WorkoutFinish workoutFinish,
    required Set<String> hiddenContentIds,
  }) {
    final workoutId = workoutFinish.workoutId;

    if (workoutId != null &&
        workoutId.isNotEmpty &&
        hiddenContentIds.contains('workoutFinish_$workoutId')) {
      return true;
    }

    if (hiddenContentIds.contains('user_${workoutFinish.userId}')) {
      return true;
    }

    return false;
  }

  Future<List<WorkoutFinish>> _filterVisibleWorkouts({
    required List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    required String? viewerUid,
    required String ownerUid,
    int? limit,
  }) async {
    final isOwnerViewingOwnFeed =
        viewerUid != null && viewerUid == ownerUid;

    final hiddenContentIds = viewerUid == null || isOwnerViewingOwnFeed
        ? <String>{}
        : await _getHiddenContentIds(
            viewerUid: viewerUid,
          );

    final workouts = <WorkoutFinish>[];

    for (final doc in docs) {
      final data = doc.data();

      if (_isHiddenByModeration(data)) {
        continue;
      }

      final workoutFinish = _workoutFinishFromDocument(doc);

      if (!isOwnerViewingOwnFeed &&
          _isHiddenByViewer(
            workoutFinish: workoutFinish,
            hiddenContentIds: hiddenContentIds,
          )) {
        continue;
      }

      workouts.add(workoutFinish);

      if (limit != null && workouts.length >= limit) {
        break;
      }
    }

    return workouts;
  }

  @override
  Future<void> uploadWorkoutFinish({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
    String? thumbnailUrl,
  }) async {
    final docRef = _workoutFinishCollection.doc();

    final cleanImageUrls = _cleanImageUrls(imageUrls);
    final cleanThumbnailUrl = _cleanThumbnailUrl(thumbnailUrl);

    final data = workoutFinish
        .copyWith(
          workoutId: docRef.id,
          workoutImagesUrl: cleanImageUrls,
          workoutThumbnailUrl: cleanThumbnailUrl,
          likesCount: 0,
          commentsCount: 0,
        )
        .toJson();

    data.remove('timestamp');
    data.remove('createdAt');
    data.remove('updatedAt');

    await docRef.set({
      ...data,
      'workoutId': docRef.id,
      'userId': workoutFinish.userId,
      'workoutImagesUrl': cleanImageUrls,
      'workoutThumbnailUrl': cleanThumbnailUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),

      /// 좋아요와 댓글은 새 게시글 생성 시 0부터 시작한다.
      'likesCount': 0,
      'commentsCount': 0,

      'reportsCount': 0,
      'moderationStatus': 'normal',
    });
  }

  @override
  Future<void> deleteWorkoutFinish({
    required WorkoutFinish workoutFinish,
  }) async {
    final workoutId = workoutFinish.workoutId?.trim();

    if (workoutId == null || workoutId.isEmpty) {
      throw ArgumentError('WorkoutFinish workoutId is invalid');
    }

    await _workoutFinishCollection.doc(workoutId).delete();
  }

  @override
  Future<void> updateWorkoutFinishImages({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
    String? thumbnailUrl,
  }) async {
    final workoutId = workoutFinish.workoutId?.trim();

    if (workoutId == null || workoutId.isEmpty) {
      throw ArgumentError('WorkoutFinish workoutId is invalid');
    }

    final cleanImageUrls = _cleanImageUrls(imageUrls);
    final cleanThumbnailUrl = _cleanThumbnailUrl(thumbnailUrl);

    final updateData = <String, dynamic>{
      'workoutImagesUrl': cleanImageUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (cleanThumbnailUrl != null) {
      updateData['workoutThumbnailUrl'] = cleanThumbnailUrl;
    } else if (cleanImageUrls.isEmpty) {
      updateData['workoutThumbnailUrl'] = FieldValue.delete();
    }

    await _workoutFinishCollection.doc(workoutId).update(updateData);
  }

  @override
  Future<WorkoutFinish?> getTodayWorkoutRecord({
    required String userId,
  }) async {
    final now = DateTime.now();

    final start = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final end = start.add(
      const Duration(days: 1),
    );

    final snap = await _workoutFinishCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where(
          'timestamp',
          isLessThan: Timestamp.fromDate(end),
        )
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      return null;
    }

    final doc = snap.docs.first;
    final data = doc.data();

    if (_isHiddenByModeration(data)) {
      return null;
    }

    return _workoutFinishFromDocument(doc);
  }

  @override
  Future<List<WorkoutFinish>> getWorkoutRecord({
    required String userId,
    String? viewerUid,
  }) async {
    final snap = await _workoutFinishCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(30)
        .get();

    return _filterVisibleWorkouts(
      docs: snap.docs,
      viewerUid: viewerUid,
      ownerUid: userId,
      limit: 10,
    );
  }

  @override
  Future<WorkoutFinish> workoutFinish({
    required String workoutFinishId,
  }) async {
    final id = workoutFinishId.trim();

    if (id.isEmpty) {
      throw ArgumentError('workoutFinishId is empty');
    }

    final doc = await _workoutFinishCollection.doc(id).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('WorkoutFinish not found');
    }

    final data = doc.data()!;

    if (_isHiddenByModeration(data)) {
      throw Exception('WorkoutFinish hidden by moderation');
    }

    return _workoutFinishFromDocument(doc);
  }

  @override
  Stream<WorkoutFinish?> watchWorkoutFinish({
    required String workoutFinishId,
  }) {
    final id = workoutFinishId.trim();

    if (id.isEmpty) {
      return Stream<WorkoutFinish?>.value(null);
    }

    return _workoutFinishCollection.doc(id).snapshots().map((doc) {
      final data = doc.data();

      if (!doc.exists || data == null) {
        return null;
      }

      if (_isHiddenByModeration(data)) {
        return null;
      }

      return _workoutFinishFromDocument(doc);
    });
  }

  @override
  Stream<int> watchCommentsCount({
    required String workoutFinishId,
  }) {
    final id = workoutFinishId.trim();

    if (id.isEmpty) {
      return Stream<int>.value(0);
    }

    return _workoutFinishCollection
        .doc(id)
        .snapshots()
        .map((doc) {
      final data = doc.data();

      if (!doc.exists || data == null) {
        return 0;
      }

      if (_isHiddenByModeration(data)) {
        return 0;
      }

      return _parseCount(data['commentsCount']);
    }).distinct();
  }

  @override
  Future<List<WorkoutFinish>> getFeedWorkoutFinish({
    required String userId,
    String? viewerUid,
  }) {
    return getFeedListWorkoutFinish(
      userId: userId,
      viewerUid: viewerUid,
      limit: 60,
    );
  }

  @override
  Future<List<WorkoutFinish>> getFeedListWorkoutFinish({
    required String userId,
    String? viewerUid,
    int limit = 60,
  }) async {
    final safeLimit = limit <= 0 ? 60 : limit;

    final snap = await _workoutFinishCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(safeLimit)
        .get();

    return _filterVisibleWorkouts(
      docs: snap.docs,
      viewerUid: viewerUid,
      ownerUid: userId,
      limit: safeLimit,
    );
  }

  @override
  Future<List<WorkoutFinish>> getProfileWorkoutGrid({
    required String userId,
    String? viewerUid,
    int limit = 60,
  }) async {
    final safeLimit = limit <= 0 ? 60 : limit;

    final snap = await _workoutFinishCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .orderBy(
          'timestamp',
          descending: true,
        )
        .limit(safeLimit)
        .get();

    return _filterVisibleWorkouts(
      docs: snap.docs,
      viewerUid: viewerUid,
      ownerUid: userId,
      limit: safeLimit,
    );
  }

  @override
  Future<int> getWorkoutCount({
    required String userId,
  }) async {
    final snap = await _workoutFinishCollection
        .where(
          'userId',
          isEqualTo: userId,
        )
        .count()
        .get();

    return snap.count ?? 0;
  }
}