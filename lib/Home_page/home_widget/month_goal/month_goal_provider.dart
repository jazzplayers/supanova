import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:home_function/Home_page/home_widget/month_goal/month_goal_repo.dart';

part 'month_goal_provider.g.dart';

@riverpod
MonthGoalRepo monthGoalRepo(Ref ref) {
  return MonthGoalRepo();
}

@riverpod
Future<double> monthlyGoal(Ref ref, String userId) async {
  if (userId.isEmpty) {
    return 0.0; // 사용자 ID가 없는 경우 기본값 반환
  }
  final repo = ref.read(monthGoalRepoProvider);
  return await repo.getMonthlyGoal(userId);
}

@riverpod
Stream<double> monthlyGoalStream(Ref ref, String userId) {
  if (userId.isEmpty) {
    return Stream.value(0.0); // 사용자 ID가 없는 경우 기본값 반환
  }
  final repo = ref.read(monthGoalRepoProvider);
  return repo.monthlyGoalStream(userId);
}

@riverpod
Future<double> totalDistanceThisDay(Ref ref, String userId) async {
  if (userId.isEmpty) {
    return 0.0; // 사용자 ID가 없는 경우 기본값 반환
  }
  final repo = ref.read(monthGoalRepoProvider);
  return repo.getTotalDistanceThisDay(userId: userId);
}

@riverpod
Future<double> totalDistanceThisMonth(Ref ref, String userId) async {
  if (userId.isEmpty) {
    return 0.0; // 사용자 ID가 없는 경우 기본값 반환
  }
  final repo = ref.read(monthGoalRepoProvider);
  return await repo.getTotalDistanceThisMonth(userId: userId);
}