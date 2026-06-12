import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/ranking/run_ranking.dart';
import 'package:home_function/ranking/run_ranking_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';

class RunRankingScreen extends ConsumerWidget {
  const RunRankingScreen({super.key});

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 52,
          title: const Text(
            '러닝 랭킹',
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
            preferredSize: Size.fromHeight(49),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RankingTabBar(),
                Divider(
                  color: _line,
                  height: 0.7,
                  thickness: 0.7,
                ),
              ],
            ),
          ),
        ),
        body: const SafeArea(
          top: false,
          bottom: false,
          child: TabBarView(
            children: [
              _RankingList(type: _RankingType.monthly),
              _RankingList(type: _RankingType.total),
            ],
          ),
        ),
      ),
    );
  }
}

class _RankingTabBar extends StatelessWidget {
  const _RankingTabBar();

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TabBar(
        dividerColor: Colors.transparent,
        indicatorColor: _primaryText,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: _primaryText,
        unselectedLabelColor: _secondaryText,
        labelStyle: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        tabs: const [
          Tab(text: '이번 달'),
          Tab(text: '전체'),
        ],
      ),
    );
  }
}

enum _RankingType {
  monthly,
  total,
}

class _RankingList extends ConsumerWidget {
  final _RankingType type;

  const _RankingList({
    required this.type,
  });

  static const Color _bg = Color(0xFF000000);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaQuery.of(context);

    final rankingAsync = switch (type) {
      _RankingType.monthly => ref.watch(monthlyRunRankingProvider),
      _RankingType.total => ref.watch(totalRunRankingProvider),
    };

    return rankingAsync.when(
      data: (rankings) {
        if (rankings.isEmpty) {
          return const _EmptyRankingView();
        }

        return ListView.separated(
          padding: EdgeInsets.fromLTRB(
            0,
            8,
            0,
            24 + media.padding.bottom,
          ),
          itemCount: rankings.length,
          separatorBuilder: (_, __) => const Divider(
            color: Color(0xFF242428),
            height: 0.7,
            thickness: 0.7,
            indent: 86,
          ),
          itemBuilder: (context, index) {
            final ranking = rankings[index];
            final rank = index + 1;

            return _RankingTile(
              ranking: ranking,
              rank: rank,
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: _primaryText,
          strokeWidth: 2,
        ),
      ),
      error: (error, stackTrace) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;

          showAppSnackBar(
            context,
            message: '랭킹을 불러오지 못했습니다.',
            icon: Icons.error_rounded,
            isError: true,
          );
        });

        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              '랭킹을 불러오지 못했습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _RankingTile extends ConsumerWidget {
  final RunRanking ranking;
  final int rank;

  const _RankingTile({
    required this.ranking,
    required this.rank,
  });

  static const Color _bg = Color(0xFF000000);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distanceKm = ranking.distanceMeters / 1000;
    final userAsync = ref.watch(userAuthDataProvider(ranking.userId));

    return InkWell(
      onTap: () {
        if (ranking.userId.isEmpty) {
          showAppSnackBar(
            context,
            message: '사용자 정보를 열 수 없습니다.',
            icon: Icons.error_rounded,
            isError: true,
          );
          return;
        }

        context.push('/user/${ranking.userId}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 11,
        ),
        child: Row(
          children: [
            _RankBadge(rank: rank),
            const SizedBox(width: 13),
            userAsync.when(
              data: (user) {
                final profileImageUrl = user?.profileImageUrl;
                final hasProfileImage =
                    profileImageUrl != null && profileImageUrl.isNotEmpty;

                return CircleAvatar(
                  radius: 23,
                  backgroundColor: _surfaceSoft,
                  backgroundImage:
                      hasProfileImage ? NetworkImage(profileImageUrl) : null,
                  child: !hasProfileImage
                      ? const Icon(
                          Icons.person_rounded,
                          color: _secondaryText,
                          size: 24,
                        )
                      : null,
                );
              },
              loading: () => const CircleAvatar(
                radius: 23,
                backgroundColor: _surfaceSoft,
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _accent,
                  ),
                ),
              ),
              error: (e, st) => const CircleAvatar(
                radius: 23,
                backgroundColor: _surfaceSoft,
                child: Icon(
                  Icons.person_rounded,
                  color: _secondaryText,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _UserRankingInfo(
                userAsync: userAsync,
                ranking: ranking,
              ),
            ),
            const SizedBox(width: 10),
            _DistanceBlock(distanceKm: distanceKm),
          ],
        ),
      ),
    );
  }

  static String formatSeconds(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      if (minutes == 0) {
        return '$hours시간';
      }

      return '$hours시간 $minutes분';
    }

    return '$minutes분';
  }
}

class _UserRankingInfo extends StatelessWidget {
  final AsyncValue<dynamic> userAsync;
  final RunRanking ranking;

  const _UserRankingInfo({
    required this.userAsync,
    required this.ranking,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        userAsync.when(
          data: (user) {
            final displayName = user?.displayName ?? '사용자';

            return Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            );
          },
          loading: () => const Text(
            '불러오는 중...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _secondaryText,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          error: (e, st) => const Text(
            '사용자',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${ranking.workoutCount}회 · ${_RankingTile.formatSeconds(ranking.seconds)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _secondaryText,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _DistanceBlock extends StatelessWidget {
  final double distanceKm;

  const _DistanceBlock({
    required this.distanceKm,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 56,
        maxWidth: 82,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              distanceKm.toStringAsFixed(2),
              maxLines: 1,
              style: const TextStyle(
                color: _primaryText,
                fontSize: 17,
                height: 1.0,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              'km',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 12,
                height: 1.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({
    required this.rank,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _gold = Color(0xFFFFB74D);
  static const Color _bronze = Color(0xFFCD7F32);

  @override
  Widget build(BuildContext context) {
    if (rank == 1) {
      return const SizedBox(
        width: 34,
        child: Center(
          child: Text(
            '🥇',
            style: TextStyle(fontSize: 24),
          ),
        ),
      );
    }

    if (rank == 2) {
      return const SizedBox(
        width: 34,
        child: Center(
          child: Text(
            '🥈',
            style: TextStyle(fontSize: 23),
          ),
        ),
      );
    }

    if (rank == 3) {
      return const SizedBox(
        width: 34,
        child: Center(
          child: Text(
            '🥉',
            style: TextStyle(fontSize: 23),
          ),
        ),
      );
    }

    return SizedBox(
      width: 34,
      child: Center(
        child: Text(
          '$rank',
          maxLines: 1,
          style: const TextStyle(
            color: _secondaryText,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _EmptyRankingView extends StatelessWidget {
  const _EmptyRankingView();

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        80,
        16,
        24 + media.padding.bottom,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _line,
              width: 0.8,
            ),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 42,
                color: _accent,
              ),
              SizedBox(height: 14),
              Text(
                '아직 랭킹 데이터가 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '운동 기록이 쌓이면 랭킹이 표시됩니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}