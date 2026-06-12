import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';

class PrivacySettingsPage extends ConsumerWidget {
  const PrivacySettingsPage({super.key});

  static const Color _bg = Color(0xFF0B0F14);
  static const Color _card = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);
  static const Color _red = Color(0xFFFF6B6B);

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Future<void> _updatePrivateSetting({
    required String uid,
    required bool value,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'isPrivate': value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  bool _getIsPrivate(Map<String, dynamic>? data) {
    final value = data?['isPrivate'];

    if (value is bool) {
      return value;
    }

    return false;
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
          '공개 범위',
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
        stream: _userStream(uid),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();
          final isPrivate = _getIsPrivate(data);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              const _SectionTitle(title: '계정 공개 범위'),

              _PrivacyCard(
                children: [
                  _PrivacySwitchTile(
                    icon: Icons.lock_outline_rounded,
                    title: '비공개 계정',
                    subtitle: '비공개 계정으로 설정하면 다른 사용자가 내 운동 기록과 프로필 정보를 제한적으로 보게 됩니다.',
                    value: isPrivate,
                    onChanged: (value) async {
                      try {
                        await _updatePrivateSetting(
                          uid: uid,
                          value: value,
                        );
                      } catch (_) {
                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('공개 범위 설정을 저장하지 못했습니다.'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _InfoBox(
                isPrivate: isPrivate,
              ),

              const SizedBox(height: 20),

              const Text(
                '현재 공개 범위 설정은 계정 단위로 적용됩니다. 운동 기록별 공개 범위 설정은 추후 업데이트에서 제공될 수 있습니다.',
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
    return const Padding(
      padding: EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        '계정 공개 범위',
        style: TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 13,
          fontWeight: FontWeight.w800,
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PrivacySettingsPage._card,
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

class _PrivacySwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PrivacySwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        value ? PrivacySettingsPage._red : PrivacySettingsPage._blue;

    return Padding(
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
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
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
                    color: PrivacySettingsPage._primaryText,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: PrivacySettingsPage._secondaryText,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: PrivacySettingsPage._red,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final bool isPrivate;

  const _InfoBox({
    required this.isPrivate,
  });

  @override
  Widget build(BuildContext context) {
    final title = isPrivate ? '현재 비공개 계정입니다.' : '현재 공개 계정입니다.';

    final description = isPrivate
        ? '내 프로필과 운동 기록은 제한적으로 표시됩니다. 추후 팔로워 승인 기능이 추가되면 팔로워에게만 공개할 수 있습니다.'
        : '다른 사용자가 내 프로필과 운동 기록을 볼 수 있습니다.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPrivate
                ? Icons.visibility_off_outlined
                : Icons.public_rounded,
            color: isPrivate
                ? PrivacySettingsPage._red
                : PrivacySettingsPage._blue,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: PrivacySettingsPage._primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: PrivacySettingsPage._secondaryText,
                    fontSize: 12.5,
                    height: 1.45,
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