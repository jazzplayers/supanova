import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';

class UserLoginPage extends ConsumerStatefulWidget {
  const UserLoginPage({super.key});

  @override
  ConsumerState<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends ConsumerState<UserLoginPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _blue = Color(0xFF5DADEC);

  bool _isEmailLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;

  bool get _isLoading => _isEmailLoading || _isGoogleLoading;

  bool _isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  ScrollPhysics _scrollPhysics(BuildContext context) {
    return _isIOS(context)
        ? const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          )
        : const ClampingScrollPhysics();
  }

  Future<void> logIn() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    final authRepo = ref.read(userAuthRepositoryProvider);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty && password.isEmpty) {
      _showLoginSnackBar(
        '이메일과 비밀번호를 입력해주세요.',
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    if (email.isEmpty) {
      _showLoginSnackBar(
        '이메일을 입력해주세요.',
        icon: Icons.mail_outline_rounded,
      );
      return;
    }

    if (!_isValidEmail(email)) {
      _showLoginSnackBar(
        '이메일 형식이 올바르지 않습니다.',
        icon: Icons.error_outline_rounded,
      );
      return;
    }

    if (password.isEmpty) {
      _showLoginSnackBar(
        '비밀번호를 입력해주세요.',
        icon: Icons.lock_outline_rounded,
      );
      return;
    }

    try {
      setState(() {
        _isEmailLoading = true;
      });

      await authRepo.userSignIn(
        email: email,
        password: password,
      );

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      _showLoginSnackBar(
        _parseEmailLoginError(e),
        icon: Icons.error_rounded,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isEmailLoading = false;
        });
      }
    }
  }

  Future<void> signInWithGoogle() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    try {
      setState(() {
        _isGoogleLoading = true;
      });

      ref.invalidate(signInWithGoogleProvider);

      await ref.read(signInWithGoogleProvider.future);

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      final message = _parseGoogleLoginError(e);

      if (message == null) return;

      _showLoginSnackBar(
        message,
        icon: Icons.error_rounded,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    ).hasMatch(email);
  }

  String _parseEmailLoginError(Object error) {
    String raw = error.toString().toLowerCase();

    if (error is FirebaseAuthException) {
      raw = error.code.toLowerCase();
    }

    if (raw.contains('invalid-email')) {
      return '이메일 형식이 올바르지 않습니다.';
    }

    if (raw.contains('invalid-credential') ||
        raw.contains('wrong-password') ||
        raw.contains('user-not-found')) {
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    }

    if (raw.contains('user-disabled')) {
      return '사용할 수 없는 계정입니다. 고객지원으로 문의해주세요.';
    }

    if (raw.contains('too-many-requests')) {
      return '로그인 시도가 너무 많습니다. 잠시 후 다시 시도해주세요.';
    }

    if (raw.contains('network-request-failed') ||
        raw.contains('network') ||
        raw.contains('unavailable')) {
      return '인터넷 연결을 확인한 뒤 다시 시도해주세요.';
    }

    if (raw.contains('operation-not-allowed')) {
      return '현재 이메일 로그인을 사용할 수 없습니다. 잠시 후 다시 시도해주세요.';
    }

    return '로그인에 실패했습니다. 이메일과 비밀번호를 다시 확인해주세요.';
  }

  String? _parseGoogleLoginError(Object error) {
    String raw = error.toString().toLowerCase();

    if (error is FirebaseAuthException) {
      raw = error.code.toLowerCase();
    }

    if (raw.contains('sign_in_canceled') ||
        raw.contains('cancel') ||
        raw.contains('popup_closed') ||
        raw.contains('로그인 취소')) {
      return null;
    }

    if (raw.contains('account-exists-with-different-credential')) {
      return '이미 다른 로그인 방식으로 가입된 이메일입니다.';
    }

    if (raw.contains('network-request-failed') ||
        raw.contains('network') ||
        raw.contains('unavailable')) {
      return '인터넷 연결을 확인한 뒤 다시 시도해주세요.';
    }

    if (raw.contains('permission-denied')) {
      return '구글 로그인을 처리하지 못했습니다. 잠시 후 다시 시도해주세요.';
    }

    if (raw.contains('user-disabled')) {
      return '사용할 수 없는 계정입니다. 고객지원으로 문의해주세요.';
    }

    return '구글 로그인에 실패했습니다. 잠시 후 다시 시도해주세요.';
  }

  void _showLoginSnackBar(
    String message, {
    IconData icon = Icons.error_rounded,
  }) {
    if (!mounted) return;

    showAppSnackBar(
      context,
      message: message,
      icon: icon,
      isError: true,
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Widget _dividerWithText(String text) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: _line,
            height: 0.7,
            thickness: 0.7,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.05,
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: _line,
            height: 0.7,
            thickness: 0.7,
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: _secondaryText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      prefixIcon: Icon(
        icon,
        color: _secondaryText,
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: _surfaceSoft,
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
          color: _blue,
          width: 1.2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: _line,
          width: 0.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final maxWidth = math.min(width - 32, 430.0);
    final compact = width < 360;
    final canTap = !_isLoading;

    return PopScope(
      canPop: !_isLoading,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: _bg,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            top: true,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: AutofillGroup(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    physics: _scrollPhysics(context),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      compact ? 18 : 24,
                      16,
                      26 + media.padding.bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _LogoHeader(
                          compact: compact,
                        ),
                        SizedBox(height: compact ? 30 : 38),
                        _LoginCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 52,
                                child: OutlinedButton.icon(
                                  onPressed:
                                      canTap ? signInWithGoogle : null,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: _surfaceSoft,
                                    foregroundColor: _primaryText,
                                    disabledForegroundColor: _softText,
                                    side: const BorderSide(
                                      color: _line,
                                      width: 0.8,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  icon: _isGoogleLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: _blue,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.login_rounded,
                                          color: _blue,
                                          size: 21,
                                        ),
                                  label: const Text(
                                    'Google로 계속하기',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 26),
                              _dividerWithText('또는 이메일로 로그인'),
                              const SizedBox(height: 22),
                              TextField(
                                controller: _emailCtrl,
                                focusNode: _emailFocusNode,
                                enabled: canTap,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.email,
                                  AutofillHints.username,
                                ],
                                autocorrect: false,
                                enableSuggestions: false,
                                style: const TextStyle(
                                  color: _primaryText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.1,
                                ),
                                cursorColor: _blue,
                                decoration: _inputDecoration(
                                  label: '이메일',
                                  icon: Icons.mail_outline_rounded,
                                ),
                                onSubmitted: (_) {
                                  _passwordFocusNode.requestFocus();
                                },
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordCtrl,
                                focusNode: _passwordFocusNode,
                                enabled: canTap,
                                obscureText: _obscurePassword,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.password,
                                ],
                                autocorrect: false,
                                enableSuggestions: false,
                                style: const TextStyle(
                                  color: _primaryText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.1,
                                ),
                                cursorColor: _blue,
                                decoration: _inputDecoration(
                                  label: '비밀번호',
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    tooltip: _obscurePassword
                                        ? '비밀번호 보기'
                                        : '비밀번호 숨기기',
                                    onPressed: canTap
                                        ? () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          }
                                        : null,
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: _secondaryText,
                                      size: 21,
                                    ),
                                  ),
                                ),
                                onSubmitted: (_) => logIn(),
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: canTap ? logIn : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _blue,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: _surfaceSoft,
                                    disabledForegroundColor: _softText,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: _isEmailLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.3,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          '이메일로 로그인',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: canTap
                              ? () {
                                  context.push('/register');
                                }
                              : null,
                          child: Text(
                            '이메일로 회원가입',
                            style: TextStyle(
                              color: canTap ? _blue : _softText,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '계속 진행하면 SUPANOVA의 이용약관 및 개인정보처리방침에 동의한 것으로 간주됩니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _softText,
                            fontSize: 11.8,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  final bool compact;

  const _LogoHeader({
    required this.compact,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: compact ? 64 : 72,
          height: compact ? 64 : 72,
          decoration: BoxDecoration(
            color: _blue.withValues(alpha: 0.13),
            shape: BoxShape.circle,
            border: Border.all(
              color: _blue.withValues(alpha: 0.28),
              width: 0.8,
            ),
          ),
          child: Icon(
            Icons.bolt_rounded,
            color: _blue,
            size: compact ? 34 : 38,
          ),
        ),
        SizedBox(height: compact ? 14 : 16),
        Text(
          'SUPANOVA',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _primaryText,
            fontSize: compact ? 32 : 36,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '운동을 기록하고 함께 성장하세요',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _secondaryText,
            fontSize: 14.5,
            height: 1.4,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  final Widget child;

  const _LoginCard({
    required this.child,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: child,
    );
  }
}