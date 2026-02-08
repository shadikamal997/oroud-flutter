// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offer_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Offer {

 String get id; String get title; double get originalPrice; double get discountedPrice; double get discountPercentage; String get imageUrl; DateTime get expiryDate; bool get isPremium; Shop get shop;
/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfferCopyWith<Offer> get copyWith => _$OfferCopyWithImpl<Offer>(this as Offer, _$identity);

  /// Serializes this Offer to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Offer&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.discountedPrice, discountedPrice) || other.discountedPrice == discountedPrice)&&(identical(other.discountPercentage, discountPercentage) || other.discountPercentage == discountPercentage)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.shop, shop) || other.shop == shop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,originalPrice,discountedPrice,discountPercentage,imageUrl,expiryDate,isPremium,shop);

@override
String toString() {
  return 'Offer(id: $id, title: $title, originalPrice: $originalPrice, discountedPrice: $discountedPrice, discountPercentage: $discountPercentage, imageUrl: $imageUrl, expiryDate: $expiryDate, isPremium: $isPremium, shop: $shop)';
}


}

/// @nodoc
abstract mixin class $OfferCopyWith<$Res>  {
  factory $OfferCopyWith(Offer value, $Res Function(Offer) _then) = _$OfferCopyWithImpl;
@useResult
$Res call({
 String id, String title, double originalPrice, double discountedPrice, double discountPercentage, String imageUrl, DateTime expiryDate, bool isPremium, Shop shop
});


$ShopCopyWith<$Res> get shop;

}
/// @nodoc
class _$OfferCopyWithImpl<$Res>
    implements $OfferCopyWith<$Res> {
  _$OfferCopyWithImpl(this._self, this._then);

  final Offer _self;
  final $Res Function(Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? originalPrice = null,Object? discountedPrice = null,Object? discountPercentage = null,Object? imageUrl = null,Object? expiryDate = null,Object? isPremium = null,Object? shop = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalPrice: null == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double,discountedPrice: null == discountedPrice ? _self.discountedPrice : discountedPrice // ignore: cast_nullable_to_non_nullable
as double,discountPercentage: null == discountPercentage ? _self.discountPercentage : discountPercentage // ignore: cast_nullable_to_non_nullable
as double,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,expiryDate: null == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,shop: null == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as Shop,
  ));
}
/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res> get shop {
  
  return $ShopCopyWith<$Res>(_self.shop, (value) {
    return _then(_self.copyWith(shop: value));
  });
}
}


/// Adds pattern-matching-related methods to [Offer].
extension OfferPatterns on Offer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Offer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Offer value)  $default,){
final _that = this;
switch (_that) {
case _Offer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Offer value)?  $default,){
final _that = this;
switch (_that) {
case _Offer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  double originalPrice,  double discountedPrice,  double discountPercentage,  String imageUrl,  DateTime expiryDate,  bool isPremium,  Shop shop)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.id,_that.title,_that.originalPrice,_that.discountedPrice,_that.discountPercentage,_that.imageUrl,_that.expiryDate,_that.isPremium,_that.shop);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  double originalPrice,  double discountedPrice,  double discountPercentage,  String imageUrl,  DateTime expiryDate,  bool isPremium,  Shop shop)  $default,) {final _that = this;
switch (_that) {
case _Offer():
return $default(_that.id,_that.title,_that.originalPrice,_that.discountedPrice,_that.discountPercentage,_that.imageUrl,_that.expiryDate,_that.isPremium,_that.shop);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  double originalPrice,  double discountedPrice,  double discountPercentage,  String imageUrl,  DateTime expiryDate,  bool isPremium,  Shop shop)?  $default,) {final _that = this;
switch (_that) {
case _Offer() when $default != null:
return $default(_that.id,_that.title,_that.originalPrice,_that.discountedPrice,_that.discountPercentage,_that.imageUrl,_that.expiryDate,_that.isPremium,_that.shop);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Offer implements Offer {
  const _Offer({required this.id, required this.title, required this.originalPrice, required this.discountedPrice, required this.discountPercentage, required this.imageUrl, required this.expiryDate, required this.isPremium, required this.shop});
  factory _Offer.fromJson(Map<String, dynamic> json) => _$OfferFromJson(json);

@override final  String id;
@override final  String title;
@override final  double originalPrice;
@override final  double discountedPrice;
@override final  double discountPercentage;
@override final  String imageUrl;
@override final  DateTime expiryDate;
@override final  bool isPremium;
@override final  Shop shop;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfferCopyWith<_Offer> get copyWith => __$OfferCopyWithImpl<_Offer>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OfferToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Offer&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.originalPrice, originalPrice) || other.originalPrice == originalPrice)&&(identical(other.discountedPrice, discountedPrice) || other.discountedPrice == discountedPrice)&&(identical(other.discountPercentage, discountPercentage) || other.discountPercentage == discountPercentage)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.expiryDate, expiryDate) || other.expiryDate == expiryDate)&&(identical(other.isPremium, isPremium) || other.isPremium == isPremium)&&(identical(other.shop, shop) || other.shop == shop));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,originalPrice,discountedPrice,discountPercentage,imageUrl,expiryDate,isPremium,shop);

