import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_function/workout_finish/workout_finish.dart';

abstract class WorkoutFinishRepo {
  Future<void> uploadWorkoutFinish({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
  });

  Future<void> deleteWorkoutFinish({
    required WorkoutFinish workoutFinish,
  });

  Future<void> updateWorkoutFinishImages({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
  });

  Future<WorkoutFinish?> getTodayWorkoutRecord({
    required String userId,
  });

  Future<List<WorkoutFinish>> getWorkoutRecord({
    required String userId,
  });

  Future<WorkoutFinish> workoutFinish({
    required String workoutFinishId,
  });

  Future<List<WorkoutFinish>> getFeedWorkoutFinish({
    required String userId,
  });

  Future<int> getWorkoutCount({
    required String userId,
  });
}

class WorkoutFinishRepoImpl implements WorkoutFinishRepo {
  final FirebaseFirestore _db;

  WorkoutFinishRepoImpl(this._db);

  @override
  Future<void> uploadWorkoutFinish({
    required WorkoutFinish workoutFinish,
    required List<String> imageUrls,
  }) async {
    final docRef = _db.collection('workoutFinish').doc();

    final data = workoutFinish
        .copyWith(
          workoutId: docRef.id,
          workoutImagesUrl: imageUrls,
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
      'timestamp': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'likesCount': 0,
      'commentsCount': 0,
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
  }) async {
    final workoutId = workoutFinish.workoutId;

    if (workoutId == null || workoutId.isEmpty) {
      throw ArgumentError('WorkoutFinish workoutId is invalid');
    }

    await _db.collection('workoutFinish').doc(workoutId).update({
      'workoutImagesUrl': imageUrls,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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

    return WorkoutFinish.fromJson({
      ...doc.data(),
      'workoutId': doc.id,
    });
  }

  @override
  Future<List<WorkoutFinish>> getWorkoutRecord({
    required String userId,
  }) async {
    final snap = await _db
        .collection('workoutFinish')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    return snap.docs.map((doc) {
      return WorkoutFinish.fromJson({
        ...doc.data(),
        'workoutId': doc.id,
      });
    }).toList();
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

    return WorkoutFinish.fromJson({
      ...doc.data()!,
      'workoutId': doc.id,
    });
  }

  @override
  Future<List<WorkoutFinish>> getFeedWorkoutFinish({
    required String userId,
  }) async {
    final snap = await _db
        .collection('workoutFinish')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snap.docs.map((doc) {
      return WorkoutFinish.fromJson({
        ...doc.data(),
        'workoutId': doc.id,
      });
    }).toList();
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