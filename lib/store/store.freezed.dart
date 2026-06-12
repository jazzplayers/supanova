// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'store.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Store {

 String get ownerId; String get storeName; String get storeAddress; String get storeRoadAddress; String get storePhone; String get storeImage; DateTime get storeCreatedAt; DateTime get storeUpdatedAt;@GeoPointConverter() GeoPoint get location;
/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoreCopyWith<Store> get copyWith => _$StoreCopyWithImpl<Store>(this as Store, _$identity);

  /// Serializes this Store to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Store&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.storeAddress, storeAddress) || other.storeAddress == storeAddress)&&(identical(other.storeRoadAddress, storeRoadAddress) || other.storeRoadAddress == storeRoadAddress)&&(identical(other.storePhone, storePhone) || other.storePhone == storePhone)&&(identical(other.storeImage, storeImage) || other.storeImage == storeImage)&&(identical(other.storeCreatedAt, storeCreatedAt) || other.storeCreatedAt == storeCreatedAt)&&(identical(other.storeUpdatedAt, storeUpdatedAt) || other.storeUpdatedAt == storeUpdatedAt)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerId,storeName,storeAddress,storeRoadAddress,storePhone,storeImage,storeCreatedAt,storeUpdatedAt,location);

@override
String toString() {
  return 'Store(ownerId: $ownerId, storeName: $storeName, storeAddress: $storeAddress, storeRoadAddress: $storeRoadAddress, storePhone: $storePhone, storeImage: $storeImage, storeCreatedAt: $storeCreatedAt, storeUpdatedAt: $storeUpdatedAt, location: $location)';
}


}

/// @nodoc
abstract mixin class $StoreCopyWith<$Res>  {
  factory $StoreCopyWith(Store value, $Res Function(Store) _then) = _$StoreCopyWithImpl;
@useResult
$Res call({
 String ownerId, String storeName, String storeAddress, String storeRoadAddress, String storePhone, String storeImage, DateTime storeCreatedAt, DateTime storeUpdatedAt,@GeoPointConverter() GeoPoint location
});




}
/// @nodoc
class _$StoreCopyWithImpl<$Res>
    implements $StoreCopyWith<$Res> {
  _$StoreCopyWithImpl(this._self, this._then);

  final Store _self;
  final $Res Function(Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ownerId = null,Object? storeName = null,Object? storeAddress = null,Object? storeRoadAddress = null,Object? storePhone = null,Object? storeImage = null,Object? storeCreatedAt = null,Object? storeUpdatedAt = null,Object? location = null,}) {
  return _then(_self.copyWith(
ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,storeAddress: null == storeAddress ? _self.storeAddress : storeAddress // ignore: cast_nullable_to_non_nullable
as String,storeRoadAddress: null == storeRoadAddress ? _self.storeRoadAddress : storeRoadAddress // ignore: cast_nullable_to_non_nullable
as String,storePhone: null == storePhone ? _self.storePhone : storePhone // ignore: cast_nullable_to_non_nullable
as String,storeImage: null == storeImage ? _self.storeImage : storeImage // ignore: cast_nullable_to_non_nullable
as String,storeCreatedAt: null == storeCreatedAt ? _self.storeCreatedAt : storeCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,storeUpdatedAt: null == storeUpdatedAt ? _self.storeUpdatedAt : storeUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint,
  ));
}

}


