import 'package:cloud_functions/cloud_functions.dart';

class ReportResult {
  const ReportResult({
    required this.ok,
    required this.alreadyReported,
    this.reportId,
  });

  final bool ok;
  final bool alreadyReported;
  final String? reportId;

  factory ReportResult.fromMap(Map<String, dynamic> map) {
    return ReportResult(
      ok: map['ok'] == true,
      alreadyReported: map['alreadyReported'] == true,
      reportId: map['reportId'] as String?,
    );
  }
}

abstract class ReportsRepo {
  Future<ReportResult> createReport({
    required String targetType,
    required String targetId,
    required String reasonCode,
    String? reasonText,
  });
}

class ReportsRepoImpl implements ReportsRepo {
  ReportsRepoImpl(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<ReportResult> createReport({
    required String targetType,
    required String targetId,
    required String reasonCode,
    String? reasonText,
  }) async {
    try {
      final callable = _functions.httpsCallable('createReport');

      final result = await callable.call<Map<String, dynamic>>({
        'targetType': targetType,
        'targetId': targetId,
        'reasonCode': reasonCode,
        'reasonText': reasonText,
      });

      return ReportResult.fromMap(result.data);
    } on FirebaseFunctionsException catch (e) {
      throw Exception(_messageFromFunctionsException(e));
    } catch (_) {
      throw Exception('신고 처리 중 문제가 발생했습니다.');
    }
  }

  String _messageFromFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return '로그인이 필요합니다.';
      case 'invalid-argument':
        return e.message ?? '신고 정보가 올바르지 않습니다.';
      case 'not-found':
        return '신고 대상을 찾을 수 없습니다.';
      case 'already-exists':
        return '이미 신고한 대상입니다.';
      case 'permission-denied':
        return '신고 권한이 없습니다.';
      default:
        return e.message ?? '신고 처리 중 문제가 발생했습니다.';
    }
  }
}