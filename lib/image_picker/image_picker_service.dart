import 'dart:io';
import 'package:image_picker/image_picker.dart';

abstract class ImagePickerService {
  Future<File?> pickSingleImageFromGallery();
  Future<File?> pickImageFromCamera();
  Future<List<File>> pickMultipleImages();
}

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

///pickSingleImageFromGallery()는 갤러리에서 단일 이미지를 선택하는 기능을 제공하는 메서드입니다.

///---------------------
///프로필 사진 등록할 떄 사용
///---------------------
  @override
  Future<File?> pickSingleImageFromGallery() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (picked == null) return null;
    return File(picked.path);
  }

///---------------------
/// 사진 하나만 등록할 때
///---------------------
  @override
  Future<File?> pickImageFromCamera() async {
    final pickedImage = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedImage == null) return null;
    return File(pickedImage.path);
  }

/// ======================
/// 운동 기록 사진 등록할 때 사용
/// ======================
  @override
  Future<List<File>> pickMultipleImages() async {
    /// 여기에서 _picker.pickMultiImage() 메서드를 누르면,
    /// 사용자가 갤러리에서 여러 이미지를 선택할 수 있는 인터페이스가 나타납니다.
    /// 
    /// 이미지를 여러개 골랐을 때, pickedImages는 List<XFile> 타입이 됩니다.
    /// XFile은 이미지 파일의 경로와 메타데이터를 포함하는 객체입니다.
    final pickedImages = await _picker.pickMultiImage(
      imageQuality: 50,
      maxWidth: 1024,
      maxHeight: 1024,
    );

/// pickedImages는 List<XFile> 타입이다.
/// map 내부의 xFile은 List 안의 "각각의 XFile 객체"를 의미한다.

    return pickedImages.map((xFile) => File(xFile.path)).toList();
  }
}