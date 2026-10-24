
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  bool _waitingForServer = false;

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.workoutFinishId != widget.workoutFinishId ||
        oldWidget.myUid != widget.myUid) {
      _optimisticIsLiked = null;
      _optimisticLikesCount = null;
      _isSubmitting = false;
      _waitingForServer = false;
    }
  }

  void _syncFromServer({
    required bool? serverIsLiked,
    required int? serverLikesCount,
  }) {
    if (_isSubmitting) return;

    if (_waitingForServer) {
      if (serverIsLiked == _optimisticIsLiked &&
          serverLikesCount == _optimisticLikesCount) {
        _waitingForServer = false;
      } else {
        return;
      }
    }

    if (serverIsLiked != null) {
      _optimisticIsLiked = serverIsLiked;
    }

    if (serverLikesCount != null) {
      _optimisticLikesCount = serverLikesCount;
    }
  }

  Future<void> _toggleLike({
    required bool currentIsLiked,
    required int currentLikesCount,
  }) async {
    if (_isSubmitting || _waitingForServer) return;

    final previousIsLiked = currentIsLiked;
    final previousLikesCount = currentLikesCount;

    final nextIsLiked = !currentIsLiked;
    final nextLikesCount = nextIsLiked
        ? currentLikesCount + 1
        : (currentLikesCount - 1).clamp(0, 1 << 31);

    final targetWorkoutFinishId = widget.workoutFinishId;
    final targetMyUid = widget.myUid;

    setState(() {
      _isSubmitting = true;
      _optimisticIsLiked = nextIsLiked;
      _optimisticLikesCount = nextLikesCount;
    });

    try {
      final likeController = ref.read(
        likeControllerProvider.notifier,
      );

      if (nextIsLiked) {
        await likeController.like(targetWorkoutFinishId);
      } else {
        await likeController.unlike(targetWorkoutFinishId);
      }

      if (!mounted) return;

      ref.invalidate(
        isLikedProvider(targetWorkoutFinishId, targetMyUid),
      );
      ref.invalidate(
        likeCountProvider(targetWorkoutFinishId),
      );
      ref.invalidate(
        likedUserIdsProvider(targetWorkoutFinishId),
      );

      if (widget.workoutFinishId != targetWorkoutFinishId ||
          widget.myUid != targetMyUid) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _waitingForServer = true;
      });
    } catch (e, st) {
      debugPrint('Error toggling like: $e');
      debugPrintStack(stackTrace: st);

      if (!mounted) return;

      if (widget.workoutFinishId != targetWorkoutFinishId ||
          widget.myUid != targetMyUid) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _waitingForServer = false;
        _optimisticIsLiked = previousIsLiked;
        _optimisticLikesCount = previousLikesCount;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('좋아요 처리 중 오류가 발생했습니다.'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showLikedUsers() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (context) {
        return LikedUserListSheet(
          workoutFinishId: widget.workoutFinishId,
        );
      },
    );
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

    final isLiked =
        _optimisticIsLiked ?? serverIsLiked ?? false;

    final likesCount =
        _optimisticLikesCount ?? serverLikesCount ?? 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 좋아요 버튼
        AnimatedScale(
          scale: isLiked ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: (_isSubmitting || _waitingForServer)
                ? null
                : () {
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
                isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey(isLiked),
                color: isLiked
                    ? const Color(0xFFFF3B5C)
                    : Colors.white70,
                size: 25,
              ),
            ),
          ),
        ),

        // 좋아요 수 클릭 시 목록 표시
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showLikedUsers,
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

// ============================================================
// 좋아요 사용자 목록 바텀시트
// ============================================================

class LikedUserListSheet extends ConsumerWidget {
  final String workoutFinishId;

  const LikedUserListSheet({
    super.key,
    required this.workoutFinishId,
  });

  static const Color _backgroundColor = Color(0xFF171717);
  static const Color _secondaryTextColor = Color(0xFF9E9E9E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedUserIdsAsync = ref.watch(
      likedUserIdsProvider(workoutFinishId),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.30,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 드래그 핸들
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(
                    top: 12,
                    bottom: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),

              // 상단 제목
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 12,
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    const Text(
                      '좋아요',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(width: 8),

                    likedUserIdsAsync.maybeWhen(
                      data: (userIds) {
                        return Text(
                          '${userIds.length}',
                          style: const TextStyle(
                            color: _secondaryTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                      orElse: () => const SizedBox.shrink(),
                    ),

                    const Spacer(),

                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 22,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              const Divider(
                height: 1,
                thickness: 0.5,
                color: Color(0xFF333333),
              ),

              // 사용자 목록
              Expanded(
                child: likedUserIdsAsync.when(
                  data: (userIds) {
                    if (userIds.isEmpty) {
                      return ListView(
                        controller: scrollController,
                        children: const [
                          SizedBox(height: 90),

                          Icon(
                            Icons.favorite_border_rounded,
                            color: Colors.white30,
                            size: 52,
                          ),

                          SizedBox(height: 16),

                          Center(
                            child: Text(
                              '아직 좋아요가 없습니다',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          SizedBox(height: 8),

                          Center(
                            child: Text(
                              '첫 번째 좋아요를 기다리고 있어요.',
                              style: TextStyle(
                                color: _secondaryTextColor,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      itemCount: userIds.length,
                      itemBuilder: (context, index) {
                        final uid = userIds[index];

                        return _LikedUserTile(
                          key: ValueKey(uid),
                          uid: uid,
                        );
                      },
                    );
                  },

                  loading: () {
                    return ListView(
                      controller: scrollController,
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ],
                    );
                  },

                  error: (error, stackTrace) {
                    debugPrint(
                      'likedUserIds error: $error',
                    );
                    debugPrintStack(
                      stackTrace: stackTrace,
                    );

                    return ListView(
                      controller: scrollController,
                      children: const [
                        SizedBox(height: 100),

                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.white54,
                          size: 42,
                        ),

                        SizedBox(height: 16),

                        Center(
                          child: Text(
                            '좋아요 목록을 불러오지 못했습니다.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// 좋아요 사용자 리스트 아이템
// ============================================================

class _LikedUserTile extends ConsumerWidget {
  final String uid;

  const _LikedUserTile({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(
      userAuthDataProvider(uid),
    );

    return userAsync.when(
      data: (user) {
        final displayName = user?.displayName ?? '알 수 없는 사용자';
        final profileImageUrl = user?.profileImageUrl;

        final hasProfileImage =
            profileImageUrl != null &&
            profileImageUrl.isNotEmpty;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: user == null
                ? null
                : () {
                    // 시트가 닫힌 뒤에도 사용할 라우터를 미리 보관합니다.
                    final router = GoRouter.of(context);
                    Navigator.of(context).pop();
                    router.push('/user/${Uri.encodeComponent(uid)}');
                  },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: const Color(0xFF303030),
                    backgroundImage: hasProfileImage
                        ? NetworkImage(profileImageUrl)
                        : null,
                    child: !hasProfileImage
                        ? const Icon(
                            Icons.person_rounded,
                            color: Colors.white54,
                            size: 25,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white38,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },

      loading: () {
        return const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 7,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: Color(0xFF303030),
                child: Icon(
                  Icons.person_rounded,
                  color: Colors.white24,
                ),
              ),

              SizedBox(width: 14),

              Text(
                '불러오는 중...',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },

      error: (error, stackTrace) {
        debugPrint(
          'userAuthDataProvider error ($uid): $error',
        );

        return const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: Color(0xFF303030),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white38,
                ),
              ),

              SizedBox(width: 14),

              Text(
                '사용자 정보를 불러오지 못했습니다.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
