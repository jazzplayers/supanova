import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';
import 'package:home_function/workout_finish/feed/feed_edit_page.dart';
import 'package:home_function/workout_finish/feed/like_Controller/like_button.dart';
import 'package:home_function/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish_provider.dart';

class FeedPage extends ConsumerStatefulWidget {
  final WorkoutFinish workoutFinish;

  const FeedPage({
    super.key,
    required this.workoutFinish,
  });

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  static const Color _bg = Color(0xFF000000);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _line = Color(0xFF242428);
  static const Color _accent = Color(0xFF5DADEC);

  late WorkoutFinish _workoutFinish;

  @override
  void initState() {
    super.initState();
    _workoutFinish = widget.workoutFinish;
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(
      userAuthDataProvider(_workoutFinish.userId),
    );

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 52,
        title: const Text(
          '운동 피드',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(0.7),
          child: Divider(
            color: _line,
            height: 0.7,
            thickness: 0.7,
          ),
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text(
                '사용자 정보를 찾을 수 없습니다.',
                style: TextStyle(
                  color: _secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              bottom: 28 + MediaQuery.paddingOf(context).bottom,
            ),
            child: FeedCard(
              postOwnerUid: _workoutFinish.userId,
              displayName: user.displayName,
              email: user.email,
              userProfileUrl: user.profileImageUrl,
              workoutFinish: _workoutFinish,
              onUpdated: (updatedWorkoutFinish) {
                setState(() {
                  _workoutFinish = updatedWorkoutFinish;
                });
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: _accent,
            strokeWidth: 2,
          ),
        ),
        error: (e, st) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '유저 정보 로드 실패: $e',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FeedCard extends ConsumerWidget {
  final String postOwnerUid;
  final String displayName;
  final String email;
  final String? userProfileUrl;
  final WorkoutFinish workoutFinish;
  final ValueChanged<WorkoutFinish> onUpdated;

  const FeedCard({
    super.key,
    required this.postOwnerUid,
    required this.displayName,
    required this.email,
    this.userProfileUrl,
    required this.workoutFinish,
    required this.onUpdated,
  });

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  // static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

  Future<void> _goToEditPage({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final updated = await Navigator.of(context).push<WorkoutFinish>(
      MaterialPageRoute(
        builder: (_) => FeedEditPage(
          workoutFinish: workoutFinish,
        ),
      ),
    );

    if (updated == null) return;
    if (!context.mounted) return;

    onUpdated(updated);

    final workoutId = updated.workoutId;

    ref.invalidate(todayWorkoutFinishProvider);
    ref.invalidate(workoutFinishListProvider(updated.userId));
    ref.invalidate(feedWorkoutFinishProvider(updated.userId));

    if (workoutId != null && workoutId.isNotEmpty) {
      ref.invalidate(
        workoutFinishProvider(
          workoutFinishId: workoutId,
        ),
      );
    }
  }

  Future<void> _showDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final media = MediaQuery.of(dialogContext);
        final maxWidth = math.min(media.size.width - 32, 380.0);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: media.size.height * 0.86,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _line,
                    width: 0.8,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: _danger.withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 32,
                        color: _danger,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '게시글 삭제',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '삭제한 게시글은 되돌릴 수 없습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 300;

                        final cancelButton = SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryText,
                              side: const BorderSide(
                                color: _line,
                                width: 0.8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );

                        final deleteButton = SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _danger,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              '삭제',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        );

                        if (narrow) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: deleteButton,
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: cancelButton,
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: cancelButton),
                            const SizedBox(width: 10),
                            Expanded(child: deleteButton),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result != true) return;

    await _deletePost(
      context: context,
      ref: ref,
    );
  }

  Future<void> _deletePost({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final workoutId = workoutFinish.workoutId;

      if (workoutId == null || workoutId.isEmpty) {
        throw Exception('운동 기록 ID가 없습니다.');
      }

      await ref.read(
        deleteWorkoutFinishProvider(
          workoutFinish: workoutFinish,
        ).future,
      );

      if (!context.mounted) return;

      ref.invalidate(todayWorkoutFinishProvider);
      ref.invalidate(workoutFinishListProvider(workoutFinish.userId));
      ref.invalidate(feedWorkoutFinishProvider(workoutFinish.userId));
      ref.invalidate(
        workoutFinishProvider(
          workoutFinishId: workoutId,
        ),
      );

      showAppSnackBar(
        context,
        message: '게시글이 삭제되었습니다.',
        icon: Icons.check_circle_rounded,
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) return;

      showAppSnackBar(
        context,
        message: '삭제 중 오류가 발생했습니다.',
        icon: Icons.error_rounded,
        isError: true,
      );
    }
  }

  String _formatTime() {
    final createdAt = workoutFinish.createdAt;

    if (createdAt == null) return '';

    final y = createdAt.year.toString();
    final m = createdAt.month.toString().padLeft(2, '0');
    final d = createdAt.day.toString().padLeft(2, '0');
    final h = createdAt.hour.toString().padLeft(2, '0');
    final min = createdAt.minute.toString().padLeft(2, '0');

    return '$y.$m.$d $h:$min';
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분 $seconds초';
    }

    return '$minutes분 $seconds초';
  }

