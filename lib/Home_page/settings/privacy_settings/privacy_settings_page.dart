import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';

class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<PrivacySettingsPage> createState() =>
      _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends ConsumerState<PrivacySettingsPage> {
  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _blue = Color(0xFF5DADEC);
  static const Color _red = Color(0xFFE85D5D);

  bool _isUpdating = false;

  bool _isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  IconData _backIcon(BuildContext context) {
    return _isIOS(context)
        ? Icons.arrow_back_ios_new_rounded
        : Icons.arrow_back_rounded;
  }

  double _appBarHeight(BuildContext context) {
    return _isIOS(context) ? 52 : 56;
  }

  ScrollPhysics _scrollPhysics(BuildContext context) {
    return _isIOS(context)
        ? const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          )
        : const ClampingScrollPhysics();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Future<void> _updatePrivateSetting({
    required String uid,
    required bool value,
  }) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set(
        {
          'isPrivate': value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      if (!mounted) return;

      showAppSnackBar(
        context,
        message: value ? '비공개 계정으로 변경되었습니다.' : '공개 계정으로 변경되었습니다.',
        icon: Icons.check_circle_rounded,
      );
    } catch (_) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '공개 범위 설정을 저장하지 못했습니다. 다시 시도해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  bool _getIsPrivate(Map<String, dynamic>? data) {
    final value = data?['isPrivate'];

    if (value is bool) {
      return value;
    }

    return false;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isIOS = _isIOS(context);

    return AppBar(
      backgroundColor: _bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: _appBarHeight(context),
      leadingWidth: isIOS ? 52 : 56,
      title: const Text(
        '공개 범위',
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
        tooltip: '뒤로가기',
        visualDensity: VisualDensity.compact,
        onPressed: _isUpdating ? null : () => context.pop(),
        icon: Icon(
          _backIcon(context),
          color: _isUpdating ? _softText : _primaryText,
          size: isIOS ? 20 : 23,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(myUidProvider);
    final media = MediaQuery.of(context);
    final maxWidth = math.min(media.size.width, 720.0);

    if (uid == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(context),
        body: const SafeArea(
          top: false,
          child: _StateMessage(
            icon: Icons.lock_outline_rounded,
            title: '로그인이 필요합니다',
            message: '공개 범위를 설정하려면 먼저 로그인해주세요.',
          ),
        ),
      );
    }

    return PopScope(
      canPop: !_isUpdating,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(context),
        body: SafeArea(
          top: false,
          bottom: false,
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _userStream(uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const _StateMessage(
                  icon: Icons.error_outline_rounded,
                  title: '공개 범위를 불러오지 못했습니다',
                  message: '인터넷 연결을 확인한 뒤 다시 시도해주세요.',
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: _blue,
                    strokeWidth: 2.5,
                  ),
                );
              }

              final data = snapshot.data?.data();
              final isPrivate = _getIsPrivate(data);

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: maxWidth,
                  ),
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: _scrollPhysics(context),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      28 + media.padding.bottom,
                    ),
                    children: [
                      const _SectionTitle(title: '계정 공개 범위'),
                      _PrivacyCard(
                        children: [
                          _PrivacySwitchTile(
                            icon: isPrivate
                                ? Icons.lock_outline_rounded
                                : Icons.public_rounded,
                            title: '비공개 계정',
                            subtitle:
                                '켜면 내 프로필과 운동 기록이 다른 사용자에게 제한적으로 표시됩니다.',
                            value: isPrivate,
                            isUpdating: _isUpdating,
                            onChanged: _isUpdating
                                ? null
                                : (value) {
                                    _updatePrivateSetting(
                                      uid: uid,
                                      value: value,
                                    );
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _InfoBox(
                        isPrivate: isPrivate,
                      ),
                      const SizedBox(height: 16),
                      const _NoticeBox(),
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 0, 1, 9),
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

class _PrivacyCard extends StatelessWidget {
  final List<Widget> children;

  const _PrivacyCard({
    required this.children,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

class _PrivacySwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool isUpdating;
  final ValueChanged<bool>? onChanged;

  const _PrivacySwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isUpdating,
    required this.onChanged,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _blue = Color(0xFF5DADEC);
  static const Color _red = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context) {
    final pointColor = value ? _red : _blue;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 15, 12, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: pointColor.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: pointColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isUpdating ? _softText : _primaryText,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (isUpdating) ...[
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 13,
                          height: 13,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _blue,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isUpdating ? _softText : _secondaryText,
                      fontSize: 12.7,
                      height: 1.38,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.05,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _line,
                  width: 0.8,
                ),
              ),
              child: Switch.adaptive(
                value: value,
                activeThumbColor: _red,
                activeTrackColor: _red.withValues(alpha: 0.35),
                inactiveThumbColor: _blue,
                inactiveTrackColor: _blue.withValues(alpha: 0.22),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final bool isPrivate;

  const _InfoBox({
    required this.isPrivate,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _blue = Color(0xFF5DADEC);
  static const Color _red = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context) {
    final title = isPrivate ? '현재 비공개 계정입니다' : '현재 공개 계정입니다';

    final description = isPrivate
        ? '내 프로필과 운동 기록이 다른 사용자에게 제한적으로 표시됩니다.'
        : '다른 사용자가 내 프로필과 운동 기록을 볼 수 있습니다.';

    final icon = isPrivate ? Icons.visibility_off_outlined : Icons.public;
    final color = isPrivate ? _red : _blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 12.8,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox();

  static const Color _surface = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: _blue,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '현재 공개 범위 설정은 계정 전체에 적용됩니다. 운동 기록별 공개 범위 설정은 추후 업데이트에서 제공될 수 있습니다.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 12.7,
                height: 1.45,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = math.min(media.size.width - 32, 420.0);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _line,
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _blue.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _blue,
                  size: 28,
                ),
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
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}