// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reportsRepo)
final reportsRepoProvider = ReportsRepoProvider._();

final class ReportsRepoProvider
    extends $FunctionalProvider<ReportsRepo, ReportsRepo, ReportsRepo>
    with $Provider<ReportsRepo> {
  ReportsRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsRepoHash();

  @$internal
  @override
  $ProviderElement<ReportsRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReportsRepo create(Ref ref) {
    return reportsRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportsRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportsRepo>(value),
    );
  }
}

String _$reportsRepoHash() => r'a0f264640b2c5c4ee5641500ae56570974469ba4';

@ProviderFor(createReport)
final createReportProvider = CreateReportFamily._();

final class CreateReportProvider
    extends
        $FunctionalProvider<
          AsyncValue<ReportResult>,
          ReportResult,
          FutureOr<ReportResult>
        >
    with $FutureModifier<ReportResult>, $FutureProvider<ReportResult> {
  CreateReportProvider._({
    required CreateReportFamily super.from,
    required ({
      String targetType,
      String targetId,
      String reasonCode,
      String? reasonText,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'createReportProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$createReportHash();

  @override
  String toString() {
    return r'createReportProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<ReportResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ReportResult> create(Ref ref) {
    final argument =
        this.argument
            as ({
              String targetType,
              String targetId,
              String reasonCode,
              String? reasonText,
            });
    return createReport(
      ref,
      targetType: argument.targetType,
      targetId: argument.targetId,
      reasonCode: argument.reasonCode,
      reasonText: argument.reasonText,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CreateReportProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$createReportHash() => r'8b619bdccbab005319235272229dd682a32f1fe8';

final class CreateReportFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<ReportResult>,
          ({
            String targetType,
            String targetId,
            String reasonCode,
            String? reasonText,
          })
        > {
  CreateReportFamily._()
    : super(
        retry: null,
        name: r'createReportProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CreateReportProvider call({
    required String targetType,
    required String targetId,
    required String reasonCode,
    String? reasonText,
  }) => CreateReportProvider._(
    argument: (
      targetType: targetType,
      targetId: targetId,
      reasonCode: reasonCode,
      reasonText: reasonText,
    ),
    from: this,
  );

  @override
  String toString() => r'createReportProvider';
}
