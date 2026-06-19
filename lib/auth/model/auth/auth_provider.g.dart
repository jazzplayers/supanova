// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userAuthRepository)
final userAuthRepositoryProvider = UserAuthRepositoryProvider._();

final class UserAuthRepositoryProvider
    extends
        $FunctionalProvider<
          UserAuthRepository,
          UserAuthRepository,
          UserAuthRepository
        >
    with $Provider<UserAuthRepository> {
  UserAuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userAuthRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userAuthRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserAuthRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UserAuthRepository create(Ref ref) {
    return userAuthRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserAuthRepository>(value),
    );
  }
}

String _$userAuthRepositoryHash() =>
    r'97f5b9e03334d15d591fee5561a83f006f771556';

/// Firebase Auth 로그인 상태 감지용
/// UserAuthRepositoryImpl 안의 _ensureUserFields()가 여기서도 실행됨.

@ProviderFor(userAuthStateChanges)
final userAuthStateChangesProvider = UserAuthStateChangesProvider._();

/// Firebase Auth 로그인 상태 감지용
/// UserAuthRepositoryImpl 안의 _ensureUserFields()가 여기서도 실행됨.

final class UserAuthStateChangesProvider
    extends $FunctionalProvider<AsyncValue<User?>, User?, Stream<User?>>
    with $FutureModifier<User?>, $StreamProvider<User?> {
  /// Firebase Auth 로그인 상태 감지용
  /// UserAuthRepositoryImpl 안의 _ensureUserFields()가 여기서도 실행됨.
  UserAuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userAuthStateChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userAuthStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<User?> create(Ref ref) {
    return userAuthStateChanges(ref);
  }
}

String _$userAuthStateChangesHash() =>
    r'ca8f1fd57234d84d3df75b8109e86f216175da55';

@ProviderFor(userAuthData)
final userAuthDataProvider = UserAuthDataFamily._();

final class UserAuthDataProvider
    extends $FunctionalProvider<AsyncValue<Auth?>, Auth?, Stream<Auth?>>
    with $FutureModifier<Auth?>, $StreamProvider<Auth?> {
  UserAuthDataProvider._({
    required UserAuthDataFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userAuthDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userAuthDataHash();

  @override
  String toString() {
    return r'userAuthDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Auth?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Auth?> create(Ref ref) {
    final argument = this.argument as String;
    return userAuthData(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserAuthDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userAuthDataHash() => r'0132fc16e86f49a1f45df0c475a7375bd8547687';

final class UserAuthDataFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Auth?>, String> {
  UserAuthDataFamily._()
    : super(
        retry: null,
        name: r'userAuthDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UserAuthDataProvider call(String uid) =>
      UserAuthDataProvider._(argument: uid, from: this);

  @override
  String toString() => r'userAuthDataProvider';
}

@ProviderFor(userSignOut)
final userSignOutProvider = UserSignOutProvider._();

final class UserSignOutProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  UserSignOutProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userSignOutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userSignOutHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return userSignOut(ref);
  }
}

String _$userSignOutHash() => r'9a200b6cf562cd1417bee446ee3182a7826dc78d';

@ProviderFor(deleteAccount)
final deleteAccountProvider = DeleteAccountProvider._();

final class DeleteAccountProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  DeleteAccountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteAccountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return deleteAccount(ref);
  }
}

String _$deleteAccountHash() => r'1e433c3e2ea5f5a926658e14d31f1019d8809706';

@ProviderFor(myUid)
final myUidProvider = MyUidProvider._();

final class MyUidProvider extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  MyUidProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myUidProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myUidHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return myUid(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$myUidHash() => r'18ae167e761a9741b5af8343bd5010d75a67cccd';

@ProviderFor(updateUserData)
final updateUserDataProvider = UpdateUserDataFamily._();

final class UpdateUserDataProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  UpdateUserDataProvider._({
    required UpdateUserDataFamily super.from,
    required ({
      String uid,
      String? displayName,
      String? profileImageUrl,
      String? bio,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'updateUserDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$updateUserDataHash();

  @override
  String toString() {
    return r'updateUserDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument =
        this.argument
            as ({
              String uid,
              String? displayName,
              String? profileImageUrl,
              String? bio,
            });
    return updateUserData(
      ref,
      uid: argument.uid,
      displayName: argument.displayName,
      profileImageUrl: argument.profileImageUrl,
      bio: argument.bio,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateUserDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$updateUserDataHash() => r'dccff04d977ff086ebed31b226fac0d5fed533d8';

final class UpdateUserDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<void>,
          ({
            String uid,
            String? displayName,
            String? profileImageUrl,
            String? bio,
          })
        > {
  UpdateUserDataFamily._()
    : super(
        retry: null,
        name: r'updateUserDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UpdateUserDataProvider call({
    required String uid,
    String? displayName,
    String? profileImageUrl,
    String? bio,
  }) => UpdateUserDataProvider._(
    argument: (
      uid: uid,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      bio: bio,
    ),
    from: this,
  );

  @override
  String toString() => r'updateUserDataProvider';
}

@ProviderFor(isDisplayNameAvailable)
final isDisplayNameAvailableProvider = IsDisplayNameAvailableFamily._();

final class IsDisplayNameAvailableProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  IsDisplayNameAvailableProvider._({
    required IsDisplayNameAvailableFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isDisplayNameAvailableProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isDisplayNameAvailableHash();

  @override
  String toString() {
    return r'isDisplayNameAvailableProvider'
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
    return isDisplayNameAvailable(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsDisplayNameAvailableProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isDisplayNameAvailableHash() =>
    r'80a598abed3122e6daabcec4a2b2a8628edaadd9';

final class IsDisplayNameAvailableFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsDisplayNameAvailableFamily._()
    : super(
        retry: null,
        name: r'isDisplayNameAvailableProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  IsDisplayNameAvailableProvider call(String displayName) =>
      IsDisplayNameAvailableProvider._(argument: displayName, from: this);

  @override
  String toString() => r'isDisplayNameAvailableProvider';
}

@ProviderFor(signInWithGoogle)
final signInWithGoogleProvider = SignInWithGoogleProvider._();

final class SignInWithGoogleProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  SignInWithGoogleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInWithGoogleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInWithGoogleHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return signInWithGoogle(ref);
  }
}

String _$signInWithGoogleHash() => r'7449b8fdf185389a2fb790352ae64fea79270eb3';
