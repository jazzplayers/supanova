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

  Future<List<WorkoutFinish>> getFeedWorkoutFinish({
    required String userId,
    String? viewerUid,
  });

  /// ======================
  /// 피드 리스트 화면용
  /// ======================
  ///
  /// 인스타그램처럼 특정 운동 기록을 눌렀을 때,
  /// 해당 유저의 운동 기록들을 세로 리스트로 연속해서 보여주기 위한 메서드입니다.
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

  bool _isHiddenByModeration(Map<String, dynamic> data) {
    return data['moderationStatus'] == _hiddenPendingReview;
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
    final isOwnerViewingOwnFeed = viewerUid != null && viewerUid == ownerUid;

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

      final workoutFinish = WorkoutFinish.fromJson({
        ...data,
        'workoutId': doc.id,
      });

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
    final docRef = _db.collection('workoutFinish').doc();

    final data = workoutFinish
        .copyWith(
          workoutId: docRef.id,
          workoutImagesUrl: imageUrls,
          workoutThumbnailUrl: thumbnailUrl,
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
      'workoutImagesUrl': imageUrls,
      'workoutThumbnailUrl': thumbnailUrl,
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
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
    final workoutId = workoutFinish.workoutId;

    if (workoutId == null || workoutId.isEmpty) {
      throw ArgumentError('WorkoutFinish workoutId is invalid');
    }

    await _db.collection('workoutFinish').doc(workoutId).delete();
  }

  @override
  Future<void> updateWorkoutFinishImages({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
    String? thumbnailUrl,
  }) async {
    final workoutId = workoutFinish.workoutId;

    if (workoutId == null || workoutId.isEmpty) {
      throw ArgumentError('WorkoutFinish workoutId is invalid');
    }

    final updateData = <String, dynamic>{
      'workoutImagesUrl': imageUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (thumbnailUrl != null) {
      updateData['workoutThumbnailUrl'] = thumbnailUrl;
    }

    await _db.collection('workoutFinish').doc(workoutId).update(updateData);
  }

  @override
  Future<WorkoutFinish?> getTodayWorkoutRecord({
    required String userId,
  }) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final snap = await _db
        .collection('workoutFinish')
        .where('userId', isEqualTo: userId)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('timestamp', isLessThan: Timestamp.fromDate(end))
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final doc = snap.docs.first;
    final data = doc.data();

    if (_isHiddenByModeration(data)) {
      return null;
    }

    return WorkoutFinish.fromJson({
      ...data,
      'workoutId': doc.id,
    });
  }

  @override
  Future<List<WorkoutFinish>> getWorkoutRecord({
    required String userId,
    String? viewerUid,
  }) async {
    final snap = await _db
        .collection('workoutFinish')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
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
    final doc =
        await _db.collection('workoutFinish').doc(workoutFinishId).get();

    if (!doc.exists || doc.data() == null) {
      throw Exception('WorkoutFinish not found');
    }

    final data = doc.data()!;

    if (_isHiddenByModeration(data)) {
      throw Exception('WorkoutFinish hidden by moderation');
    }

    return WorkoutFinish.fromJson({
      ...data,
      'workoutId': doc.id,
    });
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

    final snap = await _db
        .collection('workoutFinish')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
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

    final snap = await _db
        .collection('workoutFinish')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
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
    final snap = await _db
        .collection('workoutFinish')
        .where('userId', isEqualTo: userId)
        .count()
        .get();

    return snap.count ?? 0;
  }
}