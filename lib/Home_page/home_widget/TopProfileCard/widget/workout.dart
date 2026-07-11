import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/workout_finish/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish_provider.dart';

class WorkoutGridSheet extends ConsumerWidget {
  const WorkoutGridSheet({
    super.key,
    required this.userId,
    required this.scrollController,
  });

  final String userId;
  final ScrollController scrollController;

  static const Color _bg = Color(0xFF050507);
  static const Color _line = Color(0xFF1F1F24);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaQuery.of(context);
    final workoutsAsync = ref.watch(profileWorkoutGridProvider(userId));

    final int? cachedCount = workoutsAsync.maybeWhen(
      data: (workouts) => workouts.length,
      orElse: () => null,
    );

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(6, 0, 6, 6),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(26),
            bottom: Radius.circular(18),
          ),
          border: Border.all(
            color: _line,
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(180),
              blurRadius: 32,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(26),
            bottom: Radius.circular(18),
          ),
          child: CustomScrollView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _WorkoutSheetHeader(
                  count: cachedCount,
                ),
              ),
              workoutsAsync.when(
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: WorkoutEmptyView(
                        bottomPadding: media.padding.bottom,
                      ),
                    );
                  }

                  return _WorkoutGrid(
                    workouts: workouts,
                    bottomPadding: media.padding.bottom,
                  );
                },
                loading: () {
                  return _WorkoutGridSkeleton(
                    bottomPadding: media.padding.bottom,
                  );
                },
                error: (e, st) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _WorkoutErrorView(
                      bottomPadding: media.padding.bottom,
                      onRetry: () {
                        ref.invalidate(profileWorkoutGridProvider(userId));
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutSheetHeader extends StatelessWidget {
  const _WorkoutSheetHeader({
    required this.count,
  });

  final int? count;

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF8E8E95);
  static const Color _line = Color(0xFF1F1F24);
  static const Color _chipBg = Color(0xFF151519);

  @override
  Widget build(BuildContext context) {
    final countText = count == null ? null : '$count개';

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF050507),
        border: Border(
          bottom: BorderSide(
            color: _line,
            width: 0.7,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 14),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A40),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '운동 기록',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _primaryText,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.45,
                          height: 1.05,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '사진과 날짜로 보는 운동 히스토리',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (countText != null) ...[
                  Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _chipBg,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withAlpha(16),
                        width: 0.7,
                      ),
                    ),
                    child: Text(
                      countText,
                      style: const TextStyle(
                        color: _primaryText,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                _CloseButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  static const Color _buttonBg = Color(0xFF151519);
  static const Color _primaryText = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _buttonBg,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            Icons.close_rounded,
            color: _primaryText,
            size: 21,
          ),
        ),
      ),
    );
  }
}

class _WorkoutGrid extends StatelessWidget {
  const _WorkoutGrid({
    required this.workouts,
    required this.bottomPadding,
  });

  final List<WorkoutFinish> workouts;
  final double bottomPadding;

  String? _resolveGridImageUrl(WorkoutFinish workout) {
    final thumbnailUrl = workout.workoutThumbnailUrl?.trim() ?? '';

    if (thumbnailUrl.isNotEmpty) {
      return thumbnailUrl;
    }

    if (workout.workoutImagesUrl.isNotEmpty) {
      return workout.workoutImagesUrl.first;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        16 + bottomPadding,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final workout = workouts[index];
            final imageUrl = _resolveGridImageUrl(workout);

            return WorkoutImageGridTile(
              workout: workout,
              imageUrl: imageUrl,
            );
          },
          childCount: workouts.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1,
        ),
      ),
    );
  }
}

class WorkoutImageGridTile extends StatelessWidget {
  const WorkoutImageGridTile({
    super.key,
    required this.workout,
    required this.imageUrl,
  });

  final WorkoutFinish workout;
  final String? imageUrl;

  static const Color _surface = Color(0xFF121216);

