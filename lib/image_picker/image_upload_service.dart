import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

abstract class ImageUploadService {
  Future<String> uploadImageFile({
    required File file,
    required String path,
  });

  Future<List<String>> uploadImageFiles({
    required List<File> files,
    required String path,
  });

  Future<void> deleteImageFile({
    required String imageUrl,
  });

  Future<void> deleteImageFiles({
    required List<String> imageUrls,
  });
}

class ImageUploadServiceImpl implements ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static const int _maxWidth = 1600;
  static const int _maxHeight = 1600;
  static const int _quality = 75;

  /// 이 크기보다 작은 이미지는 굳이 압축하지 않음.
  static const int _compressThresholdBytes = 700 * 1024;

  String _getExtension(File file) {
    final filePath = file.path;
    final lastDotIndex = filePath.lastIndexOf('.');

    if (lastDotIndex == -1 || lastDotIndex == filePath.length - 1) {
      throw ArgumentError('File does not have a valid extension: ${file.path}');
    }

    return filePath.substring(lastDotIndex + 1).toLowerCase();
  }

  String _getContentType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        throw ArgumentError('Unsupported file extension: $ext');
    }
  }

  /// 업로드용 이미지 데이터를 준비함.
  ///
  /// 큰 이미지는 JPEG로 압축해서 용량을 줄이고,
  /// 작은 이미지는 원본 그대로 업로드함.
  Future<_PreparedImage> _prepareImage(File file) async {
    final originalExt = _getExtension(file);
    final originalContentType = _getContentType(originalExt);
    final originalSize = await file.length();

    /// GIF는 압축하면 애니메이션이 깨질 수 있으므로 원본 유지.
    if (originalExt == 'gif') {
      return _PreparedImage(
        file: file,
        bytes: null,
        extension: originalExt,
        contentType: originalContentType,
      );
    }

    /// 이미 작은 이미지는 압축하지 않음.
    if (originalSize <= _compressThresholdBytes) {
      return _PreparedImage(
        file: file,
        bytes: null,
        extension: originalExt,
        contentType: originalContentType,
      );
    }

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: _maxWidth,
      minHeight: _maxHeight,
      quality: _quality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    /// 압축 실패 시 원본 업로드
    if (compressedBytes == null) {
      return _PreparedImage(
        file: file,
        bytes: null,
        extension: originalExt,
        contentType: originalContentType,
      );
    }

    /// 압축했는데 오히려 더 크면 원본 업로드
    if (compressedBytes.length >= originalSize) {
      return _PreparedImage(
        file: file,
        bytes: null,
        extension: originalExt,
        contentType: originalContentType,
      );
    }

    /// 압축 성공 시 JPEG로 업로드
    return _PreparedImage(
      file: file,
      bytes: compressedBytes,
      extension: 'jpg',
      contentType: 'image/jpeg',
    );
  }

  Future<String> _uploadPreparedImage({
    required File file,
    required String pathWithoutExtension,
  }) async {
    final preparedImage = await _prepareImage(file);

    final ref = _storage
        .ref()
        .child('$pathWithoutExtension.${preparedImage.extension}');

    final metadata = SettableMetadata(
      contentType: preparedImage.contentType,
    );

    if (preparedImage.bytes != null) {
      await ref.putData(preparedImage.bytes!, metadata);
    } else {
      await ref.putFile(preparedImage.file, metadata);
    }

    return ref.getDownloadURL();
  }

  /// 단일 이미지 업로드
  ///
  /// path 예시:
  /// users/{uid}/profile/image
  ///
  /// 확장자는 자동으로 붙음.
  @override
  Future<String> uploadImageFile({
    required File file,
    required String path,
  }) async {
    return _uploadPreparedImage(
      file: file,
      pathWithoutExtension: path,
    );
  }

  /// 여러 이미지 업로드
  ///
  /// path 예시:
  /// workoutFinish/{workoutFinishId}/images
  @override
  Future<List<String>> uploadImageFiles({
    required List<File> files,
    required String path,
  }) async {
    final now = DateTime.now().microsecondsSinceEpoch;

    final futures = files.asMap().entries.map((entry) {
      final index = entry.key;
      final file = entry.value;

      final filePathWithoutExtension = '$path/${now}_$index';

      return _uploadPreparedImage(
        file: file,
        pathWithoutExtension: filePathWithoutExtension,
      );
    });

    return Future.wait(futures);
  }

  @override
  Future<void> deleteImageFile({
    required String imageUrl,
  }) async {
    final ref = _storage.refFromURL(imageUrl);
    await ref.delete();
  }

  @override
  Future<void> deleteImageFiles({
    required List<String> imageUrls,
  }) async {
    final futures = imageUrls.map((url) async {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    });

    await Future.wait(futures);
  }
}

class _PreparedImage {
  final File file;
  final Uint8List? bytes;
  final String extension;
  final String contentType;

  const _PreparedImage({
    required this.file,
    required this.bytes,
    required this.extension,
    required this.contentType,
  });
}