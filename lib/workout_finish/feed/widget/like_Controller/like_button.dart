import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'like_provider.dart';

class LikeButton extends ConsumerStatefulWidget {
  final String myUid;
  final String workoutFinishId;

  const LikeButton({
    super.key,
    required this.myUid,
    required this.workoutFinishId,
  });

  @override
  ConsumerState<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends ConsumerState<LikeButton> {
  bool? _optimisticIsLiked;
  int? _optimisticLikesCount;
  bool _isSubmitting = false;

  void _syncFromServer({
    required bool? serverIsLiked,
    required int? serverLikesCount,
  }) {
    if (_isSubmitting) return;

    if (serverIsLiked != null && _optimisticIsLiked != serverIsLiked) {
      _optimisticIsLiked = serverIsLiked;
    }

    if (serverLikesCount != null && _optimisticLikesCount != serverLikesCount) {
      _optimisticLikesCount = serverLikesCount;
    }
  }

  Future<void> _toggleLike({
    required bool currentIsLiked,
    required int currentLikesCount,
  }) async {
    if (_isSubmitting) return;

    final previousIsLiked = currentIsLiked;
    final previousLikesCount = currentLikesCount;

    final nextIsLiked = !currentIsLiked;
    final nextLikesCount = nextIsLiked
        ? currentLikesCount + 1
        : (currentLikesCount - 1).clamp(0, 1 << 31);

    setState(() {
      _isSubmitting = true;
      _optimisticIsLiked = nextIsLiked;
      _optimisticLikesCount = nextLikesCount;
    });

    try {
      final likeController = ref.read(likeControllerProvider.notifier);

      if (nextIsLiked) {
        await likeController.like(widget.workoutFinishId);
      } else {
        await likeController.unlike(widget.workoutFinishId);
      }

      ref.invalidate(isLikedProvider(widget.workoutFinishId, widget.myUid));
      ref.invalidate(likeCountProvider(widget.workoutFinishId));
      ref.invalidate(likedUserIdsProvider(widget.workoutFinishId));

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
    } catch (e, st) {
      debugPrint('Error toggling like: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _optimisticIsLiked = previousIsLiked;
        _optimisticLikesCount = previousLikesCount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('좋아요 처리 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final likeCountAsync = ref.watch(
      likeCountProvider(widget.workoutFinishId),
    );

    final isLikedAsync = ref.watch(
      isLikedProvider(widget.workoutFinishId, widget.myUid),
    );

    final serverIsLiked = isLikedAsync.value;
    final serverLikesCount = likeCountAsync.value;

    _syncFromServer(
      serverIsLiked: serverIsLiked,
      serverLikesCount: serverLikesCount,
    );

    final isLiked = _optimisticIsLiked ?? serverIsLiked ?? false;
    final likesCount = _optimisticLikesCount ?? serverLikesCount ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedScale(
          scale: isLiked ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              _toggleLike(
                currentIsLiked: isLiked,
                currentLikesCount: likesCount,
              );
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: child,
                );
              },
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isLiked),
                color: isLiked ? Colors.red : Colors.white70,
              ),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
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
                  workoutFinishId: widget.workoutFinishId,
                );
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 120),
              child: Text(
                '$likesCount',
                key: ValueKey(likesCount),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
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
                            backgroundImage:
                                profileImageUrl != null &&
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