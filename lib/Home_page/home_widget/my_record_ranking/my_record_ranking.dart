import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyRecordRanking extends ConsumerWidget {
  final String userId;
  final bool isMe;
  const MyRecordRanking({
    super.key,
    required this.userId,
    required this.isMe,
  });

  static const _primaryText = Color(0xFF2B2F33);
  static const _secondaryText = Color(0xFF6B7280);
  static const _accentColor = Color(0xFF4F7CF7);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container();
  }
}