import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/Home_page/home_widget/RecentRecords/RecentRecords.dart';
import 'package:home_function/Home_page/home_widget/TopProfileCard/Top_Profile_card.dart';
import 'package:home_function/Home_page/home_widget/month_goal/month_goal_provider.dart';
import 'package:home_function/Home_page/home_widget/statsRow/statsRow.dart';
import 'package:home_function/Home_page/page/home_ranking_page.dart';
import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/block/blockUser_provider.dart';
import 'package:home_function/calendar/calendar_page.dart';
import 'package:home_function/core/firebase.dart';
import 'package:home_function/reports/reports_provider.dart';
import 'package:home_function/workout_finish/workout_finish/workout_finish_provider.dart';

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
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _danger = Color(0xFFFF6B6B);
  static const Color _accent = Color(0xFF5DADEC);

  bool _isBlocking = false;
  bool _isReporting = false;

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

  Stream<bool> _watchIsFollowing({
    required String? myUid,
    required String targetUid,
  }) {
    if (myUid == null || myUid.isEmpty) {
      return Stream<bool>.value(false);
    }

    if (myUid == targetUid) {
      return Stream<bool>.value(true);
    }

    final db = ref.read(firestoreProvider);

    return db
        .collection('users')
        .doc(myUid)
        .collection('followings')
        .doc(targetUid)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Stream<bool> _watchIsHiddenByReport({
    required String? myUid,
    required String targetUid,
  }) {
    if (myUid == null || myUid.isEmpty) {
      return Stream<bool>.value(false);
    }

    if (myUid == targetUid) {
      return Stream<bool>.value(false);
    }

    final db = ref.read(firestoreProvider);
    final hiddenKey = 'user_$targetUid';

    return db
        .collection('users')
        .doc(myUid)
        .collection('hiddenContent')
        .doc(hiddenKey)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return false;
      }

      final data = snapshot.data();

      if (data == null) {
        return true;
      }

      final targetType = data['targetType'];
      final targetId = data['targetId'];
      final source = data['source'];

      return targetType == 'user' &&
          targetId == targetUid &&
          source == 'report';
    });
  }

  void _showSnackBar({
    required String message,
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
          duration: const Duration(seconds: 2),
          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isError
                  ? const Color(0xFF4A1E24)
                  : const Color(0xFF12333A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isError
                    ? _danger.withAlpha(150)
                    : const Color(0xFF64D2C8).withAlpha(150),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isError
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_rounded,
                  color: isError ? _danger : const Color(0xFF64D2C8),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: _primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  Future<bool> _showBlockConfirmDialog({
    required String displayName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(
              color: _line,
              width: 0.8,
            ),
          ),
          title: const Text(
            '사용자를 차단할까요?',
            style: TextStyle(
              color: _primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            '$displayName님을 차단하면 서로의 프로필, 게시물, 운동 기록을 볼 수 없고 팔로우가 해제됩니다.',
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                '취소',
                style: TextStyle(
                  color: _secondaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                '차단',
                style: TextStyle(
                  color: _danger,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _blockUser({
    required String targetDisplayName,
  }) async {
    if (_isBlocking || _isReporting) return;

    final confirmed = await _showBlockConfirmDialog(
      displayName: targetDisplayName,
    );

    if (!mounted || !confirmed) return;

    setState(() {
      _isBlocking = true;
    });

    try {
      final blockRepo = ref.read(blockRepositoryProvider);

      await blockRepo.blockUser(
        targetUid: widget.userId,
      );

      if (!mounted) return;

      ref.invalidate(myBlockedUserIdsProvider);
      ref.invalidate(isBlockedByMeProvider(widget.userId));
      ref.invalidate(isBlockedEitherWayProvider(widget.userId));
      ref.invalidate(userAuthDataProvider(widget.userId));
      ref.invalidate(workoutFinishListProvider(widget.userId));

      _showSnackBar(
        message: '사용자를 차단했습니다.',
      );

      if (context.canPop()) {
        context.pop();
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        message: e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBlocking = false;
        });
      }
    }
  }

  Future<void> _showReportBottomSheet({
    required String targetDisplayName,
  }) async {
    if (_isReporting || _isBlocking) return;

    const reasons = <String, String>{
      'spam': '스팸 또는 광고',
      'harassment': '괴롭힘 또는 비방',
      'hate': '혐오 표현',
      'sexual': '선정적인 콘텐츠',
      'violence': '폭력적인 콘텐츠',
      'privacy': '개인정보 노출',
      'illegal': '불법 또는 위험한 행위',
      'other': '기타',
    };

    String selectedReason = 'spam';
    bool isSubmitting = false;
    final reasonController = TextEditingController();

    final submittedMessage = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(173),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            Future<void> submitReport() async {
              if (isSubmitting) return;

              setModalState(() {
                isSubmitting = true;
              });

              if (mounted) {
                setState(() {
                  _isReporting = true;
                });
              }

              try {
                final result = await ref.read(
                  createReportProvider(
                    targetType: 'user',
                    targetId: widget.userId,
                    reasonCode: selectedReason,
                    reasonText: reasonController.text.trim(),
                  ).future,
                );

                if (!sheetContext.mounted) return;

                Navigator.of(
                  sheetContext,
                  rootNavigator: true,
                ).pop(
                  result.alreadyReported
                      ? '이미 신고한 사용자입니다.'
                      : '신고가 접수되었습니다.',
                );
              } catch (e, st) {
                debugPrint('createReport user report error: $e');
                debugPrint('createReport user report stackTrace: $st');

                if (!modalContext.mounted) return;

                final message = e
                    .toString()
                    .replaceFirst('Exception: ', '')
                    .trim();

                _showSnackBar(
                  message: message.isEmpty
                      ? '신고에 실패했습니다. 잠시 후 다시 시도해주세요.'
                      : message,
                  isError: true,
                );

                setModalState(() {
                  isSubmitting = false;
                });

                if (mounted) {
                  setState(() {
                    _isReporting = false;
                  });
                }
              }
            }

            return PopScope(
              canPop: !isSubmitting,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(modalContext).viewInsets.bottom + 14,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _line,
                        width: 0.8,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 38,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A40),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            '신고하기',
                            style: TextStyle(
                              color: _primaryText,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$targetDisplayName님을 신고하는 이유를 선택해주세요. 접수된 신고는 검토 후 처리됩니다.',
                            style: const TextStyle(
                              color: _secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              color: _surfaceSoft,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _line,
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              children: reasons.entries.map((entry) {
                                final isSelected =
                                    selectedReason == entry.key;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: isSubmitting
                                      ? null
                                      : () {
                                          setModalState(() {
                                            selectedReason = entry.key;
                                          });
                                        },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 13,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_off,
                                          color: isSelected
                                              ? _accent
                                              : _secondaryText,
                                          size: 21,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? _primaryText
                                                  : _secondaryText,
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          if (selectedReason == 'other') ...[
                            const SizedBox(height: 14),
                            TextField(
                              controller: reasonController,
                              enabled: !isSubmitting,
                              maxLength: 300,
                              maxLines: 3,
                              style: const TextStyle(
                                color: _primaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: '신고 내용을 입력해주세요.',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF77777D),
                                  fontWeight: FontWeight.w500,
                                ),
                                counterStyle: const TextStyle(
                                  color: Color(0xFF77777D),
                                ),
                                filled: true,
                                fillColor: _surfaceSoft,
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _line,
                                    width: 0.8,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _line,
                                    width: 0.8,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _accent,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: TextButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () {
                                            Navigator.of(
                                              sheetContext,
                                              rootNavigator: true,
                                            ).pop();
                                          },
                                    style: TextButton.styleFrom(
                                      foregroundColor: _secondaryText,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: const BorderSide(
                                          color: _line,
                                          width: 0.8,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      '취소',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed:
                                        isSubmitting ? null : submitReport,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _danger,
                                      foregroundColor: _primaryText,
                                      disabledBackgroundColor:
                                          _danger.withAlpha(90),
                                      disabledForegroundColor:
                                          _primaryText.withAlpha(150),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: isSubmitting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: _primaryText,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            '신고 접수',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    reasonController.dispose();

    if (!mounted) return;

    setState(() {
      _isReporting = false;
    });

    if (submittedMessage != null && submittedMessage.isNotEmpty) {
      _showSnackBar(
        message: submittedMessage,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;

    if (currentUser == null) {
      return const _RedirectToLogin();
    }

    final myUid = currentUser.uid;
    final isMe = myUid == widget.userId;
    final userAsync = ref.watch(userAuthDataProvider(widget.userId));

    return userAsync.when(
      data: (user) {
        if (user == null) {
          if (isMe) {
            return const _SignOutAndRedirectToLogin();
          }

          return _MessageScaffold(
            icon: Icons.person_off_outlined,
            title: '사용자 정보를 찾을 수 없습니다',
            message: '삭제되었거나 존재하지 않는 사용자입니다.',
            buttonText: '뒤로가기',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/login');
              }
            },
          );
        }

        final shouldWatchBlock = !isMe;
        final blockAsync = shouldWatchBlock
            ? ref.watch(isBlockedEitherWayProvider(widget.userId))
            : const AsyncData<bool>(false);

        return blockAsync.when(
          data: (isBlocked) {
            return StreamBuilder<bool>(
              stream: _watchIsFollowing(
                myUid: myUid,
                targetUid: widget.userId,
              ),
              initialData: isMe,
              builder: (context, followSnapshot) {
                final isFollowing = followSnapshot.data ?? false;

                return StreamBuilder<bool>(
                  stream: _watchIsHiddenByReport(
                    myUid: myUid,
                    targetUid: widget.userId,
                  ),
                  initialData: false,
                  builder: (context, hiddenSnapshot) {
                    final isHiddenByReport = hiddenSnapshot.data ?? false;
                    final isPrivate = user.isPrivate == true;
                    final isPrivateLocked =
                        !isMe && isPrivate && !isFollowing;
                    final isRestricted = isBlocked ||
                        isPrivateLocked ||
                        isHiddenByReport;

                    return _buildHomeScaffold(
                      context: context,
                      user: user,
                      isMe: isMe,
                      isBlocked: isBlocked,
                      isPrivateLocked: isPrivateLocked,
                      isHiddenByReport: isHiddenByReport,
                      isRestricted: isRestricted,
                    );
                  },
                );
              },
            );
          },
          loading: () {
            return const _LoadingScaffold();
          },
          error: (e, st) {
            debugPrint('HomePage block check error: $e');
            debugPrint('HomePage block check stackTrace: $st');

            return _MessageScaffold(
              icon: Icons.error_outline_rounded,
              title: '에러가 발생했습니다',
              message: '프로필 접근 상태를 확인하지 못했습니다.',
              buttonText: '다시 불러오기',
              onPressed: () {
                ref.invalidate(isBlockedEitherWayProvider(widget.userId));
                ref.invalidate(userAuthDataProvider(widget.userId));
              },
            );
          },
        );
      },
      loading: () {
        return const _LoadingScaffold();
      },
      error: (e, st) {
        debugPrint('HomePage userAuthDataProvider error: $e');
        debugPrint('HomePage userAuthDataProvider stackTrace: $st');

        return _MessageScaffold(
          icon: Icons.error_outline_rounded,
          title: '에러가 발생했습니다',
          message: '사용자 정보를 불러오지 못했습니다.',
          buttonText: '다시 불러오기',
          onPressed: () {
            ref.invalidate(userAuthDataProvider(widget.userId));
          },
        );
      },
    );
  }

  Widget _buildHomeScaffold({
    required BuildContext context,
    required dynamic user,
    required bool isMe,
    required bool isBlocked,
    required bool isPrivateLocked,
    required bool isHiddenByReport,
    required bool isRestricted,
  }) {
    final media = MediaQuery.of(context);
    final contentPadding = _contentPadding(context);

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
        leadingWidth: 54,
        leading: isMe
            ? null
            : _BackIconButton(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              ),
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
          if (!isRestricted)
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
            )
          else if (!isRestricted)
            PopupMenuButton<String>(
              tooltip: '메뉴',
              enabled: !_isBlocking && !_isReporting,
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
              onSelected: (value) async {
                if (value == 'report') {
                  await _showReportBottomSheet(
                    targetDisplayName: user.displayName,
                  );
                  return;
                }

                if (value == 'block') {
                  await _blockUser(
                    targetDisplayName: user.displayName,
                  );
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 20,
                          color: _primaryText,
                        ),
                        SizedBox(width: 12),
                        Text(
                          '신고하기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuDivider(
                    height: 0.7,
                  ),
                  PopupMenuItem(
                    value: 'block',
                    child: Row(
                      children: [
                        Icon(
                          Icons.block_rounded,
                          size: 20,
                          color: _danger,
                        ),
                        SizedBox(width: 12),
                        Text(
                          '차단하기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: _isBlocking || _isReporting
                      ? const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: _primaryText,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : const Icon(
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
            ref.invalidate(isBlockedByMeProvider(widget.userId));
            ref.invalidate(isBlockedEitherWayProvider(widget.userId));
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
                        isRestricted: isRestricted,
                        isBlocked: isBlocked,
                        isPrivateLocked: isPrivateLocked,
                      ),
                      const SizedBox(height: 14),
                      if (isRestricted)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: contentPadding,
                          ),
                          child: RestrictedProfileView(
                            displayName: user.displayName,
                          ),
                        )
                      else ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: contentPadding,
                          ),
                          child: StatsRow(userId: widget.userId),
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: contentPadding,
                          ),
                          child: SectionFrame(
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
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class RestrictedProfileView extends StatelessWidget {
  final String displayName;

  const RestrictedProfileView({
    super.key,
    required this.displayName,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 34),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: _surfaceSoft,
              shape: BoxShape.circle,
              border: Border.all(
                color: _line,
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.lock_outline_rounded,
              color: _primaryText,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '비공개 계정입니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.25,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '이 사용자의 프로필과 운동 기록은 볼 수 없습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _RedirectToLogin extends StatefulWidget {
  const _RedirectToLogin();

  @override
  State<_RedirectToLogin> createState() => _RedirectToLoginState();
}

class _RedirectToLoginState extends State<_RedirectToLogin> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _LoadingScaffold();
  }
}

class _SignOutAndRedirectToLogin extends ConsumerStatefulWidget {
  const _SignOutAndRedirectToLogin();

  @override
  ConsumerState<_SignOutAndRedirectToLogin> createState() {
    return _SignOutAndRedirectToLoginState();
  }
}

class _SignOutAndRedirectToLoginState
    extends ConsumerState<_SignOutAndRedirectToLogin> {
  bool _started = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _signOutAndRedirect();
    });
  }

  Future<void> _signOutAndRedirect() async {
    if (_started) return;

    _started = true;

    try {
      await ref.read(firebaseAuthProvider).signOut();
    } catch (e, st) {
      debugPrint('HomePage signOut after missing user document error: $e');
      debugPrint('HomePage signOut stackTrace: $st');
    }

    if (!mounted) return;

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return const _LoadingScaffold();
  }
}

class _MessageScaffold extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onPressed;

  const _MessageScaffold({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onPressed,
  });

  static const Color _bg = Color(0xFF000000);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: _primaryText,
                  size: 34,
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _primaryText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: onPressed,
                  child: Text(
                    buttonText,
                    style: const TextStyle(
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
}

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  static const Color _bg = Color(0xFF000000);
  static const Color _primaryText = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
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
  }
}

class _BackIconButton extends StatelessWidget {
  const _BackIconButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  static const Color _primaryText = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: IconButton(
        tooltip: '뒤로가기',
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
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: _primaryText,
          size: 22,
        ),
      ),
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