import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_function/core/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'like_controller.dart';
import 'like_service.dart';
import 'like_repo.dart';
  
part 'like_provider.g.dart';

final likeControllerProvider = AsyncNotifierProvider<LikeController, void>(() {
  return LikeController();
});

@riverpod
LikeService likeService(Ref ref) {
  return LikeService();
}

@riverpod
LikeRepository likeRepository(Ref ref) {
  final db = ref.watch(firestoreProvider);
  return LikeRepositoryImpl(db);
}

@riverpod
Stream<int> likeCount(Ref ref, String workoutFinishId) {
  final repo = ref.watch(likeRepositoryProvider);
  return repo.watchLikeCount(workoutFinishId);
}

@riverpod
Future<List<String>> likedUserIds(Ref ref, String workoutFinishId) {
  final repo = ref.watch(likeRepositoryProvider);
  return repo.getLikedUserIds(workoutFinishId);
}

@riverpod
Stream<bool> isLiked(
  Ref ref,
  String workoutFinishId,
  String myUid,
) {
  final repo = ref.watch(likeRepositoryProvider);

  return repo.watchIsLiked(
    workoutFinishId: workoutFinishId,
    myUid: myUid,
  );
}