import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_function/follow/follow_service/follow_provider.dart';

class FollowController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> follow(String targetUid) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(followServiceProvider).followUser(targetUid);
    });
  }

  Future<void> unfollow(String targetUid) async {
    state = const AsyncLoading();
    /// guard 는 try-catch를 간편하게 사용할 수 있게 해주는 메서드입니다. --- IGNORE ---
    state = await AsyncValue.guard(() async {
      await ref.read(followServiceProvider).unfollowUser(targetUid);
    });
  }
}