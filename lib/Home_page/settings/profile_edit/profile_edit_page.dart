import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/image_picker/image_picker_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  static const Color _bg = Color(0xFF0B0F14);
  static const Color _card = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

  final TextEditingController _displayNameController =
      TextEditingController();

  File? _pickedImage;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final pickedFiles =
          await ref.read(imagePickerServiceProvider).pickMultipleImages();

      if (pickedFiles.isEmpty) return;

      if (!mounted) return;

      setState(() {
        _pickedImage = pickedFiles.first;
      });

      showAppSnackBar(
        context,
        message: '프로필 사진이 선택되었습니다.',
        icon: Icons.check_circle_rounded,
      );
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '사진 선택 실패: $e',
        icon: Icons.error_rounded,
        isError: true,
      );
    }
  }

  Future<void> _saveProfile({
    required String uid,
    required String currentDisplayName,
  }) async {
    final newDisplayName = _displayNameController.text.trim();

    if (newDisplayName.isEmpty) {
      showAppSnackBar(
        context,
        message: '닉네임을 입력해주세요.',
        icon: Icons.edit_rounded,
        isError: true,
      );
      return;
    }

    if (newDisplayName.length > 20) {
      showAppSnackBar(
        context,
        message: '닉네임은 20자 이하로 입력해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? profileImageUrl;

      if (_pickedImage != null) {
        final imageUploadService = ref.read(imageUploadServiceProvider);

        profileImageUrl = await imageUploadService.uploadImageFile(
          file: _pickedImage!,
          path: 'profiles/$uid/profile_${DateTime.now().millisecondsSinceEpoch}',
        );
      }

      if (newDisplayName != currentDisplayName.trim()) {
        final isAvailable = await ref.read(
          isDisplayNameAvailableProvider(newDisplayName).future,
        );

        if (!mounted) return;

        if (!isAvailable) {
          setState(() => _isSaving = false);

          showAppSnackBar(
            context,
            message: '이미 사용 중인 닉네임입니다.',
            icon: Icons.error_rounded,
            isError: true,
          );
          return;
        }
      }

      await ref.read(
        updateUserDataProvider(
          uid: uid,
          displayName: newDisplayName,
          profileImageUrl: profileImageUrl,
        ).future,
      );

      ref.invalidate(userAuthDataProvider(uid));

      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '프로필이 수정되었습니다.',
        icon: Icons.check_circle_rounded,
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '프로필 수정 실패: $e',
        icon: Icons.error_rounded,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(myUidProvider);

    if (myUid == null) {
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

    final userAsync = ref.watch(userAuthDataProvider(myUid));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '프로필 수정',
          style: TextStyle(
            color: _primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: _isSaving ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: _primaryText,
        ),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(
              child: Text(
                '유저 정보를 찾을 수 없습니다.',
                style: TextStyle(color: _primaryText),
              ),
            );
          }

          if (!_initialized) {
            _displayNameController.text = user.displayName;
            _initialized = true;
          }

          final hasProfileImage =
              user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _isSaving ? null : _pickProfileImage,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: _card,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : hasProfileImage
                                ? NetworkImage(user.profileImageUrl!)
                                : null,
                        child: _pickedImage == null && !hasProfileImage
                            ? const Icon(
                                Icons.person_rounded,
                                size: 52,
                                color: _secondaryText,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 2,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: _blue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _bg,
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 34),

              const _InputLabel('닉네임'),
              const SizedBox(height: 8),
              _ProfileInputField(
                controller: _displayNameController,
                hintText: '닉네임을 입력하세요',
                maxLength: 20,
                enabled: !_isSaving,
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving
                      ? null
                      : () => _saveProfile(
                            uid: myUid,
                            currentDisplayName: user.displayName,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    disabledBackgroundColor: _blue.withValues(alpha: 0.35),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          '저장하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: _blue),
        ),
        error: (e, st) => const Center(
          child: Text(
            '프로필 정보를 불러오지 못했습니다.',
            style: TextStyle(color: _primaryText),
          ),
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;

  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFFF5F7FA),
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _ProfileInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLength;
  final bool enabled;

  const _ProfileInputField({
    required this.controller,
    required this.hintText,
    required this.maxLength,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLength: maxLength,
      cursorColor: const Color(0xFF5DADEC),
      style: const TextStyle(
        color: Color(0xFFF5F7FA),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Color(0xFF6B7280),
        ),
        counterStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 11,
        ),
        filled: true,
        fillColor: const Color(0xFF151B22),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF5DADEC),
            width: 1.4,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.04),
          ),
        ),
      ),
    );
  }
}