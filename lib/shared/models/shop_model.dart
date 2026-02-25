import 'package:freezed_annotation/freezed_annotation.dart';
import 'city_model.dart';
import 'area_model.dart';

part 'shop_model.freezed.dart';
part 'shop_model.g.dart';

@freezed
abstract class Shop with _$Shop {
  const factory Shop({
    required String id,
    required String name,
    String? logoUrl,
    String? coverUrl,
    String? phone,
    String? whatsapp,
    String? address,
    required double latitude,
    required double longitude,
    required int trustScore,
    required bool isPremium,
    required bool isVerified,
    required DateTime createdAt,
    required DateTime updatedAt,
    required City city,
    required Area area,
  }) = _Shop;

  factory Shop.fromJson(Map<String, dynamic> json) => _$ShopFromJson(json);
}
