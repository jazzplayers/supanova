// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeedCommentModel {

/// 댓글 문서 ID
 String get commentId;/// 댓글이 작성된 운동 게시글 ID
 String get workoutFinishId;/// 댓글 작성자 UID
 String get userId;/// 댓글 작성 당시 작성자 닉네임
 String get displayName;/// 댓글 작성 당시 작성자 프로필 이미지
 String get profileImageUrl;/// 댓글 내용
 String get text;/// 댓글 수정 여부
 bool get isEdited;/// 댓글 작성 시간
@FeedCommentDateTimeConverter() DateTime? get createdAt;/// 댓글 수정 시간
@FeedCommentDateTimeConverter() DateTime? get updatedAt;
/// Create a copy of FeedCommentModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedCommentModelCopyWith<FeedCommentModel> get copyWith => _$FeedCommentModelCopyWithImpl<FeedCommentModel>(this as FeedCommentModel, _$identity);

  /// Serializes this FeedCommentModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedCommentModel&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.workoutFinishId, workoutFinishId) || other.workoutFinishId == workoutFinishId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.text, text) || other.text == text)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,commentId,workoutFinishId,userId,displayName,profileImageUrl,text,isEdited,createdAt,updatedAt);

@override
String toString() {
  return 'FeedCommentModel(commentId: $commentId, workoutFinishId: $workoutFinishId, userId: $userId, displayName: $displayName, profileImageUrl: $profileImageUrl, text: $text, isEdited: $isEdited, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $FeedCommentModelCopyWith<$Res>  {
  factory $FeedCommentModelCopyWith(FeedCommentModel value, $Res Function(FeedCommentModel) _then) = _$FeedCommentModelCopyWithImpl;
@useResult
$Res call({
 String commentId, String workoutFinishId, String userId, String displayName, String profileImageUrl, String text, bool isEdited,@FeedCommentDateTimeConverter() DateTime? createdAt,@FeedCommentDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class _$FeedCommentModelCopyWithImpl<$Res>
    implements $FeedCommentModelCopyWith<$Res> {
  _$FeedCommentModelCopyWithImpl(this._self, this._then);

  final FeedCommentModel _self;
  final $Res Function(FeedCommentModel) _then;

/// Create a copy of FeedCommentModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? commentId = null,Object? workoutFinishId = null,Object? userId = null,Object? displayName = null,Object? profileImageUrl = null,Object? text = null,Object? isEdited = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
commentId: null == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as String,workoutFinishId: null == workoutFinishId ? _self.workoutFinishId : workoutFinishId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: null == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedCommentModel].
extension FeedCommentModelPatterns on FeedCommentModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedCommentModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedCommentModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedCommentModel value)  $default,){
final _that = this;
switch (_that) {
case _FeedCommentModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedCommentModel value)?  $default,){
final _that = this;
switch (_that) {
case _FeedCommentModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String commentId,  String workoutFinishId,  String userId,  String displayName,  String profileImageUrl,  String text,  bool isEdited, @FeedCommentDateTimeConverter()  DateTime? createdAt, @FeedCommentDateTimeConverter()  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedCommentModel() when $default != null:
return $default(_that.commentId,_that.workoutFinishId,_that.userId,_that.displayName,_that.profileImageUrl,_that.text,_that.isEdited,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String commentId,  String workoutFinishId,  String userId,  String displayName,  String profileImageUrl,  String text,  bool isEdited, @FeedCommentDateTimeConverter()  DateTime? createdAt, @FeedCommentDateTimeConverter()  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _FeedCommentModel():
return $default(_that.commentId,_that.workoutFinishId,_that.userId,_that.displayName,_that.profileImageUrl,_that.text,_that.isEdited,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String commentId,  String workoutFinishId,  String userId,  String displayName,  String profileImageUrl,  String text,  bool isEdited, @FeedCommentDateTimeConverter()  DateTime? createdAt, @FeedCommentDateTimeConverter()  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _FeedCommentModel() when $default != null:
return $default(_that.commentId,_that.workoutFinishId,_that.userId,_that.displayName,_that.profileImageUrl,_that.text,_that.isEdited,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeedCommentModel implements FeedCommentModel {
  const _FeedCommentModel({this.commentId = '', this.workoutFinishId = '', this.userId = '', this.displayName = '사용자', this.profileImageUrl = '', this.text = '', this.isEdited = false, @FeedCommentDateTimeConverter() this.createdAt, @FeedCommentDateTimeConverter() this.updatedAt});
  factory _FeedCommentModel.fromJson(Map<String, dynamic> json) => _$FeedCommentModelFromJson(json);

/// 댓글 문서 ID
@override@JsonKey() final  String commentId;
/// 댓글이 작성된 운동 게시글 ID
@override@JsonKey() final  String workoutFinishId;
/// 댓글 작성자 UID
@override@JsonKey() final  String userId;
/// 댓글 작성 당시 작성자 닉네임
@override@JsonKey() final  String displayName;
/// 댓글 작성 당시 작성자 프로필 이미지
@override@JsonKey() final  String profileImageUrl;
/// 댓글 내용
@override@JsonKey() final  String text;
/// 댓글 수정 여부
@override@JsonKey() final  bool isEdited;
/// 댓글 작성 시간
@override@FeedCommentDateTimeConverter() final  DateTime? createdAt;
/// 댓글 수정 시간
@override@FeedCommentDateTimeConverter() final  DateTime? updatedAt;

/// Create a copy of FeedCommentModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedCommentModelCopyWith<_FeedCommentModel> get copyWith => __$FeedCommentModelCopyWithImpl<_FeedCommentModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeedCommentModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedCommentModel&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.workoutFinishId, workoutFinishId) || other.workoutFinishId == workoutFinishId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.profileImageUrl, profileImageUrl) || other.profileImageUrl == profileImageUrl)&&(identical(other.text, text) || other.text == text)&&(identical(other.isEdited, isEdited) || other.isEdited == isEdited)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,commentId,workoutFinishId,userId,displayName,profileImageUrl,text,isEdited,createdAt,updatedAt);

@override
String toString() {
  return 'FeedCommentModel(commentId: $commentId, workoutFinishId: $workoutFinishId, userId: $userId, displayName: $displayName, profileImageUrl: $profileImageUrl, text: $text, isEdited: $isEdited, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$FeedCommentModelCopyWith<$Res> implements $FeedCommentModelCopyWith<$Res> {
  factory _$FeedCommentModelCopyWith(_FeedCommentModel value, $Res Function(_FeedCommentModel) _then) = __$FeedCommentModelCopyWithImpl;
@override @useResult
$Res call({
 String commentId, String workoutFinishId, String userId, String displayName, String profileImageUrl, String text, bool isEdited,@FeedCommentDateTimeConverter() DateTime? createdAt,@FeedCommentDateTimeConverter() DateTime? updatedAt
});




}
/// @nodoc
class __$FeedCommentModelCopyWithImpl<$Res>
    implements _$FeedCommentModelCopyWith<$Res> {
  __$FeedCommentModelCopyWithImpl(this._self, this._then);

  final _FeedCommentModel _self;
  final $Res Function(_FeedCommentModel) _then;

/// Create a copy of FeedCommentModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? commentId = null,Object? workoutFinishId = null,Object? userId = null,Object? displayName = null,Object? profileImageUrl = null,Object? text = null,Object? isEdited = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_FeedCommentModel(
commentId: null == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as String,workoutFinishId: null == workoutFinishId ? _self.workoutFinishId : workoutFinishId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,profileImageUrl: null == profileImageUrl ? _self.profileImageUrl : profileImageUrl // ignore: cast_nullable_to_non_nullable
as String,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,isEdited: null == isEdited ? _self.isEdited : isEdited // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
