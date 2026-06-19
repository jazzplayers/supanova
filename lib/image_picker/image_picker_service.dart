import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

abstract class ImagePickerService {
  Future<File?> pickSingleImageFromGallery();
  Future<File?> pickImageFromCamera();
  Future<List<File>> pickMultipleImages();
}

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// ======================
  /// 이미지 압축 공통 메서드
  /// ======================
  Future<File> _compressImage(
    File originalFile, {
    required int maxWidth,
    required int maxHeight,
    int quality = 70,
  }) async {
    try {
      final targetPath =
          '${Directory.systemTemp.path}/supanova_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final compressedXFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        targetPath,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );

      if (compressedXFile == null) {
        return originalFile;
      }

      final compressedFile = File(compressedXFile.path);

      final originalSize = await originalFile.length();
      final compressedSize = await compressedFile.length();

      /// 압축했는데 오히려 용량이 커지면 원본 사용
      if (compressedSize >= originalSize) {
        return originalFile;
      }

      return compressedFile;
    } catch (_) {
      /// 압축 실패해도 앱이 죽지 않게 원본 반환
      return originalFile;
    }
  }

  /// pickSingleImageFromGallery()는 갤러리에서 단일 이미지를 선택하는 기능을 제공하는 메서드입니다.
  ///
  /// ---------------------
  /// 프로필 사진 등록할 때 사용
  /// ---------------------
  @override
  Future<File?> pickSingleImageFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked == null) return null;

    final originalFile = File(picked.path);

    return _compressImage(
      originalFile,
      maxWidth: 1024,
      maxHeight: 1024,
      quality: 70,
    );
  }

  /// ---------------------
  /// 사진 하나만 등록할 때
  /// ---------------------
  @override
  Future<File?> pickImageFromCamera() async {
    final pickedImage = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) return null;

    final originalFile = File(pickedImage.path);

    return _compressImage(
      originalFile,
      maxWidth: 1280,
      maxHeight: 1280,
      quality: 70,
    );
  }

  /// ======================
  /// 운동 기록 사진 등록할 때 사용
  /// ======================
  @override
  Future<List<File>> pickMultipleImages() async {
    final pickedImages = await _picker.pickMultiImage();

    if (pickedImages.isEmpty) {
      return [];
    }

    final compressedImages = <File>[];

    for (final xFile in pickedImages) {
      final originalFile = File(xFile.path);

      final compressedFile = await _compressImage(
        originalFile,
        maxWidth: 1280,
        maxHeight: 1280,
        quality: 70,
      );

      compressedImages.add(compressedFile);
    }

    return compressedImages;
  }
}