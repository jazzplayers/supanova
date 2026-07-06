
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:home_function/Home_page/home_widget/month_goal/month_goal_UI.dart';
import 'package:home_function/Home_page/home_widget/month_goal/month_goal_provider.dart';


class StatsRow extends ConsumerWidget {
  final String userId;

  const StatsRow({
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionFrame(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 13,
          ),
          child: MiniStat(
            userId: userId,
            title: '오늘 달린 거리',
            fallbackText: '0.00 km',
          ),
        ),
        const SizedBox(height: 14),
        SectionFrame(
          padding: EdgeInsets.zero,
          child: MonthGauge(userId: userId),
        ),
      ],
    );
  }
}

class MiniStat extends ConsumerWidget {
  const MiniStat({
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

class SectionFrame extends StatelessWidget {
  const SectionFrame({
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