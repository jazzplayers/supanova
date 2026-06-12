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

@riverpod
Future<List<String>> uploadImageFiles(
  Ref ref, {
  required List<File> files,
  required String path,
}) {
  final imageUploadService = ref.read(imageUploadServiceProvider);

  if (files.isEmpty) {
    return Future.value([]);
  }

  return imageUploadService.uploadImageFiles(
    files: files,
    path: path,
  );
}

@riverpod
Future<void> deleteImageFile(
  Ref ref, {
  required String imageUrl,
}) {
  final imageUploadService = ref.read(imageUploadServiceProvider);

  if (imageUrl.isEmpty) {
    return Future.value();
  }

  return imageUploadService.deleteImageFile(
    imageUrl: imageUrl,
  );
}

@riverpod
Future<void> deleteImageFiles(
  Ref ref, {
  required List<String> imageUrls,
}) {
  final imageUploadService = ref.read(imageUploadServiceProvider);

  if (imageUrls.isEmpty) {
    return Future.value();
  }

  return imageUploadService.deleteImageFiles(
    imageUrls: imageUrls,
  );
}

@riverpod
class WorkoutFinishImages extends _$WorkoutFinishImages {
  @override
  List<File> build() => [];

  void setImages(List<File> files) {
    state = [...files];
  }

  void addImage(File file) {
    state = [...state, file];
  }

  void addImages(List<File> files) {
    if (files.isEmpty) return;

    state = [
      ...state,
      ...files,
    ];
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
}