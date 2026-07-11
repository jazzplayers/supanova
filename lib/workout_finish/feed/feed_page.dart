import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/reports/reports_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';
import 'package:home_function/workout_finish/feed/feed_edit_page.dart';
import 'package:home_function/workout_finish/feed/widget/like_Controller/like_button.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish_provider.dart';

part 'widget/feed_card.dart';
part 'widget/feed_header.dart';
part 'widget/feed_hero.dart';
part 'widget/feed_media.dart';
part 'widget/feed_route_map.dart';
part 'widget/feed_stats.dart';

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

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.paddingOf(context).bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: FeedCard(
                    availableHeight: constraints.maxHeight,
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
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: _accent,
            strokeWidth: 2,
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '유저 정보 로드 실패: $error',
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

bool _isValidNetworkImageUrl(String? url) {
  final value = url?.trim();

  if (value == null || value.isEmpty) {
    return false;
  }

  return value.startsWith('http://') || value.startsWith('https://');
}