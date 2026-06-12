import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:home_function/workout/workout_model/workout_stats_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'workout_finish.freezed.dart';
part 'workout_finish.g.dart';


@freezed
abstract class WorkoutFinish with _$WorkoutFinish {
  const factory WorkoutFinish({
    String? workoutId,
    required String userId,
    required double distanceMeters,
    required int seconds,
    required double speedKmh, 
    required double paceMinPerKm,
    @Default(<String>[]) List<String> workoutImagesUrl,
    @Default(0) int likesCount,
    @Default(0) int commentsCount,
    ///routePoints 는 firestore에 바로 저장하면 용량이 너무 커서,
    /// LatLng 객체를 List<double>로 변환해서 저장해야 한다.
    /// LatLngListConverter는 LatLng 객체를 List<double>로 변환하는 역할을 한다.
    @LatLngListConverter() @Default(<LatLng>[]) List<LatLng> routePoints,
    ///timestamp/createdAt/updatedAt 는 firestore에 serverTimestamp로 저장하기 때문에, JSON에는 포함되지 않도록 한다.
    ///그럼 여기서는 지워줄까? 아니면 JSON에는 포함되지만 firestore에는 serverTimestamp로 저장하도록 할까? 후자가 더 편할 것 같다. 
    ///JSON에는 timestamp/createdAt/updatedAt이 포함되지만, firestore에는 serverTimestamp로 저장하도록 한다.
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