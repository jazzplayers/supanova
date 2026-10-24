import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:home_function/core/firebase.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish_repo.dart';

part '../workout_finish_provider.g.dart';

/// ======================
/// 운동 완료 Repository
/// ======================
@riverpod
WorkoutFinishRepo workoutFinishRepo(Ref ref) {
  final db = ref.watch(firestoreProvider);

  return WorkoutFinishRepoImpl(db);
}

/// ======================
/// 운동 완료 업로드
/// ======================
///
/// 업로드 도중 화면이 변경되더라도 provider가 dispose되지 않도록
/// keepAlive를 사용합니다.
@Riverpod(keepAlive: true)
Future<void> uploadWorkoutFinish(
  Ref ref, {
  required WorkoutFinish workoutFinish,
  required List<String> imageUrls,
  String? thumbnailUrl,
}) async {
  final workoutFinishRepo = ref.read(
    workoutFinishRepoProvider,
  );

  await workoutFinishRepo.uploadWorkoutFinish(
    workoutFinish: workoutFinish,
    imageUrls: imageUrls,
    thumbnailUrl: thumbnailUrl,
  );

  if (!ref.mounted) {
    return;
  }

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
  final workoutFinishRepo = ref.read(
    workoutFinishRepoProvider,
  );

  await workoutFinishRepo.deleteWorkoutFinish(
    workoutFinish: workoutFinish,
  );

  if (!ref.mounted) {
    return;
  }

  ref.invalidate(todayWorkoutFinishProvider);
  ref.invalidate(workoutCountProvider(workoutFinish.userId));
  ref.invalidate(workoutFinishListProvider(workoutFinish.userId));
  ref.invalidate(feedWorkoutFinishProvider(workoutFinish.userId));
  ref.invalidate(feedListWorkoutFinishProvider(workoutFinish.userId));
  ref.invalidate(profileWorkoutGridProvider(workoutFinish.userId));

  final workoutId = workoutFinish.workoutId?.trim();

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
  final workoutFinishRepo = ref.read(
    workoutFinishRepoProvider,
  );

  await workoutFinishRepo.updateWorkoutFinishImages(
    workoutFinish: workoutFinish,
    imageUrls: imageUrls,
    thumbnailUrl: thumbnailUrl,
  );

  if (!ref.mounted) {
    return;
  }

  ref.invalidate(workoutFinishListProvider(workoutFinish.userId));
  ref.invalidate(feedWorkoutFinishProvider(workoutFinish.userId));
  ref.invalidate(feedListWorkoutFinishProvider(workoutFinish.userId));
  ref.invalidate(profileWorkoutGridProvider(workoutFinish.userId));

  final workoutId = workoutFinish.workoutId?.trim();

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
Future<WorkoutFinish?> todayWorkoutFinish(
  Ref ref,
) async {
  final auth = ref.read(firebaseAuthProvider);
  final workoutFinishRepo = ref.watch(
    workoutFinishRepoProvider,
  );

  final uid = auth.currentUser?.uid;

  if (uid == null) {
    return null;
  }

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
  final workoutFinishRepo = ref.watch(
    workoutFinishRepoProvider,
  );

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
  final id = workoutFinishId.trim();

  if (id.isEmpty) {
    return null;
  }

  final workoutFinishRepo = ref.watch(
    workoutFinishRepoProvider,
  );

  return workoutFinishRepo.workoutFinish(
    workoutFinishId: id,
  );
}

/// ======================
/// 기존 피드 운동 기록
/// ======================
@riverpod
Future<List<WorkoutFinish>> feedWorkoutFinish(
  Ref ref,
  String userId,
) async {
  final auth = ref.read(firebaseAuthProvider);
  final workoutFinishRepo = ref.watch(
    workoutFinishRepoProvider,
  );

  final viewerUid = auth.currentUser?.uid;

  return workoutFinishRepo.getFeedWorkoutFinish(
    userId: userId,
    viewerUid: viewerUid,
  );
}

/// ======================
/// 피드 리스트 화면용
/// ======================
@Riverpod(keepAlive: true)
Future<List<WorkoutFinish>> feedListWorkoutFinish(
  Ref ref,
  String userId, {
  int limit = 60,
}) async {
  final auth = ref.read(firebaseAuthProvider);
  final workoutFinishRepo = ref.watch(
    workoutFinishRepoProvider,
  );

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
  final workoutFinishRepo = ref.watch(
    workoutFinishRepoProvider,
  );

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
  final workoutFinishRepo = ref.watch(
    workoutFinishRepoProvider,
  );

  return workoutFinishRepo.getWorkoutCount(
    userId: userId,
  );
}