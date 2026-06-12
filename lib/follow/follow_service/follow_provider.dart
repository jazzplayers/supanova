import 'package:home_function/follow/follow_service/follow_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'follow_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part '../follow_provider.g.dart';

final followControllerProvider = AsyncNotifierProvider<FollowController, void>(() {
  return FollowController();
});

@riverpod
FollowService followService(Ref ref) {
  return FollowService();
}