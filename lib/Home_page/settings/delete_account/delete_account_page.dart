import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';

class DeleteAccountPage extends ConsumerStatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  ConsumerState<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends ConsumerState<DeleteAccountPage> {
  final TextEditingController _confirmController = TextEditingController();

  bool _isChecked = false;
  bool _isLoading = false;

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _danger = Color(0xFFE85D5D);

  bool get _canDelete {
    return _isChecked && _confirmController.text.trim() == '회원탈퇴';
  }

  bool _isCupertinoPlatform(BuildContext context) {
    final platform = Theme.of(context).platform;

    return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  }

  IconData _backIcon(BuildContext context) {
    return _isCupertinoPlatform(context)
        ? Icons.arrow_back_ios_new_rounded
        : Icons.arrow_back_rounded;
  }

  double _backIconSize(BuildContext context) {
    return _isCupertinoPlatform(context) ? 20 : 22;
  }

  ScrollPhysics _scrollPhysics(BuildContext context) {
    return _isCupertinoPlatform(context)
        ? const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          )
        : const ClampingScrollPhysics();
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleDeleteAccount() async {
    if (!_canDelete || _isLoading) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    Object? deleteError;

    try {
      ref.invalidate(deleteAccountProvider);
      await ref.read(deleteAccountProvider.future);
    } catch (e) {
      deleteError = e;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (deleteError != null) {
      final message = _parseDeleteAccountError(deleteError);

      showAppSnackBar(
        context,
        message: message,
        icon: Icons.error_rounded,
        isError: true,
      );
      return;
    }

    try {
      context.go('/login');
    } catch (_) {}
  }

  String _parseDeleteAccountError(Object error) {
    final raw = error.toString();

    if (raw.contains('unauthenticated') ||
        raw.contains('로그인이 필요') ||
        raw.contains('no-current-user')) {
      return '로그인이 필요합니다. 다시 로그인한 뒤 회원탈퇴를 진행해주세요.';
    }

    if (raw.contains('requires-recent-login') ||
        raw.contains('다시 로그인') ||
        raw.contains('recent-login')) {
      return '보안을 위해 다시 로그인한 뒤 회원탈퇴를 진행해주세요.';
    }

    if (raw.contains('permission-denied')) {
      return '탈퇴 요청을 처리할 수 없습니다. 잠시 후 다시 시도해주세요.';
    }

    if (raw.contains('deadline-exceeded') ||
        raw.contains('timeout') ||
        raw.contains('시간')) {
      return '탈퇴 처리 시간이 길어지고 있습니다. 잠시 후 다시 시도해주세요.';
    }

    if (raw.contains('network') || raw.contains('unavailable')) {
      return '인터넷 연결을 확인한 뒤 다시 시도해주세요.';
    }

    if (raw.contains('internal')) {
      return '탈퇴 처리 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
    }

    return '회원탈퇴에 실패했습니다. 잠시 후 다시 시도해주세요.';
  }

  void _showDeleteConfirmDialog() {
    if (!_canDelete || _isLoading) return;

    showDialog<void>(
      context: context,
      barrierDismissible: !_isLoading,
      useSafeArea: true,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(
              color: _line,
              width: 0.8,
            ),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          contentPadding: const EdgeInsets.fromLTRB(22, 12, 22, 4),
          actionsPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          actionsAlignment: MainAxisAlignment.end,
          title: const Text(
            '정말 탈퇴하시겠어요?',
            style: TextStyle(
              color: _primaryText,
              fontSize: 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          content: const Text(
            '탈퇴하면 계정, 프로필, 운동 기록, 피드, 사진, 팔로우 관계, 좋아요 기록이 삭제됩니다.\n\n'
            '삭제된 정보는 복구할 수 없습니다.',
            style: TextStyle(
              color: _secondaryText,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                    },
              child: const Text(
                '취소',
                style: TextStyle(
                  color: _secondaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.of(dialogContext).pop();
                      _handleDeleteAccount();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _danger,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(82, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '탈퇴하기',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleCheck() {
    if (_isLoading) return;

    setState(() {
      _isChecked = !_isChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          toolbarHeight: 52,
          leadingWidth: 56,
          leading: IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: _isLoading ? null : () => context.pop(),
            icon: Icon(
              _backIcon(context),
              color: _isLoading ? _softText : _primaryText,
              size: _backIconSize(context),
            ),
          ),
          title: const Text(
            '회원탈퇴',
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
        body: SafeArea(
          top: false,
          bottom: true,
          child: Stack(
            children: [
              ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: _scrollPhysics(context),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  24,
                ),
                children: [
                  const _WarningHeader(),
                  const SizedBox(height: 14),
                  const _InfoCard(
                    title: '탈퇴 전에 확인해주세요',
                    items: [
                      '회원탈퇴 후 계정과 이용 기록은 복구할 수 없습니다.',
                      '같은 이메일로 다시 가입하더라도 기존 기록은 이어지지 않을 수 있습니다.',
                      '사진과 운동 기록 등 관련 정보 정리에 시간이 걸릴 수 있습니다.',
                      '처리 중 인터넷 연결이 끊기면 탈퇴가 완료되지 않을 수 있습니다.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _InfoCard(
                    title: '삭제 처리되는 정보',
                    items: [
                      '로그인 계정 및 기본 회원 정보',
                      '닉네임, 자기소개, 프로필 사진 등 프로필 정보',
                      '내가 올린 운동 기록과 운동 피드',
                      '운동 피드에 첨부한 사진',
                      '팔로워와 팔로잉 관계',
                      '내가 누른 좋아요 기록',
                      '랭킹에 반영된 내 운동 기록',
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _DangerNoticeCard(),
                  const SizedBox(height: 18),
                  _CheckBoxCard(
                    isChecked: _isChecked,
                    isLoading: _isLoading,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                    onTap: _toggleCheck,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "아래 입력창에 '회원탈퇴'를 입력해주세요.",
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 9),
                  TextField(
                    controller: _confirmController,
                    enabled: !_isLoading,
                    cursorColor: _danger,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(
                      color: _primaryText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    onSubmitted: (_) {
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '회원탈퇴',
                      hintStyle: const TextStyle(
                        color: _softText,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: _surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: _line,
                          width: 0.8,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: _line,
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: _danger,
                          width: 1.1,
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: _line,
                          width: 0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _canDelete && !_isLoading
                          ? _showDeleteConfirmDialog
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _danger,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _surfaceSoft,
                        disabledForegroundColor: _softText,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.3,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '회원탈퇴',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    child: Text(
                      '취소하고 돌아가기',
                      style: TextStyle(
                        color: _isLoading ? _softText : _secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              if (_isLoading)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WarningHeader extends StatelessWidget {
  const _WarningHeader();

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _danger = Color(0xFFE85D5D);
  static const Color _dangerSoft = Color(0xFF2A1012);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
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
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: _dangerSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: _danger,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '회원탈퇴는 되돌릴 수 없습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '탈퇴를 진행하기 전에 삭제되는 정보를 꼭 확인해주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13.5,
              height: 1.42,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<String> items;

  const _InfoCard({
    required this.title,
    required this.items,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _danger = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
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
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1.5),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 17,
                      color: _danger,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 13.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerNoticeCard extends StatelessWidget {
  const _DangerNoticeCard();

  static const Color _surface = Color(0xFF160B0C);
  static const Color _line = Color(0xFF3A171A);
  static const Color _secondaryText = Color(0xFFD7A6A6);
  static const Color _danger = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context) {
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
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: _danger,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '탈퇴가 시작되면 관련 정보가 순차적으로 정리됩니다. 완료될 때까지 화면을 닫지 않는 것을 권장합니다.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 13.3,
                height: 1.42,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckBoxCard extends StatelessWidget {
  final bool isChecked;
  final bool isLoading;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTap;

  const _CheckBoxCard({
    required this.isChecked,
    required this.isLoading,
    required this.onChanged,
    required this.onTap,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _danger = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isChecked ? _danger.withValues(alpha: 0.65) : _line,
              width: 0.8,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isChecked,
                onChanged: isLoading ? null : onChanged,
                activeColor: _danger,
                checkColor: Colors.white,
                side: const BorderSide(
                  color: _secondaryText,
                  width: 1.2,
                ),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.padded,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 1),
                  child: Text(
                    '위 내용을 모두 확인했으며, 탈퇴 후 계정과 이용 기록을 복구할 수 없다는 점에 동의합니다.',
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 13.8,
                      height: 1.45,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}