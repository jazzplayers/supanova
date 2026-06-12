// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_stats_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WorkoutStatsState {

 WorkoutStatStatus get status; double get speedKmh; double get paceMinPerKm; double get distanceMeters; int get seconds;@LatLngListConverter() List<LatLng> get routePoints;
/// Create a copy of WorkoutStatsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkoutStatsStateCopyWith<WorkoutStatsState> get copyWith => _$WorkoutStatsStateCopyWithImpl<WorkoutStatsState>(this as WorkoutStatsState, _$identity);

  /// Serializes this WorkoutStatsState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkoutStatsState&&(identical(other.status, status) || other.status == status)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.paceMinPerKm, paceMinPerKm) || other.paceMinPerKm == paceMinPerKm)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&const DeepCollectionEquality().equals(other.routePoints, routePoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,speedKmh,paceMinPerKm,distanceMeters,seconds,const DeepCollectionEquality().hash(routePoints));

@override
String toString() {
  return 'WorkoutStatsState(status: $status, speedKmh: $speedKmh, paceMinPerKm: $paceMinPerKm, distanceMeters: $distanceMeters, seconds: $seconds, routePoints: $routePoints)';
}


}

/// @nodoc
abstract mixin class $WorkoutStatsStateCopyWith<$Res>  {
  factory $WorkoutStatsStateCopyWith(WorkoutStatsState value, $Res Function(WorkoutStatsState) _then) = _$WorkoutStatsStateCopyWithImpl;
@useResult
$Res call({
 WorkoutStatStatus status, double speedKmh, double paceMinPerKm, double distanceMeters, int seconds,@LatLngListConverter() List<LatLng> routePoints
});




}
/// @nodoc
class _$WorkoutStatsStateCopyWithImpl<$Res>
    implements $WorkoutStatsStateCopyWith<$Res> {
  _$WorkoutStatsStateCopyWithImpl(this._self, this._then);

  final WorkoutStatsState _self;
  final $Res Function(WorkoutStatsState) _then;

/// Create a copy of WorkoutStatsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? speedKmh = null,Object? paceMinPerKm = null,Object? distanceMeters = null,Object? seconds = null,Object? routePoints = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WorkoutStatStatus,speedKmh: null == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double,paceMinPerKm: null == paceMinPerKm ? _self.paceMinPerKm : paceMinPerKm // ignore: cast_nullable_to_non_nullable
as double,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,routePoints: null == routePoints ? _self.routePoints : routePoints // ignore: cast_nullable_to_non_nullable
as List<LatLng>,
  ));
}

}


