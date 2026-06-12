// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_finish.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutFinish {

 String? get workoutId; String get userId; double get distanceMeters; int get seconds; double get speedKmh; double get paceMinPerKm; List<String> get workoutImagesUrl; int get likesCount; int get commentsCount;///routePoints 는 firestore에 바로 저장하면 용량이 너무 커서,
/// LatLng 객체를 List<double>로 변환해서 저장해야 한다.
/// LatLngListConverter는 LatLng 객체를 List<double>로 변환하는 역할을 한다.
@LatLngListConverter() List<LatLng> get routePoints;///timestamp/createdAt/updatedAt 는 firestore에 serverTimestamp로 저장하기 때문에, JSON에는 포함되지 않도록 한다.
///그럼 여기서는 지워줄까? 아니면 JSON에는 포함되지만 firestore에는 serverTimestamp로 저장하도록 할까? 후자가 더 편할 것 같다. 
///JSON에는 timestamp/createdAt/updatedAt이 포함되지만, firestore에는 serverTimestamp로 저장하도록 한다.
@DateTimeConverter() DateTime? get timestamp;@DateTimeConverter() DateTime? get createdAt;@DateTimeConverter() DateTime? get updatedAt;
/// Create a copy of WorkoutFinish
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutFinishCopyWith<WorkoutFinish> get copyWith => _$WorkoutFinishCopyWithImpl<WorkoutFinish>(this as WorkoutFinish, _$identity);

  /// Serializes this WorkoutFinish to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutFinish&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.paceMinPerKm, paceMinPerKm) || other.paceMinPerKm == paceMinPerKm)&&const DeepCollectionEquality().equals(other.workoutImagesUrl, workoutImagesUrl)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&const DeepCollectionEquality().equals(other.routePoints, routePoints)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutId,userId,distanceMeters,seconds,speedKmh,paceMinPerKm,const DeepCollectionEquality().hash(workoutImagesUrl),likesCount,commentsCount,const DeepCollectionEquality().hash(routePoints),timestamp,createdAt,updatedAt);

