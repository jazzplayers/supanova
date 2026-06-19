import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';

class UserRegisterPage extends ConsumerStatefulWidget {
  const UserRegisterPage({super.key});

  @override
  ConsumerState<UserRegisterPage> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<UserRegisterPage> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  final TextEditingController _displayNameCtrl = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _displayNameFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

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

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _displayNameCtrl.dispose();

    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _displayNameFocusNode.dispose();

    super.dispose();
  }

  Future<void> register() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    if (formKey.currentState?.validate() != true) return;

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();
    final displayName = _displayNameCtrl.text.trim();

    if (password != confirmPassword) {
      showAppSnackBar(
        context,
        message: '비밀번호가 일치하지 않습니다.',
        icon: Icons.error_rounded,
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = ref.read(userAuthRepositoryProvider);

      await authRepo.userSignUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (authRepo.currentUser == null) {
        await authRepo.userSignIn(
          email: email,
          password: password,
        );
      }

      final uid = authRepo.currentUser?.uid;

      if (uid == null || uid.isEmpty) {
        throw Exception('no-current-user');
      }

      if (!mounted) return;

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: _parseRegisterError(e),
        icon: Icons.error_rounded,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _parseRegisterError(Object error) {
    String raw = error.toString().toLowerCase();

    if (error is FirebaseAuthException) {
      raw = error.code.toLowerCase();
    }

    if (raw.contains('email-already-in-use') || raw.contains('이미 가입된 이메일')) {
      return '이미 가입된 이메일입니다.';
    }

    if (raw.contains('invalid-email') || raw.contains('이메일 형식')) {
      return '이메일 형식이 올바르지 않습니다.';
    }

    if (raw.contains('weak-password') || raw.contains('비밀번호가 너무 약')) {
      return '비밀번호가 너무 약합니다. 6자 이상으로 입력해주세요.';
    }

    if (raw.contains('operation-not-allowed')) {
      return '현재 이메일 회원가입을 사용할 수 없습니다. 잠시 후 다시 시도해주세요.';
    }

    if (raw.contains('이미 사용 중인 닉네임')) {
      return '이미 사용 중인 닉네임입니다.';
    }

    if (raw.contains('permission-denied')) {
      return '회원가입을 처리하지 못했습니다. 잠시 후 다시 시도해주세요.';
    }

    if (raw.contains('사용자 정보 저장 실패')) {
      return '회원 정보를 저장하지 못했습니다. 잠시 후 다시 시도해주세요.';
    }

    if (raw.contains('no-current-user') ||
        raw.contains('로그인 유저 정보를 가져오지 못했습니다')) {
      return '회원가입은 완료되었지만 로그인 상태 확인에 실패했습니다. 다시 로그인해주세요.';
    }

    if (raw.contains('network') || raw.contains('unavailable')) {
      return '인터넷 연결을 확인한 뒤 다시 시도해주세요.';
    }

    if (raw.contains('too-many-requests')) {
      return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
    }

    return '회원가입에 실패했습니다. 입력한 정보를 다시 확인해주세요.';
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
      leading: IconButton(
        tooltip: '뒤로가기',
        visualDensity: VisualDensity.compact,
        onPressed: _isLoading
            ? null
            : () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/login');
                }
              },
        icon: Icon(
          _backIcon(context),
          color: _isLoading ? _softText : _primaryText,
          size: isIOS ? 20 : 23,
        ),
      ),
      title: const Text(
        '회원가입',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final maxWidth = math.min(width - 32, 430.0);
    final compact = width < 360;

    return PopScope(
      canPop: !_isLoading,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: _bg,
          resizeToAvoidBottomInset: true,
          appBar: _buildAppBar(context),
          body: SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: AutofillGroup(
                  child: Form(
                    key: formKey,
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      physics: _scrollPhysics(context),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        compact ? 20 : 26,
                        16,
                        26 + media.padding.bottom,
                      ),
                      children: [
                        const _RegisterHeader(),
                        SizedBox(height: compact ? 24 : 28),
                        _RegisterCard(
                          child: Column(
                            children: [
                              _RegisterTextField(
                                controller: _emailCtrl,
                                focusNode: _emailFocusNode,
                                label: '이메일',
                                hintText: 'example@email.com',
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.email,
                                  AutofillHints.username,
                                ],
                                enabled: !_isLoading,
                                onFieldSubmitted: (_) {
                                  _passwordFocusNode.requestFocus();
                                },
                                validator: (value) {
                                  final text = value?.trim() ?? '';

                                  if (text.isEmpty) {
                                    return '이메일을 입력해주세요.';
                                  }

                                  final emailRegex = RegExp(
                                    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                  );

                                  if (!emailRegex.hasMatch(text)) {
                                    return '유효한 이메일 주소를 입력해주세요.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _RegisterTextField(
                                controller: _passwordCtrl,
                                focusNode: _passwordFocusNode,
                                label: '비밀번호',
                                hintText: '6자 이상 입력',
                                prefixIcon: Icons.lock_outline_rounded,
                                obscureText: _obscurePassword,
                                enabled: !_isLoading,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onFieldSubmitted: (_) {
                                  _confirmPasswordFocusNode.requestFocus();
                                },
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? '비밀번호 보기'
                                      : '비밀번호 숨기기',
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: _secondaryText,
                                    size: 21,
                                  ),
                                ),
                                validator: (value) {
                                  final text = value ?? '';

                                  if (text.isEmpty) {
                                    return '비밀번호를 입력해주세요.';
                                  }

                                  if (text.length < 6) {
                                    return '비밀번호는 6자 이상이어야 합니다.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _RegisterTextField(
                                controller: _confirmPasswordCtrl,
                                focusNode: _confirmPasswordFocusNode,
                                label: '비밀번호 확인',
                                hintText: '비밀번호 다시 입력',
                                prefixIcon: Icons.lock_reset_rounded,
                                obscureText: _obscureConfirmPassword,
                                enabled: !_isLoading,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [
                                  AutofillHints.newPassword,
                                ],
                                onFieldSubmitted: (_) {
                                  _displayNameFocusNode.requestFocus();
                                },
                                suffixIcon: IconButton(
                                  tooltip: _obscureConfirmPassword
                                      ? '비밀번호 보기'
                                      : '비밀번호 숨기기',
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: _secondaryText,
                                    size: 21,
                                  ),
                                ),
                                validator: (value) {
                                  final text = value ?? '';

                                  if (text.isEmpty) {
                                    return '비밀번호를 한 번 더 입력해주세요.';
                                  }

                                  if (text != _passwordCtrl.text) {
                                    return '비밀번호가 일치하지 않습니다.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              _RegisterTextField(
                                controller: _displayNameCtrl,
                                focusNode: _displayNameFocusNode,
                                label: '닉네임',
                                hintText: '20자 이하',
                                prefixIcon: Icons.person_outline_rounded,
                                enabled: !_isLoading,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [
                                  AutofillHints.nickname,
                                  AutofillHints.name,
                                ],
                                onFieldSubmitted: (_) => register(),
                                validator: (value) {
                                  final text = value?.trim() ?? '';

                                  if (text.isEmpty) {
                                    return '닉네임을 입력해주세요.';
                                  }

                                  if (text.length > 20) {
                                    return '닉네임은 20자 이하로 입력해주세요.';
                                  }

                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                height: 52,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accent,
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
                                          '회원가입',
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
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  context.go('/login');
                                },
                          child: Text(
                            '이미 계정이 있으신가요? 로그인',
                            style: TextStyle(
                              color: _isLoading ? _softText : _secondaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const _PolicyNotice(),
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

class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.13),
            shape: BoxShape.circle,
            border: Border.all(
              color: _accent.withValues(alpha: 0.28),
              width: 0.8,
            ),
          ),
          child: const Icon(
            Icons.bolt_rounded,
            color: _accent,
            size: 30,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          '계정 만들기',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _primaryText,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.7,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          '이메일과 닉네임을 입력해서 SUPANOVA를 시작하세요.',
          style: TextStyle(
            color: _secondaryText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 1.4,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }
}

class _RegisterCard extends StatelessWidget {
  final Widget child;

  const _RegisterCard({
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

class _PolicyNotice extends StatelessWidget {
  const _PolicyNotice();

  static const Color _softText = Color(0xFF66666D);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          '회원가입을 진행하면 SUPANOVA의 이용약관 및 개인정보처리방침에 동의한 것으로 간주됩니다.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _softText,
            fontSize: 11.8,
            height: 1.45,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.05,
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () {
            context.push('/terms-privacy');
          },
          child: const Text(
            '이용약관 및 개인정보처리방침 보기',
            style: TextStyle(
              color: _secondaryText,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.05,
            ),
          ),
        ),
      ],
    );
  }
}

class _RegisterTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;
  final String? Function(String?) validator;
  final ValueChanged<String>? onFieldSubmitted;

  const _RegisterTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    required this.validator,
    this.focusNode,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.suffixIcon,
    this.onFieldSubmitted,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onFieldSubmitted: onFieldSubmitted,
      autocorrect: false,
      enableSuggestions: !obscureText,
      cursorColor: _accent,
      style: const TextStyle(
        color: _primaryText,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: _secondaryText,
          size: 21,
        ),
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(
          color: _secondaryText,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(
          color: _softText,
          fontWeight: FontWeight.w500,
        ),
        errorStyle: const TextStyle(
          color: _danger,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
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
            color: _accent,
            width: 1.1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: _danger,
            width: 1.0,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
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
    );
  }
}