/// Adds pattern-matching-related methods to [WorkoutStatsState].
extension WorkoutStatsStatePatterns on WorkoutStatsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WorkoutStatsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WorkoutStatsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WorkoutStatsState value)  $default,){
final _that = this;
switch (_that) {
case _WorkoutStatsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WorkoutStatsState value)?  $default,){
final _that = this;
switch (_that) {
case _WorkoutStatsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( WorkoutStatStatus status,  double speedKmh,  double paceMinPerKm,  double distanceMeters,  int seconds, @LatLngListConverter()  List<LatLng> routePoints)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WorkoutStatsState() when $default != null:
return $default(_that.status,_that.speedKmh,_that.paceMinPerKm,_that.distanceMeters,_that.seconds,_that.routePoints);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( WorkoutStatStatus status,  double speedKmh,  double paceMinPerKm,  double distanceMeters,  int seconds, @LatLngListConverter()  List<LatLng> routePoints)  $default,) {final _that = this;
switch (_that) {
case _WorkoutStatsState():
return $default(_that.status,_that.speedKmh,_that.paceMinPerKm,_that.distanceMeters,_that.seconds,_that.routePoints);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( WorkoutStatStatus status,  double speedKmh,  double paceMinPerKm,  double distanceMeters,  int seconds, @LatLngListConverter()  List<LatLng> routePoints)?  $default,) {final _that = this;
switch (_that) {
case _WorkoutStatsState() when $default != null:
return $default(_that.status,_that.speedKmh,_that.paceMinPerKm,_that.distanceMeters,_that.seconds,_that.routePoints);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WorkoutStatsState implements WorkoutStatsState {
  const _WorkoutStatsState({this.status = WorkoutStatStatus.idle, this.speedKmh = 0.0, this.paceMinPerKm = 0.0, this.distanceMeters = 0.0, this.seconds = 0, @LatLngListConverter() final  List<LatLng> routePoints = const <LatLng>[]}): _routePoints = routePoints;
  factory _WorkoutStatsState.fromJson(Map<String, dynamic> json) => _$WorkoutStatsStateFromJson(json);

@override@JsonKey() final  WorkoutStatStatus status;
@override@JsonKey() final  double speedKmh;
@override@JsonKey() final  double paceMinPerKm;
@override@JsonKey() final  double distanceMeters;
@override@JsonKey() final  int seconds;
 final  List<LatLng> _routePoints;
@override@JsonKey()@LatLngListConverter() List<LatLng> get routePoints {
  if (_routePoints is EqualUnmodifiableListView) return _routePoints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_routePoints);
}


/// Create a copy of WorkoutStatsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkoutStatsStateCopyWith<_WorkoutStatsState> get copyWith => __$WorkoutStatsStateCopyWithImpl<_WorkoutStatsState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkoutStatsStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WorkoutStatsState&&(identical(other.status, status) || other.status == status)&&(identical(other.speedKmh, speedKmh) || other.speedKmh == speedKmh)&&(identical(other.paceMinPerKm, paceMinPerKm) || other.paceMinPerKm == paceMinPerKm)&&(identical(other.distanceMeters, distanceMeters) || other.distanceMeters == distanceMeters)&&(identical(other.seconds, seconds) || other.seconds == seconds)&&const DeepCollectionEquality().equals(other._routePoints, _routePoints));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,speedKmh,paceMinPerKm,distanceMeters,seconds,const DeepCollectionEquality().hash(_routePoints));

@override
String toString() {
  return 'WorkoutStatsState(status: $status, speedKmh: $speedKmh, paceMinPerKm: $paceMinPerKm, distanceMeters: $distanceMeters, seconds: $seconds, routePoints: $routePoints)';
}


}

/// @nodoc
abstract mixin class _$WorkoutStatsStateCopyWith<$Res> implements $WorkoutStatsStateCopyWith<$Res> {
  factory _$WorkoutStatsStateCopyWith(_WorkoutStatsState value, $Res Function(_WorkoutStatsState) _then) = __$WorkoutStatsStateCopyWithImpl;
@override @useResult
$Res call({
 WorkoutStatStatus status, double speedKmh, double paceMinPerKm, double distanceMeters, int seconds,@LatLngListConverter() List<LatLng> routePoints
});




}
/// @nodoc
class __$WorkoutStatsStateCopyWithImpl<$Res>
    implements _$WorkoutStatsStateCopyWith<$Res> {
  __$WorkoutStatsStateCopyWithImpl(this._self, this._then);

  final _WorkoutStatsState _self;
  final $Res Function(_WorkoutStatsState) _then;

/// Create a copy of WorkoutStatsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? speedKmh = null,Object? paceMinPerKm = null,Object? distanceMeters = null,Object? seconds = null,Object? routePoints = null,}) {
  return _then(_WorkoutStatsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as WorkoutStatStatus,speedKmh: null == speedKmh ? _self.speedKmh : speedKmh // ignore: cast_nullable_to_non_nullable
as double,paceMinPerKm: null == paceMinPerKm ? _self.paceMinPerKm : paceMinPerKm // ignore: cast_nullable_to_non_nullable
as double,distanceMeters: null == distanceMeters ? _self.distanceMeters : distanceMeters // ignore: cast_nullable_to_non_nullable
as double,seconds: null == seconds ? _self.seconds : seconds // ignore: cast_nullable_to_non_nullable
as int,routePoints: null == routePoints ? _self._routePoints : routePoints // ignore: cast_nullable_to_non_nullable
as List<LatLng>,
  ));
}


}

// dart format on
