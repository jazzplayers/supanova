import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';


abstract class ImageUploadService {
  Future<String> uploadImageFile({required File file, required String path});
  Future<List<String>> uploadImageFiles({required List<File> files, required String path});
  Future<void> deleteImageFile({required String imageUrl});
  Future<void> deleteImageFiles({required List<String> imageUrls});
}

class ImageUploadServiceImpl implements ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// _getExtension()는 파일의 확장자를 추출하는 기능을 제공하는 메서드입니다.
  /// _getExtension() 메서드는 pick한 파일에서 확장자를 추출하는 기능을 제공하는 메서드입니다.
  String _getExtension(File file) {
    final filePath = file.path;
    ///lastIndexOf('.')는 파일 경로에서 마지막으로 나타나는 '.'의 위치를 찾습니다.
    final lastDotIndex = filePath.lastIndexOf('.');
    ///lastDotIndex가 -1이면 파일 경로에 '.'이 없다는 의미이고, lastDotIndex가 filePath.length - 1이면 파일 경로가 '.'로 끝난다는 의미입니다.
    ///lastIndexOf() 에서 찾는 값이 있으면 index를 반환하고 찾는 값이 없으면 -1을 반환합니다. 따라서 lastDotIndex가 -1이면 파일 경로에 '.'이 없다는 의미입니다.
    ///filePath.length - 1은 파일 경로의 마지막 인덱스를 나타냅니다. 따라서 lastDotIndex가 filePath.length - 1이면 파일 경로가 '.'로 끝난다는 의미입니다.
    if (lastDotIndex == -1 || lastDotIndex == filePath.length -1) {
      throw ArgumentError('File does not have a valid extension: ${file.path}');
    }
    ///substring()는 문자열에서 특정 부분을 추출하는 메서드입니다. 여기서는 lastDotIndex + 1부터 문자열의 끝까지를 추출하여 확장자를 얻습니다.
    final ext = filePath.substring(lastDotIndex + 1).toLowerCase();
    return ext;
  }

/// _getContentType()는 파일 확장자에 해당하는 MIME 타입을 반환하는 기능을 제공하는 메서드입니다.
/// MIME 타입은 인터넷에서 파일의 형식을 나타내는 표준 방식입니다. 
/// 예를 들어, 'image/jpeg'는 JPEG 이미지 파일을 나타내며, 'image/png'는 PNG 이미지 파일을 나타냅니다.
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