@override
String toString() {
  return 'WorkoutFinish(workoutId: $workoutId, userId: $userId, distanceMeters: $distanceMeters, seconds: $seconds, speedKmh: $speedKmh, paceMinPerKm: $paceMinPerKm, workoutImagesUrl: $workoutImagesUrl, likesCount: $likesCount, commentsCount: $commentsCount, routePoints: $routePoints, timestamp: $timestamp, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $WorkoutFinishCopyWith<$Res>  {
  factory $WorkoutFinishCopyWith(WorkoutFinish value, $Res Function(WorkoutFinish) _then) = _$WorkoutFinishCopyWithImpl;
@useResult
$Res call({
 String? workoutId, String userId, double distanceMeters, int seconds, double speedKmh, double paceMinPerKm, List<String> workoutImagesUrl, int likesCount, int commentsCount,@LatLngListConverter() List<LatLng> routePoints,@DateTimeConverter() DateTime? timestamp,@DateTimeConverter() DateTime? createdAt,@DateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$WorkoutFinishCopyWithImpl<$Res>
    implements $WorkoutFinishCopyWith<$Res> {
  _$WorkoutFinishCopyWithImpl(this._self, this._then);

  final WorkoutFinish _self;
  final $Res Function(WorkoutFinish) _then;

/// Create a copy of WorkoutFinish
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? workoutId = freezed,Object? userId = null,Object? distanceMeters = null,Object? seconds = null,Object? speedKmh = null,Object? paceMinPerKm = null,Object? workoutImagesUrl = null,Object? likesCount = null,Object? commentsCount = null,Object? routePoints = null,Object? timestamp = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,speedKmh: null == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double,paceMinPerKm: null == paceMinPerKm ? _self.paceMinPerKm : paceMinPerKm // ignore: cast_nullable_to_non_nullable
as double,workoutImagesUrl: null == workoutImagesUrl ? _self.workoutImagesUrl : workoutImagesUrl // ignore: cast_nullable_to_non_nullable
as List<String>,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,routePoints: null == routePoints ? _self.routePoints : routePoints // ignore: cast_nullable_to_non_nullable
as List<LatLng>,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutFinish].
extension WorkoutFinishPatterns on WorkoutFinish {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutFinish value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutFinish() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutFinish value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutFinish():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutFinish value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutFinish() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? workoutId,  String userId,  double distanceMeters,  int seconds,  double speedKmh,  double paceMinPerKm,  List<String> workoutImagesUrl,  int likesCount,  int commentsCount, @LatLngListConverter()  List<LatLng> routePoints, @DateTimeConverter()  DateTime? timestamp, @DateTimeConverter()  DateTime? createdAt, @DateTimeConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutFinish() when $default != null:
return $default(_that.workoutId,_that.userId,_that.distanceMeters,_that.seconds,_that.speedKmh,_that.paceMinPerKm,_that.workoutImagesUrl,_that.likesCount,_that.commentsCount,_that.routePoints,_that.timestamp,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? workoutId,  String userId,  double distanceMeters,  int seconds,  double speedKmh,  double paceMinPerKm,  List<String> workoutImagesUrl,  int likesCount,  int commentsCount, @LatLngListConverter()  List<LatLng> routePoints, @DateTimeConverter()  DateTime? timestamp, @DateTimeConverter()  DateTime? createdAt, @DateTimeConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _WorkoutFinish():
return $default(_that.workoutId,_that.userId,_that.distanceMeters,_that.seconds,_that.speedKmh,_that.paceMinPerKm,_that.workoutImagesUrl,_that.likesCount,_that.commentsCount,_that.routePoints,_that.timestamp,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? workoutId,  String userId,  double distanceMeters,  int seconds,  double speedKmh,  double paceMinPerKm,  List<String> workoutImagesUrl,  int likesCount,  int commentsCount, @LatLngListConverter()  List<LatLng> routePoints, @DateTimeConverter()  DateTime? timestamp, @DateTimeConverter()  DateTime? createdAt, @DateTimeConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutFinish() when $default != null:
return $default(_that.workoutId,_that.userId,_that.distanceMeters,_that.seconds,_that.speedKmh,_that.paceMinPerKm,_that.workoutImagesUrl,_that.likesCount,_that.commentsCount,_that.routePoints,_that.timestamp,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutFinish implements WorkoutFinish {
  const _WorkoutFinish({this.workoutId, required this.userId, required this.distanceMeters, required this.seconds, required this.speedKmh, required this.paceMinPerKm, final  List<String> workoutImagesUrl = const <String>[], this.likesCount = 0, this.commentsCount = 0, @LatLngListConverter() final  List<LatLng> routePoints = const <LatLng>[], @DateTimeConverter() this.timestamp, @DateTimeConverter() this.createdAt, @DateTimeConverter() this.updatedAt}): _workoutImagesUrl = workoutImagesUrl,_routePoints = routePoints;
  factory _WorkoutFinish.fromJson(Map<String, dynamic> json) => _$WorkoutFinishFromJson(json);

@override final  String? workoutId;
@override final  String userId;
@override final  double distanceMeters;
@override final  int seconds;
@override final  double speedKmh;
@override final  double paceMinPerKm;
 final  List<String> _workoutImagesUrl;
@override@JsonKey() List<String> get workoutImagesUrl {
  if (_workoutImagesUrl is EqualUnmodifiableListView) return _workoutImagesUrl;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workoutImagesUrl);
}

@override@JsonKey() final  int likesCount;
@override@JsonKey() final  int commentsCount;
///routePoints 는 firestore에 바로 저장하면 용량이 너무 커서,
/// LatLng 객체를 List<double>로 변환해서 저장해야 한다.
/// LatLngListConverter는 LatLng 객체를 List<double>로 변환하는 역할을 한다.
 final  List<LatLng> _routePoints;
///routePoints 는 firestore에 바로 저장하면 용량이 너무 커서,
/// LatLng 객체를 List<double>로 변환해서 저장해야 한다.
/// LatLngListConverter는 LatLng 객체를 List<double>로 변환하는 역할을 한다.
@override@JsonKey()@LatLngListConverter() List<LatLng> get routePoints {
  if (_routePoints is EqualUnmodifiableListView) return _routePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routePoints);
}

///timestamp/createdAt/updatedAt 는 firestore에 serverTimestamp로 저장하기 때문에, JSON에는 포함되지 않도록 한다.
///그럼 여기서는 지워줄까? 아니면 JSON에는 포함되지만 firestore에는 serverTimestamp로 저장하도록 할까? 후자가 더 편할 것 같다. 
///JSON에는 timestamp/createdAt/updatedAt이 포함되지만, firestore에는 serverTimestamp로 저장하도록 한다.
@override@DateTimeConverter() final  DateTime? timestamp;
@override@DateTimeConverter() final  DateTime? createdAt;
@override@DateTimeConverter() final  DateTime? updatedAt;

/// Create a copy of WorkoutFinish
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutFinishCopyWith<_WorkoutFinish> get copyWith => __$WorkoutFinishCopyWithImpl<_WorkoutFinish>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutFinishToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutFinish&&(identical(other.workoutId, workoutId) || other.workoutId == workoutId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.paceMinPerKm, paceMinPerKm) || other.paceMinPerKm == paceMinPerKm)&&const DeepCollectionEquality().equals(other._workoutImagesUrl, _workoutImagesUrl)&&(identical(other.likesCount, likesCount) || other.likesCount == likesCount)&&(identical(other.commentsCount, commentsCount) || other.commentsCount == commentsCount)&&const DeepCollectionEquality().equals(other._routePoints, _routePoints)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,workoutId,userId,distanceMeters,seconds,speedKmh,paceMinPerKm,const DeepCollectionEquality().hash(_workoutImagesUrl),likesCount,commentsCount,const DeepCollectionEquality().hash(_routePoints),timestamp,createdAt,updatedAt);

@override
String toString() {
  return 'WorkoutFinish(workoutId: $workoutId, userId: $userId, distanceMeters: $distanceMeters, seconds: $seconds, speedKmh: $speedKmh, paceMinPerKm: $paceMinPerKm, workoutImagesUrl: $workoutImagesUrl, likesCount: $likesCount, commentsCount: $commentsCount, routePoints: $routePoints, timestamp: $timestamp, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$WorkoutFinishCopyWith<$Res> implements $WorkoutFinishCopyWith<$Res> {
  factory _$WorkoutFinishCopyWith(_WorkoutFinish value, $Res Function(_WorkoutFinish) _then) = __$WorkoutFinishCopyWithImpl;
@override @useResult
$Res call({
 String? workoutId, String userId, double distanceMeters, int seconds, double speedKmh, double paceMinPerKm, List<String> workoutImagesUrl, int likesCount, int commentsCount,@LatLngListConverter() List<LatLng> routePoints,@DateTimeConverter() DateTime? timestamp,@DateTimeConverter() DateTime? createdAt,@DateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$WorkoutFinishCopyWithImpl<$Res>
    implements _$WorkoutFinishCopyWith<$Res> {
  __$WorkoutFinishCopyWithImpl(this._self, this._then);

  final _WorkoutFinish _self;
  final $Res Function(_WorkoutFinish) _then;

/// Create a copy of WorkoutFinish
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? workoutId = freezed,Object? userId = null,Object? distanceMeters = null,Object? seconds = null,Object? speedKmh = null,Object? paceMinPerKm = null,Object? workoutImagesUrl = null,Object? likesCount = null,Object? commentsCount = null,Object? routePoints = null,Object? timestamp = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_WorkoutFinish(
workoutId: freezed == workoutId ? _self.workoutId : workoutId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,speedKmh: null == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double,paceMinPerKm: null == paceMinPerKm ? _self.paceMinPerKm : paceMinPerKm // ignore: cast_nullable_to_non_nullable
as double,workoutImagesUrl: null == workoutImagesUrl ? _self._workoutImagesUrl : workoutImagesUrl // ignore: cast_nullable_to_non_nullable
as List<String>,likesCount: null == likesCount ? _self.likesCount : likesCount // ignore: cast_nullable_to_non_nullable
as int,commentsCount: null == commentsCount ? _self.commentsCount : commentsCount // ignore: cast_nullable_to_non_nullable
as int,routePoints: null == routePoints ? _self._routePoints : routePoints // ignore: cast_nullable_to_non_nullable
as List<LatLng>,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