  String _formatPace(double pace) {
    if (pace.isNaN || pace.isInfinite || pace <= 0) {
      return '--:-- min/km';
    }

    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} min/km';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImages = workoutFinish.workoutImagesUrl.isNotEmpty;

    final myUid = ref.watch(myUidProvider);
    final isMyPost = myUid == postOwnerUid;

    final distanceKm = workoutFinish.distanceMeters / 1000;
    final durationText = _formatDuration(workoutFinish.seconds);
    final paceText = _formatPace(workoutFinish.paceMinPerKm);
    final speedText = '${workoutFinish.speedKmh.toStringAsFixed(2)} km/h';

    final hasProfileImage =
        userProfileUrl != null && userProfileUrl!.isNotEmpty;

    return Container(
      width: double.infinity,
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: _surfaceSoft,
                  backgroundImage:
                      hasProfileImage ? NetworkImage(userProfileUrl!) : null,
                  child: !hasProfileImage
                      ? const Icon(
                          Icons.person_rounded,
                          color: _secondaryText,
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (postOwnerUid.isNotEmpty) {
                        Navigator.of(context).pushNamed('/user/$postOwnerUid');
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _primaryText,
                            fontWeight: FontWeight.w900,
                            fontSize: 15.5,
                            letterSpacing: -0.25,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatTime(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _secondaryText,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isMyPost)
                  PopupMenuButton<String>(
                    tooltip: '메뉴',
                    color: _surface,
                    surfaceTintColor: Colors.transparent,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(
                        color: _line,
                        width: 0.8,
                      ),
                    ),
                    icon: const Icon(
                      Icons.more_horiz_rounded,
                      color: _primaryText,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _goToEditPage(
                          context: context,
                          ref: ref,
                        );
                      }

                      if (value == 'delete') {
                        _showDeleteDialog(
                          context: context,
                          ref: ref,
                        );
                      }
                    },
                    itemBuilder: (context) {
                      return const [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                color: _accent,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                '수정',
                                style: TextStyle(
                                  color: _primaryText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                color: _danger,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                '삭제',
                                style: TextStyle(
                                  color: _danger,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
              ],
            ),
          ),
          if (hasImages)
            FeedImage(
              imageUrls: workoutFinish.workoutImagesUrl,
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _NoImageWorkoutBanner(),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                if (myUid != null &&
                    workoutFinish.workoutId != null &&
                    workoutFinish.workoutId!.isNotEmpty)
                  LikeButton(
                    
                    myUid: myUid,
                    workoutFinishId: workoutFinish.workoutId!,
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: displayName,
                    style: const TextStyle(
                      color: _primaryText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const TextSpan(
                    text: ' 님이 운동을 완료했습니다.',
                    style: TextStyle(
                      color: _primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 340;

                return GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 9,
                  crossAxisSpacing: 9,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: compact ? 2.05 : 2.28,
                  children: [
                    _WorkoutMetricTile(
                      icon: Icons.route_outlined,
                      label: '거리',
                      value: '${distanceKm.toStringAsFixed(2)} km',
                    ),
                    _WorkoutMetricTile(
                      icon: Icons.timer_outlined,
                      label: '시간',
                      value: durationText,
                    ),
                    _WorkoutMetricTile(
                      icon: Icons.directions_run_outlined,
                      label: '페이스',
                      value: paceText,
                    ),
                    _WorkoutMetricTile(
                      icon: Icons.speed_outlined,
                      label: '속도',
                      value: speedText,
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(
            color: _line,
            height: 0.7,
            thickness: 0.7,
          ),
        ],
      ),
    );
  }
}

class FeedImage extends StatefulWidget {
  final List<String> imageUrls;

  const FeedImage({
    super.key,
    required this.imageUrls,
  });

  @override
  State<FeedImage> createState() => _FeedImageState();
}

class _FeedImageState extends State<FeedImage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  void didUpdateWidget(covariant FeedImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.imageUrls.length != widget.imageUrls.length) {
      setState(() {
        _currentIndex = 0;
      });

      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            key: ValueKey(widget.imageUrls.join(',')),
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                color: _surface,
                child: Image.network(
                  widget.imageUrls[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return const Center(
                      child: CircularProgressIndicator(
                        color: _accent,
                        strokeWidth: 2,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: _secondaryText,
                        size: 42,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.62),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        if (widget.imageUrls.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 9,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                final selected = _currentIndex == index;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: selected ? 7 : 5,
                  height: selected ? 7 : 5,
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white
                        : Colors.white.withOpacity(0.42),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _NoImageWorkoutBanner extends StatelessWidget {
  const _NoImageWorkoutBanner();

  static const Color _surface = Color(0xFF0B0B0D);
  // static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 178,
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_run_rounded,
            color: _accent,
            size: 38,
          ),
          SizedBox(height: 11),
          Text(
            '운동 기록',
            style: TextStyle(
              color: _primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '사진 없이 업로드된 운동입니다.',
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutMetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WorkoutMetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: _surfaceSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: _accent,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 13.2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}