/// uploadImageFile()는 단일 이미지 파일을 Firebase Storage에 업로드하는 기능을 제공하는 메서드입니다.
  @override
  Future<String> uploadImageFile({
    required File file,
    required String path,
  }) async {
    try {
      ///ext 는 확장자 ß
      final ext = _getExtension(file);
      /// contentType은 업로드되는 파일의 MIME 타입을 지정하는 속성입니다.
      /// 예를 들어, 'image/jpeg'는 JPEG 이미지 파일을 나타내며,
      /// 'image/png'는 PNG 이미지 파일을 나타냅니다.
      final contentType = _getContentType(ext);
      /// ref는 Firebase Storage에서 파일을 저장할 위치를 나타내는 객체입니다.
      /// ref()는 나뭇가지 구조에서 특정 위치를 참조하는 메서드입니다.
      /// child(path)는 ref()로 참조된 위치에서 하위 경로를 지정하는 메서드입니다.
      /// 예를 들어 path가 'images/photo.jpg'라면, 
      /// ref.child(path)는 'images/photo.jpg' 위치를 참조하게 됩니다.
      /// 즉, _storage.ref().child(path) 의 전체 결과 예시를 들자면,
      /// _storage.ref().child('images/photo.jpg')는 Firebase Storage의 
      /// 'images/photo.jpg' 위치를 참조하는 객체가 됩니다.
      /// users/{userId}/workoutFinishes/{workoutFinishId}/images/photo.jpg 
      /// 와 같은 경로를 참조할 수 있습니다.
      /// [path] 는 must not include a file extension.
      /// Example: users/{uid}/profile/image
      final ref = _storage.ref().child('$path.$ext');
      /// task는 파일 업로드 작업을 나타내는 객체입니다.
      /// putFile() 메서드는 파일을 Firebase Storage에 업로드하는 기능을 제공,
      /// SettableMetadata(contentType: 'image/jpeg')는
      /// 업로드되는 파일의 메타데이터를 설정하는 부분입니다. 
      /// 여기서는 contentType을 'image/jpeg'로 지정하여 
      /// 업로드되는 파일이 JPEG 이미지임을 명시적으로 나타냅니다.
      /// 이렇게 하면 Firebase Storage에서 해당 파일을 올바르게 처리할 수 있습니다.
      /// 나중에 파일을 다운로드하거나 사용할 때도 올바른 콘텐츠 유형이 적용됩니다.
      /// 
      /// SettableMetadata는 Firebase Storage에 업로드되는 파일의 메타데이터를 설정하는 클래스입니다.
      /// contentType은 업로드되는 파일의 MIME 타입을 지정하는 속성입니다.
      /// 예를 들어, 'image/jpeg'는 JPEG 이미지 파일을 나타내며,
      /// 'image/png'는 PNG 이미지 파일을 나타냅니다.
      ///
      /// getDownloadURL()는 업로드된 파일의 다운로드 URL을 가져오는 메서드이다.
      final task = await ref.putFile(file, SettableMetadata(contentType: contentType));
      /// task.ref.getDownloadURL()는 업로드된 파일의 다운로드 URL을 가져오는 메서드입니다.
      return await task.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> uploadImageFiles({
    required List<File> files,
    required String path,
  }) async {
    try {
      /// entries - List의 인덱스와 값을 함께 반환하는 메서드
      /// asMap()는 List를 Map으로 변환하는 메서드로, 인덱스를 키로 사용하여 List의 요소에 접근할 수 있게 해줌
      /// 따라서 files.asMap().entries는 List<File>을 Map<int, File>로 변환한 후, 각 요소의 인덱스와 값을 함께 반환하는Iterable<MapEntry<int, File>>를 생성
      /// 예를 들어, files가 [fileA, fileB, fileC]라면, files.asMap().entries는 [(0, fileA), (1, fileB), (2, fileC)]와 같은 형태로 반환됨
      /// 따라서 map() 메서드 내에서 entry.key는 파일의 인덱스(0, 1, 2 등)를 나타내고, entry.value는 해당 인덱스에 위치한 File 객체를 나타냄
      /// 이렇게 하면 각 파일을 고유한 이름으로 저장할 수 있게 됨 (예: image_0.jpg, image_1.jpg 등)
        final futures = files.asMap().entries.map((entry) async {
        final index = entry.key;
        final file = entry.value;
        final ext = _getExtension(file);
        final contentType = _getContentType(ext);
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$index.$ext';

        final ref = _storage.ref().child('$path/$fileName');

        final task = await ref.putFile(
          file,
          SettableMetadata(contentType: contentType),
        );

        return await task.ref.getDownloadURL();
      });

      return Future.wait(futures);
    } catch (e) {
      /// rethrow는 catch 블록에서 예외를 다시 던지는 키워드입니다.
      /// 예외를 처리한 후에도 예외가 발생한 원래 위치로 예외를 전달하여 상위 호출자에서 예외를 처리할 수 있도록 합니다.
      /// 예를 들어, uploadImageFiles() 메서드에서 예외가 발생하면, catch 블록에서 예외를 처리한 후 rethrow를 사용하여 예외를 다시 던집니다.
      /// 이렇게 하면 uploadImageFiles() 메서드를 호출한 상위 코드에서 예외를 처리할 수 있게 됩니다. rethrow를 사용하지 않으면,
      /// 예외가 catch 블록에서 처리된 것으로 간주되어 상위 호출자에서는 예외를 인식하지 못하게 됩니다.
      rethrow;
    }
  }

  @override
  Future<void> deleteImageFile({required String imageUrl}) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteImageFiles({required List<String> imageUrls}) async {
    try {
      final futures = imageUrls.map((url) async {
        final ref = _storage.refFromURL(url);
        await ref.delete();
      });
      await Future.wait(futures);
    } catch (e) {
      rethrow;
    }
  } 
}