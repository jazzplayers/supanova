import 'dart:io';
import 'dart:math' as math;

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
  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _blue = Color(0xFF5DADEC);

  final TextEditingController _displayNameController =
      TextEditingController();

  File? _pickedImage;
  bool _isSaving = false;
  bool _initialized = false;

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
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    if (_isSaving) return;

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
    } catch (_) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '사진을 선택하지 못했습니다. 다시 시도해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
    }
  }

  Future<void> _saveProfile({
    required String uid,
    required String currentDisplayName,
  }) async {
    if (_isSaving) return;

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

    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    try {
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

      String? profileImageUrl;

      if (_pickedImage != null) {
        final imageUploadService = ref.read(imageUploadServiceProvider);

        profileImageUrl = await imageUploadService.uploadImageFile(
          file: _pickedImage!,
          path:
              'profiles/$uid/profile_${DateTime.now().millisecondsSinceEpoch}',
        );
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
    } catch (_) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '프로필을 수정하지 못했습니다. 잠시 후 다시 시도해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
        '프로필 수정',
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
        onPressed: _isSaving ? null : () => context.pop(),
        icon: Icon(
          _backIcon(context),
          color: _isSaving ? _softText : _primaryText,
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
    final myUid = ref.watch(myUidProvider);
    final media = MediaQuery.of(context);
    final maxWidth = math.min(media.size.width, 720.0);

    if (myUid == null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: _buildAppBar(context),
        body: const SafeArea(
          top: false,
          child: _StateMessage(
            icon: Icons.lock_outline_rounded,
            title: '로그인이 필요합니다',
            message: '프로필을 수정하려면 먼저 로그인해주세요.',
          ),
        ),
      );
    }

    final userAsync = ref.watch(userAuthDataProvider(myUid));

    return PopScope(
      canPop: !_isSaving,
      child: Scaffold(
        backgroundColor: _bg,
        resizeToAvoidBottomInset: true,
        appBar: _buildAppBar(context),
        body: SafeArea(
          top: false,
          bottom: false,
          child: userAsync.when(
            data: (user) {
              if (user == null) {
                return const _StateMessage(
                  icon: Icons.person_off_outlined,
                  title: '프로필 정보를 찾을 수 없습니다',
                  message: '잠시 후 다시 시도해주세요.',
                );
              }

              if (!_initialized) {
                _displayNameController.text = user.displayName;
                _initialized = true;
              }

              final hasProfileImage = user.profileImageUrl != null &&
                  user.profileImageUrl!.isNotEmpty;

              ImageProvider? profileImageProvider;

              if (_pickedImage != null) {
                profileImageProvider = FileImage(_pickedImage!);
              } else if (hasProfileImage) {
                profileImageProvider = NetworkImage(user.profileImageUrl!);
              }

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
                      18,
                      16,
                      28 + media.padding.bottom,
                    ),
                    children: [
                      _ProfileImagePicker(
                        imageProvider: profileImageProvider,
                        isSaving: _isSaving,
                        onTap: _pickProfileImage,
                      ),
                      const SizedBox(height: 28),
                      _EditCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _InputLabel('닉네임'),
                            const SizedBox(height: 8),
                            _ProfileInputField(
                              controller: _displayNameController,
                              hintText: '닉네임을 입력하세요',
                              maxLength: 20,
                              enabled: !_isSaving,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '다른 이용자에게 표시되는 이름입니다.',
                              style: TextStyle(
                                color: _secondaryText,
                                fontSize: 12.5,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.05,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () => _saveProfile(
                                    uid: myUid,
                                    currentDisplayName: user.displayName,
                                  ),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _isSaving ? null : () => context.pop(),
                        child: Text(
                          '취소하고 돌아가기',
                          style: TextStyle(
                            color: _isSaving ? _softText : _secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: _blue,
                strokeWidth: 2.5,
              ),
            ),
            error: (e, st) => const _StateMessage(
              icon: Icons.error_outline_rounded,
              title: '프로필 정보를 불러오지 못했습니다',
              message: '인터넷 연결을 확인한 뒤 다시 시도해주세요.',
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileImagePicker extends StatelessWidget {
  final ImageProvider? imageProvider;
  final bool isSaving;
  final VoidCallback onTap;

  const _ProfileImagePicker({
    required this.imageProvider,
    required this.isSaving,
    required this.onTap,
  });

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
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
          GestureDetector(
            onTap: isSaving ? null : onTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF121216),
                    border: Border.all(
                      color: _line,
                      width: 0.8,
                    ),
                    image: imageProvider != null
                        ? DecorationImage(
                            image: imageProvider!,
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageProvider == null
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
                    width: 36,
                    height: 36,
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
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '프로필 사진',
            style: TextStyle(
              color: _primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.25,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '사진을 눌러 프로필 이미지를 변경할 수 있습니다.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13.2,
              height: 1.4,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditCard extends StatelessWidget {
  final Widget child;

  const _EditCard({
    required this.child,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: child,
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;

  const _InputLabel(this.text);

  static const Color _primaryText = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _primaryText,
        fontSize: 14,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.15,
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

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLength: maxLength,
      cursorColor: _blue,
      textInputAction: TextInputAction.done,
      keyboardType: TextInputType.text,
      style: const TextStyle(
        color: _primaryText,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      onSubmitted: (_) {
        FocusScope.of(context).unfocus();
      },
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: _softText,
          fontWeight: FontWeight.w600,
        ),
        counterStyle: const TextStyle(
          color: _secondaryText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
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