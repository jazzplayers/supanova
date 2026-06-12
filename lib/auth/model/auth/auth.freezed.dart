// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Auth {

 String get uid; String get displayName; String get email; String get displayNameKey; int get workoutCount; int get followersCount; int get followingsCount; double get totalDistance; bool get isPrivate;@DateTimeConverter() DateTime? get createdAt;@DateTimeConverter() DateTime? get updatedAt; String get bio; String get profileImageUrl;
/// Create a copy of Auth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthCopyWith<Auth> get copyWith => _$AuthCopyWithImpl<Auth>(this as Auth, _$identity);

  /// Serializes this Auth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Auth&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayNameKey, displayNameKey) || other.displayNameKey == displayNameKey)&&(identical(other.workoutCount, workoutCount) || other.workoutCount == workoutCount)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingsCount, followingsCount) || other.followingsCount == followingsCount)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,email,displayNameKey,workoutCount,followersCount,followingsCount,totalDistance,isPrivate,createdAt,updatedAt,bio,profileImageUrl);

@override
String toString() {
  return 'Auth(uid: $uid, displayName: $displayName, email: $email, displayNameKey: $displayNameKey, workoutCount: $workoutCount, followersCount: $followersCount, followingsCount: $followingsCount, totalDistance: $totalDistance, isPrivate: $isPrivate, createdAt: $createdAt, updatedAt: $updatedAt, bio: $bio, profileImageUrl: $profileImageUrl)';
}


}