@override
String toString() {
  return 'Offer(id: $id, title: $title, originalPrice: $originalPrice, discountedPrice: $discountedPrice, discountPercentage: $discountPercentage, imageUrl: $imageUrl, expiryDate: $expiryDate, isPremium: $isPremium, shop: $shop)';
}


}

/// @nodoc
abstract mixin class _$OfferCopyWith<$Res> implements $OfferCopyWith<$Res> {
  factory _$OfferCopyWith(_Offer value, $Res Function(_Offer) _then) = __$OfferCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, double originalPrice, double discountedPrice, double discountPercentage, String imageUrl, DateTime expiryDate, bool isPremium, Shop shop
});


@override $ShopCopyWith<$Res> get shop;

}
/// @nodoc
class __$OfferCopyWithImpl<$Res>
    implements _$OfferCopyWith<$Res> {
  __$OfferCopyWithImpl(this._self, this._then);

  final _Offer _self;
  final $Res Function(_Offer) _then;

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? originalPrice = null,Object? discountedPrice = null,Object? discountPercentage = null,Object? imageUrl = null,Object? expiryDate = null,Object? isPremium = null,Object? shop = null,}) {
  return _then(_Offer(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,originalPrice: null == originalPrice ? _self.originalPrice : originalPrice // ignore: cast_nullable_to_non_nullable
as double,discountedPrice: null == discountedPrice ? _self.discountedPrice : discountedPrice // ignore: cast_nullable_to_non_nullable
as double,discountPercentage: null == discountPercentage ? _self.discountPercentage : discountPercentage // ignore: cast_nullable_to_non_nullable
as double,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,expiryDate: null == expiryDate ? _self.expiryDate : expiryDate // ignore: cast_nullable_to_non_nullable
as DateTime,isPremium: null == isPremium ? _self.isPremium : isPremium // ignore: cast_nullable_to_non_nullable
as bool,shop: null == shop ? _self.shop : shop // ignore: cast_nullable_to_non_nullable
as Shop,
  ));
}

/// Create a copy of Offer
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ShopCopyWith<$Res> get shop {
  
  return $ShopCopyWith<$Res>(_self.shop, (value) {
    return _then(_self.copyWith(shop: value));
  });
}
}


/// @nodoc
mixin _$Shop {

 String get id; String get name; String get logoUrl; int get trustScore;
/// Create a copy of Shop
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShopCopyWith<Shop> get copyWith => _$ShopCopyWithImpl<Shop>(this as Shop, _$identity);

  /// Serializes this Shop to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Shop&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logoUrl,trustScore);

@override
String toString() {
  return 'Shop(id: $id, name: $name, logoUrl: $logoUrl, trustScore: $trustScore)';
}


}

/// @nodoc
abstract mixin class $ShopCopyWith<$Res>  {
  factory $ShopCopyWith(Shop value, $Res Function(Shop) _then) = _$ShopCopyWithImpl;
@useResult
$Res call({
 String id, String name, String logoUrl, int trustScore
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? logoUrl = null,Object? trustScore = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String logoUrl,  int trustScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Shop() when $default != null:
return $default(_that.id,_that.name,_that.logoUrl,_that.trustScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String logoUrl,  int trustScore)  $default,) {final _that = this;
switch (_that) {
case _Shop():
return $default(_that.id,_that.name,_that.logoUrl,_that.trustScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String logoUrl,  int trustScore)?  $default,) {final _that = this;
switch (_that) {
case _Shop() when $default != null:
return $default(_that.id,_that.name,_that.logoUrl,_that.trustScore);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Shop implements Shop {
  const _Shop({required this.id, required this.name, required this.logoUrl, required this.trustScore});
  factory _Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);

@override final  String id;
@override final  String name;
@override final  String logoUrl;
@override final  int trustScore;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Shop&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.trustScore, trustScore) || other.trustScore == trustScore));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,logoUrl,trustScore);

@override
String toString() {
  return 'Shop(id: $id, name: $name, logoUrl: $logoUrl, trustScore: $trustScore)';
}


}

/// @nodoc
abstract mixin class _$ShopCopyWith<$Res> implements $ShopCopyWith<$Res> {
  factory _$ShopCopyWith(_Shop value, $Res Function(_Shop) _then) = __$ShopCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String logoUrl, int trustScore
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? logoUrl = null,Object? trustScore = null,}) {
  return _then(_Shop(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,logoUrl: null == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String,trustScore: null == trustScore ? _self.trustScore : trustScore // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
