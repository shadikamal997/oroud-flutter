// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Shop {

 String get id; String get name; String? get logoUrl; String? get coverUrl; String? get phone; String? get whatsapp; String? get address; double get latitude; double get longitude; int get trustScore; bool get isPremium; bool get isVerified; DateTime get createdAt; DateTime get updatedAt; City get city; Area get area;
/// Create a copy of Shop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopCopyWith<Shop> get copyWith => _$ShopCopyWithImpl<Shop>(this as Shop, _$identity);

  /// Serializes this Shop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Shop&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.city, city) || other.city == city)&&(identical(other.area, area) || other.area == area));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logoUrl,coverUrl,phone,whatsapp,address,latitude,longitude,trustScore,isPremium,isVerified,createdAt,updatedAt,city,area);

@override
String toString() {
  return 'Shop(id: $id, name: $name, logoUrl: $logoUrl, coverUrl: $coverUrl, phone: $phone, whatsapp: $whatsapp, address: $address, latitude: $latitude, longitude: $longitude, trustScore: $trustScore, isPremium: $isPremium, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt, city: $city, area: $area)';
}


}

/// @nodoc
abstract mixin class $ShopCopyWith<$Res>  {
  factory $ShopCopyWith(Shop value, $Res Function(Shop) _then) = _$ShopCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? logoUrl, String? coverUrl, String? phone, String? whatsapp, String? address, double latitude, double longitude, int trustScore, bool isPremium, bool isVerified, DateTime createdAt, DateTime updatedAt, City city, Area area
});




}
/// @nodoc
class _$ShopCopyWithImpl<$Res>
    implements $ShopCopyWith<$Res> {
  _$ShopCopyWithImpl(this._self, this._then);

  final Shop _self;
  final $Res Function(Shop) _then;

/// Create a copy of Shop
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? logoUrl = freezed,Object? coverUrl = freezed,Object? phone = freezed,Object? whatsapp = freezed,Object? address = freezed,Object? latitude = null,Object? longitude = null,Object? trustScore = null,Object? isPremium = null,Object? isVerified = null,Object? createdAt = null,Object? updatedAt = null,Object? city = null,Object? area = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as City,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as Area,
  ));
}

}


/// Adds pattern-matching-related methods to [Shop].
extension ShopPatterns on Shop {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Shop value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Shop() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Shop value)  $default,){
final _that = this;
switch (_that) {
case _Shop():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Shop value)?  $default,){
final _that = this;
switch (_that) {
case _Shop() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? logoUrl,  String? coverUrl,  String? phone,  String? whatsapp,  String? address,  double latitude,  double longitude,  int trustScore,  bool isPremium,  bool isVerified,  DateTime createdAt,  DateTime updatedAt,  City city,  Area area)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Shop() when $default != null:
return $default(_that.id,_that.name,_that.logoUrl,_that.coverUrl,_that.phone,_that.whatsapp,_that.address,_that.latitude,_that.longitude,_that.trustScore,_that.isPremium,_that.isVerified,_that.createdAt,_that.updatedAt,_that.city,_that.area);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? logoUrl,  String? coverUrl,  String? phone,  String? whatsapp,  String? address,  double latitude,  double longitude,  int trustScore,  bool isPremium,  bool isVerified,  DateTime createdAt,  DateTime updatedAt,  City city,  Area area)  $default,) {final _that = this;
switch (_that) {
case _Shop():
return $default(_that.id,_that.name,_that.logoUrl,_that.coverUrl,_that.phone,_that.whatsapp,_that.address,_that.latitude,_that.longitude,_that.trustScore,_that.isPremium,_that.isVerified,_that.createdAt,_that.updatedAt,_that.city,_that.area);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? logoUrl,  String? coverUrl,  String? phone,  String? whatsapp,  String? address,  double latitude,  double longitude,  int trustScore,  bool isPremium,  bool isVerified,  DateTime createdAt,  DateTime updatedAt,  City city,  Area area)?  $default,) {final _that = this;
switch (_that) {
case _Shop() when $default != null:
return $default(_that.id,_that.name,_that.logoUrl,_that.coverUrl,_that.phone,_that.whatsapp,_that.address,_that.latitude,_that.longitude,_that.trustScore,_that.isPremium,_that.isVerified,_that.createdAt,_that.updatedAt,_that.city,_that.area);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Shop implements Shop {
  const _Shop({required this.id, required this.name, this.logoUrl, this.coverUrl, this.phone, this.whatsapp, this.address, required this.latitude, required this.longitude, required this.trustScore, required this.isPremium, required this.isVerified, required this.createdAt, required this.updatedAt, required this.city, required this.area});
  factory _Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? logoUrl;
@override final  String? coverUrl;
@override final  String? phone;
@override final  String? whatsapp;
@override final  String? address;
@override final  double latitude;
@override final  double longitude;
@override final  int trustScore;
@override final  bool isPremium;
@override final  bool isVerified;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  City city;
@override final  Area area;

/// Create a copy of Shop
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShopCopyWith<_Shop> get copyWith => __$ShopCopyWithImpl<_Shop>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShopToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Shop&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.whatsapp, whatsapp) || other.whatsapp == whatsapp)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.isVerified, isVerified) || other.isVerified == isVerified)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.city, city) || other.city == city)&&(identical(other.area, area) || other.area == area));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logoUrl,coverUrl,phone,whatsapp,address,latitude,longitude,trustScore,isPremium,isVerified,createdAt,updatedAt,city,area);

@override
String toString() {
  return 'Shop(id: $id, name: $name, logoUrl: $logoUrl, coverUrl: $coverUrl, phone: $phone, whatsapp: $whatsapp, address: $address, latitude: $latitude, longitude: $longitude, trustScore: $trustScore, isPremium: $isPremium, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt, city: $city, area: $area)';
}


}

/// @nodoc
abstract mixin class _$ShopCopyWith<$Res> implements $ShopCopyWith<$Res> {
  factory _$ShopCopyWith(_Shop value, $Res Function(_Shop) _then) = __$ShopCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? logoUrl, String? coverUrl, String? phone, String? whatsapp, String? address, double latitude, double longitude, int trustScore, bool isPremium, bool isVerified, DateTime createdAt, DateTime updatedAt, City city, Area area
});




}
/// @nodoc
class __$ShopCopyWithImpl<$Res>
    implements _$ShopCopyWith<$Res> {
  __$ShopCopyWithImpl(this._self, this._then);

  final _Shop _self;
  final $Res Function(_Shop) _then;

/// Create a copy of Shop
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? logoUrl = freezed,Object? coverUrl = freezed,Object? phone = freezed,Object? whatsapp = freezed,Object? address = freezed,Object? latitude = null,Object? longitude = null,Object? trustScore = null,Object? isPremium = null,Object? isVerified = null,Object? createdAt = null,Object? updatedAt = null,Object? city = null,Object? area = null,}) {
  return _then(_Shop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,whatsapp: freezed == whatsapp ? _self.whatsapp : whatsapp // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,isVerified: null == isVerified ? _self.isVerified : isVerified // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as City,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as Area,
  ));
}


}

// dart format on
