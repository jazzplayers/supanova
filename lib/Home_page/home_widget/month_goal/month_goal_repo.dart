import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

abstract class MonthGoalRepository {
  Future<void> setMonthlyGoal(String userId, double goalDistance);
  Stream<double> monthlyGoalStream(String userId);
  Future<double> getMonthlyGoal(String userId);
  Future<double> getTotalDistanceThisDay({required String userId});
  Future<double> getTotalDistanceThisMonth({required String userId});
}

class MonthGoalRepo implements MonthGoalRepository {
  final _db = FirebaseFirestore.instance;

  static const String _workoutCollectionName = 'workoutFinish';

  double _sumDistance(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) {
    double totalDistance = 0.0;

    for (final doc in snap.docs) {
      final data = doc.data();
      totalDistance += (data['distanceMeters'] as num?)?.toDouble() ?? 0.0;
    }

    return totalDistance;
  }

  @override
  Future<void> setMonthlyGoal(
    String userId,
    double goalDistance,
  ) async {
    final now = DateTime.now();
    final docId = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    await _db
        .collection('users')
        .doc(userId)
        .collection('monthly_goals')
        .doc(docId)
        .set(
      {
        'goal_distance': goalDistance,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Stream<double> monthlyGoalStream(String userId) {
    final now = DateTime.now();
    final docId = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    return _db
        .collection('users')
        .doc(userId)
        .collection('monthly_goals')
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 0.0;

      return (doc.data()?['goal_distance'] as num?)?.toDouble() ?? 0.0;
    });
  }

  @override
  Future<double> getMonthlyGoal(String userId) async {
    final now = DateTime.now();
    final docId = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('monthly_goals')
        .doc(docId)
        .get();

    if (!doc.exists) return 0.0;

    return (doc.data()?['goal_distance'] as num?)?.toDouble() ?? 0.0;
  }

  @override
  Future<double> getTotalDistanceThisDay({
    required String userId,
  }) async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      final snap = await _db
          .collection(_workoutCollectionName)
          .where('userId', isEqualTo: userId)
          .where(
            'timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
          )
          .where(
            'timestamp',
            isLessThan: Timestamp.fromDate(end),
          )
          .orderBy('timestamp', descending: true)
          .get();

      return _sumDistance(snap);
    } catch (e, st) {
      debugPrint('getTotalDistanceThisDay error: $e');
      debugPrint('getTotalDistanceThisDay stack: $st');
      rethrow;
    }
  }

  @override
  Future<double> getTotalDistanceThisMonth({required String userId}) async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1);

      final snap = await _db
          .collection(_workoutCollectionName)
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('timestamp', isLessThan: Timestamp.fromDate(end))
          .orderBy('timestamp', descending: true)
          .get();

      return _sumDistance(snap);
    } catch (e, st) {
      debugPrint('getTotalDistanceThisMonth error: $e');
      debugPrint('getTotalDistanceThisMonth stack: $st');
      rethrow;
    }
  }
}