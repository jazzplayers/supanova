import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_function/workout_finish/feed/like_Controller/like_provider.dart';

class LikeController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> like(String workoutFinishId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(likeServiceProvider).feedLike(
            workoutFinishId,
          );
    });
  }

    Future<void> unlike(String workoutFinishId) async {
      state = const AsyncLoading();
      state = await AsyncValue.guard(() async {
        await ref.read(likeServiceProvider).feedUnlike(
              workoutFinishId,
            );
      });
    }
  }