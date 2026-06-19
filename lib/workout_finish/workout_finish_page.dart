import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/core/firebase.dart';
import 'package:home_function/image_picker/image_picker_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';
import 'package:home_function/workout/workout_stat_provider/workout_stat_notifier.dart';
import 'package:home_function/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish_provider.dart';

class WorkoutFinishPage extends ConsumerStatefulWidget {
  final WorkoutFinish finish;

  const WorkoutFinishPage({
    super.key,
    required this.finish,
  });

  @override
  ConsumerState<WorkoutFinishPage> createState() => _WorkoutFinishPageState();
}

enum _WorkoutImageSource {
  camera,
  gallery,
}

class _WorkoutFinishPageState extends ConsumerState<WorkoutFinishPage> {
  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

  static const int _maxImageCount = 6;

  List<File> _pickedFiles = [];
  bool _isUploading = false;

  ScrollPhysics _scrollPhysics(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS) {
      return const BouncingScrollPhysics();
    }

    return const ClampingScrollPhysics();
  }

  void _addPickedFiles(List<File> files) {
    if (files.isEmpty) return;

    final remainingCount = _maxImageCount - _pickedFiles.length;

    if (remainingCount <= 0) {
      showAppSnackBar(
        context,
        message: '사진은 최대 $_maxImageCount장까지 추가할 수 있습니다.',
        icon: Icons.info_outline_rounded,
        isError: true,
      );
      return;
    }

    final existingPaths = _pickedFiles.map((file) => file.path).toSet();

    final uniqueFiles = files
        .where((file) => !existingPaths.contains(file.path))
        .take(remainingCount)
        .toList();

    if (uniqueFiles.isEmpty) return;

    setState(() {
      _pickedFiles = [
        ..._pickedFiles,
        ...uniqueFiles,
      ];
    });

    showAppSnackBar(
      context,
      message: '${uniqueFiles.length}장의 사진이 선택되었습니다.',
      icon: Icons.check_circle_rounded,
    );
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      final pickedFiles =
          await ref.read(imagePickerServiceProvider).pickMultipleImages();

      if (!mounted || pickedFiles.isEmpty) return;

      _addPickedFiles(pickedFiles);
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

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile =
          await ref.read(imagePickerServiceProvider).pickImageFromCamera();

      if (!mounted || pickedFile == null) return;

      _addPickedFiles([pickedFile]);
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '카메라 사진 선택 실패: $e',
        icon: Icons.error_rounded,
        isError: true,
      );
    }
  }

  void _removePickedFile(File file) {
    setState(() {
      _pickedFiles =
          _pickedFiles.where((picked) => picked.path != file.path).toList();
    });
  }

  String _buildImagePath({
    required String uid,
    required int index,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return 'workouts/$uid/$now-$index.jpg';
  }

  Future<List<String>> _uploadSelectedImages(String uid) async {
    if (_pickedFiles.isEmpty) return [];

    final imageUploadService = ref.read(imageUploadServiceProvider);
    final imageUrls = <String>[];

    for (int i = 0; i < _pickedFiles.length; i++) {
      final imageUrl = await imageUploadService.uploadImageFile(
        file: _pickedFiles[i],
        path: _buildImagePath(uid: uid, index: i),
      );

      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }

  Future<void> _showUploadSheet(BuildContext context) async {
    if (_isUploading) return;

    final source = await showModalBottomSheet<_WorkoutImageSource>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(173),
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
            clipBehavior: Clip.antiAlias,
            child: SingleChildScrollView(
              physics: _scrollPhysics(sheetContext),
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
                    '사진 추가',
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
                  Text(
                    '운동 기록에 추가할 사진을 선택해주세요.\n최대 $_maxImageCount장까지 추가할 수 있어요.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SheetActionTile(
                    icon: Icons.photo_camera_outlined,
                    title: '카메라로 촬영',
                    subtitle: '운동 사진을 바로 촬영합니다',
                    onTap: () {
                      Navigator.of(sheetContext, rootNavigator: true)
                          .pop(_WorkoutImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 8),
                  _SheetActionTile(
                    icon: Icons.photo_library_outlined,
                    title: '갤러리에서 선택',
                    subtitle: '앨범에서 여러 장을 선택할 수 있어요',
                    onTap: () {
                      Navigator.of(sheetContext, rootNavigator: true)
                          .pop(_WorkoutImageSource.gallery);
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

    if (source == _WorkoutImageSource.camera) {
      await _pickImageFromCamera();
    } else {
      await _pickImagesFromGallery();
    }
  }

  Widget _buildImagePreviewSection() {
    if (_pickedFiles.isEmpty) {
      return const _SectionFrame(
        padding: EdgeInsets.symmetric(
          vertical: 28,
          horizontal: 18,
        ),
        child: Column(
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 40,
              color: _secondaryText,
            ),
            SizedBox(height: 12),
            Text(
              '선택된 사진이 없습니다',
              style: TextStyle(
                color: _primaryText,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '카메라 또는 갤러리에서 사진을 추가해보세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return _SectionFrame(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '선택한 사진',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                  ),
                ),
              ),
              Text(
                '${_pickedFiles.length}/$_maxImageCount장',
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final spacing = 8.0;
              final crossAxisCount = constraints.maxWidth < 340 ? 3 : 4;
              final itemSize =
                  (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                      crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: _pickedFiles.map((file) {
                  return SizedBox(
                    width: itemSize,
                    height: itemSize,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              file,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const ColoredBox(
                                  color: Color(0xFF121216),
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: _secondaryText,
                                      size: 26,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: _isUploading
                                ? null
                                : () => _removePickedFile(file),
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(184),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitWorkoutFinish() async {
    if (_isUploading) return;

    final auth = ref.read(firebaseAuthProvider);
    final user = auth.currentUser;
    final finish = widget.finish;

    if (user == null) {
      showAppSnackBar(
        context,
        message: '로그인이 필요합니다.',
        icon: Icons.lock_rounded,
        isError: true,
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final imageUrls = await _uploadSelectedImages(user.uid);

      await ref.read(
        uploadWorkoutFinishProvider(
          workoutFinish: finish,
          imageUrls: imageUrls,
        ).future,
      );

      if (!mounted) return;

      showAppSnackBar(
        context,
        message: imageUrls.isEmpty
            ? '운동 기록이 업로드되었습니다.'
            : '운동 기록과 사진 업로드가 완료되었습니다.',
        icon: Icons.check_circle_rounded,
      );

      setState(() {
        _pickedFiles.clear();
      });

      await ref.read(workoutProvider.notifier).idle();

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '운동 기록 업로드 실패: $e',
        icon: Icons.error_rounded,
        isError: true,
      );
    } finally {
      if (!mounted) return;
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteWorkoutFinish() async {
    if (_isUploading) return;

    final confirm = await _showDeleteDialog(context);

    if (!confirm) return;

    if (!mounted) return;

    setState(() => _isUploading = true);

    try {
      setState(() {
        _pickedFiles.clear();
      });

      showAppSnackBar(
        context,
        message: '운동 기록이 삭제되었습니다.',
        icon: Icons.check_circle_rounded,
      );

      await ref.read(workoutProvider.notifier).idle();

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '운동 기록 삭제 실패: $e',
        icon: Icons.error_rounded,
        isError: true,
      );
    } finally {
      if (!mounted) return;
      setState(() => _isUploading = false);
    }
  }

  Future<bool> _showDeleteDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          barrierColor: Colors.black.withAlpha(180),
          builder: (dialogContext) {
            final media = MediaQuery.of(dialogContext);
            final maxWidth = math.min(media.size.width - 32, 380.0);

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: media.size.height * 0.86,
                ),
                child: SingleChildScrollView(
                  physics: _scrollPhysics(dialogContext),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
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
                            color: _danger.withAlpha(36),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 32,
                            color: _danger,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          '운동 기록 삭제',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _primaryText,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.35,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '업로드하지 않은 사진과 기록은 사라집니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _secondaryText,
                            fontSize: 14,
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 22),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final narrow = constraints.maxWidth < 300;

                            final cancelButton = SizedBox(
                              height: 46,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(false);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _primaryText,
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
                            );

                            final deleteButton = SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(true);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _danger,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  '삭제',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            );

                            if (narrow) {
                              return Column(
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: deleteButton,
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: cancelButton,
                                  ),
                                ],
                              );
                            }

                            return Row(
                              children: [
                                Expanded(child: cancelButton),
                                const SizedBox(width: 10),
                                Expanded(child: deleteButton),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }

  String _formatPace(double pace) {
    if (pace.isNaN || pace.isInfinite || pace <= 0) {
      return '--:-- min/km';
    }

    final totalSeconds = (pace * 60).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} min/km';
  }

  String _formatTime(int seconds) {
    final safeSeconds = seconds < 0 ? 0 : seconds;

    final hours = safeSeconds ~/ 3600;
    final minutes = (safeSeconds % 3600) ~/ 60;
    final remainSeconds = safeSeconds % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분 $remainSeconds초';
    }

    return '$minutes분 $remainSeconds초';
  }

  double _safeDistanceKm(double distanceMeters) {
    if (distanceMeters.isNaN || distanceMeters.isInfinite || distanceMeters < 0) {
      return 0.0;
    }

    return distanceMeters / 1000;
  }

  double _safeSpeedKmh(double speedKmh) {
    if (speedKmh.isNaN || speedKmh.isInfinite || speedKmh < 0) {
      return 0.0;
    }

    return speedKmh;
  }

  @override
  Widget build(BuildContext context) {
    final finish = widget.finish;

    final km = _safeDistanceKm(finish.distanceMeters);
    final timeText = _formatTime(finish.seconds);
    final paceText = _formatPace(finish.paceMinPerKm);
    final speedKmh = _safeSpeedKmh(finish.speedKmh);
    final media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: 52,
        title: const Text(
          '운동 완료',
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
        bottom: false,
        child: SingleChildScrollView(
          physics: _scrollPhysics(context),
          padding: EdgeInsets.fromLTRB(
            16,
            18,
            16,
            24 + media.padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FinishHero(
                km: km,
                timeText: timeText,
              ),
              const SizedBox(height: 16),
              _PhotoAddButton(
                isUploading: _isUploading,
                pickedCount: _pickedFiles.length,
                maxCount: _maxImageCount,
                onTap: () => _showUploadSheet(context),
              ),
              const SizedBox(height: 14),
              _buildImagePreviewSection(),
              const SizedBox(height: 14),
              _SectionFrame(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '운동 기록',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _RecordRow(
                      icon: Icons.route_outlined,
                      label: '운동 거리',
                      value: '${km.toStringAsFixed(2)} km',
                    ),
                    const SizedBox(height: 14),
                    _RecordRow(
                      icon: Icons.timer_outlined,
                      label: '운동 시간',
                      value: timeText,
                    ),
                    const SizedBox(height: 14),
                    _RecordRow(
                      icon: Icons.speed_outlined,
                      label: '평균 속도',
                      value: '${speedKmh.toStringAsFixed(2)} km/h',
                    ),
                    const SizedBox(height: 14),
                    _RecordRow(
                      icon: Icons.directions_run_outlined,
                      label: '평균 페이스',
                      value: paceText,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _SubmitButton(
                isUploading: _isUploading,
                onTap: _submitWorkoutFinish,
              ),
              const SizedBox(height: 10),
              _DeleteButton(
                isUploading: _isUploading,
                onTap: _deleteWorkoutFinish,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinishHero extends StatelessWidget {
  final double km;
  final String timeText;

  const _FinishHero({
    required this.km,
    required this.timeText,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return _SectionFrame(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: _accent.withAlpha(33),
              shape: BoxShape.circle,
              border: Border.all(
                color: _accent.withAlpha(51),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 44,
              color: _accent,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            '운동이 완료되었습니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${km.toStringAsFixed(2)} km · $timeText',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoAddButton extends StatelessWidget {
  final bool isUploading;
  final int pickedCount;
  final int maxCount;
  final VoidCallback onTap;

  const _PhotoAddButton({
    required this.isUploading,
    required this.pickedCount,
    required this.maxCount,
    required this.onTap,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final isMax = pickedCount >= maxCount;

    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: isUploading || isMax ? null : onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: _surface,
          foregroundColor: _primaryText,
          disabledForegroundColor: _secondaryText,
          side: const BorderSide(
            color: _line,
            width: 0.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_camera_outlined,
              color: _accent,
              size: 21,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                isMax
                    ? '사진 최대 $maxCount장 선택됨'
                    : pickedCount > 0
                        ? '사진 추가 · $pickedCount장 선택됨'
                        : '사진 추가',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _primaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.isUploading,
    required this.onTap,
  });

  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isUploading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          disabledBackgroundColor: _accent.withAlpha(89),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isUploading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : const Text(
                '운동 기록 업로드',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final bool isUploading;
  final VoidCallback onTap;

  const _DeleteButton({
    required this.isUploading,
    required this.onTap,
  });

  static const Color _danger = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isUploading ? null : onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _danger,
          side: BorderSide(
            color: _danger.withAlpha(191),
            width: 0.8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: const Text(
          '삭제하기',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RecordRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _accent.withAlpha(33),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: _accent,
            size: 20,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: _surfaceSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionFrame extends StatelessWidget {
  const _SectionFrame({
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsets padding;

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
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
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
      ),
    );
  }
}