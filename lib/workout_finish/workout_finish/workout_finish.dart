import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:home_function/workout/workout_model/workout_stats_state.dart';

part '../workout_finish.freezed.dart';
part '../workout_finish.g.dart';

@freezed
abstract class WorkoutFinish with _$WorkoutFinish {
  const factory WorkoutFinish({
    /// Firestore 문서 ID
    String? workoutId,

    /// 운동 기록 작성자 UID
    required String userId,

    /// 이동 거리(m)
    required double distanceMeters,

    /// 운동 시간(초)
    required int seconds,

    /// 평균 속도(km/h)
    required double speedKmh,

    /// 평균 페이스(min/km)
    required double paceMinPerKm,

    /// 운동 원본 이미지 URL
    @Default(<String>[]) List<String> workoutImagesUrl,

    /// 피드 및 프로필 그리드용 썸네일 URL
    ///
    /// 기존 문서에는 해당 필드가 없을 수 있으므로 nullable로 유지한다.
    String? workoutThumbnailUrl,

    /// 좋아요 개수
    @Default(0) int likesCount,

    /// 댓글 개수
    ///
    /// 댓글 작성 및 삭제 Cloud Function에서 값을 증감한다.
    @Default(0) int commentsCount,

    /// 운동 이동 경로
    @LatLngListConverter()
    @Default(<LatLng>[])
    List<LatLng> routePoints,

    /// 운동 기록 시간
    @DateTimeConverter() DateTime? timestamp,

    /// 생성 시간
    @DateTimeConverter() DateTime? createdAt,

    /// 수정 시간
    @DateTimeConverter() DateTime? updatedAt,
  }) = _WorkoutFinish;

  factory WorkoutFinish.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFinishFromJson(json);
}

class DateTimeConverter implements JsonConverter<DateTime?, Timestamp?> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  @override
  Timestamp? toJson(DateTime? dateTime) {
    if (dateTime == null) {
      return null;
    }

    return Timestamp.fromDate(dateTime);
  }
}