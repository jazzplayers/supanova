import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'image_picker_service.dart';
import 'image_upload_service.dart';

part 'image_picker_provider.g.dart';

@riverpod
ImagePickerService imagePickerService(Ref ref) {
  return ImagePickerServiceImpl();
}

@riverpod
ImageUploadService imageUploadService(Ref ref) {
  return ImageUploadServiceImpl();
}

/// ======================
/// 단일 이미지 업로드
/// ======================
@riverpod
Future<String> uploadImageFile(
  Ref ref, {
  required File file,
  required String path,
}) {
  final imageUploadService = ref.read(imageUploadServiceProvider);

  return imageUploadService.uploadImageFile(
    file: file,
    path: path,
  );
}

/// ======================
/// 여러 이미지 업로드
/// ======================
@riverpod
Future<List<String>> uploadImageFiles(
  Ref ref, {
  required List<File> files,
  required String path,
}) {
  if (files.isEmpty) {
    return Future.value([]);
  }

  final imageUploadService = ref.read(imageUploadServiceProvider);

  return imageUploadService.uploadImageFiles(
    files: files,
    path: path,
  );
}

/// ======================
/// 단일 이미지 삭제
/// ======================
@riverpod
Future<void> deleteImageFile(
  Ref ref, {
  required String imageUrl,
}) {
  if (imageUrl.trim().isEmpty) {
    return Future.value();
  }

  final imageUploadService = ref.read(imageUploadServiceProvider);

  return imageUploadService.deleteImageFile(
    imageUrl: imageUrl,
  );
}

/// ======================
/// 여러 이미지 삭제
/// ======================
@riverpod
Future<void> deleteImageFiles(
  Ref ref, {
  required List<String> imageUrls,
}) {
  final filteredUrls = imageUrls
      .where((url) => url.trim().isNotEmpty)
      .toList();

  if (filteredUrls.isEmpty) {
    return Future.value();
  }

  final imageUploadService = ref.read(imageUploadServiceProvider);

  return imageUploadService.deleteImageFiles(
    imageUrls: filteredUrls,
  );
}

/// ======================
/// 운동 완료 이미지 선택 상태
/// ======================
@riverpod
class WorkoutFinishImages extends _$WorkoutFinishImages {
  static const int maxImageCount = 5;

  @override
  List<File> build() => [];

  int get count => state.length;

  int get remainingCount {
    final remaining = maxImageCount - state.length;
    return remaining < 0 ? 0 : remaining;
  }

  bool get canAddMore => state.length < maxImageCount;

  bool get isEmpty => state.isEmpty;

  bool get isNotEmpty => state.isNotEmpty;

  void setImages(List<File> files) {
    state = _normalizeFiles(files);
  }

  void addImage(File file) {
    if (!canAddMore) return;

    state = _normalizeFiles([
      ...state,
      file,
    ]);
  }

  void addImages(List<File> files) {
    if (files.isEmpty) return;
    if (!canAddMore) return;

    state = _normalizeFiles([
      ...state,
      ...files,
    ]);
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.length) return;

    final copied = [...state];
    copied.removeAt(index);

    state = copied;
  }

  void removeImageFile(File file) {
    state = state.where((item) => item.path != file.path).toList();
  }

  void clear() {
    state = [];
  }

  List<File> _normalizeFiles(List<File> files) {
    final result = <File>[];
    final seenPaths = <String>{};

    for (final file in files) {
      if (seenPaths.contains(file.path)) {
        continue;
      }

      seenPaths.add(file.path);
      result.add(file);

      if (result.length >= maxImageCount) {
        break;
      }
    }

    return result;
  }
}