// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'month_goal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MonthGoal {

 String get id; double get goalDistance; int get year; int get month; DateTime? get createdAt;
/// Create a copy of MonthGoal
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MonthGoalCopyWith<MonthGoal> get copyWith => _$MonthGoalCopyWithImpl<MonthGoal>(this as MonthGoal, _$identity);

  /// Serializes this MonthGoal to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MonthGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.goalDistance, goalDistance) || other.goalDistance == goalDistance)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalDistance,year,month,createdAt);

@override
String toString() {
  return 'MonthGoal(id: $id, goalDistance: $goalDistance, year: $year, month: $month, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MonthGoalCopyWith<$Res>  {
  factory $MonthGoalCopyWith(MonthGoal value, $Res Function(MonthGoal) _then) = _$MonthGoalCopyWithImpl;
@useResult
$Res call({
 String id, double goalDistance, int year, int month, DateTime? createdAt
});




}
/// @nodoc
class _$MonthGoalCopyWithImpl<$Res>
    implements $MonthGoalCopyWith<$Res> {
  _$MonthGoalCopyWithImpl(this._self, this._then);

  final MonthGoal _self;
  final $Res Function(MonthGoal) _then;

/// Create a copy of MonthGoal
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? goalDistance = null,Object? year = null,Object? month = null,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalDistance: null == goalDistance ? _self.goalDistance : goalDistance // ignore: cast_nullable_to_non_nullable
as double,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MonthGoal].
extension MonthGoalPatterns on MonthGoal {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MonthGoal value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MonthGoal() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MonthGoal value)  $default,){
final _that = this;
switch (_that) {
case _MonthGoal():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MonthGoal value)?  $default,){
final _that = this;
switch (_that) {
case _MonthGoal() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  double goalDistance,  int year,  int month,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MonthGoal() when $default != null:
return $default(_that.id,_that.goalDistance,_that.year,_that.month,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  double goalDistance,  int year,  int month,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _MonthGoal():
return $default(_that.id,_that.goalDistance,_that.year,_that.month,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  double goalDistance,  int year,  int month,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MonthGoal() when $default != null:
return $default(_that.id,_that.goalDistance,_that.year,_that.month,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MonthGoal implements MonthGoal {
  const _MonthGoal({required this.id, required this.goalDistance, required this.year, required this.month, this.createdAt});
  factory _MonthGoal.fromJson(Map<String, dynamic> json) => _$MonthGoalFromJson(json);

@override final  String id;
@override final  double goalDistance;
@override final  int year;
@override final  int month;
@override final  DateTime? createdAt;

/// Create a copy of MonthGoal
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MonthGoalCopyWith<_MonthGoal> get copyWith => __$MonthGoalCopyWithImpl<_MonthGoal>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MonthGoalToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MonthGoal&&(identical(other.id, id) || other.id == id)&&(identical(other.goalDistance, goalDistance) || other.goalDistance == goalDistance)&&(identical(other.year, year) || other.year == year)&&(identical(other.month, month) || other.month == month)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,goalDistance,year,month,createdAt);

@override
String toString() {
  return 'MonthGoal(id: $id, goalDistance: $goalDistance, year: $year, month: $month, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MonthGoalCopyWith<$Res> implements $MonthGoalCopyWith<$Res> {
  factory _$MonthGoalCopyWith(_MonthGoal value, $Res Function(_MonthGoal) _then) = __$MonthGoalCopyWithImpl;
@override @useResult
$Res call({
 String id, double goalDistance, int year, int month, DateTime? createdAt
});




}
/// @nodoc
class __$MonthGoalCopyWithImpl<$Res>
    implements _$MonthGoalCopyWith<$Res> {
  __$MonthGoalCopyWithImpl(this._self, this._then);

  final _MonthGoal _self;
  final $Res Function(_MonthGoal) _then;

/// Create a copy of MonthGoal
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? goalDistance = null,Object? year = null,Object? month = null,Object? createdAt = freezed,}) {
  return _then(_MonthGoal(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,goalDistance: null == goalDistance ? _self.goalDistance : goalDistance // ignore: cast_nullable_to_non_nullable
as double,year: null == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int,month: null == month ? _self.month : month // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
