// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AdModel _$AdModelFromJson(Map<String, dynamic> json) => _AdModel(
  id: json['id'] as String,
  title: json['title'] as String,
  imageUrl: json['imageUrl'] as String,
  redirectUrl: json['redirectUrl'] as String,
  placement: $enumDecode(_$AdPlacementEnumMap, json['placement']),
  cityId: json['cityId'] as String?,
  isActive: json['isActive'] as bool,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate: DateTime.parse(json['endDate'] as String),
  priority: (json['priority'] as num).toInt(),
  clicks: (json['clicks'] as num).toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$AdModelToJson(_AdModel instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'imageUrl': instance.imageUrl,
  'redirectUrl': instance.redirectUrl,
  'placement': _$AdPlacementEnumMap[instance.placement]!,
  'cityId': instance.cityId,
  'isActive': instance.isActive,
  'startDate': instance.startDate.toIso8601String(),
  'endDate': instance.endDate.toIso8601String(),
  'priority': instance.priority,
  'clicks': instance.clicks,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$AdPlacementEnumMap = {
  AdPlacement.HERO: 'HERO',
  AdPlacement.HOME_FEED: 'HOME_FEED',
  AdPlacement.SIDEBAR: 'SIDEBAR',
  AdPlacement.POPUP: 'POPUP',
};
