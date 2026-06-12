import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'like_provider.dart';

class LikeButton extends ConsumerWidget {
  final String myUid;
  final String workoutFinishId;

  const LikeButton({
    super.key,
    required this.myUid,
    required this.workoutFinishId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeCountAsync = ref.watch(likeCountProvider(workoutFinishId));
    final isLikedAsync = ref.watch(isLikedProvider(workoutFinishId, myUid));

    final likeController = ref.read(likeControllerProvider.notifier);

    final isLiked = isLikedAsync.value ?? false;
    final likesCount = likeCountAsync.value ?? 0;

    return Row(
      children: [
        IconButton(
          onPressed: () async {
            try {
              if (isLiked) {
                await likeController.unlike(workoutFinishId);
              } else {
                await likeController.like(workoutFinishId);
              }
            } catch (e, st) {
              debugPrint('Error toggling like: $e');
              debugPrintStack(stackTrace: st);
            }
          },
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.white70,
          ),
        ),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              builder: (_) {
                return LikedUserListSheet(
                  workoutFinishId: workoutFinishId,
                );
              },
            );
          },
          child: Text(
            '$likesCount',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class LikedUserListSheet extends ConsumerWidget {
  final String workoutFinishId;

  const LikedUserListSheet({
    super.key,
    required this.workoutFinishId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedUserIdsAsync = ref.watch(
      likedUserIdsProvider(workoutFinishId),
    );

    return SizedBox(
      height: 400,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 10, bottom: 12),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              '좋아요',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: likedUserIdsAsync.when(
              data: (userIds) {
                if (userIds.isEmpty) {
                  return const Center(
                    child: Text(
                      '좋아요 누른 사람이 없습니다.',
                      style: TextStyle(color: Colors.black87, fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: userIds.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final uid = userIds[index];
                    final userAsync = ref.watch(userAuthDataProvider(uid));

                    return userAsync.when(
                      data: (user) {
                        final displayName =
                            user?.displayName ?? '알 수 없는 사용자';
                        final profileImageUrl = user?.profileImageUrl;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: profileImageUrl != null &&
                                    profileImageUrl.isNotEmpty
                                ? NetworkImage(profileImageUrl)
                                : null,
                            child: profileImageUrl == null ||
                                    profileImageUrl.isEmpty
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                      loading: () => const ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text('불러오는 중...'),
                      ),
                      error: (e, st) => const ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.error_outline),
                        ),
                        title: Text('유저 정보를 불러오지 못했습니다.'),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, st) {
                debugPrint('likedUserIds error: $e');
                debugPrintStack(stackTrace: st);

                return Center(
                  child: Text(
                    '좋아요 목록 에러: $e',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}