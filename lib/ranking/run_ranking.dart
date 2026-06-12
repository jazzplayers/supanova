import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'run_ranking.freezed.dart';
part 'run_ranking.g.dart';


@freezed
abstract class RunRanking with _$RunRanking {
  const factory RunRanking({
    /// rankings/.../users/{uid}
    required String userId,

    /// 랭킹 화면 표시용
    @Default('Unknown') String displayName,
    String? profileImageUrl,

    /// 누적 거리
    @Default(0.0) double distanceMeters,

    /// 누적 운동 횟수
    @Default(0) int workoutCount,

    /// 누적 운동 시간
    @Default(0) int seconds,

    /// 마지막 업데이트 시간
    @DateTimeConverter() DateTime? updatedAt,
  }) = _RunRanking;

  factory RunRanking.fromJson(Map<String, dynamic> json) =>
      _$RunRankingFromJson(json);

  factory RunRanking.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};

    return RunRanking.fromJson({
      ...data,
      'userId': data['userId'] ?? doc.id,
    });
  }
}

class DateTimeConverter implements JsonConverter<DateTime?, Timestamp?> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(Timestamp? json) => json?.toDate();

  @override
  Timestamp? toJson(DateTime? object) =>
      object != null ? Timestamp.fromDate(object) : null;
}