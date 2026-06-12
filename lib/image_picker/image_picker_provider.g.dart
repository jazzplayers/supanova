// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_picker_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(imagePickerService)
final imagePickerServiceProvider = ImagePickerServiceProvider._();

final class ImagePickerServiceProvider
    extends
        $FunctionalProvider<
          ImagePickerService,
          ImagePickerService,
          ImagePickerService
        >
    with $Provider<ImagePickerService> {
  ImagePickerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imagePickerServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imagePickerServiceHash();

  @$internal
  @override
  $ProviderElement<ImagePickerService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImagePickerService create(Ref ref) {
    return imagePickerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImagePickerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImagePickerService>(value),
    );
  }
}

String _$imagePickerServiceHash() =>
    r'a63d69fa8a81519538a0ebcc9e1e43ca932f2447';

@ProviderFor(imageUploadService)
final imageUploadServiceProvider = ImageUploadServiceProvider._();

final class ImageUploadServiceProvider
    extends
        $FunctionalProvider<
          ImageUploadService,
          ImageUploadService,
          ImageUploadService
        >
    with $Provider<ImageUploadService> {
  ImageUploadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageUploadServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageUploadServiceHash();

  @$internal
  @override
  $ProviderElement<ImageUploadService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImageUploadService create(Ref ref) {
    return imageUploadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageUploadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageUploadService>(value),
    );
  }
}

String _$imageUploadServiceHash() =>
    r'cc33443840aec7b87aaa1516259dcb707d0d5102';

@ProviderFor(uploadImageFile)
final uploadImageFileProvider = UploadImageFileFamily._();

final class UploadImageFileProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  UploadImageFileProvider._({
    required UploadImageFileFamily super.from,
    required ({File file, String path}) super.argument,
  }) : super(
         retry: null,
         name: r'uploadImageFileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$uploadImageFileHash();

  @override
  String toString() {
    return r'uploadImageFileProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as ({File file, String path});
    return uploadImageFile(ref, file: argument.file, path: argument.path);
  }

  @override
  bool operator ==(Object other) {
    return other is UploadImageFileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$uploadImageFileHash() => r'facb482d292c196b73df9ec4d73d4630872611a0';

final class UploadImageFileFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String>,
          ({File file, String path})
        > {
  UploadImageFileFamily._()
    : super(
        retry: null,
        name: r'uploadImageFileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UploadImageFileProvider call({required File file, required String path}) =>
      UploadImageFileProvider._(argument: (file: file, path: path), from: this);

  @override
  String toString() => r'uploadImageFileProvider';
}

@ProviderFor(uploadImageFiles)
final uploadImageFilesProvider = UploadImageFilesFamily._();

final class UploadImageFilesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  UploadImageFilesProvider._({
    required UploadImageFilesFamily super.from,
    required ({List<File> files, String path}) super.argument,
  }) : super(
         retry: null,
         name: r'uploadImageFilesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$uploadImageFilesHash();

  @override
  String toString() {
    return r'uploadImageFilesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as ({List<File> files, String path});
    return uploadImageFiles(ref, files: argument.files, path: argument.path);
  }

  @override
  bool operator ==(Object other) {
    return other is UploadImageFilesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$uploadImageFilesHash() => r'088e6bffbff7e6168b5aae80c13f027b6b725ffb';

final class UploadImageFilesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<String>>,
          ({List<File> files, String path})
        > {
  UploadImageFilesFamily._()
    : super(
        retry: null,
        name: r'uploadImageFilesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UploadImageFilesProvider call({
    required List<File> files,
    required String path,
  }) => UploadImageFilesProvider._(
    argument: (files: files, path: path),
    from: this,
  );

  @override
  String toString() => r'uploadImageFilesProvider';
}

@ProviderFor(deleteImageFile)
final deleteImageFileProvider = DeleteImageFileFamily._();

final class DeleteImageFileProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  DeleteImageFileProvider._({
    required DeleteImageFileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deleteImageFileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteImageFileHash();

  @override
  String toString() {
    return r'deleteImageFileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as String;
    return deleteImageFile(ref, imageUrl: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteImageFileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteImageFileHash() => r'832b557c4dfca56b3c73d735ab1dc930461e04e8';

final class DeleteImageFileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, String> {
  DeleteImageFileFamily._()
    : super(
        retry: null,
        name: r'deleteImageFileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteImageFileProvider call({required String imageUrl}) =>
      DeleteImageFileProvider._(argument: imageUrl, from: this);

  @override
  String toString() => r'deleteImageFileProvider';
}

@ProviderFor(deleteImageFiles)
final deleteImageFilesProvider = DeleteImageFilesFamily._();

final class DeleteImageFilesProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  DeleteImageFilesProvider._({
    required DeleteImageFilesFamily super.from,
    required List<String> super.argument,
  }) : super(
         retry: null,
         name: r'deleteImageFilesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deleteImageFilesHash();

  @override
  String toString() {
    return r'deleteImageFilesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as List<String>;
    return deleteImageFiles(ref, imageUrls: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeleteImageFilesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deleteImageFilesHash() => r'3f22d4e57a766c077187b63dc9dbb51e61b46362';

final class DeleteImageFilesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, List<String>> {
  DeleteImageFilesFamily._()
    : super(
        retry: null,
        name: r'deleteImageFilesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DeleteImageFilesProvider call({required List<String> imageUrls}) =>
      DeleteImageFilesProvider._(argument: imageUrls, from: this);

  @override
  String toString() => r'deleteImageFilesProvider';
}

@ProviderFor(WorkoutFinishImages)
final workoutFinishImagesProvider = WorkoutFinishImagesProvider._();

final class WorkoutFinishImagesProvider
    extends $NotifierProvider<WorkoutFinishImages, List<File>> {
  WorkoutFinishImagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'workoutFinishImagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$workoutFinishImagesHash();

  @$internal
  @override
  WorkoutFinishImages create() => WorkoutFinishImages();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<File> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<File>>(value),
    );
  }
}

String _$workoutFinishImagesHash() =>
    r'2e8224e986f9e7b47cab331d3882e6abaee22802';

abstract class _$WorkoutFinishImages extends $Notifier<List<File>> {
  List<File> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<File>, List<File>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<File>, List<File>>,
              List<File>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
