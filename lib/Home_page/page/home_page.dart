import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/Home_page/home_widget/month_goal/month_goal_UI.dart';
import 'package:home_function/Home_page/home_widget/month_goal/month_goal_provider.dart';
import 'package:home_function/Home_page/home_widget/TopProfileCard/Top_Profile_card.dart';
import 'package:home_function/Home_page/page/home_ranking_page.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/calendar/calendar_page.dart';
import 'package:home_function/core/firebase.dart';
import 'package:home_function/workout_finish/workout_finish_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  final String userId;

  const HomePage({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  double _contentPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < 360 ? 14 : 16;
  }

  ScrollPhysics _pageScrollPhysics(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS) {
      return const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      );
    }

    return const AlwaysScrollableScrollPhysics(
      parent: ClampingScrollPhysics(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userAuthDataProvider(widget.userId));
    final myUid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final isMe = myUid == widget.userId;

    final media = MediaQuery.of(context);
    final contentPadding = _contentPadding(context);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            backgroundColor: _bg,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_off_outlined,
                        color: _primaryText,
                        size: 34,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        '사용자 정보를 찾을 수 없습니다',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _primaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '잠시 후에도 계속 보이면 다시 불러오기를 눌러주세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () {
                          ref.invalidate(userAuthDataProvider(widget.userId));
                        },
                        child: const Text(
                          '다시 불러오기',
                          style: TextStyle(
                            color: _primaryText,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: _bg,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: _bg,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            toolbarHeight: 52,
            automaticallyImplyLeading: false,
            titleSpacing: 12,
            title: Text(
              user.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
                color: _primaryText,
              ),
            ),
            actions: [
              _AppBarIconButton(
                icon: Icons.calendar_month_outlined,
                onTap: () {
                  _showCalendarBottomSheet(context, widget.userId);
                },
              ),
              if (isMe)
                PopupMenuButton<String>(
                  tooltip: '메뉴',
                  color: _surface,
                  surfaceTintColor: Colors.transparent,
                  elevation: 8,
                  position: PopupMenuPosition.under,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: _line,
                      width: 0.8,
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'settings') {
                      context.push('/settings');
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value: 'settings',
                        child: Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              size: 20,
                              color: _primaryText,
                            ),
                            SizedBox(width: 12),
                            Text(
                              '설정',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _primaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ];
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: Icon(
                        Icons.more_horiz,
                        color: _primaryText,
                        size: 27,
                      ),
                    ),
                  ),
                ),
            ],
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(0.7),
              child: Divider(
                color: _line,
                height: 0.7,
                thickness: 0.7,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            bottom: false,
            child: RefreshIndicator(
              color: _primaryText,
              backgroundColor: _surface,
              displacement: 24,
              onRefresh: () async {
                ref.invalidate(userAuthDataProvider(widget.userId));
                ref.invalidate(totalDistanceThisDayProvider(widget.userId));
                ref.invalidate(workoutFinishListProvider(widget.userId));
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bottomPadding = 30.0 + media.padding.bottom;

                  return SingleChildScrollView(
                    physics: _pageScrollPhysics(context),
                    padding: EdgeInsets.fromLTRB(
                      0,
                      12,
                      0,
                      bottomPadding,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: math.max(
                          0,
                          constraints.maxHeight - bottomPadding,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TopProfileCard(
                            userId: widget.userId,
                            isMe: isMe,
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding,
                            ),
                            child: _StatsRow(userId: widget.userId),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding,
                            ),
                            child: _SectionFrame(
                              child: HomeRanking(userId: widget.userId),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: contentPadding,
                            ),
                            child: RecentRecords(userId: widget.userId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      loading: () {
        return const Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Center(
              child: CircularProgressIndicator(
                color: _primaryText,
                strokeWidth: 2,
              ),
            ),
          ),
        );
      },
      error: (e, st) {
        debugPrint('HomePage userAuthDataProvider error: $e');
        debugPrint('HomePage userAuthDataProvider stackTrace: $st');

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: _primaryText,
                      size: 34,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '에러가 발생했습니다',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _primaryText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '사용자 정보를 불러오지 못했습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextButton(
                      onPressed: () {
                        ref.invalidate(userAuthDataProvider(widget.userId));
                      },
                      child: const Text(
                        '다시 불러오기',
                        style: TextStyle(
                          color: _primaryText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  static const Color _primaryText = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        foregroundColor: _primaryText,
        fixedSize: const Size(42, 42),
        minimumSize: const Size(42, 42),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      icon: Icon(
        icon,
        size: 23,
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  final String userId;

  const _StatsRow({
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionFrame(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          child: _MiniStat(
            userId: userId,
            title: '오늘 달린 거리',
            fallbackText: '0.00 km',
          ),
        ),
        const SizedBox(height: 14),
        _SectionFrame(
          padding: EdgeInsets.zero,
          child: MonthGauge(userId: userId),
        ),
      ],
    );
  }
}

class _MiniStat extends ConsumerWidget {
  const _MiniStat({
    required this.userId,
    required this.title,
    required this.fallbackText,
  });

  final String userId;
  final String title;
  final String fallbackText;

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalDistanceThisDay = ref.watch(
      totalDistanceThisDayProvider(userId),
    );

    final text = totalDistanceThisDay.when(
      data: (totalDistance) {
        if (totalDistance <= 0) return fallbackText;

        final km = totalDistance / 1000.0;
        return '${km.toStringAsFixed(2)} km';
      },
      loading: () => '로딩 중',
      error: (e, st) => '에러',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;

        return Row(
          children: [
            Container(
              width: compact ? 39 : 42,
              height: compact ? 39 : 42,
              decoration: BoxDecoration(
                color: _accent.withAlpha(33),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_run_rounded,
                size: compact ? 21 : 23,
                color: _accent,
              ),
            ),
            SizedBox(width: compact ? 10 : 13),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _secondaryText,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  text,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: compact ? 18 : 20,
                    fontWeight: FontWeight.w900,
                    color: _primaryText,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class RecentRecords extends ConsumerStatefulWidget {
  final String userId;

  const RecentRecords({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<RecentRecords> createState() => _RecentRecordsState();
}

class _RecentRecordsState extends ConsumerState<RecentRecords> {
  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final height = media.size.height;
    final isSmallHeight = height < 720;

    final cardHeight = isSmallHeight
        ? (height * 0.34).clamp(245.0, 305.0)
        : (height * 0.36).clamp(270.0, 345.0);

    return SizedBox(
      width: double.infinity,
      height: cardHeight,
      child: _SectionFrame(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              title: '최근 운동 기록',
              icon: Icons.history,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RecentWorkoutRecords(userId: widget.userId),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentWorkoutRecords extends ConsumerWidget {
  final String userId;

  const RecentWorkoutRecords({
    super.key,
    required this.userId,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  ScrollPhysics _listScrollPhysics(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS) {
      return const BouncingScrollPhysics();
    }

    return const ClampingScrollPhysics();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(workoutFinishListProvider(userId));

    return recordsAsync.when(
      data: (records) {
        if (records.isEmpty) {
          return const Center(
            child: Text(
              '아직 운동 기록이 없어요',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                color: _secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return ListView.separated(
          itemCount: records.length,
          padding: EdgeInsets.zero,
          physics: _listScrollPhysics(context),
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final w = records[index];
            final ts = w.timestamp;

            final dateStr = ts == null
                ? '날짜 없음'
                : '${ts.year}.${ts.month.toString().padLeft(2, '0')}.${ts.day.toString().padLeft(2, '0')}';

            final distance =
                '${(w.distanceMeters / 1000).toStringAsFixed(2)} km';

            final pace = _formatPace(w.paceMinPerKm);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  context.push('/workoutFeed', extra: w);
                },
                child: _RecordItem(
                  date: dateStr,
                  distance: distance,
                  pace: pace,
                ),
              ),
            );
          },
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(
            color: _primaryText,
            strokeWidth: 2,
          ),
        );
      },
      error: (e, st) {
        debugPrint('RecentWorkoutRecords error: $e');
        debugPrint('RecentWorkoutRecords stackTrace: $st');

        return const Center(
          child: Text(
            '운동 기록을 불러오지 못했습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  String _formatPace(double paceMinPerKm) {
    if (paceMinPerKm <= 0 || paceMinPerKm.isNaN || paceMinPerKm.isInfinite) {
      return '--:-- /km';
    }

    final totalSeconds = (paceMinPerKm * 60).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} /km';
  }
}

class _RecordItem extends StatelessWidget {
  const _RecordItem({
    required this.date,
    required this.distance,
    required this.pace,
  });

  final String date;
  final String distance;
  final String pace;

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 340;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 14,
            vertical: 13,
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
              Container(
                width: compact ? 38 : 40,
                height: compact ? 38 : 40,
                decoration: BoxDecoration(
                  color: _accent.withAlpha(33),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_run_rounded,
                  color: _accent,
                  size: compact ? 20 : 22,
                ),
              ),
              SizedBox(width: compact ? 11 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      date,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _primaryText,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pace,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 0,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    distance,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: _primaryText,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: _accent,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _primaryText,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionFrame extends StatelessWidget {
  const _SectionFrame({
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsets padding;

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: child,
    );
  }
}

void _showCalendarBottomSheet(BuildContext context, String userId) {
  const Color bg = Color(0xFF000000);
  const Color line = Color(0xFF242428);
  const Color handle = Color(0xFF3A3A40);

  showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withAlpha(173),
    builder: (sheetContext) {
      final media = MediaQuery.of(sheetContext);
      final height = media.size.height;
      final isSmallHeight = height < 720;

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: isSmallHeight ? 0.94 : 0.90,
        minChildSize: 0.55,
        maxChildSize: 0.96,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: line,
                  width: 0.8,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Column(
                children: [
                  SizedBox(
                    height: 28,
                    child: Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: handle,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                      child: PrimaryScrollController(
                        controller: scrollController,
                        child: WorkoutCalendarPage(
                          userId: userId,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}