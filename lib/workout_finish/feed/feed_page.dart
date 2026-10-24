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
import 'package:home_function/workout_finish/feed/widget/comment/feed_comment_page.dart';
import 'package:home_function/workout_finish/feed/widget/like_Controller/like_button.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish_provider.dart';

part 'feed_widgets/feed_card.dart';
part 'feed_widgets/feed_header.dart';
part 'feed_widgets/feed_hero.dart';
part 'feed_widgets/feed_media.dart';
part 'feed_widgets/feed_route_map.dart';
part 'feed_widgets/feed_stats.dart';

/// FeedPage에서 특정 게시글의 전체 댓글 수를 실시간으로 감시합니다.
///
/// WorkoutFinishRepo에 추가한 watchCommentsCount()를 사용하므로
/// 댓글 목록 조회 제한과 관계없이 부모 게시글의 commentsCount가 표시됩니다.
final feedPageCommentsCountProvider =
    StreamProvider.autoDispose.family<int, String>(
  (ref, workoutFinishId) {
    final id = workoutFinishId.trim();

    if (id.isEmpty) {
      return Stream<int>.value(0);
    }

    final repo = ref.watch(
      workoutFinishRepoProvider,
    );

    return repo.watchCommentsCount(
      workoutFinishId: id,
    );
  },
);

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
  void didUpdateWidget(covariant FeedPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.workoutFinish != widget.workoutFinish) {
      _workoutFinish = widget.workoutFinish;
    }
  }

  Future<void> _openComments(
    WorkoutFinish workoutFinish,
  ) async {
    final workoutFinishId =
        workoutFinish.workoutId?.trim();

    if (workoutFinishId == null ||
        workoutFinishId.isEmpty) {
      showAppSnackBar(
        context,
        message: '게시글 정보를 찾을 수 없습니다.',
        icon: Icons.error_outline_rounded,
        isError: true,
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) {
          return FeedCommentPage(
            workoutFinishId: workoutFinishId,
            postOwnerUid: workoutFinish.userId,
            initialCommentsCount:
                workoutFinish.commentsCount,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutFinishId =
        _workoutFinish.workoutId?.trim() ?? '';

    final commentsCountAsync = ref.watch(
      feedPageCommentsCountProvider(
        workoutFinishId,
      ),
    );

    final commentsCount = commentsCountAsync.maybeWhen(
      data: (value) => value,
      orElse: () => _workoutFinish.commentsCount,
    );

    final currentWorkoutFinish =
        _workoutFinish.copyWith(
      commentsCount: commentsCount,
    );

    final userAsync = ref.watch(
      userAuthDataProvider(
        currentWorkoutFinish.userId,
      ),
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
        actions: [
          _FeedCommentButton(
            commentsCount: commentsCount,
            onPressed: () {
              _openComments(
                currentWorkoutFinish,
              );
            },
          ),
          const SizedBox(width: 4),
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
                  bottom:
                      MediaQuery.paddingOf(context).bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: FeedCard(
                    availableHeight:
                        constraints.maxHeight,
                    postOwnerUid:
                        currentWorkoutFinish.userId,
                    displayName: user.displayName,
                    email: user.email,
                    userProfileUrl:
                        user.profileImageUrl,
                    workoutFinish:
                        currentWorkoutFinish,
                    onUpdated:
                        (updatedWorkoutFinish) {
                      if (!mounted) {
                        return;
                      }

                      setState(() {
                        _workoutFinish =
                            updatedWorkoutFinish.copyWith(
                          commentsCount:
                              commentsCount,
                        );
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
        error: (error, stackTrace) {
          debugPrint(
            'FeedPage user load error: $error',
          );

          debugPrintStack(
            stackTrace: stackTrace,
          );

          return Center(
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
          );
        },
      ),
    );
  }
}

class _FeedCommentButton extends StatelessWidget {
  final int commentsCount;
  final VoidCallback onPressed;

  const _FeedCommentButton({
    required this.commentsCount,
    required this.onPressed,
  });

  static const Color _backgroundColor = Color(0xFF000000);
  static const Color _primaryTextColor = Color(0xFFFFFFFF);
  static const Color _accentColor = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final countText = commentsCount > 999
        ? '999+'
        : commentsCount.toString();

    return IconButton(
      tooltip: '댓글 보기',
      onPressed: onPressed,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            color: _primaryTextColor,
            size: 23,
          ),
          if (commentsCount > 0)
            Positioned(
              top: -8,
              right: -11,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: _accentColor,
                  borderRadius:
                      BorderRadius.circular(999),
                  border: Border.all(
                    color: _backgroundColor,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  countText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _primaryTextColor,
                    fontSize: 9.5,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

bool _isValidNetworkImageUrl(String? url) {
  final value = url?.trim();

  if (value == null || value.isEmpty) {
    return false;
  }

  final uri = Uri.tryParse(value);

  if (uri == null || uri.host.isEmpty) {
    return false;
  }

  return uri.scheme == 'http' ||
      uri.scheme == 'https';
}