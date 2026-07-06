// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blockUser_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(blockRepository)
final blockRepositoryProvider = BlockRepositoryProvider._();

final class BlockRepositoryProvider
    extends
        $FunctionalProvider<BlockRepository, BlockRepository, BlockRepository>
    with $Provider<BlockRepository> {
  BlockRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockRepositoryHash();

  @$internal
  @override
  $ProviderElement<BlockRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BlockRepository create(Ref ref) {
    return blockRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BlockRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BlockRepository>(value),
    );
  }
}

String _$blockRepositoryHash() => r'7916c7c946de8554aee349e58cd8adfa56da16c7';

@ProviderFor(myBlockedUserIds)
final myBlockedUserIdsProvider = MyBlockedUserIdsProvider._();

final class MyBlockedUserIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          Stream<List<String>>
        >
    with $FutureModifier<List<String>>, $StreamProvider<List<String>> {
  MyBlockedUserIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myBlockedUserIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myBlockedUserIdsHash();

  @$internal
  @override
  $StreamProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<String>> create(Ref ref) {
    return myBlockedUserIds(ref);
  }
}

String _$myBlockedUserIdsHash() => r'008313b9202f421348a02859914bd72b82eff545';

@ProviderFor(isBlockedByMe)
final isBlockedByMeProvider = IsBlockedByMeFamily._();

final class IsBlockedByMeProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  IsBlockedByMeProvider._({
    required IsBlockedByMeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isBlockedByMeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isBlockedByMeHash();

  @override
  String toString() {
    return r'isBlockedByMeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isBlockedByMe(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsBlockedByMeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isBlockedByMeHash() => r'0beea0acc2bddfd69dcb84f6548f5d9799152cb6';

final class IsBlockedByMeFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  IsBlockedByMeFamily._()
    : super(
        retry: null,
        name: r'isBlockedByMeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsBlockedByMeProvider call(String targetUid) =>
      IsBlockedByMeProvider._(argument: targetUid, from: this);

  @override
  String toString() => r'isBlockedByMeProvider';
}

@ProviderFor(isBlockedEitherWay)
final isBlockedEitherWayProvider = IsBlockedEitherWayFamily._();

final class IsBlockedEitherWayProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  IsBlockedEitherWayProvider._({
    required IsBlockedEitherWayFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isBlockedEitherWayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isBlockedEitherWayHash();

  @override
  String toString() {
    return r'isBlockedEitherWayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return isBlockedEitherWay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsBlockedEitherWayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isBlockedEitherWayHash() =>
    r'ebef2fc6433202b265f1b02a0853dcb56957519e';

final class IsBlockedEitherWayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsBlockedEitherWayFamily._()
    : super(
        retry: null,
        name: r'isBlockedEitherWayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsBlockedEitherWayProvider call(String targetUid) =>
      IsBlockedEitherWayProvider._(argument: targetUid, from: this);

  @override
  String toString() => r'isBlockedEitherWayProvider';
}
