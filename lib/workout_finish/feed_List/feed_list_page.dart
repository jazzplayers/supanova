import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/workout_finish/feed/feed_page.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish_provider.dart';

class WorkoutFeedListPage extends ConsumerStatefulWidget {
  const WorkoutFeedListPage({
    super.key,
    required this.userId,
    required this.initialWorkoutId,
  });

  final String userId;
  final String initialWorkoutId;

  @override
  ConsumerState<WorkoutFeedListPage> createState() =>
      _WorkoutFeedListPageState();
}

class _WorkoutFeedListPageState extends ConsumerState<WorkoutFeedListPage> {
  PageController? _pageController;
  int _currentIndex = 0;

  static const Color _bg = Color(0xFF000000);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _line = Color(0xFF242428);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  void didUpdateWidget(covariant WorkoutFeedListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.userId != widget.userId ||
        oldWidget.initialWorkoutId != widget.initialWorkoutId) {
      _pageController?.dispose();
      _pageController = null;
      _currentIndex = 0;
    }
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  int _initialIndexOf(List<WorkoutFinish> workouts) {
    final targetId = widget.initialWorkoutId.trim();

    if (targetId.isEmpty) return 0;

    final index = workouts.indexWhere((workout) {
      return workout.workoutId == targetId;
    });

    if (index < 0) return 0;

    return index;
  }

  PageController _ensurePageController(List<WorkoutFinish> workouts) {
    final existingController = _pageController;

    if (existingController != null) {
      return existingController;
    }

    final lastIndex = workouts.isEmpty ? 0 : workouts.length - 1;
    final initialIndex = _initialIndexOf(workouts).clamp(0, lastIndex).toInt();

    _currentIndex = initialIndex;
    _pageController = PageController(
      initialPage: initialIndex,
    );

    return _pageController!;
  }

  Future<void> _refresh() async {
    ref.invalidate(feedListWorkoutFinishProvider(widget.userId));
    ref.invalidate(feedWorkoutFinishProvider(widget.userId));
    ref.invalidate(profileWorkoutGridProvider(widget.userId));

    await ref.read(
      feedListWorkoutFinishProvider(widget.userId).future,
    );
  }

  void _invalidateAfterUpdate(WorkoutFinish updatedWorkoutFinish) {
    ref.invalidate(feedListWorkoutFinishProvider(widget.userId));
    ref.invalidate(feedWorkoutFinishProvider(widget.userId));
    ref.invalidate(profileWorkoutGridProvider(widget.userId));

    final workoutId = updatedWorkoutFinish.workoutId;
    if (workoutId != null && workoutId.isNotEmpty) {
      ref.invalidate(
        workoutFinishProvider(
          workoutFinishId: workoutId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(
      feedListWorkoutFinishProvider(widget.userId),
    );

    final userAsync = ref.watch(
      userAuthDataProvider(widget.userId),
    );

    return Scaffold(
      backgroundColor: _bg,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 52,
        title: Text(
          '운동 피드',
          style: const TextStyle(
            color: _primaryText,
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Center(
            child: ClipOval(
              child: Material(
                color: Colors.black.withAlpha(120),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).maybePop();
                  },
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _primaryText,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: workoutsAsync.when(
        data: (workouts) {
          if (workouts.isEmpty) {
            return const _FeedListEmptyView();
          }

          final pageController = _ensurePageController(workouts);

          if (_currentIndex >= workouts.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              final lastIndex = workouts.length - 1;

              setState(() {
                _currentIndex = lastIndex;
              });

              if (pageController.hasClients) {
                pageController.jumpToPage(lastIndex);
              }
            });
          }

          return userAsync.when(
            data: (user) {
              if (user == null) {
                return const _FeedListMessageView(
                  icon: Icons.person_off_outlined,
                  title: '사용자 정보를 찾을 수 없습니다.',
                  message: '잠시 후 다시 시도해주세요.',
                );
              }

              return RefreshIndicator(
                color: _accent,
                backgroundColor: const Color(0xFF111115),
                displacement: MediaQuery.paddingOf(context).top + 52,
                onRefresh: _refresh,
                child: PageView.builder(
                  controller: pageController,
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  pageSnapping: true,
                  allowImplicitScrolling: true,
                  itemCount: workouts.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final workout = workouts[index];

                    return SizedBox.expand(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableHeight = constraints.maxHeight.isFinite
                              ? constraints.maxHeight
                              : MediaQuery.sizeOf(context).height;

                          final mediaPadding = MediaQuery.paddingOf(context);

                          return FeedCard(
                            availableHeight: availableHeight,
                            topOverlayInset: mediaPadding.top + 42,
                            bottomOverlayInset: mediaPadding.bottom,
                            isInFeedList: true,
                            postOwnerUid: workout.userId,
                            displayName: user.displayName,
                            email: user.email,
                            userProfileUrl: user.profileImageUrl,
                            workoutFinish: workout,
                            onUpdated: _invalidateAfterUpdate,
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const _FeedListLoadingView(),
            error: (e, st) => _FeedListMessageView(
              icon: Icons.error_outline_rounded,
              title: '사용자 정보를 불러오지 못했어요',
              message: '$e',
            ),
          );
        },
        loading: () => const _FeedListLoadingView(),
        error: (e, st) => _FeedListMessageView(
          icon: Icons.error_outline_rounded,
          title: '운동 피드를 불러오지 못했어요',
          message: '$e',
        ),
      ),
    );
  }
}

class _FeedListLoadingView extends StatelessWidget {
  const _FeedListLoadingView();

  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: _accent,
        strokeWidth: 2,
      ),
    );
  }
}

class _FeedListEmptyView extends StatelessWidget {
  const _FeedListEmptyView();

  @override
  Widget build(BuildContext context) {
    return const _FeedListMessageView(
      icon: Icons.directions_run_rounded,
      title: '운동 기록이 없어요',
      message: '운동을 완료하면 피드가 여기에 표시됩니다.',
    );
  }
}

class _FeedListMessageView extends StatelessWidget {
  const _FeedListMessageView({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  static const Color _surfaceSoft = Color(0xFF15151A);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _surfaceSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _line,
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  icon,
                  color: _secondaryText,
                  size: 29,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.35,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 13,
                  height: 1.42,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
