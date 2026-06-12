import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 52,
        title: const Text(
          '설정',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
        leading: IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _primaryText,
            size: 20,
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
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            0,
            12,
            0,
            28 + media.padding.bottom,
          ),
          children: [
            const _SectionTitle(title: '계정'),
            _SettingGroup(
              children: [
                _SettingTile(
                  icon: Icons.person_outline_rounded,
                  title: '프로필 수정',
                  subtitle: '닉네임, 프로필 사진 변경',
                  onTap: () {
                    context.push('/settings-edit-profile');
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            const _SectionTitle(title: '앱 설정'),
            _SettingGroup(
              children: [
                _SettingTile(
                  icon: Icons.notifications_none_rounded,
                  title: '알림 설정',
                  subtitle: '좋아요, 팔로우 알림',
                  onTap: () {
                    context.push('/settings-notification');
                  },
                ),
                const _GroupDivider(),
                _SettingTile(
                  icon: Icons.visibility_outlined,
                  title: '공개 범위',
                  subtitle: '계정 공개 여부 설정',
                  onTap: () {
                    context.push('/settings-privacy');
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            const _SectionTitle(title: '고객지원'),
            _SettingGroup(
              children: [
                _SettingTile(
                  icon: Icons.mail_outline_rounded,
                  title: '문의하기',
                  subtitle: '문제 신고 및 의견 보내기',
                  onTap: () {
                    context.push('/settings-contact');
                  },
                ),
                const _GroupDivider(),
                _SettingTile(
                  icon: Icons.description_outlined,
                  title: '이용약관 및 개인정보처리방침',
                  subtitle: '서비스 정책 확인',
                  onTap: () {
                    context.push('/terms-privacy');
                  },
                ),
              ],
            ),

            const SizedBox(height: 22),

            const _SectionTitle(title: '계정 관리'),
            _SettingGroup(
              children: [
                _SettingTile(
                  icon: Icons.logout_rounded,
                  title: '로그아웃',
                  subtitle: '현재 계정에서 로그아웃',
                  iconColor: _accent,
                  onTap: () {
                    _showLogoutSheet(context, ref);
                  },
                ),
                const _GroupDivider(),
                _SettingTile(
                  icon: Icons.delete_forever_outlined,
                  title: '회원 탈퇴',
                  subtitle: '계정과 데이터 삭제',
                  iconColor: _danger,
                  titleColor: _danger,
                  onTap: () {
                    context.push('/settings-delete-account');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showLogoutSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.68),
      builder: (sheetContext) {
        return _ConfirmSheet(
          icon: Icons.logout_rounded,
          iconColor: _accent,
          title: '로그아웃',
          message: '정말 현재 계정에서 로그아웃 하시겠습니까?',
          confirmText: '로그아웃',
          confirmColor: _accent,
          onCancel: () {
            Navigator.of(sheetContext, rootNavigator: true).pop(false);
          },
          onConfirm: () {
            Navigator.of(sheetContext, rootNavigator: true).pop(true);
          },
        );
      },
    );

    if (result != true) return;

    try {
      await ref.read(userSignOutProvider.future);

      if (!context.mounted) return;
      context.go('/login');
    } catch (_) {
      if (!context.mounted) return;

      showAppSnackBar(
        context,
        message: '로그아웃에 실패했습니다. 다시 시도해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 9),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _SettingGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingGroup({
    required this.children,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.titleColor,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final pointColor = iconColor ?? _accent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
          child: Row(
            children: [
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: pointColor.withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: pointColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: titleColor ?? _primaryText,
                        fontSize: 14.8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _surfaceSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _line,
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: _secondaryText,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: _line,
      height: 0.7,
      thickness: 0.7,
      indent: 66,
      endIndent: 12,
    );
  }
}

class _ConfirmSheet extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String confirmText;
  final Color confirmColor;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmSheet({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.confirmColor,
    required this.onCancel,
    required this.onConfirm,
  });

  static const Color _bg = Color(0xFF000000);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = math.min(media.size.width - 16, 460.0);

    return SafeArea(
      top: false,
      child: Container(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            decoration: const BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
                bottom: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: _line, width: 0.8),
                left: BorderSide(color: _line, width: 0.8),
                right: BorderSide(color: _line, width: 0.8),
                bottom: BorderSide(color: _line, width: 0.8),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                18,
                10,
                18,
                14 + media.padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A40),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 29,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _primaryText,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 14,
                      height: 1.42,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 22),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final narrow = constraints.maxWidth < 310;

                      final cancelButton = SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryText,
                            side: const BorderSide(
                              color: _line,
                              width: 0.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      );

                      final confirmButton = SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: onConfirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: confirmColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            confirmText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      );

                      if (narrow) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: confirmButton,
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: cancelButton,
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: cancelButton),
                          const SizedBox(width: 10),
                          Expanded(child: confirmButton),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}