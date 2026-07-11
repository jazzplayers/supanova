import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:home_function/core/firebase.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish_repo.dart';

part '../workout_finish_provider.g.dart';

@riverpod
WorkoutFinishRepo workoutFinishRepo(Ref ref) {
  final db = ref.watch(firestoreProvider);
  return WorkoutFinishRepoImpl(db);
}

/// ======================
/// 운동 완료 업로드
/// ======================
///
/// keepAlive를 켜는 이유:
/// upload 도중 화면이 바뀌거나 provider listener가 사라지면
/// autoDispose provider가 dispose될 수 있음.
/// 그 상태에서 await 이후 ref.invalidate를 호출하면
/// Cannot use the Ref of uploadWorkoutFinishProvider...
/// 에러가 날 수 있음.
@Riverpod(keepAlive: true)
Future<void> uploadWorkoutFinish(
  Ref ref, {
  required WorkoutFinish workoutFinish,
  required List<String> imageUrls,
  String? thumbnailUrl,
}) async {
  final workoutFinishRepo = ref.read(workoutFinishRepoProvider);

  await workoutFinishRepo.uploadWorkoutFinish(
    workoutFinish: workoutFinish,
    imageUrls: imageUrls,
    thumbnailUrl: thumbnailUrl,
  );

  if (!ref.mounted) return;

  ref.invalidate(todayWorkoutFinishProvider);
  ref.invalidate(workoutCountProvider(workoutFinish.userId));
  ref.invalidate(workoutFinishListProvider(workoutFinish.userId));
  ref.invalidate(feedWorkoutFinishProvider(workoutFinish.userId));
  ref.invalidate(feedListWorkoutFinishProvider(workoutFinish.userId));
  ref.invalidate(profileWorkoutGridProvider(workoutFinish.userId));
}

/// ======================
/// 운동 완료 삭제
/// ======================
@Riverpod(keepAlive: true)
Future<void> deleteWorkoutFinish(
  Ref ref, {
  required WorkoutFinish workoutFinish,
}) async {
  final workoutFinishRepo = ref.read(workoutFinishRepoProvider);

  await workoutFinishRepo.deleteWorkoutFinish(
    workoutFinish: workoutFinish,
  );

  if (!ref.mounted) return;

  ref.invalidate(todayWorkoutFinishProvider);
  ref.invalidate(workoutCountProvider(workoutFinish.userId));
  ref.invalidate(workoutFinishListProvider(workoutFinish.userId));
  ref.invalidate(feedWorkoutFinishProvider(workoutFinish.userId));
  ref.invalidate(feedListWorkoutFinishProvider(workoutFinish.userId));
  ref.invalidate(profileWorkoutGridProvider(workoutFinish.userId));

  final workoutId = workoutFinish.workoutId;
  if (workoutId != null && workoutId.isNotEmpty) {
    ref.invalidate(
      workoutFinishProvider(
        workoutFinishId: workoutId,
      ),
    );
  }
}

/// ======================
/// 운동 완료 이미지 수정
/// ======================
@Riverpod(keepAlive: true)
Future<void> updateWorkoutFinishImages(
  Ref ref, {
  required WorkoutFinish workoutFinish,
  required List<String> imageUrls,
  String? thumbnailUrl,
}) async {
  final workoutFinishRepo = ref.read(workoutFinishRepoProvider);

  await workoutFinishRepo.updateWorkoutFinishImages(
    workoutFinish: workoutFinish,
    imageUrls: imageUrls,
    thumbnailUrl: thumbnailUrl,
  );

  if (!ref.mounted) return;

  ref.invalidate(workoutFinishListProvider(workoutFinish.userId));
  ref.invalidate(feedWorkoutFinishProvider(workoutFinish.userId));
  ref.invalidate(feedListWorkoutFinishProvider(workoutFinish.userId));
  ref.invalidate(profileWorkoutGridProvider(workoutFinish.userId));

  final workoutId = workoutFinish.workoutId;
  if (workoutId != null && workoutId.isNotEmpty) {
    ref.invalidate(
      workoutFinishProvider(
        workoutFinishId: workoutId,
      ),
    );
  }
}

/// ======================
/// 오늘 운동 기록
/// ======================
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

/// ======================
/// 운동 기록 리스트
/// ======================
@riverpod
Future<List<WorkoutFinish>> workoutFinishList(
  Ref ref,
  String userId,
) async {
  final auth = ref.read(firebaseAuthProvider);
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  final viewerUid = auth.currentUser?.uid;

  return workoutFinishRepo.getWorkoutRecord(
    userId: userId,
    viewerUid: viewerUid,
  );
}

/// ======================
/// 단일 운동 기록
/// ======================
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

/// ======================
/// 기존 피드 운동 기록
/// ======================
///
/// 기존 화면에서 쓰고 있던 provider라서 유지.
/// 내부 Repo에서는 getFeedListWorkoutFinish를 재사용해도 됨.
@riverpod
Future<List<WorkoutFinish>> feedWorkoutFinish(
  Ref ref,
  String userId,
) async {
  final auth = ref.read(firebaseAuthProvider);
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  final viewerUid = auth.currentUser?.uid;

  return workoutFinishRepo.getFeedWorkoutFinish(
    userId: userId,
    viewerUid: viewerUid,
  );
}

/// ======================
/// 피드 리스트 화면용
/// ======================
///
/// 인스타그램처럼 특정 게시글을 누르면,
/// 해당 유저의 운동 기록들을 세로 리스트로 연속해서 보여주는 화면에 사용.
@Riverpod(keepAlive: true)
Future<List<WorkoutFinish>> feedListWorkoutFinish(
  Ref ref,
  String userId, {
  int limit = 60,
}) async {
  final auth = ref.read(firebaseAuthProvider);
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  final viewerUid = auth.currentUser?.uid;

  return workoutFinishRepo.getFeedListWorkoutFinish(
    userId: userId,
    viewerUid: viewerUid,
    limit: limit,
  );
}

/// ======================
/// 프로필 운동 그리드
/// ======================
@Riverpod(keepAlive: true)
Future<List<WorkoutFinish>> profileWorkoutGrid(
  Ref ref,
  String userId,
) async {
  final auth = ref.read(firebaseAuthProvider);
  final workoutFinishRepo = ref.watch(workoutFinishRepoProvider);

  final viewerUid = auth.currentUser?.uid;

  return workoutFinishRepo.getProfileWorkoutGrid(
    userId: userId,
    viewerUid: viewerUid,
    limit: 30,
  );
}

/// ======================
/// 운동 개수
/// ======================
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