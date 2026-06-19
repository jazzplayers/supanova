import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/ranking/run_ranking.dart';
import 'package:home_function/ranking/run_ranking_provider.dart';

class HomeRanking extends ConsumerWidget {
  final String userId;

  const HomeRanking({
    super.key,
    required this.userId,
  });

  // static const Color _bg = Color(0xFF000000);
  // static const Color _surface = Color(0xFF0B0B0D);
  // static const Color _surfaceSoft = Color(0xFF121216);
  // static const Color _line = Color(0xFF242428);
  // static const Color _primaryText = Color(0xFFFFFFFF);
  // static const Color _secondaryText = Color(0xFF9B9BA1);
  // static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _gold = Color(0xFFFFB74D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyRankingAsync = ref.watch(
      myMonthlyRunRankingProvider(userId),
    );
    final monthlyRankAsync = ref.watch(
      myMonthlyRunRankProvider(userId),
    );

    final totalRankingAsync = ref.watch(
      myTotalRunRankingProvider(userId),
    );
    final totalRankAsync = ref.watch(
      myTotalRunRankProvider(userId),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeRankingHeader(
            onTapMore: () {
              context.push('/run-ranking');
            },
          ),
          const SizedBox(height: 13),
          _MyRankingTile(
            title: '이번 달 랭킹',
            icon: Icons.emoji_events_outlined,
            pointColor: _accent,
            rankingAsync: monthlyRankingAsync,
            rankAsync: monthlyRankAsync,
          ),
          const SizedBox(height: 9),
          _MyRankingTile(
            title: '전체 랭킹',
            icon: Icons.workspace_premium_outlined,
            pointColor: _gold,
            rankingAsync: totalRankingAsync,
            rankAsync: totalRankAsync,
          ),
        ],
      ),
    );
  }
}

class _HomeRankingHeader extends StatelessWidget {
  final VoidCallback onTapMore;

  const _HomeRankingHeader({
    required this.onTapMore,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.leaderboard_outlined,
          size: 20,
          color: _accent,
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Text(
            '나의 러닝 랭킹',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: _primaryText,
              letterSpacing: -0.3,
            ),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTapMore,
          child: const Padding(
            padding: EdgeInsets.fromLTRB(8, 6, 0, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '전체보기',
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(width: 1),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 19,
                  color: _secondaryText,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MyRankingTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color pointColor;
  final AsyncValue<RunRanking?> rankingAsync;
  final AsyncValue<int?> rankAsync;

  const _MyRankingTile({
    required this.title,
    required this.icon,
    required this.pointColor,
    required this.rankingAsync,
    required this.rankAsync,
  });

  // static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  // static const Color _softText = Color(0xFF66666D);

  @override
  Widget build(BuildContext context) {
    final isLoading = rankingAsync.isLoading || rankAsync.isLoading;
    final hasError = rankingAsync.hasError || rankAsync.hasError;

    if (isLoading) {
      return _RankingCardShell(
        child: SizedBox(
          height: 64,
          child: Center(
            child: SizedBox(
              width: 21,
              height: 21,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: pointColor,
              ),
            ),
          ),
        ),
      );
    }

    if (hasError) {
      return const _RankingCardShell(
        child: SizedBox(
          height: 64,
          child: Center(
            child: Text(
              '랭킹을 불러오지 못했습니다',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _secondaryText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    final ranking = rankingAsync.value;
    final rank = rankAsync.value;

    if (ranking == null || rank == null) {
      return _RankingCardShell(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _IconBox(
                icon: icon,
                pointColor: pointColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '기록 없음',
                maxLines: 1,
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final distanceKm = ranking.distanceMeters / 1000;

    return _RankingCardShell(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 330;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _IconBox(
                      icon: icon,
                      pointColor: pointColor,
                      compact: true,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: pointColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$rank등',
                        maxLines: 1,
                        style: const TextStyle(
                          color: _primaryText,
                          fontSize: 24,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _RankingInfoRow(
                  label: '거리',
                  value: '${distanceKm.toStringAsFixed(2)} km',
                ),
                const SizedBox(height: 7),
                _RankingInfoRow(
                  label: '운동 횟수',
                  value: '${ranking.workoutCount}회',
                ),
              ],
            );
          }

          return Row(
            children: [
              _IconBox(
                icon: icon,
                pointColor: pointColor,
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 88,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: pointColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$rank등',
                        maxLines: 1,
                        style: const TextStyle(
                          color: _primaryText,
                          fontSize: 29,
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: _line,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  children: [
                    _RankingInfoRow(
                      label: '거리',
                      value: '${distanceKm.toStringAsFixed(2)} km',
                    ),
                    const SizedBox(height: 8),
                    _RankingInfoRow(
                      label: '운동 횟수',
                      value: '${ranking.workoutCount}회',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RankingCardShell extends StatelessWidget {
  final Widget child;

  const _RankingCardShell({
    required this.child,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
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
      child: child,
    );
  }
}

class _RankingInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _RankingInfoRow({
    required this.label,
    required this.value,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 0,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                color: _primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final Color pointColor;
  final bool compact;

  const _IconBox({
    required this.icon,
    required this.pointColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 42.0 : 48.0;
    final iconSize = compact ? 22.0 : 25.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: pointColor.withOpacity(0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: pointColor,
        size: iconSize,
      ),
    );
  }
}