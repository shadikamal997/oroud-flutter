// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Offer _$OfferFromJson(Map<String, dynamic> json) => _Offer(
  id: json['id'] as String,
  title: json['title'] as String,
  originalPrice: (json['originalPrice'] as num).toDouble(),
  discountedPrice: (json['discountedPrice'] as num).toDouble(),
  discountPercentage: (json['discountPercentage'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String,
  expiryDate: DateTime.parse(json['expiryDate'] as String),
  isPremium: json['isPremium'] as bool,
  shop: Shop.fromJson(json['shop'] as Map<String, dynamic>),
);

Map<String, dynamic> _$OfferToJson(_Offer instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'originalPrice': instance.originalPrice,
  'discountedPrice': instance.discountedPrice,
  'discountPercentage': instance.discountPercentage,
  'imageUrl': instance.imageUrl,
  'expiryDate': instance.expiryDate.toIso8601String(),
  'isPremium': instance.isPremium,
  'shop': instance.shop,
};

_Shop _$ShopFromJson(Map<String, dynamic> json) => _Shop(
  id: json['id'] as String,
  name: json['name'] as String,
  logoUrl: json['logoUrl'] as String,
  trustScore: (json['trustScore'] as num).toInt(),
);

Map<String, dynamic> _$ShopToJson(_Shop instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'logoUrl': instance.logoUrl,
  'trustScore': instance.trustScore,
};
