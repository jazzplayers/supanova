import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _blue = Color(0xFF5DADEC);

  final Set<String> _updatingKeys = {};

  bool get _isUpdating => _updatingKeys.isNotEmpty;

  bool _isKeyUpdating(String key) {
    return _updatingKeys.contains(key);
  }

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

  Stream<DocumentSnapshot<Map<String, dynamic>>> _settingsStream(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications')
        .snapshots();
  }

  Future<void> _updateSetting({
    required String uid,
    required String key,
    required bool value,
  }) async {
    if (_isUpdating) return;

    setState(() {
      _updatingKeys.add(key);
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('notifications')
          .set(
        {
          key: value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '알림 설정을 저장하지 못했습니다. 다시 시도해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingKeys.remove(key);
        });
      }
    }
  }

  Future<void> _updateAllSettings({
    required String uid,
    required bool value,
  }) async {
    if (_isUpdating) return;

    setState(() {
      _updatingKeys.addAll([
        'allNotifications',
        'likeNotifications',
        'followNotifications',
      ]);
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('settings')
          .doc('notifications')
          .set(
        {
          'allNotifications': value,
          'likeNotifications': value,
          'followNotifications': value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '알림 설정을 저장하지 못했습니다. 다시 시도해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingKeys.clear();
        });
      }
    }
  }

  bool _getBool(
    Map<String, dynamic>? data,
    String key, {
    bool defaultValue = true,
  }) {
    final value = data?[key];

    if (value is bool) {
      return value;
    }

    return defaultValue;
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
        '알림 설정',
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
            message: '알림 설정을 변경하려면 먼저 로그인해주세요.',
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
            stream: _settingsStream(uid),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const _StateMessage(
                  icon: Icons.error_outline_rounded,
                  title: '알림 설정을 불러오지 못했습니다',
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

              final allNotifications = _getBool(
                data,
                'allNotifications',
                defaultValue: true,
              );

              final likeNotifications = _getBool(
                data,
                'likeNotifications',
                defaultValue: true,
              );

              final followNotifications = _getBool(
                data,
                'followNotifications',
                defaultValue: true,
              );

              final effectiveLikeNotifications =
                  allNotifications && likeNotifications;

              final effectiveFollowNotifications =
                  allNotifications && followNotifications;

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
                      const _SectionTitle(title: '전체'),
                      _SettingCard(
                        children: [
                          _NotificationSwitchTile(
                            icon: Icons.notifications_active_outlined,
                            title: '전체 알림',
                            subtitle: 'SUPANOVA의 모든 알림을 받을지 설정합니다.',
                            value: allNotifications,
                            isUpdating: _isKeyUpdating('allNotifications'),
                            onChanged: _isUpdating
                                ? null
                                : (value) {
                                    _updateAllSettings(
                                      uid: uid,
                                      value: value,
                                    );
                                  },
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const _SectionTitle(title: '활동 알림'),
                      _SettingCard(
                        children: [
                          _NotificationSwitchTile(
                            icon: Icons.favorite_border_rounded,
                            title: '좋아요 알림',
                            subtitle: '내 운동 기록에 좋아요가 달리면 알림을 받습니다.',
                            value: effectiveLikeNotifications,
                            enabled: allNotifications,
                            isUpdating: _isKeyUpdating('likeNotifications'),
                            onChanged: _isUpdating || !allNotifications
                                ? null
                                : (value) {
                                    _updateSetting(
                                      uid: uid,
                                      key: 'likeNotifications',
                                      value: value,
                                    );
                                  },
                          ),
                          const _Divider(),
                          _NotificationSwitchTile(
                            icon: Icons.person_add_alt_1_outlined,
                            title: '팔로우 알림',
                            subtitle: '새로운 팔로워가 생기면 알림을 받습니다.',
                            value: effectiveFollowNotifications,
                            enabled: allNotifications,
                            isUpdating: _isKeyUpdating('followNotifications'),
                            onChanged: _isUpdating || !allNotifications
                                ? null
                                : (value) {
                                    _updateSetting(
                                      uid: uid,
                                      key: 'followNotifications',
                                      value: value,
                                    );
                                  },
                          ),
                        ],
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

class _SettingCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingCard({
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

class _NotificationSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final bool isUpdating;
  final ValueChanged<bool>? onChanged;

  const _NotificationSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isUpdating,
    required this.onChanged,
    this.enabled = true,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final itemEnabled = enabled && onChanged != null;

    return Opacity(
      opacity: itemEnabled ? 1.0 : 0.52,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 15, 12, 15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: _blue,
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
                            color: itemEnabled ? _primaryText : _softText,
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
                      color: itemEnabled ? _secondaryText : _softText,
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
                activeThumbColor: _blue,
                activeTrackColor: _blue.withValues(alpha: 0.35),
                inactiveThumbColor: _softText,
                inactiveTrackColor: _softText.withValues(alpha: 0.25),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: itemEnabled ? onChanged : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

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
              '알림 설정은 저장됩니다. 실제 푸시 알림 기능은 앱 업데이트를 통해 순차적으로 제공될 수 있습니다.',
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