/// @nodoc
abstract mixin class $AuthCopyWith<$Res>  {
  factory $AuthCopyWith(Auth value, $Res Function(Auth) _then) = _$AuthCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName, String email, String displayNameKey, int workoutCount, int followersCount, int followingsCount, double totalDistance, bool isPrivate,@DateTimeConverter() DateTime? createdAt,@DateTimeConverter() DateTime? updatedAt, String bio, String profileImageUrl
});




}
/// @nodoc
class _$AuthCopyWithImpl<$Res>
    implements $AuthCopyWith<$Res> {
  _$AuthCopyWithImpl(this._self, this._then);

  final Auth _self;
  final $Res Function(Auth) _then;

/// Create a copy of Auth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? email = null,Object? displayNameKey = null,Object? workoutCount = null,Object? followersCount = null,Object? followingsCount = null,Object? totalDistance = null,Object? isPrivate = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? bio = null,Object? profileImageUrl = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayNameKey: null == displayNameKey ? _self.displayNameKey : displayNameKey // ignore: cast_nullable_to_non_nullable
as String,workoutCount: null == workoutCount ? _self.workoutCount : workoutCount // ignore: cast_nullable_to_non_nullable
as int,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingsCount: null == followingsCount ? _self.followingsCount : followingsCount // ignore: cast_nullable_to_non_nullable
as int,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: null == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Auth].
extension AuthPatterns on Auth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Auth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Auth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Auth value)  $default,){
final _that = this;
switch (_that) {
case _Auth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Auth value)?  $default,){
final _that = this;
switch (_that) {
case _Auth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName,  String email,  String displayNameKey,  int workoutCount,  int followersCount,  int followingsCount,  double totalDistance,  bool isPrivate, @DateTimeConverter()  DateTime? createdAt, @DateTimeConverter()  DateTime? updatedAt,  String bio,  String profileImageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Auth() when $default != null:
return $default(_that.uid,_that.displayName,_that.email,_that.displayNameKey,_that.workoutCount,_that.followersCount,_that.followingsCount,_that.totalDistance,_that.isPrivate,_that.createdAt,_that.updatedAt,_that.bio,_that.profileImageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName,  String email,  String displayNameKey,  int workoutCount,  int followersCount,  int followingsCount,  double totalDistance,  bool isPrivate, @DateTimeConverter()  DateTime? createdAt, @DateTimeConverter()  DateTime? updatedAt,  String bio,  String profileImageUrl)  $default,) {final _that = this;
switch (_that) {
case _Auth():
return $default(_that.uid,_that.displayName,_that.email,_that.displayNameKey,_that.workoutCount,_that.followersCount,_that.followingsCount,_that.totalDistance,_that.isPrivate,_that.createdAt,_that.updatedAt,_that.bio,_that.profileImageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName,  String email,  String displayNameKey,  int workoutCount,  int followersCount,  int followingsCount,  double totalDistance,  bool isPrivate, @DateTimeConverter()  DateTime? createdAt, @DateTimeConverter()  DateTime? updatedAt,  String bio,  String profileImageUrl)?  $default,) {final _that = this;
switch (_that) {
case _Auth() when $default != null:
return $default(_that.uid,_that.displayName,_that.email,_that.displayNameKey,_that.workoutCount,_that.followersCount,_that.followingsCount,_that.totalDistance,_that.isPrivate,_that.createdAt,_that.updatedAt,_that.bio,_that.profileImageUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Auth implements Auth {
  const _Auth({required this.uid, this.displayName = '', this.email = '', this.displayNameKey = '', this.workoutCount = 0, this.followersCount = 0, this.followingsCount = 0, this.totalDistance = 0.0, this.isPrivate = false, @DateTimeConverter() this.createdAt, @DateTimeConverter() this.updatedAt, this.bio = '', this.profileImageUrl = ''});
  factory _Auth.fromJson(Map<String, dynamic> json) => _$AuthFromJson(json);

@override final  String uid;
@override@JsonKey() final  String displayName;
@override@JsonKey() final  String email;
@override@JsonKey() final  String displayNameKey;
@override@JsonKey() final  int workoutCount;
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int followingsCount;
@override@JsonKey() final  double totalDistance;
@override@JsonKey() final  bool isPrivate;
@override@DateTimeConverter() final  DateTime? createdAt;
@override@DateTimeConverter() final  DateTime? updatedAt;
@override@JsonKey() final  String bio;
@override@JsonKey() final  String profileImageUrl;

/// Create a copy of Auth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthCopyWith<_Auth> get copyWith => __$AuthCopyWithImpl<_Auth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Auth&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayNameKey, displayNameKey) || other.displayNameKey == displayNameKey)&&(identical(other.workoutCount, workoutCount) || other.workoutCount == workoutCount)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingsCount, followingsCount) || other.followingsCount == followingsCount)&&(identical(other.totalDistance, totalDistance) || other.totalDistance == totalDistance)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uid,displayName,email,displayNameKey,workoutCount,followersCount,followingsCount,totalDistance,isPrivate,createdAt,updatedAt,bio,profileImageUrl);

@override
String toString() {
  return 'Auth(uid: $uid, displayName: $displayName, email: $email, displayNameKey: $displayNameKey, workoutCount: $workoutCount, followersCount: $followersCount, followingsCount: $followingsCount, totalDistance: $totalDistance, isPrivate: $isPrivate, createdAt: $createdAt, updatedAt: $updatedAt, bio: $bio, profileImageUrl: $profileImageUrl)';
}


}

/// @nodoc
abstract mixin class _$AuthCopyWith<$Res> implements $AuthCopyWith<$Res> {
  factory _$AuthCopyWith(_Auth value, $Res Function(_Auth) _then) = __$AuthCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName, String email, String displayNameKey, int workoutCount, int followersCount, int followingsCount, double totalDistance, bool isPrivate,@DateTimeConverter() DateTime? createdAt,@DateTimeConverter() DateTime? updatedAt, String bio, String profileImageUrl
});




}
/// @nodoc
class __$AuthCopyWithImpl<$Res>
    implements _$AuthCopyWith<$Res> {
  __$AuthCopyWithImpl(this._self, this._then);

  final _Auth _self;
  final $Res Function(_Auth) _then;

/// Create a copy of Auth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? email = null,Object? displayNameKey = null,Object? workoutCount = null,Object? followersCount = null,Object? followingsCount = null,Object? totalDistance = null,Object? isPrivate = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? bio = null,Object? profileImageUrl = null,}) {
  return _then(_Auth(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayNameKey: null == displayNameKey ? _self.displayNameKey : displayNameKey // ignore: cast_nullable_to_non_nullable
as String,workoutCount: null == workoutCount ? _self.workoutCount : workoutCount // ignore: cast_nullable_to_non_nullable
as int,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingsCount: null == followingsCount ? _self.followingsCount : followingsCount // ignore: cast_nullable_to_non_nullable
as int,totalDistance: null == totalDistance ? _self.totalDistance : totalDistance // ignore: cast_nullable_to_non_nullable
as double,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: null == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
