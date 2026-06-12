// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_ranking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runRankingRepo)
final runRankingRepoProvider = RunRankingRepoProvider._();

final class RunRankingRepoProvider
    extends $FunctionalProvider<RunRankingRepo, RunRankingRepo, RunRankingRepo>
    with $Provider<RunRankingRepo> {
  RunRankingRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runRankingRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runRankingRepoHash();

  @$internal
  @override
  $ProviderElement<RunRankingRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RunRankingRepo create(Ref ref) {
    return runRankingRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunRankingRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunRankingRepo>(value),
    );
  }
}

String _$runRankingRepoHash() => r'b7e6553546274aa4f802455276ea9b300f41666f';

/// 전체 러닝 랭킹 Top 50

@ProviderFor(totalRunRanking)
final totalRunRankingProvider = TotalRunRankingProvider._();

/// 전체 러닝 랭킹 Top 50

final class TotalRunRankingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunRanking>>,
          List<RunRanking>,
          Stream<List<RunRanking>>
        >
    with $FutureModifier<List<RunRanking>>, $StreamProvider<List<RunRanking>> {
  /// 전체 러닝 랭킹 Top 50
  TotalRunRankingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalRunRankingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalRunRankingHash();

  @$internal
  @override
  $StreamProviderElement<List<RunRanking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RunRanking>> create(Ref ref) {
    return totalRunRanking(ref);
  }
}

String _$totalRunRankingHash() => r'ee012ac0e53bca79679c1514bed8683f0ffef9f5';

/// 이번 달 러닝 랭킹 Top 50

@ProviderFor(monthlyRunRanking)
final monthlyRunRankingProvider = MonthlyRunRankingProvider._();

/// 이번 달 러닝 랭킹 Top 50

final class MonthlyRunRankingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunRanking>>,
          List<RunRanking>,
          Stream<List<RunRanking>>
        >
    with $FutureModifier<List<RunRanking>>, $StreamProvider<List<RunRanking>> {
  /// 이번 달 러닝 랭킹 Top 50
  MonthlyRunRankingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'monthlyRunRankingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$monthlyRunRankingHash();

  @$internal
  @override
  $StreamProviderElement<List<RunRanking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RunRanking>> create(Ref ref) {
    return monthlyRunRanking(ref);
  }
}

String _$monthlyRunRankingHash() => r'f44b9f559e1dde0c288b784c48e040dd863ea78c';

/// 특정 월 러닝 랭킹
///
/// 사용 예:
/// ref.watch(runRankingByMonthProvider('202605'))

@ProviderFor(runRankingByMonth)
final runRankingByMonthProvider = RunRankingByMonthFamily._();

/// 특정 월 러닝 랭킹
///
/// 사용 예:
/// ref.watch(runRankingByMonthProvider('202605'))

