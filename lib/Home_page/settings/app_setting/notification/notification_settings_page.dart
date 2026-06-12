import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';

class NotificationSettingsPage extends ConsumerWidget {
  const NotificationSettingsPage({super.key});

  static const Color _bg = Color(0xFF0B0F14);
  static const Color _card = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

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
  }

  Future<void> _updateAllSettings({
    required String uid,
    required bool value,
  }) async {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(myUidProvider);

    if (uid == null) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: Text(
            '로그인이 필요합니다.',
            style: TextStyle(color: _primaryText),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '알림 설정',
          style: TextStyle(
            color: _primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: _primaryText,
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _settingsStream(uid),
        builder: (context, snapshot) {
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

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              const _SectionTitle(title: '전체'),
              _SettingCard(
                children: [
                  _NotificationSwitchTile(
                    icon: Icons.notifications_active_outlined,
                    title: '전체 알림',
                    subtitle: 'SUPANOVA의 모든 알림을 받을지 설정합니다.',
                    value: allNotifications,
                    onChanged: (value) {
                      _updateAllSettings(
                        uid: uid,
                        value: value,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const _SectionTitle(title: '활동 알림'),
              _SettingCard(
                children: [
                  _NotificationSwitchTile(
                    icon: Icons.favorite_border_rounded,
                    title: '좋아요 알림',
                    subtitle: '내 운동 기록에 좋아요가 달리면 알림을 받습니다.',
                    value: likeNotifications,
                    enabled: allNotifications,
                    onChanged: (value) {
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
                    value: followNotifications,
                    enabled: allNotifications,
                    onChanged: (value) {
                      _updateSetting(
                        uid: uid,
                        key: 'followNotifications',
                        value: value,
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                '알림 설정은 저장되지만, 실제 푸시 알림은 추후 업데이트에서 제공될 수 있습니다.',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 13,
          fontWeight: FontWeight.w800,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NotificationSettingsPage._card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: children,
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
  final ValueChanged<bool> onChanged;

  const _NotificationSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final itemOpacity = enabled ? 1.0 : 0.45;

    return Opacity(
      opacity: itemOpacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: NotificationSettingsPage._blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: NotificationSettingsPage._blue,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: NotificationSettingsPage._primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: NotificationSettingsPage._secondaryText,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeThumbColor: NotificationSettingsPage._blue,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.white.withValues(alpha: 0.06),
    );
  }
}