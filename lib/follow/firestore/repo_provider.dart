import 'package:home_function/follow/firestore/repo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:home_function/core/firebase.dart';
import 'package:rxdart/rxdart.dart';

part 'repo_provider.g.dart';

@riverpod
FollowRepository followRepository(Ref ref) {
  final db = ref.watch(firestoreProvider);
  return FollowRepositoryImpl(db);
}

@riverpod
Stream<bool> isFollowing(Ref ref, String myUid, String targetUid) {
  final repo = ref.watch(followRepositoryProvider);
  return repo.watchIsFollowing(myUid, targetUid);
}

@riverpod
Stream<int> followersCount(Ref ref, String userId) {
  final repo = ref.watch(followRepositoryProvider);
  return repo.watchFollowersCount(userId);
}

@riverpod
Stream<int> followingsCount(Ref ref, String userId) {
  final repo = ref.watch(followRepositoryProvider);
  return repo.watchFollowingsCount(userId);
}

@riverpod
Future<List<String>> followersList(Ref ref, String userId) {
  final repo = ref.watch(followRepositoryProvider);
  return repo.getFollowersList(userId);
}

@riverpod
Future<List<String>> followingsList(Ref ref, String userId) {
  final repo = ref.watch(followRepositoryProvider);
  return repo.getFollowingsList(userId);
}

/// enum 이름은 UpperCamelCase,
/// enum 값은 네가 쓰던 스타일에 맞춰 그대로 유지.
enum FollowState {
  notFollowing,
  Following,
  FollowedBy,
  MutualFollow,
}

@riverpod
Stream<FollowState> followStatus(
  Ref ref,
  String myUid,
  String targetUid,
) {
  final repo = ref.watch(followRepositoryProvider);

  final followingStream = repo.watchIsFollowing(myUid, targetUid);
  final followedByStream = repo.watchIsFollowing(targetUid, myUid);

  return Rx.combineLatest2<bool, bool, FollowState>(
    followingStream,
    followedByStream,
    (isFollowing, isFollowedBy) {
      if (isFollowing && isFollowedBy) {
        return FollowState.MutualFollow;
      } else if (isFollowing && !isFollowedBy) {
        return FollowState.Following;
      } else if (!isFollowing && isFollowedBy) {
        return FollowState.FollowedBy;
      } else {
        return FollowState.notFollowing;
      }
    },
  );
}