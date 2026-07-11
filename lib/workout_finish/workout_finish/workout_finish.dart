import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:home_function/workout/workout_model/workout_stats_state.dart';

part '../workout_finish.freezed.dart';
part '../workout_finish.g.dart';

@freezed
abstract class WorkoutFinish with _$WorkoutFinish {
  const factory WorkoutFinish({
    String? workoutId,
    required String userId,
    required double distanceMeters,
    required int seconds,
    required double speedKmh,
    required double paceMinPerKm,

    /// 운동 원본 이미지 URL 목록
    @Default(<String>[]) List<String> workoutImagesUrl,

    /// 프로필 그리드/피드 미리보기용 썸네일 이미지 URL
    ///
    /// 기존 workoutFinish 문서에는 이 필드가 없을 수 있으므로 nullable로 둔다.
    /// 화면에서는 workoutThumbnailUrl이 없으면 workoutImagesUrl.first로 fallback하면 된다.
    String? workoutThumbnailUrl,

    @Default(0) int likesCount,
    @Default(0) int commentsCount,

    /// routePoints는 Firestore에 바로 저장하면 용량이 커질 수 있으므로,
    /// LatLng 객체를 List<double> 형태로 변환해서 저장한다.
    @LatLngListConverter() @Default(<LatLng>[]) List<LatLng> routePoints,

    /// timestamp / createdAt / updatedAt은 Firestore에 serverTimestamp로 저장한다.
    @DateTimeConverter() DateTime? timestamp,
    @DateTimeConverter() DateTime? createdAt,
    @DateTimeConverter() DateTime? updatedAt,
  }) = _WorkoutFinish;

  factory WorkoutFinish.fromJson(Map<String, dynamic> json) =>
      _$WorkoutFinishFromJson(json);
}

class DateTimeConverter implements JsonConverter<DateTime?, Timestamp?> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(Timestamp? json) => json?.toDate();

  @override
  Timestamp? toJson(DateTime? object) =>
      object != null ? Timestamp.fromDate(object) : null;
}