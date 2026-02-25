// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Shop _$ShopFromJson(Map<String, dynamic> json) => _Shop(
  id: json['id'] as String,
  name: json['name'] as String,
  logoUrl: json['logoUrl'] as String?,
  coverUrl: json['coverUrl'] as String?,
  phone: json['phone'] as String?,
  whatsapp: json['whatsapp'] as String?,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  trustScore: (json['trustScore'] as num).toInt(),
  isPremium: json['isPremium'] as bool,
  isVerified: json['isVerified'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  city: City.fromJson(json['city'] as Map<String, dynamic>),
  area: Area.fromJson(json['area'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ShopToJson(_Shop instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'logoUrl': instance.logoUrl,
  'coverUrl': instance.coverUrl,
  'phone': instance.phone,
  'whatsapp': instance.whatsapp,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'trustScore': instance.trustScore,
  'isPremium': instance.isPremium,
  'isVerified': instance.isVerified,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'city': instance.city,
  'area': instance.area,
};
