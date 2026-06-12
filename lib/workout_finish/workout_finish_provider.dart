import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:home_function/core/firebase.dart';
import 'package:home_function/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish_repo.dart';

part 'workout_finish_provider.g.dart';

@riverpod
WorkoutFinishRepo workoutFinishRepo(Ref ref) {
  final db = ref.watch(firestoreProvider);
  return WorkoutFinishRepoImpl(db);
}

@riverpod
Future<void> uploadWorkoutFinish(
  Ref ref, {
  required WorkoutFinish workoutFinish,
  required List<String> imageUrls,
}) async {
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  await workoutFinishRepo.uploadWorkoutFinish(
    workoutFinish: workoutFinish,
    imageUrls: imageUrls,
  );
}

@riverpod
Future<void> deleteWorkoutFinish(
  Ref ref, {
  required WorkoutFinish workoutFinish,
}) async {
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  await workoutFinishRepo.deleteWorkoutFinish(
    workoutFinish: workoutFinish,
  );
}

@riverpod
Future<void> updateWorkoutFinishImages(
  Ref ref, {
  required WorkoutFinish workoutFinish,
  required List<String> imageUrls,
}) async {
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  await workoutFinishRepo.updateWorkoutFinishImages(
    workoutFinish: workoutFinish,
    imageUrls: imageUrls,
  );
}

@riverpod
Future<WorkoutFinish?> todayWorkoutFinish(Ref ref) async {
  final auth = ref.read(firebaseAuthProvider);
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  final uid = auth.currentUser?.uid;
  if (uid == null) return null;

  return workoutFinishRepo.getTodayWorkoutRecord(
    userId: uid,
  );
}

@riverpod
Future<List<WorkoutFinish>> workoutFinishList(
  Ref ref,
  String userId,
) async {
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  return workoutFinishRepo.getWorkoutRecord(
    userId: userId,
  );
}

@riverpod
Future<WorkoutFinish?> workoutFinish(
  Ref ref, {
  required String workoutFinishId,
}) async {
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  return workoutFinishRepo.workoutFinish(
    workoutFinishId: workoutFinishId,
  );
}

@riverpod
Future<List<WorkoutFinish>> feedWorkoutFinish(
  Ref ref,
  String userId,
) async {
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  return workoutFinishRepo.getFeedWorkoutFinish(
    userId: userId,
  );
}

@riverpod
Future<int> workoutCount(
  Ref ref,
  String userId,
) async {
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  return workoutFinishRepo.getWorkoutCount(
    userId: userId,
  );
}