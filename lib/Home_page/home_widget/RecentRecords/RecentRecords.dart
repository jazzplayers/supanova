import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish_provider.dart';
import 'package:home_function/Home_page/home_widget/statsRow/statsRow.dart';


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
      child: SectionFrame(
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