  String? get _validImageUrl {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return null;
    }

    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      debugPrint('Invalid workout image url: $url');
      return null;
    }

    return url;
  }

  String get _dateText {
    final createdAt = workout.createdAt;

    if (createdAt == null) {
      return '날짜 없음';
    }

    final y = createdAt.year.toString();
    final m = createdAt.month.toString().padLeft(2, '0');
    final d = createdAt.day.toString().padLeft(2, '0');

    return '$y.$m.$d';
  }

  void _openWorkoutFeedList(BuildContext context) {
    final workoutId = workout.workoutId?.trim();

    if (workoutId == null || workoutId.isEmpty) {
      return;
    }

    final router = GoRouter.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);

    if (navigator.canPop()) {
      navigator.pop();
    }

    router.push(
      '/workoutFeedList',
      extra: {
        'userId': workout.userId,
        'initialWorkoutId': workoutId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _dateText;
    final validImageUrl = _validImageUrl;
    final hasImage = validImageUrl != null;

    return RepaintBoundary(
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            _openWorkoutFeedList(context);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                _WorkoutCachedImage(
                  imageUrl: validImageUrl,
                  dateText: dateText,
                )
              else
                _WorkoutDateOnlyTile(
                  dateText: dateText,
                ),
              if (workout.workoutImagesUrl.length > 1)
                const Positioned(
                  top: 7,
                  right: 7,
                  child: _MultiImageMark(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkoutCachedImage extends StatelessWidget {
  const _WorkoutCachedImage({
    required this.imageUrl,
    required this.dateText,
  });

  final String imageUrl;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
        final rawCacheSize = constraints.maxWidth * devicePixelRatio;

        final cacheSize = rawCacheSize.isFinite && rawCacheSize > 0
            ? rawCacheSize.round().clamp(180, 720)
            : 360;

        return Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              memCacheWidth: cacheSize,
              memCacheHeight: cacheSize,
              maxWidthDiskCache: cacheSize,
              maxHeightDiskCache: cacheSize,
              fadeInDuration: const Duration(milliseconds: 80),
              fadeOutDuration: const Duration(milliseconds: 60),
              useOldImageOnUrlChange: true,
              imageBuilder: (context, imageProvider) {
                return DecoratedBox(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                    ),
                  ),
                );
              },
              placeholder: (context, url) {
                return _WorkoutImageLoadingTile(
                  dateText: dateText,
                );
              },
              errorWidget: (context, url, error) {
                debugPrint('Workout image load failed: $error');
                debugPrint('Workout image url: $url');

                return _WorkoutDateOnlyTile(
                  dateText: dateText,
                );
              },
            ),
            Center(
              child: _CenteredWorkoutDateLabel(
                dateText: dateText,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WorkoutImageLoadingTile extends StatelessWidget {
  const _WorkoutImageLoadingTile({
    required this.dateText,
  });

  final String dateText;

  static const Color _surface = Color(0xFF111115);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: _CenteredWorkoutDateLabel(
              dateText: dateText,
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: Center(
              child: SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 1.7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredWorkoutDateLabel extends StatelessWidget {
  const _CenteredWorkoutDateLabel({
    required this.dateText,
  });

  final String dateText;

  static const Color _mainColor = Color(0xF7FFFFFF);
  static const Color _subColor = Color(0xCCFFFFFF);

  List<String> get _parts => dateText.split('.');

  String get _mainText {
    final parts = _parts;

    if (parts.length == 3) {
      return '${parts[1]}.${parts[2]}';
    }

    return dateText;
  }

  String? get _subText {
    final parts = _parts;

    if (parts.length == 3) {
      return parts[0];
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final subText = _subText;

    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _mainText,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _mainColor,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.25,
                  height: 1,
                  fontFeatures: [
                    ui.FontFeature.tabularFigures(),
                  ],
                  shadows: [
                    Shadow(
                      color: Color(0xCC000000),
                      blurRadius: 8,
                      offset: Offset(0, 1.2),
                    ),
                    Shadow(
                      color: Color(0x99000000),
                      blurRadius: 16,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
              if (subText != null) ...[
                const SizedBox(height: 3),
                Text(
                  subText,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _subColor,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.15,
                    height: 1,
                    fontFeatures: [
                      ui.FontFeature.tabularFigures(),
                    ],
                    shadows: [
                      Shadow(
                        color: Color(0xCC000000),
                        blurRadius: 7,
                        offset: Offset(0, 1),
                      ),
                      Shadow(
                        color: Color(0x99000000),
                        blurRadius: 14,
                        offset: Offset(0, 2.5),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MultiImageMark extends StatelessWidget {
  const _MultiImageMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(132),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.collections_rounded,
        color: Colors.white,
        size: 14,
      ),
    );
  }
}

class _WorkoutDateOnlyTile extends StatelessWidget {
  const _WorkoutDateOnlyTile({
    required this.dateText,
  });

  final String dateText;

  static const Color _surface = Color(0xFF111115);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _surface,
      alignment: Alignment.center,
      child: _CenteredWorkoutDateLabel(
        dateText: dateText,
      ),
    );
  }
}

class _WorkoutGridSkeleton extends StatelessWidget {
  const _WorkoutGridSkeleton({
    required this.bottomPadding,
  });

  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(
        12,
        12,
        12,
        16 + bottomPadding,
      ),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return const _SkeletonTile();
          },
          childCount: 9,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 1,
        ),
      ),
    );
  }
}

class _SkeletonTile extends StatelessWidget {
  const _SkeletonTile();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF111115),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha(10),
          width: 0.7,
        ),
      ),
      child: Center(
        child: Container(
          width: 46,
          height: 10,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C22),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class WorkoutEmptyView extends StatelessWidget {
  const WorkoutEmptyView({
    super.key,
    required this.bottomPadding,
  });

  final double bottomPadding;

  static const Color _surfaceSoft = Color(0xFF15151A);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF8E8E95);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28, 54, 28, 28 + bottomPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _surfaceSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(14),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: _secondaryText,
              size: 29,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '아직 운동 기록이 없어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '운동을 완료하면 사진과 날짜가 여기에 표시됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13,
              height: 1.42,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutErrorView extends StatelessWidget {
  const _WorkoutErrorView({
    required this.bottomPadding,
    required this.onRetry,
  });

  final double bottomPadding;
  final VoidCallback onRetry;

  static const Color _surfaceSoft = Color(0xFF15151A);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF8E8E95);
  static const Color _line = Color(0xFF26262B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(28, 54, 28, 28 + bottomPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: _surfaceSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withAlpha(14),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: _secondaryText,
              size: 29,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '운동 기록을 불러오지 못했어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '네트워크 상태를 확인한 뒤 다시 시도해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13,
              height: 1.42,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 40,
            child: OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryText,
                side: const BorderSide(
                  color: _line,
                  width: 0.8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              child: const Text(
                '다시 시도',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}