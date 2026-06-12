import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home_function/ranking/run_ranking.dart';

abstract class RunRankingRepo {
  /// 전체 러닝 랭킹 Top 50
  Stream<List<RunRanking>> watchTotalRunRanking({int limit = 50});

  /// 이번 달 러닝 랭킹 Top 50
  Stream<List<RunRanking>> watchMonthlyRunRanking({int limit = 50});
  /// 특정 월 러닝 랭킹
  /// yearMonth 예시: 202605
  Stream<List<RunRanking>> watchRunRankingByMonth({required String yearMonth, int limit = 50 });
  /// 내 전체 러닝 랭킹 데이터
  Future<RunRanking?> getMyTotalRunRanking({required String userId});
  /// 내 이번 달 러닝 랭킹 데이터
  Future<RunRanking?> getMyMonthlyRunRanking({required String userId});
  /// 내 전체 순위
  Future<int?> getMyTotalRunRank({required String userId});
  /// 내 이번 달 순위
  Future<int?> getMyMonthlyRunRank({required String userId});
}

class RunRankingRepoImpl implements RunRankingRepo {
  final FirebaseFirestore _db;

  RunRankingRepoImpl(this._db);

  @override
  Stream<List<RunRanking>> watchTotalRunRanking({
    int limit = 50,
  }) {
    return _db
        .collection('rankings')
        .doc('total_running')
        .collection('users')
        .orderBy('distanceMeters', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        return RunRanking.fromDoc(doc);
      }).toList();
    });
  }

  @override
  Stream<List<RunRanking>> watchMonthlyRunRanking({
    int limit = 50,
  }) {
    final yearMonth = _getCurrentYearMonth();

    return _db
        .collection('rankings')
        .doc('monthly_${yearMonth}_running')
        .collection('users')
        .orderBy('distanceMeters', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        return RunRanking.fromDoc(doc);
      }).toList();
    });
  }

  @override
  Stream<List<RunRanking>> watchRunRankingByMonth({
    required String yearMonth,
    int limit = 50,
  }) {
    return _db
        .collection('rankings')
        .doc('monthly_${yearMonth}_running')
        .collection('users')
        .orderBy('distanceMeters', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        return RunRanking.fromDoc(doc);
      }).toList();
    });
  }

  @override
  Future<RunRanking?> getMyTotalRunRanking({
    required String userId,
  }) async {
    final doc = await _db
        .collection('rankings')
        .doc('total_running')
        .collection('users')
        .doc(userId)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    return RunRanking.fromDoc(doc);
  }

  @override
  Future<RunRanking?> getMyMonthlyRunRanking({
    required String userId,
  }) async {
    final yearMonth = _getCurrentYearMonth();

    final doc = await _db
        .collection('rankings')
        .doc('monthly_${yearMonth}_running')
        .collection('users')
        .doc(userId)
        .get();

    if (!doc.exists || doc.data() == null) return null;

    return RunRanking.fromDoc(doc);
  }

  @override
  Future<int?> getMyTotalRunRank({
    required String userId,
  }) async {
    final myRanking = await getMyTotalRunRanking(userId: userId);

    if (myRanking == null) return null;

    final countSnap = await _db
        .collection('rankings')
        .doc('total_running')
        .collection('users')
        .where(
          'distanceMeters',
          isGreaterThan: myRanking.distanceMeters,
        )
        .count()
        .get();

    final higherUserCount = countSnap.count ?? 0;

    return higherUserCount + 1;
  }

  @override
  Future<int?> getMyMonthlyRunRank({
    required String userId,
  }) async {
    final myRanking = await getMyMonthlyRunRanking(userId: userId);

    if (myRanking == null) return null;

    final yearMonth = _getCurrentYearMonth();

    final countSnap = await _db
        .collection('rankings')
        .doc('monthly_${yearMonth}_running')
        .collection('users')
        .where(
          'distanceMeters',
          isGreaterThan: myRanking.distanceMeters,
        )
        .count()
        .get();

    final higherUserCount = countSnap.count ?? 0;

    return higherUserCount + 1;
  }

  String _getCurrentYearMonth() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');

    return '${now.year}$month';
  }
}