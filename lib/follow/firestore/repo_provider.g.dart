// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(followRepository)
final followRepositoryProvider = FollowRepositoryProvider._();

final class FollowRepositoryProvider
    extends
        $FunctionalProvider<
          FollowRepository,
          FollowRepository,
          FollowRepository
        >
    with $Provider<FollowRepository> {
  FollowRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followRepositoryHash();

  @$internal
  @override
  $ProviderElement<FollowRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FollowRepository create(Ref ref) {
    return followRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FollowRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FollowRepository>(value),
    );
  }
}

String _$followRepositoryHash() => r'a3236265ea6273782ae47adda7893bf62666e961';

@ProviderFor(isFollowing)
final isFollowingProvider = IsFollowingFamily._();

final class IsFollowingProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  IsFollowingProvider._({
    required IsFollowingFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'isFollowingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFollowingHash();

  @override
  String toString() {
    return r'isFollowingProvider'
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
    return isFollowing(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFollowingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFollowingHash() => r'c444d064097a30029b44155c974f6e9510fd5369';

final class IsFollowingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, (String, String)> {
  IsFollowingFamily._()
    : super(
        retry: null,
        name: r'isFollowingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsFollowingProvider call(String myUid, String targetUid) =>
      IsFollowingProvider._(argument: (myUid, targetUid), from: this);

  @override
  String toString() => r'isFollowingProvider';
}

@ProviderFor(followersCount)
final followersCountProvider = FollowersCountFamily._();

final class FollowersCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  FollowersCountProvider._({
    required FollowersCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followersCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followersCountHash();

  @override
  String toString() {
    return r'followersCountProvider'
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
    return followersCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowersCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followersCountHash() => r'b8d5a860929018ffbaa7d550597ffcbcf2f3abe7';

final class FollowersCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  FollowersCountFamily._()
    : super(
        retry: null,
        name: r'followersCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowersCountProvider call(String userId) =>
      FollowersCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'followersCountProvider';
}

@ProviderFor(followingsCount)
final followingsCountProvider = FollowingsCountFamily._();

final class FollowingsCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  FollowingsCountProvider._({
    required FollowingsCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followingsCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followingsCountHash();

  @override
  String toString() {
    return r'followingsCountProvider'
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
    return followingsCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowingsCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followingsCountHash() => r'a7866be69301b1305d5767af09f286fbce107648';

final class FollowingsCountFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  FollowingsCountFamily._()
    : super(
        retry: null,
        name: r'followingsCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowingsCountProvider call(String userId) =>
      FollowingsCountProvider._(argument: userId, from: this);

  @override
  String toString() => r'followingsCountProvider';
}

@ProviderFor(followersList)
final followersListProvider = FollowersListFamily._();

final class FollowersListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  FollowersListProvider._({
    required FollowersListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followersListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followersListHash();

  @override
  String toString() {
    return r'followersListProvider'
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
    return followersList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowersListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followersListHash() => r'cbbc4949594ff306acfc91f31715b3fbee9e58b6';

final class FollowersListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  FollowersListFamily._()
    : super(
        retry: null,
        name: r'followersListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowersListProvider call(String userId) =>
      FollowersListProvider._(argument: userId, from: this);

  @override
  String toString() => r'followersListProvider';
}

@ProviderFor(followingsList)
final followingsListProvider = FollowingsListFamily._();

final class FollowingsListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  FollowingsListProvider._({
    required FollowingsListFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followingsListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followingsListHash();

  @override
  String toString() {
    return r'followingsListProvider'
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
    return followingsList(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowingsListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followingsListHash() => r'f81b57a2916e4c789df34ec4c22ad73e2063205a';

final class FollowingsListFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  FollowingsListFamily._()
    : super(
        retry: null,
        name: r'followingsListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowingsListProvider call(String userId) =>
      FollowingsListProvider._(argument: userId, from: this);

  @override
  String toString() => r'followingsListProvider';
}

@ProviderFor(followStatus)
final followStatusProvider = FollowStatusFamily._();

final class FollowStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<FollowState>,
          FollowState,
          Stream<FollowState>
        >
    with $FutureModifier<FollowState>, $StreamProvider<FollowState> {
  FollowStatusProvider._({
    required FollowStatusFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'followStatusProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followStatusHash();

  @override
  String toString() {
    return r'followStatusProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<FollowState> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<FollowState> create(Ref ref) {
    final argument = this.argument as (String, String);
    return followStatus(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FollowStatusProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followStatusHash() => r'd9bf653ba4a031af8ae7eb022c53b681ce5f5a30';

final class FollowStatusFamily extends $Family
    with $FunctionalFamilyOverride<Stream<FollowState>, (String, String)> {
  FollowStatusFamily._()
    : super(
        retry: null,
        name: r'followStatusProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FollowStatusProvider call(String myUid, String targetUid) =>
      FollowStatusProvider._(argument: (myUid, targetUid), from: this);

  @override
  String toString() => r'followStatusProvider';
}
