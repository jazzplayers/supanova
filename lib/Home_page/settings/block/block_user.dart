import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/block/blockUser_provider.dart';
import 'package:home_function/core/firebase.dart';
import 'package:home_function/widget/app_snack_bar.dart';

class BlockUserPage extends ConsumerStatefulWidget {
  const BlockUserPage({super.key});

  @override
  ConsumerState<BlockUserPage> createState() => _BlockUserPageState();
}

class _BlockUserPageState extends ConsumerState<BlockUserPage> {
  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  String? _unblockingUid;

  Future<bool> _showUnblockConfirmDialog({
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
            '차단을 해제할까요?',
            style: TextStyle(
              color: _primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            '$displayName님의 차단을 해제하면 다시 프로필과 운동 기록을 볼 수 있습니다.',
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
                '해제',
                style: TextStyle(
                  color: _accent,
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

  Future<void> _unblockUser({
    required String targetUid,
    required String displayName,
  }) async {
    if (_unblockingUid != null) return;

    final confirmed = await _showUnblockConfirmDialog(
      displayName: displayName,
    );

    if (!mounted || !confirmed) return;

    setState(() {
      _unblockingUid = targetUid;
    });

    try {
      final blockRepo = ref.read(blockRepositoryProvider);

      await blockRepo.unblockUser(
        targetUid: targetUid,
      );

      ref.invalidate(myBlockedUserIdsProvider);
      ref.invalidate(isBlockedByMeProvider(targetUid));
      ref.invalidate(isBlockedEitherWayProvider(targetUid));
      ref.invalidate(userAuthDataProvider(targetUid));

      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '차단을 해제했습니다.',
        icon: Icons.check_circle_rounded,
      );
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: e.toString().replaceFirst('Exception: ', ''),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _unblockingUid = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final db = ref.watch(firestoreProvider);

    if (myUid == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Center(
            child: Text(
              '로그인이 필요합니다.',
              style: TextStyle(
                color: _secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leadingWidth: 54,
        leading: IconButton(
          tooltip: '뒤로가기',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _primaryText,
            size: 22,
          ),
        ),
        title: const Text(
          '차단한 계정',
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
      body: SafeArea(
        top: false,
        child: StreamBuilder(
          stream: db
              .collection('users')
              .doc(myUid)
              .collection('blockedUsers')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const _BlockedMessageView(
                icon: Icons.error_outline_rounded,
                title: '차단 목록을 불러오지 못했습니다',
                message: '잠시 후 다시 시도해주세요.',
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(
                  color: _primaryText,
                  strokeWidth: 2,
                ),
              );
            }

            final docs = snapshot.data!.docs;

            if (docs.isEmpty) {
              return const _BlockedMessageView(
                icon: Icons.block_rounded,
                title: '차단한 계정이 없습니다',
                message: '차단한 사용자가 생기면 이곳에서 확인할 수 있습니다.',
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              itemCount: docs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final blockedUid = docs[index].id;

                return _BlockedUserTile(
                  userId: blockedUid,
                  isLoading: _unblockingUid == blockedUid,
                  onUnblock: _unblockUser,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _BlockedUserTile extends ConsumerWidget {
  final String userId;
  final bool isLoading;
  final Future<void> Function({
    required String targetUid,
    required String displayName,
  }) onUnblock;

  const _BlockedUserTile({
    required this.userId,
    required this.isLoading,
    required this.onUnblock,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userAuthDataProvider(userId));

    return userAsync.when(
      data: (user) {
        final displayName = user?.displayName ?? '알 수 없는 사용자';
        final profileImageUrl = user?.profileImageUrl;
        final hasProfileImage =
            profileImageUrl != null && profileImageUrl.isNotEmpty;

        return Container(
          padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _line,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1A1A1F),
                backgroundImage:
                    hasProfileImage ? NetworkImage(profileImageUrl!) : null,
                child: !hasProfileImage
                    ? const Icon(
                        Icons.person_rounded,
                        color: _secondaryText,
                        size: 26,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  displayName,
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
              const SizedBox(width: 10),
              SizedBox(
                height: 34,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          onUnblock(
                            targetUid: userId,
                            displayName: displayName,
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    disabledForegroundColor: _secondaryText,
                    side: const BorderSide(
                      color: _line,
                      width: 0.8,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: _accent,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '해제',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () {
        return Container(
          height: 72,
          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _line,
              width: 0.8,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: _primaryText,
              strokeWidth: 2,
            ),
          ),
        );
      },
      error: (e, st) {
        return Container(
          padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
          decoration: BoxDecoration(
            color: _surfaceSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _line,
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF1A1A1F),
                child: Icon(
                  Icons.person_off_rounded,
                  color: _secondaryText,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '사용자 정보를 불러오지 못했습니다',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 34,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          onUnblock(
                            targetUid: userId,
                            displayName: '사용자',
                          );
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _accent,
                    disabledForegroundColor: _secondaryText,
                    side: const BorderSide(
                      color: _line,
                      width: 0.8,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            color: _accent,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          '해제',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
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

class _BlockedMessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _BlockedMessageView({
    required this.icon,
    required this.title,
    required this.message,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _primaryText,
              size: 38,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}