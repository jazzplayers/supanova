import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

@freezed
abstract class Auth with _$Auth {
  const Auth._();

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

  factory Auth.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return Auth.fromJson({
      ...data,

      // 혹시 문서 안에 uid 필드가 없더라도 doc.id로 보정
      'uid': data['uid'] ?? doc.id,
    });
  }

  Map<String, dynamic> toFirestore() {
    return toJson();
  }

  /// 신규 가입자 생성용 기본 데이터
  factory Auth.initial({
    required String uid,
    required String email,
    required String displayName,
    String profileImageUrl = '',
  }) {
    final now = DateTime.now();

    return Auth(
      uid: uid,
      email: email,
      displayName: displayName,
      displayNameKey: displayName.trim().toLowerCase(),
      profileImageUrl: profileImageUrl,
      bio: '',
      workoutCount: 0,
      followersCount: 0,
      followingsCount: 0,
      totalDistance: 0.0,
      isPrivate: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}

class DateTimeConverter implements JsonConverter<DateTime?, Object?> {
  const DateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;

    if (json is Timestamp) {
      return json.toDate();
    }

    if (json is DateTime) {
      return json;
    }

    if (json is String) {
      return DateTime.tryParse(json);
    }

    return null;
  }

  @override
  Object? toJson(DateTime? object) {
    if (object == null) return null;
    return Timestamp.fromDate(object);
  }
}