import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'reports_repo.dart';

part 'reports_provider.g.dart';

@riverpod
ReportsRepo reportsRepo(Ref ref) {
  final functions = FirebaseFunctions.instanceFor(
    region: 'asia-northeast3',
  );

  return ReportsRepoImpl(functions);
}

@riverpod
Future<ReportResult> createReport(
  Ref ref, {
  required String targetType,
  required String targetId,
  required String reasonCode,
  String? reasonText,
}) async {
  final repo = ref.watch(reportsRepoProvider);

  return repo.createReport(
    targetType: targetType,
    targetId: targetId,
    reasonCode: reasonCode,
    reasonText: reasonText,
  );
}