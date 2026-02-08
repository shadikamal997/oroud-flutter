import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer_model.freezed.dart';
part 'offer_model.g.dart';

@freezed
class Offer with _$Offer {
  const factory Offer({
    required String id,
    required String title,
    required double originalPrice,
    required double discountedPrice,
    required double discountPercentage,
    required String imageUrl,
    required DateTime expiryDate,
    required bool isPremium,
    required Shop shop,
  }) = _Offer;

  factory Offer.fromJson(Map<String, dynamic> json) =>
      _$OfferFromJson(json);
}

@freezed
class Shop with _$Shop {
  const factory Shop({
    required String id,
    required String name,
    required String logoUrl,
    required int trustScore,
  }) = _Shop;

  factory Shop.fromJson(Map<String, dynamic> json) =>
      _$ShopFromJson(json);
}
