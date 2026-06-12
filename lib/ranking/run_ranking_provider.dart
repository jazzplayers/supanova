import 'package:home_function/ranking/run_ranking.dart';
import 'package:home_function/ranking/run_ranking_repo.dart';
import 'package:home_function/core/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_ranking_provider.g.dart';

@riverpod
RunRankingRepo runRankingRepo(Ref ref) {
  final db = ref.watch(firestoreProvider);
  return RunRankingRepoImpl(db);
}

/// 전체 러닝 랭킹 Top 50
@riverpod
Stream<List<RunRanking>> totalRunRanking(Ref ref) {
  final repo = ref.watch(runRankingRepoProvider);

  return repo.watchTotalRunRanking();
}

/// 이번 달 러닝 랭킹 Top 50
@riverpod
Stream<List<RunRanking>> monthlyRunRanking(Ref ref) {
  final repo = ref.watch(runRankingRepoProvider);

  return repo.watchMonthlyRunRanking();
}

/// 특정 월 러닝 랭킹
///
/// 사용 예:
/// ref.watch(runRankingByMonthProvider('202605'))
@riverpod
Stream<List<RunRanking>> runRankingByMonth(
  Ref ref,
  String yearMonth,
) {
  final repo = ref.watch(runRankingRepoProvider);

  return repo.watchRunRankingByMonth(
    yearMonth: yearMonth,
  );
}

/// 내 전체 러닝 랭킹 데이터
@riverpod
Future<RunRanking?> myTotalRunRanking(
  Ref ref,
  String userId,
) {
  final repo = ref.watch(runRankingRepoProvider);

  return repo.getMyTotalRunRanking(
    userId: userId,
  );
}

/// 내 이번 달 러닝 랭킹 데이터
@riverpod
Future<RunRanking?> myMonthlyRunRanking(
  Ref ref,
  String userId,
) {
  final repo = ref.watch(runRankingRepoProvider);

  return repo.getMyMonthlyRunRanking(
    userId: userId,
  );
}

/// 내 전체 순위
@riverpod
Future<int?> myTotalRunRank(
  Ref ref,
  String userId,
) {
  final repo = ref.watch(runRankingRepoProvider);

  return repo.getMyTotalRunRank(
    userId: userId,
  );
}

/// 내 이번 달 순위
@riverpod
Future<int?> myMonthlyRunRank(
  Ref ref,
  String userId,
) {
  final repo = ref.watch(runRankingRepoProvider);

  return repo.getMyMonthlyRunRank(
    userId: userId,
  );
}