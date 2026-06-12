import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/follow/firestore/repo_provider.dart';
import 'package:home_function/follow/follow_service/follow_provider.dart';
import 'package:home_function/image_picker/image_picker_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';
import 'package:home_function/workout_finish/workout_finish_provider.dart';

class TopProfileCard extends ConsumerStatefulWidget {
  final String userId;
  final bool isMe;

  const TopProfileCard({
    super.key,
    required this.userId,
    required this.isMe,
  });

  @override
  ConsumerState<TopProfileCard> createState() => _TopProfileCardState();
}

enum _ProfileImageSource {
  camera,
  gallery,
}

class _TopProfileCardState extends ConsumerState<TopProfileCard> {
  bool _isProfileUploading = false;

  static const Color _bg = Color(0xFF000000);
  static const Color _line = Color(0xFF26262B);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  Future<void> _uploadProfileImage(File file) async {
    final myUid = ref.read(myUidProvider);

    if (myUid == null || myUid != widget.userId) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '본인 프로필만 수정할 수 있습니다.',
        icon: Icons.lock_rounded,
        isError: true,
      );
      return;
    }

    setState(() => _isProfileUploading = true);

    try {
      final imageUploadService = ref.read(imageUploadServiceProvider);

      final profileImageUrl = await imageUploadService.uploadImageFile(
        file: file,
        path:
            'profiles/$myUid/profile_${DateTime.now().millisecondsSinceEpoch}',
      );

      await ref.read(
        updateUserDataProvider(
          uid: myUid,
          profileImageUrl: profileImageUrl,
        ).future,
      );

      ref.invalidate(userAuthDataProvider(widget.userId));
      ref.invalidate(userAuthDataProvider(myUid));

      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '프로필 사진이 변경되었습니다.',
        icon: Icons.check_circle_rounded,
      );
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '프로필 사진 변경 실패: $e',
        icon: Icons.error_rounded,
        isError: true,
      );
    } finally {
      if (!mounted) return;
      setState(() => _isProfileUploading = false);
    }
  }

  Future<void> _showUploadDialog() async {
    if (_isProfileUploading) return;

    final source = await showModalBottomSheet<_ProfileImageSource>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.68),
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);

        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            decoration: const BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
                bottom: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(color: _line, width: 0.8),
                left: BorderSide(color: _line, width: 0.8),
                right: BorderSide(color: _line, width: 0.8),
                bottom: BorderSide(color: _line, width: 0.8),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                18,
                10,
                18,
                12 + media.padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A40),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '프로필 사진 변경',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '사진을 가져올 위치를 선택해주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SheetActionTile(
                    icon: Icons.photo_camera_outlined,
                    title: '카메라로 촬영',
                    subtitle: '새 프로필 사진을 바로 촬영합니다',
                    onTap: () {
                      Navigator.of(sheetContext, rootNavigator: true)
                          .pop(_ProfileImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SheetActionTile(
                    icon: Icons.photo_library_outlined,
                    title: '갤러리에서 선택',
                    subtitle: '앨범에서 기존 사진을 선택합니다',
                    onTap: () {
                      Navigator.of(sheetContext, rootNavigator: true)
                          .pop(_ProfileImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(sheetContext, rootNavigator: true).pop();
                      },
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || source == null) return;

    try {
      File? pickedFile;

      if (source == _ProfileImageSource.camera) {
        pickedFile =
            await ref.read(imagePickerServiceProvider).pickImageFromCamera();
      } else {
        final pickedFiles =
            await ref.read(imagePickerServiceProvider).pickMultipleImages();

        if (pickedFiles.isEmpty) return;

        pickedFile = pickedFiles.first;
      }

      if (!mounted || pickedFile == null) return;

      await _uploadProfileImage(pickedFile);
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '프로필 사진 선택 실패: $e',
        icon: Icons.error_rounded,
        isError: true,
      );
    }
  }

  Future<void> _showProfileImageViewer({
    required String? imageUrl,
    required bool hasProfileImage,
    required String displayName,
  }) async {
    if (!hasProfileImage || imageUrl == null || imageUrl.isEmpty) {
      if (widget.isMe) {
        await _showUploadDialog();
        return;
      }

      showAppSnackBar(
        context,
        message: '등록된 프로필 사진이 없습니다.',
        icon: Icons.person_rounded,
        isError: true,
      );
      return;
    }

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '프로필 사진 닫기',
      barrierColor: Colors.black.withOpacity(0.92),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return _ProfileImageViewer(
          imageUrl: imageUrl,
          displayName: displayName,
          heroTag: 'profile-avatar-${widget.userId}',
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.96,
              end: 1,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  Future<void> showEditProfileDialog({
    required String currentDisplayName,
  }) async {
    final parentContext = context;

    final updated = await showModalBottomSheet<bool>(
      context: parentContext,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.68),
      builder: (sheetContext) {
        return _EditProfileSheet(
          userId: widget.userId,
          currentDisplayName: currentDisplayName,
        );
      },
    );

    if (!mounted || updated != true) return;

    final myUid = ref.read(myUidProvider);

    ref.invalidate(userAuthDataProvider(widget.userId));

    if (myUid != null) {
      ref.invalidate(userAuthDataProvider(myUid));
    }

    showAppSnackBar(
      parentContext,
      message: '프로필이 수정되었습니다.',
      icon: Icons.check_circle_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(myUidProvider);
    final userAsync = ref.watch(userAuthDataProvider(widget.userId));
    final followersCountAsync = ref.watch(followersCountProvider(widget.userId));
    final followingsCountAsync =
        ref.watch(followingsCountProvider(widget.userId));
    final followState = ref.watch(followControllerProvider);
    final workoutCountAsync = ref.watch(workoutCountProvider(widget.userId));

    final isSubmitting = followState.isLoading;

    final isFollowingAsync = (!widget.isMe && myUid != null)
        ? ref.watch(isFollowingProvider(myUid, widget.userId))
        : const AsyncData(false);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const SizedBox(
            width: double.infinity,
            height: 150,
            child: Center(
              child: Text(
                '사용자 정보를 찾을 수 없습니다.',
                style: TextStyle(
                  color: _secondaryText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }

        final hasProfileImage =
            user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;

        return SizedBox(
          width: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final avatarRadius = compact ? 35.0 : 39.0;

              final actionButton = widget.isMe
                  ? _ProfileActionButton(
                      label: '프로필 수정',
                      onPressed: () {
                        showEditProfileDialog(
                          currentDisplayName: user.displayName,
                        );
                      },
                    )
                  : isFollowingAsync.when(
                      data: (isFollowing) {
                        return _ProfileActionButton(
                          label: isSubmitting
                              ? '처리 중...'
                              : isFollowing
                                  ? '팔로잉'
                                  : '팔로우',
                          filled: !isFollowing,
                          disabled: isSubmitting || myUid == null,
                          onPressed: (isSubmitting || myUid == null)
                              ? null
                              : () async {
                                  final controller = ref.read(
                                    followControllerProvider.notifier,
                                  );

                                  if (isFollowing) {
                                    await controller.unfollow(widget.userId);
                                  } else {
                                    await controller.follow(widget.userId);
                                  }
                                },
                        );
                      },
                      loading: () => const _ProfileActionButton(
                        label: '확인 중...',
                        disabled: true,
                        onPressed: null,
                      ),
                      error: (e, st) => const _ProfileActionButton(
                        label: '오류',
                        disabled: true,
                        onPressed: null,
                      ),
                    );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      compact ? 14 : 16,
                      14,
                      compact ? 14 : 16,
                      0,
                    ),
                    child: Row(
                      children: [
                        _ProfileAvatar(
                          radius: avatarRadius,
                          hasProfileImage: hasProfileImage,
                          imageUrl: user.profileImageUrl,
                          isUploading: _isProfileUploading,
                          isMe: widget.isMe,
                          heroTag: 'profile-avatar-${widget.userId}',
                          onAvatarTap: _isProfileUploading
                              ? null
                              : () {
                                  _showProfileImageViewer(
                                    imageUrl: user.profileImageUrl,
                                    hasProfileImage: hasProfileImage,
                                    displayName: user.displayName,
                                  );
                                },
                          onEditTap:
                              _isProfileUploading ? null : _showUploadDialog,
                        ),
                        SizedBox(width: compact ? 14 : 18),
                        Expanded(
                          child: _ProfileStatsRow(
                            workoutCountAsync: workoutCountAsync,
                            followersCountAsync: followersCountAsync,
                            followingsCountAsync: followingsCountAsync,
                            userId: widget.userId,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 14 : 16,
                    ),
                    child: _ProfileNameBlock(
                      displayName: user.displayName,
                      email: user.email,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 14 : 16,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: actionButton,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(
                    color: _line,
                    height: 1,
                    thickness: 0.7,
                  ),
                ],
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        width: double.infinity,
        height: 150,
        child: Center(
          child: CircularProgressIndicator(
            color: _primaryText,
            strokeWidth: 2,
          ),
        ),
      ),
      error: (e, st) => const SizedBox(
        width: double.infinity,
        height: 150,
        child: Center(
          child: Text(
            '프로필 로드 실패',
            style: TextStyle(
              color: _secondaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.radius,
    required this.hasProfileImage,
    required this.imageUrl,
    required this.isUploading,
    required this.isMe,
    required this.heroTag,
    required this.onAvatarTap,
    required this.onEditTap,
  });

  final double radius;
  final bool hasProfileImage;
  final String? imageUrl;
  final bool isUploading;
  final bool isMe;
  final String heroTag;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onEditTap;

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final editSize = radius < 37 ? 25.0 : 27.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onAvatarTap,
          child: Hero(
            tag: heroTag,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _accent.withOpacity(0.9),
                    width: 1.8,
                  ),
                ),
                child: CircleAvatar(
                  radius: radius,
                  backgroundColor: _surfaceSoft,
                  backgroundImage: hasProfileImage && imageUrl != null
                      ? NetworkImage(imageUrl!)
                      : null,
                  child: !hasProfileImage
                      ? Icon(
                          Icons.person_rounded,
                          size: radius,
                          color: _secondaryText,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        if (isUploading)
          Positioned.fill(
            child: IgnorePointer(
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.52),
                child: const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        if (isMe)
          Positioned(
            right: -1,
            bottom: -1,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onEditTap,
              child: Container(
                width: editSize,
                height: editSize,
                decoration: BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: radius < 37 ? 16 : 17,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileImageViewer extends StatelessWidget {
  const _ProfileImageViewer({
    required this.imageUrl,
    required this.displayName,
    required this.heroTag,
  });

  final String imageUrl;
  final String displayName;
  final String heroTag;

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _line = Color(0xFF26262B);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final imageSize = media.size.width * 0.82;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const SizedBox.expand(),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {},
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3.5,
                    clipBehavior: Clip.none,
                    child: Hero(
                      tag: heroTag,
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: Container(
                          width: imageSize,
                          height: imageSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF121216),
                            border: Border.all(
                              color: _line,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.45),
                                blurRadius: 28,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (
                              context,
                              child,
                              loadingProgress,
                            ) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return const Center(
                                child: SizedBox(
                                  width: 26,
                                  height: 26,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: _secondaryText,
                                  size: 48,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    18 + media.padding.bottom,
                  ),
                  child: const Text(
                    '사진을 확대하거나 빈 공간을 눌러 닫을 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow({
    required this.workoutCountAsync,
    required this.followersCountAsync,
    required this.followingsCountAsync,
    required this.userId,
  });

  final AsyncValue<int> workoutCountAsync;
  final AsyncValue<int> followersCountAsync;
  final AsyncValue<int> followingsCountAsync;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProfileStatItem(
            value: workoutCountAsync.when(
              data: (count) => count.toString(),
              loading: () => '...',
              error: (e, st) => '!',
            ),
            label: '운동',
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.push(
                '/followersList',
                extra: userId,
              );
            },
            child: ProfileStatItem(
              value: followersCountAsync.when(
                data: (count) => count.toString(),
                loading: () => '...',
                error: (e, st) => '!',
              ),
              label: '팔로워',
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              context.push(
                '/followingsList',
                extra: userId,
              );
            },
            child: ProfileStatItem(
              value: followingsCountAsync.when(
                data: (count) => count.toString(),
                loading: () => '...',
                error: (e, st) => '!',
              ),
              label: '팔로잉',
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileNameBlock extends StatelessWidget {
  const _ProfileNameBlock({
    required this.displayName,
    required this.email,
  });

  final String displayName;
  final String email;

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: _primaryText,
            letterSpacing: -0.35,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: _secondaryText,
            height: 1.25,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  const _ProfileActionButton({
    required this.label,
    required this.onPressed,
    this.filled = false,
    this.disabled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final bool disabled;

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF26262B);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final bgColor = filled ? _accent : _surfaceSoft;
    final fgColor = disabled
        ? _secondaryText
        : filled
            ? Colors.white
            : _primaryText;

    return SizedBox(
      height: 38,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: bgColor,
          disabledBackgroundColor: _surfaceSoft,
          foregroundColor: fgColor,
          disabledForegroundColor: _secondaryText,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: BorderSide(
              color: filled ? Colors.transparent : _line,
              width: 0.8,
            ),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  final String userId;
  final String currentDisplayName;

  const _EditProfileSheet({
    required this.userId,
    required this.currentDisplayName,
  });

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final TextEditingController _displayNameController = TextEditingController();

  bool _isSaving = false;

  static const Color _bg = Color(0xFF000000);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF26262B);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.currentDisplayName;
    _displayNameController.selection = TextSelection.fromPosition(
      TextPosition(offset: _displayNameController.text.length),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final newDisplayName = _displayNameController.text.trim();

    if (newDisplayName.isEmpty) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '닉네임을 입력해주세요.',
        icon: Icons.edit_rounded,
        isError: true,
      );
      return;
    }

    if (newDisplayName.length > 20) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '닉네임은 20자 이하로 입력해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
      return;
    }

    final myUid = ref.read(myUidProvider);

    if (myUid == null) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '로그인이 필요합니다.',
        icon: Icons.lock_rounded,
        isError: true,
      );
      return;
    }

    if (myUid != widget.userId) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '본인 프로필만 수정할 수 있습니다.',
        icon: Icons.lock_rounded,
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (newDisplayName != widget.currentDisplayName.trim()) {
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
          uid: myUid,
          displayName: newDisplayName,
        ).future,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      showAppSnackBar(
        context,
        message: '프로필 수정 실패: $e',
        icon: Icons.error_rounded,
        isError: true,
      );
    }
  }

  void _cancel() {
    if (_isSaving) return;
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: media.viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          decoration: const BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
              bottom: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(color: _line, width: 0.8),
              left: BorderSide(color: _line, width: 0.8),
              right: BorderSide(color: _line, width: 0.8),
              bottom: BorderSide(color: _line, width: 0.8),
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              18,
              10,
              18,
              14 + media.padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A40),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: _accent,
                    size: 27,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '프로필 수정',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    color: _primaryText,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  '사용할 닉네임을 입력해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: _secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _displayNameController,
                  autofocus: true,
                  maxLength: 20,
                  enabled: !_isSaving,
                  cursorColor: _accent,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!_isSaving) {
                      _save();
                    }
                  },
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _surfaceSoft,
                    counterStyle: const TextStyle(
                      color: _secondaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    labelText: '닉네임',
                    hintText: '닉네임을 입력하세요',
                    labelStyle: const TextStyle(
                      color: _secondaryText,
                      fontWeight: FontWeight.w600,
                    ),
                    hintStyle: const TextStyle(
                      color: _softText,
                      fontWeight: FontWeight.w500,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _line,
                        width: 0.8,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _accent,
                        width: 1.3,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _line,
                        width: 0.8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : _cancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _primaryText,
                            disabledForegroundColor: _secondaryText,
                            side: const BorderSide(
                              color: _line,
                              width: 0.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 46,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _surfaceSoft,
                            disabledForegroundColor: _secondaryText,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  '저장',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileStatItem extends StatelessWidget {
  final String value;
  final String label;

  const ProfileStatItem({
    super.key,
    required this.value,
    required this.label,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _primaryText,
                letterSpacing: -0.25,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  const _SheetActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF26262B);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          color: _surfaceSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _line,
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _primaryText,
              size: 23,
            ),
            const SizedBox(width: 13),
            Expanded(
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _secondaryText,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}