// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_ranking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RunRanking {

/// rankings/.../users/{uid}
 String get userId;/// 랭킹 화면 표시용
 String get displayName; String? get profileImageUrl;/// 누적 거리
 double get distanceMeters;/// 누적 운동 횟수
 int get workoutCount;/// 누적 운동 시간
 int get seconds;/// 마지막 업데이트 시간
@DateTimeConverter() DateTime? get updatedAt;
/// Create a copy of RunRanking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunRankingCopyWith<RunRanking> get copyWith => _$RunRankingCopyWithImpl<RunRanking>(this as RunRanking, _$identity);

  /// Serializes this RunRanking to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunRanking&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.workoutCount, workoutCount) || other.workoutCount == workoutCount)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,profileImageUrl,distanceMeters,workoutCount,seconds,updatedAt);

@override
String toString() {
  return 'RunRanking(userId: $userId, displayName: $displayName, profileImageUrl: $profileImageUrl, distanceMeters: $distanceMeters, workoutCount: $workoutCount, seconds: $seconds, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $RunRankingCopyWith<$Res>  {
  factory $RunRankingCopyWith(RunRanking value, $Res Function(RunRanking) _then) = _$RunRankingCopyWithImpl;
@useResult
$Res call({
 String userId, String displayName, String? profileImageUrl, double distanceMeters, int workoutCount, int seconds,@DateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$RunRankingCopyWithImpl<$Res>
    implements $RunRankingCopyWith<$Res> {
  _$RunRankingCopyWithImpl(this._self, this._then);

  final RunRanking _self;
  final $Res Function(RunRanking) _then;

/// Create a copy of RunRanking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? displayName = null,Object? profileImageUrl = freezed,Object? distanceMeters = null,Object? workoutCount = null,Object? seconds = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,workoutCount: null == workoutCount ? _self.workoutCount : workoutCount // ignore: cast_nullable_to_non_nullable
as int,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [RunRanking].
extension RunRankingPatterns on RunRanking {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunRanking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunRanking() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunRanking value)  $default,){
final _that = this;
switch (_that) {
case _RunRanking():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunRanking value)?  $default,){
final _that = this;
switch (_that) {
case _RunRanking() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? profileImageUrl,  double distanceMeters,  int workoutCount,  int seconds, @DateTimeConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunRanking() when $default != null:
return $default(_that.userId,_that.displayName,_that.profileImageUrl,_that.distanceMeters,_that.workoutCount,_that.seconds,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String displayName,  String? profileImageUrl,  double distanceMeters,  int workoutCount,  int seconds, @DateTimeConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _RunRanking():
return $default(_that.userId,_that.displayName,_that.profileImageUrl,_that.distanceMeters,_that.workoutCount,_that.seconds,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String displayName,  String? profileImageUrl,  double distanceMeters,  int workoutCount,  int seconds, @DateTimeConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _RunRanking() when $default != null:
return $default(_that.userId,_that.displayName,_that.profileImageUrl,_that.distanceMeters,_that.workoutCount,_that.seconds,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RunRanking implements RunRanking {
  const _RunRanking({required this.userId, this.displayName = 'Unknown', this.profileImageUrl, this.distanceMeters = 0.0, this.workoutCount = 0, this.seconds = 0, @DateTimeConverter() this.updatedAt});
  factory _RunRanking.fromJson(Map<String, dynamic> json) => _$RunRankingFromJson(json);

/// rankings/.../users/{uid}
@override final  String userId;
/// 랭킹 화면 표시용
@override@JsonKey() final  String displayName;
@override final  String? profileImageUrl;
/// 누적 거리
@override@JsonKey() final  double distanceMeters;
/// 누적 운동 횟수
@override@JsonKey() final  int workoutCount;
/// 누적 운동 시간
@override@JsonKey() final  int seconds;
/// 마지막 업데이트 시간
@override@DateTimeConverter() final  DateTime? updatedAt;

/// Create a copy of RunRanking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunRankingCopyWith<_RunRanking> get copyWith => __$RunRankingCopyWithImpl<_RunRanking>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunRankingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunRanking&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.workoutCount, workoutCount) || other.workoutCount == workoutCount)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,displayName,profileImageUrl,distanceMeters,workoutCount,seconds,updatedAt);

@override
String toString() {
  return 'RunRanking(userId: $userId, displayName: $displayName, profileImageUrl: $profileImageUrl, distanceMeters: $distanceMeters, workoutCount: $workoutCount, seconds: $seconds, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$RunRankingCopyWith<$Res> implements $RunRankingCopyWith<$Res> {
  factory _$RunRankingCopyWith(_RunRanking value, $Res Function(_RunRanking) _then) = __$RunRankingCopyWithImpl;
@override @useResult
$Res call({
 String userId, String displayName, String? profileImageUrl, double distanceMeters, int workoutCount, int seconds,@DateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$RunRankingCopyWithImpl<$Res>
    implements _$RunRankingCopyWith<$Res> {
  __$RunRankingCopyWithImpl(this._self, this._then);

  final _RunRanking _self;
  final $Res Function(_RunRanking) _then;

/// Create a copy of RunRanking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? displayName = null,Object? profileImageUrl = freezed,Object? distanceMeters = null,Object? workoutCount = null,Object? seconds = null,Object? updatedAt = freezed,}) {
  return _then(_RunRanking(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: freezed == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String?,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,workoutCount: null == workoutCount ? _self.workoutCount : workoutCount // ignore: cast_nullable_to_non_nullable
as int,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
