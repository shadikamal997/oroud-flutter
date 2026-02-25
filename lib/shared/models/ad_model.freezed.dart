// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ad_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AdModel {

 String get id; String get title; String get imageUrl; String get redirectUrl; AdPlacement get placement; String? get cityId; bool get isActive; DateTime get startDate; DateTime get endDate; int get priority; int get clicks; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of AdModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AdModelCopyWith<AdModel> get copyWith => _$AdModelCopyWithImpl<AdModel>(this as AdModel, _$identity);

  /// Serializes this AdModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AdModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.redirectUrl, redirectUrl) || other.redirectUrl == redirectUrl)&&(identical(other.placement, placement) || other.placement == placement)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.clicks, clicks) || other.clicks == clicks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,imageUrl,redirectUrl,placement,cityId,isActive,startDate,endDate,priority,clicks,createdAt,updatedAt);

@override
String toString() {
  return 'AdModel(id: $id, title: $title, imageUrl: $imageUrl, redirectUrl: $redirectUrl, placement: $placement, cityId: $cityId, isActive: $isActive, startDate: $startDate, endDate: $endDate, priority: $priority, clicks: $clicks, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $AdModelCopyWith<$Res>  {
  factory $AdModelCopyWith(AdModel value, $Res Function(AdModel) _then) = _$AdModelCopyWithImpl;
@useResult
$Res call({
 String id, String title, String imageUrl, String redirectUrl, AdPlacement placement, String? cityId, bool isActive, DateTime startDate, DateTime endDate, int priority, int clicks, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$AdModelCopyWithImpl<$Res>
    implements $AdModelCopyWith<$Res> {
  _$AdModelCopyWithImpl(this._self, this._then);

  final AdModel _self;
  final $Res Function(AdModel) _then;

/// Create a copy of AdModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? imageUrl = null,Object? redirectUrl = null,Object? placement = null,Object? cityId = freezed,Object? isActive = null,Object? startDate = null,Object? endDate = null,Object? priority = null,Object? clicks = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,redirectUrl: null == redirectUrl ? _self.redirectUrl : redirectUrl // ignore: cast_nullable_to_non_nullable
as String,placement: null == placement ? _self.placement : placement // ignore: cast_nullable_to_non_nullable
as AdPlacement,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,clicks: null == clicks ? _self.clicks : clicks // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [AdModel].
extension AdModelPatterns on AdModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AdModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AdModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AdModel value)  $default,){
final _that = this;
switch (_that) {
case _AdModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AdModel value)?  $default,){
final _that = this;
switch (_that) {
case _AdModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String imageUrl,  String redirectUrl,  AdPlacement placement,  String? cityId,  bool isActive,  DateTime startDate,  DateTime endDate,  int priority,  int clicks,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AdModel() when $default != null:
return $default(_that.id,_that.title,_that.imageUrl,_that.redirectUrl,_that.placement,_that.cityId,_that.isActive,_that.startDate,_that.endDate,_that.priority,_that.clicks,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String imageUrl,  String redirectUrl,  AdPlacement placement,  String? cityId,  bool isActive,  DateTime startDate,  DateTime endDate,  int priority,  int clicks,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _AdModel():
return $default(_that.id,_that.title,_that.imageUrl,_that.redirectUrl,_that.placement,_that.cityId,_that.isActive,_that.startDate,_that.endDate,_that.priority,_that.clicks,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String imageUrl,  String redirectUrl,  AdPlacement placement,  String? cityId,  bool isActive,  DateTime startDate,  DateTime endDate,  int priority,  int clicks,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _AdModel() when $default != null:
return $default(_that.id,_that.title,_that.imageUrl,_that.redirectUrl,_that.placement,_that.cityId,_that.isActive,_that.startDate,_that.endDate,_that.priority,_that.clicks,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AdModel implements AdModel {
  const _AdModel({required this.id, required this.title, required this.imageUrl, required this.redirectUrl, required this.placement, this.cityId, required this.isActive, required this.startDate, required this.endDate, required this.priority, required this.clicks, this.createdAt, this.updatedAt});
  factory _AdModel.fromJson(Map<String, dynamic> json) => _$AdModelFromJson(json);

@override final  String id;
@override final  String title;
@override final  String imageUrl;
@override final  String redirectUrl;
@override final  AdPlacement placement;
@override final  String? cityId;
@override final  bool isActive;
@override final  DateTime startDate;
@override final  DateTime endDate;
@override final  int priority;
@override final  int clicks;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of AdModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AdModelCopyWith<_AdModel> get copyWith => __$AdModelCopyWithImpl<_AdModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AdModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AdModel&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.redirectUrl, redirectUrl) || other.redirectUrl == redirectUrl)&&(identical(other.placement, placement) || other.placement == placement)&&(identical(other.cityId, cityId) || other.cityId == cityId)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.clicks, clicks) || other.clicks == clicks)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,imageUrl,redirectUrl,placement,cityId,isActive,startDate,endDate,priority,clicks,createdAt,updatedAt);

@override
String toString() {
  return 'AdModel(id: $id, title: $title, imageUrl: $imageUrl, redirectUrl: $redirectUrl, placement: $placement, cityId: $cityId, isActive: $isActive, startDate: $startDate, endDate: $endDate, priority: $priority, clicks: $clicks, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$AdModelCopyWith<$Res> implements $AdModelCopyWith<$Res> {
  factory _$AdModelCopyWith(_AdModel value, $Res Function(_AdModel) _then) = __$AdModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String imageUrl, String redirectUrl, AdPlacement placement, String? cityId, bool isActive, DateTime startDate, DateTime endDate, int priority, int clicks, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$AdModelCopyWithImpl<$Res>
    implements _$AdModelCopyWith<$Res> {
  __$AdModelCopyWithImpl(this._self, this._then);

  final _AdModel _self;
  final $Res Function(_AdModel) _then;

/// Create a copy of AdModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? imageUrl = null,Object? redirectUrl = null,Object? placement = null,Object? cityId = freezed,Object? isActive = null,Object? startDate = null,Object? endDate = null,Object? priority = null,Object? clicks = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_AdModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,redirectUrl: null == redirectUrl ? _self.redirectUrl : redirectUrl // ignore: cast_nullable_to_non_nullable
as String,placement: null == placement ? _self.placement : placement // ignore: cast_nullable_to_non_nullable
as AdPlacement,cityId: freezed == cityId ? _self.cityId : cityId // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: null == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,clicks: null == clicks ? _self.clicks : clicks // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