final class RunRankingByMonthProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunRanking>>,
          List<RunRanking>,
          Stream<List<RunRanking>>
        >
    with $FutureModifier<List<RunRanking>>, $StreamProvider<List<RunRanking>> {
  /// 특정 월 러닝 랭킹
  ///
  /// 사용 예:
  /// ref.watch(runRankingByMonthProvider('202605'))
  RunRankingByMonthProvider._({
    required RunRankingByMonthFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'runRankingByMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$runRankingByMonthHash();

  @override
  String toString() {
    return r'runRankingByMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RunRanking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RunRanking>> create(Ref ref) {
    final argument = this.argument as String;
    return runRankingByMonth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RunRankingByMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$runRankingByMonthHash() => r'049a94569a08a2e029885e8a570c131e67f265fb';

/// 특정 월 러닝 랭킹
///
/// 사용 예:
/// ref.watch(runRankingByMonthProvider('202605'))

final class RunRankingByMonthFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RunRanking>>, String> {
  RunRankingByMonthFamily._()
    : super(
        retry: null,
        name: r'runRankingByMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 특정 월 러닝 랭킹
  ///
  /// 사용 예:
  /// ref.watch(runRankingByMonthProvider('202605'))

  RunRankingByMonthProvider call(String yearMonth) =>
      RunRankingByMonthProvider._(argument: yearMonth, from: this);

  @override
  String toString() => r'runRankingByMonthProvider';
}

/// 내 전체 러닝 랭킹 데이터

@ProviderFor(myTotalRunRanking)
final myTotalRunRankingProvider = MyTotalRunRankingFamily._();

/// 내 전체 러닝 랭킹 데이터

final class MyTotalRunRankingProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunRanking?>,
          RunRanking?,
          FutureOr<RunRanking?>
        >
    with $FutureModifier<RunRanking?>, $FutureProvider<RunRanking?> {
  /// 내 전체 러닝 랭킹 데이터
  MyTotalRunRankingProvider._({
    required MyTotalRunRankingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myTotalRunRankingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myTotalRunRankingHash();

  @override
  String toString() {
    return r'myTotalRunRankingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RunRanking?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RunRanking?> create(Ref ref) {
    final argument = this.argument as String;
    return myTotalRunRanking(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyTotalRunRankingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myTotalRunRankingHash() => r'fbc230cf6d7b2a39cecd59484a86d8ffd68bf457';

/// 내 전체 러닝 랭킹 데이터

final class MyTotalRunRankingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RunRanking?>, String> {
  MyTotalRunRankingFamily._()
    : super(
        retry: null,
        name: r'myTotalRunRankingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 내 전체 러닝 랭킹 데이터

  MyTotalRunRankingProvider call(String userId) =>
      MyTotalRunRankingProvider._(argument: userId, from: this);

  @override
  String toString() => r'myTotalRunRankingProvider';
}

/// 내 이번 달 러닝 랭킹 데이터

@ProviderFor(myMonthlyRunRanking)
final myMonthlyRunRankingProvider = MyMonthlyRunRankingFamily._();

/// 내 이번 달 러닝 랭킹 데이터

final class MyMonthlyRunRankingProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunRanking?>,
          RunRanking?,
          FutureOr<RunRanking?>
        >
    with $FutureModifier<RunRanking?>, $FutureProvider<RunRanking?> {
  /// 내 이번 달 러닝 랭킹 데이터
  MyMonthlyRunRankingProvider._({
    required MyMonthlyRunRankingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myMonthlyRunRankingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myMonthlyRunRankingHash();

  @override
  String toString() {
    return r'myMonthlyRunRankingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RunRanking?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RunRanking?> create(Ref ref) {
    final argument = this.argument as String;
    return myMonthlyRunRanking(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyMonthlyRunRankingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myMonthlyRunRankingHash() =>
    r'c2b0199e09c0225166262e0369f84e08624757c2';

/// 내 이번 달 러닝 랭킹 데이터

final class MyMonthlyRunRankingFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RunRanking?>, String> {
  MyMonthlyRunRankingFamily._()
    : super(
        retry: null,
        name: r'myMonthlyRunRankingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 내 이번 달 러닝 랭킹 데이터

  MyMonthlyRunRankingProvider call(String userId) =>
      MyMonthlyRunRankingProvider._(argument: userId, from: this);

  @override
  String toString() => r'myMonthlyRunRankingProvider';
}

/// 내 전체 순위

@ProviderFor(myTotalRunRank)
final myTotalRunRankProvider = MyTotalRunRankFamily._();

/// 내 전체 순위

final class MyTotalRunRankProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// 내 전체 순위
  MyTotalRunRankProvider._({
    required MyTotalRunRankFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myTotalRunRankProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myTotalRunRankHash();

  @override
  String toString() {
    return r'myTotalRunRankProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    final argument = this.argument as String;
    return myTotalRunRank(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyTotalRunRankProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myTotalRunRankHash() => r'0fda98c34f878cd71b4e8acdea51903da56d31b9';

/// 내 전체 순위

final class MyTotalRunRankFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int?>, String> {
  MyTotalRunRankFamily._()
    : super(
        retry: null,
        name: r'myTotalRunRankProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 내 전체 순위

  MyTotalRunRankProvider call(String userId) =>
      MyTotalRunRankProvider._(argument: userId, from: this);

  @override
  String toString() => r'myTotalRunRankProvider';
}

/// 내 이번 달 순위

@ProviderFor(myMonthlyRunRank)
final myMonthlyRunRankProvider = MyMonthlyRunRankFamily._();

/// 내 이번 달 순위

final class MyMonthlyRunRankProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  /// 내 이번 달 순위
  MyMonthlyRunRankProvider._({
    required MyMonthlyRunRankFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myMonthlyRunRankProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myMonthlyRunRankHash();

  @override
  String toString() {
    return r'myMonthlyRunRankProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    final argument = this.argument as String;
    return myMonthlyRunRank(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyMonthlyRunRankProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myMonthlyRunRankHash() => r'a758215dc00553155a2c42f116ade7cc57157dee';

/// 내 이번 달 순위

final class MyMonthlyRunRankFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int?>, String> {
  MyMonthlyRunRankFamily._()
    : super(
        retry: null,
        name: r'myMonthlyRunRankProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 내 이번 달 순위

  MyMonthlyRunRankProvider call(String userId) =>
      MyMonthlyRunRankProvider._(argument: userId, from: this);

  @override
  String toString() => r'myMonthlyRunRankProvider';
}
