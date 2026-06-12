import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@freezed
abstract class Auth with _$Auth {
  const factory Auth({
    required String uid,

    @Default('') String displayName,
    @Default('') String email,
    @Default('') String displayNameKey,

    @Default(0) int workoutCount,
    @Default(0) int followersCount,
    @Default(0) int followingsCount,
    @Default(0.0) double totalDistance,

    @Default(false) bool isPrivate,

    @DateTimeConverter() DateTime? createdAt,
    @DateTimeConverter() DateTime? updatedAt,

    @Default('') String bio,
    @Default('') String profileImageUrl,
  }) = _Auth;

  factory Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);
}

class DateTimeConverter implements JsonConverter<DateTime?, Timestamp?> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(Timestamp? json) => json?.toDate();

  @override
  Timestamp? toJson(DateTime? object) =>
      object != null ? Timestamp.fromDate(object) : null;
}