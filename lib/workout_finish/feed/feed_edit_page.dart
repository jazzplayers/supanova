import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:home_function/image_picker/image_picker_provider.dart';
import 'package:home_function/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish_provider.dart';

class FeedEditPage extends ConsumerStatefulWidget {
  final WorkoutFinish workoutFinish;

  const FeedEditPage({
    super.key,
    required this.workoutFinish,
  });

  @override
  ConsumerState<FeedEditPage> createState() => _FeedEditPageState();
}

class _FeedEditPageState extends ConsumerState<FeedEditPage> {
  static const Color _bg = Color(0xFF0B0F14);
  static const Color _card = Color(0xFF151B22);
  static const Color _cardSoft = Color(0xFF1D2630);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);
  // static const Color _danger = Color(0xFFFF5A5F);

  final ImagePicker _picker = ImagePicker();

  late final List<String> _originalImageUrls;
  late List<String> _imageUrls;

  final List<XFile> _newImages = [];
  final List<String> _deletedImageUrls = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _originalImageUrls = List<String>.from(
      widget.workoutFinish.workoutImagesUrl,
    );

    _imageUrls = List<String>.from(
      widget.workoutFinish.workoutImagesUrl,
    );
  }

  Future<void> _pickImages() async {
    final pickedImages = await _picker.pickMultiImage(
      imageQuality: 85,
    );

    if (pickedImages.isEmpty) return;

    setState(() {
      _newImages.addAll(pickedImages);
    });
  }

  void _removeOldImage(String imageUrl) {
    setState(() {
      _imageUrls.remove(imageUrl);

      if (_originalImageUrls.contains(imageUrl) &&
          !_deletedImageUrls.contains(imageUrl)) {
        _deletedImageUrls.add(imageUrl);
      }
    });
  }

  void _removeNewImage(XFile image) {
    setState(() {
      _newImages.removeWhere((item) => item.path == image.path);
    });
  }

  Future<List<String>> _uploadNewImages({
    required String workoutId,
  }) async {
    if (_newImages.isEmpty) return [];

    final files = _newImages.map((image) {
      return File(image.path);
    }).toList();

    return ref.read(
      uploadImageFilesProvider(
        files: files,
        path: 'workoutFinish/${widget.workoutFinish.userId}/$workoutId/images',
      ).future,
    );
  }

  Future<void> _deleteRemovedImages() async {
    if (_deletedImageUrls.isEmpty) return;

    await ref.read(
      deleteImageFilesProvider(
        imageUrls: _deletedImageUrls,
      ).future,
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;

    try {
      final workoutId = widget.workoutFinish.workoutId;

      if (workoutId == null || workoutId.isEmpty) {
        throw Exception('운동 기록 ID가 없습니다.');
      }

      setState(() {
        _isSaving = true;
      });

      final uploadedUrls = await _uploadNewImages(
        workoutId: workoutId,
      );

      final updatedImageUrls = [
        ..._imageUrls,
        ...uploadedUrls,
      ];

      await ref.read(
        updateWorkoutFinishImagesProvider(
          workoutFinish: widget.workoutFinish,
          imageUrls: updatedImageUrls,
        ).future,
      );

      try {
        await _deleteRemovedImages();
      } catch (e) {
        debugPrint('Storage 이미지 삭제 실패: $e');
      }

      if (!mounted) return;

      final updatedWorkoutFinish = widget.workoutFinish.copyWith(
        workoutImagesUrl: updatedImageUrls,
      );

      ref.invalidate(todayWorkoutFinishProvider);
      ref.invalidate(workoutFinishListProvider(widget.workoutFinish.userId));
      ref.invalidate(feedWorkoutFinishProvider(widget.workoutFinish.userId));
      ref.invalidate(
        workoutFinishProvider(
          workoutFinishId: workoutId,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('게시글이 수정되었습니다.'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pop(updatedWorkoutFinish);
    } catch (e, st) {
      debugPrint('FeedEditPage 수정 오류: $e');
      debugPrint('$st');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('수정 중 오류가 발생했습니다: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  bool get _hasImages => _imageUrls.isNotEmpty || _newImages.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '게시글 수정',
          style: TextStyle(
            color: _primaryText,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: _blue,
                    ),
                  )
                : const Text(
                    '완료',
                    style: TextStyle(
                      color: _blue,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle(
                  title: '사진',
                  subtitle: '업로드된 사진을 삭제하거나 새 사진을 추가할 수 있습니다.',
                ),
                const SizedBox(height: 14),
                if (_hasImages)
                  GridView.builder(
                    itemCount: _imageUrls.length + _newImages.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      if (index < _imageUrls.length) {
                        final imageUrl = _imageUrls[index];

                        return _EditableImageTile.network(
                          imageUrl: imageUrl,
                          onRemove: _isSaving
                              ? null
                              : () => _removeOldImage(imageUrl),
                        );
                      }

                      final newImageIndex = index - _imageUrls.length;
                      final image = _newImages[newImageIndex];

                      return _EditableImageTile.file(
                        file: File(image.path),
                        onRemove:
                            _isSaving ? null : () => _removeNewImage(image),
                      );
                    },
                  )
                else
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          color: _secondaryText,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '등록된 사진이 없습니다.',
                          style: TextStyle(
                            color: _secondaryText,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _pickImages,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('사진 추가'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _blue,
                      side: BorderSide(
                        color: _blue.withValues(alpha: 0.6),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _cardSoft,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    '현재 버전은 사진 목록만 수정합니다.\n거리, 시간, 페이스, 좋아요 수는 수정하지 않습니다.',
                    style: TextStyle(
                      color: _secondaryText,
                      height: 1.45,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: const Center(
                child: CircularProgressIndicator(
                  color: _blue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EditableImageTile extends StatelessWidget {
  final String? imageUrl;
  final File? file;
  final VoidCallback? onRemove;

  const _EditableImageTile.network({
    required this.imageUrl,
    required this.onRemove,
  }) : file = null;

  const _EditableImageTile.file({
    required this.file,
    required this.onRemove,
  }) : imageUrl = null;

  static const Color _cardSoft = Color(0xFF1D2630);
  static const Color _danger = Color(0xFFFF5A5F);
  static const Color _secondaryText = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: radius,
          child: Container(
            color: _cardSoft,
            width: double.infinity,
            height: double.infinity,
            child: file != null
                ? Image.file(
                    file!,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: _secondaryText,
                        ),
                      );
                    },
                  ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: _danger,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: _secondaryText,
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}