/// Adds pattern-matching-related methods to [Store].
extension StorePatterns on Store {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Store value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Store value)  $default,){
final _that = this;
switch (_that) {
case _Store():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Store value)?  $default,){
final _that = this;
switch (_that) {
case _Store() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String ownerId,  String storeName,  String storeAddress,  String storeRoadAddress,  String storePhone,  String storeImage,  DateTime storeCreatedAt,  DateTime storeUpdatedAt, @GeoPointConverter()  GeoPoint location)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.ownerId,_that.storeName,_that.storeAddress,_that.storeRoadAddress,_that.storePhone,_that.storeImage,_that.storeCreatedAt,_that.storeUpdatedAt,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String ownerId,  String storeName,  String storeAddress,  String storeRoadAddress,  String storePhone,  String storeImage,  DateTime storeCreatedAt,  DateTime storeUpdatedAt, @GeoPointConverter()  GeoPoint location)  $default,) {final _that = this;
switch (_that) {
case _Store():
return $default(_that.ownerId,_that.storeName,_that.storeAddress,_that.storeRoadAddress,_that.storePhone,_that.storeImage,_that.storeCreatedAt,_that.storeUpdatedAt,_that.location);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String ownerId,  String storeName,  String storeAddress,  String storeRoadAddress,  String storePhone,  String storeImage,  DateTime storeCreatedAt,  DateTime storeUpdatedAt, @GeoPointConverter()  GeoPoint location)?  $default,) {final _that = this;
switch (_that) {
case _Store() when $default != null:
return $default(_that.ownerId,_that.storeName,_that.storeAddress,_that.storeRoadAddress,_that.storePhone,_that.storeImage,_that.storeCreatedAt,_that.storeUpdatedAt,_that.location);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Store implements Store {
  const _Store({required this.ownerId, required this.storeName, required this.storeAddress, required this.storeRoadAddress, required this.storePhone, required this.storeImage, required this.storeCreatedAt, required this.storeUpdatedAt, @GeoPointConverter() required this.location});
  factory _Store.fromJson(Map<String, dynamic> json) => _$StoreFromJson(json);

@override final  String ownerId;
@override final  String storeName;
@override final  String storeAddress;
@override final  String storeRoadAddress;
@override final  String storePhone;
@override final  String storeImage;
@override final  DateTime storeCreatedAt;
@override final  DateTime storeUpdatedAt;
@override@GeoPointConverter() final  GeoPoint location;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoreCopyWith<_Store> get copyWith => __$StoreCopyWithImpl<_Store>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StoreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Store&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.storeName, storeName) || other.storeName == storeName)&&(identical(other.storeAddress, storeAddress) || other.storeAddress == storeAddress)&&(identical(other.storeRoadAddress, storeRoadAddress) || other.storeRoadAddress == storeRoadAddress)&&(identical(other.storePhone, storePhone) || other.storePhone == storePhone)&&(identical(other.storeImage, storeImage) || other.storeImage == storeImage)&&(identical(other.storeCreatedAt, storeCreatedAt) || other.storeCreatedAt == storeCreatedAt)&&(identical(other.storeUpdatedAt, storeUpdatedAt) || other.storeUpdatedAt == storeUpdatedAt)&&(identical(other.location, location) || other.location == location));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ownerId,storeName,storeAddress,storeRoadAddress,storePhone,storeImage,storeCreatedAt,storeUpdatedAt,location);

@override
String toString() {
  return 'Store(ownerId: $ownerId, storeName: $storeName, storeAddress: $storeAddress, storeRoadAddress: $storeRoadAddress, storePhone: $storePhone, storeImage: $storeImage, storeCreatedAt: $storeCreatedAt, storeUpdatedAt: $storeUpdatedAt, location: $location)';
}


}

/// @nodoc
abstract mixin class _$StoreCopyWith<$Res> implements $StoreCopyWith<$Res> {
  factory _$StoreCopyWith(_Store value, $Res Function(_Store) _then) = __$StoreCopyWithImpl;
@override @useResult
$Res call({
 String ownerId, String storeName, String storeAddress, String storeRoadAddress, String storePhone, String storeImage, DateTime storeCreatedAt, DateTime storeUpdatedAt,@GeoPointConverter() GeoPoint location
});




}
/// @nodoc
class __$StoreCopyWithImpl<$Res>
    implements _$StoreCopyWith<$Res> {
  __$StoreCopyWithImpl(this._self, this._then);

  final _Store _self;
  final $Res Function(_Store) _then;

/// Create a copy of Store
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ownerId = null,Object? storeName = null,Object? storeAddress = null,Object? storeRoadAddress = null,Object? storePhone = null,Object? storeImage = null,Object? storeCreatedAt = null,Object? storeUpdatedAt = null,Object? location = null,}) {
  return _then(_Store(
ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,storeName: null == storeName ? _self.storeName : storeName // ignore: cast_nullable_to_non_nullable
as String,storeAddress: null == storeAddress ? _self.storeAddress : storeAddress // ignore: cast_nullable_to_non_nullable
as String,storeRoadAddress: null == storeRoadAddress ? _self.storeRoadAddress : storeRoadAddress // ignore: cast_nullable_to_non_nullable
as String,storePhone: null == storePhone ? _self.storePhone : storePhone // ignore: cast_nullable_to_non_nullable
as String,storeImage: null == storeImage ? _self.storeImage : storeImage // ignore: cast_nullable_to_non_nullable
as String,storeCreatedAt: null == storeCreatedAt ? _self.storeCreatedAt : storeCreatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,storeUpdatedAt: null == storeUpdatedAt ? _self.storeUpdatedAt : storeUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as GeoPoint,
  ));
}


}

// dart format on
