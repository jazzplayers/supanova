import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';

class UserLoginPage extends ConsumerStatefulWidget {
  const UserLoginPage({super.key});

  @override
  ConsumerState<UserLoginPage> createState() => _UserLoginPageState();
}

class _UserLoginPageState extends ConsumerState<UserLoginPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  static const Color _primaryColor = Color(0xFF42A5F5);
  static const Color _backgroundColor = Color(0xFF0B0F14);
  static const Color _cardColor = Color(0xFF151A21);
  static const Color _primaryText = Colors.white;
  static const Color _secondaryText = Color(0xFFB8C2CC);

  bool _isLoading = false;

  Future<void> logIn() async {
    final authRepo = ref.read(userAuthRepositoryProvider);
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    try {
      setState(() => _isLoading = true);

      await authRepo.userSignIn(
        email: email,
        password: password,
      );

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      _showSnackBar('로그인 실패: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      setState(() => _isLoading = true);

      await ref.read(signInWithGoogleProvider.future);

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      _showSnackBar('구글 로그인 실패: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _cardColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Widget _dividerWithText(String text) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0xFF2B3440)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFF2B3440)),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _secondaryText),
      filled: true,
      fillColor: _cardColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2B3440)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: _primaryColor,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canTap = !_isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  const Text(
                    'SUPANOVA',
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '운동을 기록하고 함께 성장하세요',
                    style: TextStyle(
                      fontSize: 15,
                      color: _secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 42),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: canTap ? signInWithGoogle : null,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _cardColor,
                        foregroundColor: _primaryText,
                        side: const BorderSide(color: Color(0xFF2B3440)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _primaryColor,
                              ),
                            )
                          : const Icon(
                              Icons.login_rounded,
                              color: _primaryColor,
                            ),
                      label: const Text(
                        'Google로 계속하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  _dividerWithText('또는 이메일로 로그인'),
                  const SizedBox(height: 24),

                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: _primaryText),
                    cursorColor: _primaryColor,
                    decoration: _inputDecoration('Email'),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    style: const TextStyle(color: _primaryText),
                    cursorColor: _primaryColor,
                    decoration: _inputDecoration('Password'),
                  ),
                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: canTap ? logIn : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                            _primaryColor.withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              '이메일로 로그인',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextButton(
                    onPressed: canTap
                        ? () {
                            context.push('/register');
                          }
                        : null,
                    child: const Text(
                      '이메일로 회원가입',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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