import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_function/workout_finish/workout_finish_provider.dart';

class RecentRecords extends ConsumerWidget {
  const RecentRecords({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final todayWorkoutRecord = ref.watch(todayWorkoutFinishProvider);

    return Container(
      width: double.infinity,
      height: 210,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: todayWorkoutRecord.when(
        data: (workout) {
          if (workout == null) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: '오늘의 운동 기록',
                  icon: Icons.history_rounded,
                ),
                const Spacer(),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_run_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '아직 운동 기록이 없어요',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '오늘 운동을 시작해보세요',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
              ],
            );
          }

          final distanceKm =
              (workout.distanceMeters / 1000).toStringAsFixed(2);

          final minutes = workout.seconds ~/ 60;
          final seconds = workout.seconds % 60;

          final paceMin = workout.paceMinPerKm.floor();
          final paceSec =
              ((workout.paceMinPerKm - paceMin) * 60).round();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(
                title: '오늘의 운동 기록',
                icon: Icons.history_rounded,
              ),
              const SizedBox(height: 16),
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  context.push('/workoutFeed', extra: workout);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.75,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.directions_run_rounded,
                          color: colorScheme.primary,
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$distanceKm km',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$minutes분 $seconds초 · ${workout.speedKmh.toStringAsFixed(2)} km/h',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${paceMin.toString().padLeft(2, '0')}:${paceSec.toString().padLeft(2, '0')} /km',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, st) => Center(
          child: Text(
            '운동 기록을 불러오지 못했습니다',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}