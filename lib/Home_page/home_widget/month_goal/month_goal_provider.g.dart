// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_goal_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(monthGoalRepo)
final monthGoalRepoProvider = MonthGoalRepoProvider._();

final class MonthGoalRepoProvider
    extends $FunctionalProvider<MonthGoalRepo, MonthGoalRepo, MonthGoalRepo>
    with $Provider<MonthGoalRepo> {
  MonthGoalRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthGoalRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthGoalRepoHash();

  @$internal
  @override
  $ProviderElement<MonthGoalRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MonthGoalRepo create(Ref ref) {
    return monthGoalRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MonthGoalRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MonthGoalRepo>(value),
    );
  }
}

String _$monthGoalRepoHash() => r'aa820f3d76b604baacb165bb0add33ce84eb7cca';

@ProviderFor(monthlyGoal)
final monthlyGoalProvider = MonthlyGoalFamily._();

final class MonthlyGoalProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  MonthlyGoalProvider._({
    required MonthlyGoalFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthlyGoalProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyGoalHash();

  @override
  String toString() {
    return r'monthlyGoalProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as String;
    return monthlyGoal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyGoalProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyGoalHash() => r'c110c6bac8d18332f3adf2c175d7285ff3f8db9d';

final class MonthlyGoalFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, String> {
  MonthlyGoalFamily._()
    : super(
        retry: null,
        name: r'monthlyGoalProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthlyGoalProvider call(String userId) =>
      MonthlyGoalProvider._(argument: userId, from: this);

  @override
  String toString() => r'monthlyGoalProvider';
}

@ProviderFor(monthlyGoalStream)
final monthlyGoalStreamProvider = MonthlyGoalStreamFamily._();

final class MonthlyGoalStreamProvider
    extends $FunctionalProvider<AsyncValue<double>, double, Stream<double>>
    with $FutureModifier<double>, $StreamProvider<double> {
  MonthlyGoalStreamProvider._({
    required MonthlyGoalStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'monthlyGoalStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyGoalStreamHash();

  @override
  String toString() {
    return r'monthlyGoalStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<double> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<double> create(Ref ref) {
    final argument = this.argument as String;
    return monthlyGoalStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyGoalStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyGoalStreamHash() => r'e6a07d1d539a3053e82d1dd73f4265cb3e75c3e0';

final class MonthlyGoalStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<double>, String> {
  MonthlyGoalStreamFamily._()
    : super(
        retry: null,
        name: r'monthlyGoalStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MonthlyGoalStreamProvider call(String userId) =>
      MonthlyGoalStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'monthlyGoalStreamProvider';
}

@ProviderFor(totalDistanceThisDay)
final totalDistanceThisDayProvider = TotalDistanceThisDayFamily._();

final class TotalDistanceThisDayProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  TotalDistanceThisDayProvider._({
    required TotalDistanceThisDayFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'totalDistanceThisDayProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalDistanceThisDayHash();

  @override
  String toString() {
    return r'totalDistanceThisDayProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as String;
    return totalDistanceThisDay(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalDistanceThisDayProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalDistanceThisDayHash() =>
    r'1663c4de6df3b3821f38dc90c60b738e1e0eb5a2';

final class TotalDistanceThisDayFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, String> {
  TotalDistanceThisDayFamily._()
    : super(
        retry: null,
        name: r'totalDistanceThisDayProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TotalDistanceThisDayProvider call(String userId) =>
      TotalDistanceThisDayProvider._(argument: userId, from: this);

  @override
  String toString() => r'totalDistanceThisDayProvider';
}

@ProviderFor(totalDistanceThisMonth)
final totalDistanceThisMonthProvider = TotalDistanceThisMonthFamily._();

final class TotalDistanceThisMonthProvider
    extends $FunctionalProvider<AsyncValue<double>, double, FutureOr<double>>
    with $FutureModifier<double>, $FutureProvider<double> {
  TotalDistanceThisMonthProvider._({
    required TotalDistanceThisMonthFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'totalDistanceThisMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalDistanceThisMonthHash();

  @override
  String toString() {
    return r'totalDistanceThisMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double> create(Ref ref) {
    final argument = this.argument as String;
    return totalDistanceThisMonth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TotalDistanceThisMonthProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalDistanceThisMonthHash() =>
    r'e067c8b4df6ef4c86a38dc0796f1e40d653a1fb5';

final class TotalDistanceThisMonthFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double>, String> {
  TotalDistanceThisMonthFamily._()
    : super(
        retry: null,
        name: r'totalDistanceThisMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TotalDistanceThisMonthProvider call(String userId) =>
      TotalDistanceThisMonthProvider._(argument: userId, from: this);

  @override
  String toString() => r'totalDistanceThisMonthProvider';
}
