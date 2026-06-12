// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_service/follow_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(followService)
final followServiceProvider = FollowServiceProvider._();

final class FollowServiceProvider
    extends $FunctionalProvider<FollowService, FollowService, FollowService>
    with $Provider<FollowService> {
  FollowServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followServiceHash();

  @$internal
  @override
  $ProviderElement<FollowService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FollowService create(Ref ref) {
    return followService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FollowService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FollowService>(value),
    );
  }
}

String _$followServiceHash() => r'9d65ad084c0589ae55250f567e2312a4fae804be';
