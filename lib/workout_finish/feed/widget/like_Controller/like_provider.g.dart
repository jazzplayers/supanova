// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(likeService)
final likeServiceProvider = LikeServiceProvider._();

final class LikeServiceProvider
    extends $FunctionalProvider<LikeService, LikeService, LikeService>
    with $Provider<LikeService> {
  LikeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'likeServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$likeServiceHash();

  @$internal
  @override
  $ProviderElement<LikeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LikeService create(Ref ref) {
    return likeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LikeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LikeService>(value),
    );
  }
}

String _$likeServiceHash() => r'43350aac5098cf0e4624a4d5852f4d15f31dcf9e';

@ProviderFor(likeRepository)
final likeRepositoryProvider = LikeRepositoryProvider._();

final class LikeRepositoryProvider
    extends $FunctionalProvider<LikeRepository, LikeRepository, LikeRepository>
    with $Provider<LikeRepository> {
  LikeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'likeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$likeRepositoryHash();

  @$internal
  @override
  $ProviderElement<LikeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LikeRepository create(Ref ref) {
    return likeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LikeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LikeRepository>(value),
    );
  }
}

String _$likeRepositoryHash() => r'2080703cb356e9e06c9d71deb1b96524f67096f5';

@ProviderFor(likeCount)
final likeCountProvider = LikeCountFamily._();

final class LikeCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  LikeCountProvider._({
    required LikeCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'likeCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$likeCountHash();

  @override
  String toString() {
    return r'likeCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as String;
    return likeCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LikeCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$likeCountHash() => r'8be1f7dddf08f22cf587c3231ee5baab1a8bd379';

final class LikeCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  LikeCountFamily._()
    : super(
        retry: null,
        name: r'likeCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LikeCountProvider call(String workoutFinishId) =>
      LikeCountProvider._(argument: workoutFinishId, from: this);

  @override
  String toString() => r'likeCountProvider';
}

@ProviderFor(likedUserIds)
final likedUserIdsProvider = LikedUserIdsFamily._();

final class LikedUserIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  LikedUserIdsProvider._({
    required LikedUserIdsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'likedUserIdsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$likedUserIdsHash();

  @override
  String toString() {
    return r'likedUserIdsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return likedUserIds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LikedUserIdsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$likedUserIdsHash() => r'b0cc980a298557f888150894fe08d197621bb16e';

final class LikedUserIdsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  LikedUserIdsFamily._()
    : super(
        retry: null,
        name: r'likedUserIdsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LikedUserIdsProvider call(String workoutFinishId) =>
      LikedUserIdsProvider._(argument: workoutFinishId, from: this);

  @override
  String toString() => r'likedUserIdsProvider';
}

@ProviderFor(isLiked)
final isLikedProvider = IsLikedFamily._();

final class IsLikedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  IsLikedProvider._({
    required IsLikedFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'isLikedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isLikedHash();

  @override
  String toString() {
    return r'isLikedProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as (String, String);
    return isLiked(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is IsLikedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isLikedHash() => r'484304db1187d272501a9c476e8fa06b8530e127';

final class IsLikedFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, (String, String)> {
  IsLikedFamily._()
    : super(
        retry: null,
        name: r'isLikedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsLikedProvider call(String workoutFinishId, String myUid) =>
      IsLikedProvider._(argument: (workoutFinishId, myUid), from: this);

  @override
  String toString() => r'isLikedProvider';
}
