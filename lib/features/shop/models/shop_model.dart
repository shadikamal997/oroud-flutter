class Shop {
  final String id;
  final String name;
  final String userId;
  final String cityId;
  final String? areaId;
  final double latitude;
  final double longitude;
  final String? logoUrl;
  final String? coverUrl;
  final String? description;
  final String phone;
  final String? website;
  final double trustScore;
  final bool isVerified;
  final bool isPremium;
  final String? subscriptionPlan;
  final DateTime? subscriptionExpiresAt;
  final int followersCount;
  final int offersCount;
  final double rating;
  final int reviewCount;
  final List<OfferPreview> offers; // 🔥 Offers for profile grid
  final DateTime createdAt;
  final DateTime updatedAt;

  // Computed fields from nested objects
  String? cityName;
  String? areaName;

  Shop({
    required this.id,
    required this.name,
    required this.userId,
    required this.cityId,
    this.areaId,
    required this.latitude,
    required this.longitude,
    this.logoUrl,
    this.coverUrl,
    this.description,
    required this.phone,
    this.website,
    required this.trustScore,
    required this.isVerified,
    required this.isPremium,
    this.subscriptionPlan,
    this.subscriptionExpiresAt,
    this.followersCount = 0,
    this.offersCount = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.offers = const [],
    required this.createdAt,
    required this.updatedAt,
    this.cityName,
    this.areaName,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numeric values (handles both String and num from backend)
    double parseDouble(dynamic value, double defaultValue) {
      if (value == null) return defaultValue;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    int parseInt(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    return Shop(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['userId'] as String? ?? '',
      cityId: json['city']?['id'] as String? ?? json['cityId'] as String? ?? '',
      areaId: json['area']?['id'] as String? ?? json['areaId'] as String?,
      latitude: parseDouble(json['latitude'], 0.0),
      longitude: parseDouble(json['longitude'], 0.0),
      logoUrl: json['logoUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String? ?? '',
      website: json['website'] as String?,
      trustScore: parseDouble(json['trustScore'], 70.0),
      isVerified: json['isVerified'] as bool? ?? false,
      isPremium: json['isPremium'] as bool? ?? false,
      subscriptionPlan: json['subscriptionPlan'] as String?,
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.parse(json['subscriptionExpiresAt'] as String)
          : null,
      followersCount: parseInt(json['followersCount'], 0),
      offersCount: parseInt(json['offersCount'], 0),
      rating: parseDouble(json['rating'], 0.0),
      reviewCount: parseInt(json['reviewCount'], 0),
      offers: (json['offers'] as List<dynamic>?)
              ?.map((e) => OfferPreview.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      // Handle both 'name' and 'nameEn' for city/area
      cityName: json['city']?['name'] as String? ?? json['city']?['nameEn'] as String?,
      areaName: json['area']?['name'] as String? ?? json['area']?['nameEn'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'cityId': cityId,
      'areaId': areaId,
      'latitude': latitude,
      'longitude': longitude,
      'logoUrl': logoUrl,
      'coverUrl': coverUrl,
      'description': description,
      'phone': phone,
      'website': website,
      'trustScore': trustScore,
      'isVerified': isVerified,
      'isPremium': isPremium,
      'subscriptionPlan': subscriptionPlan,
      'followersCount': followersCount,
      'offersCount': offersCount,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Shop &&
        other.id == id &&
        other.name == name &&
        other.followersCount == followersCount &&
        other.offersCount == offersCount &&
        other.isPremium == isPremium;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      followersCount.hashCode ^
      offersCount.hashCode ^
      isPremium.hashCode;
}

// 🔥 Preview model for offers in the profile grid
class OfferPreview {
  final String id;
  final String title;
  final String offerType;
  final double? originalPrice;
  final double? discountedPrice;
  final int? discountPercentage;
  final DateTime expiryDate;
  final bool isSponsored;
  final String? imageUrl; // First image
  final DateTime createdAt;

  const OfferPreview({
    required this.id,
    required this.title,
    required this.offerType,
    this.originalPrice,
    this.discountedPrice,
    this.discountPercentage,
    required this.expiryDate,
    required this.isSponsored,
    this.imageUrl,
    required this.createdAt,
  });

  factory OfferPreview.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;
    final firstImage =
        images != null && images.isNotEmpty ? images[0] as Map<String, dynamic> : null;

    // Helper to safely parse price values (handles both String and num from backend)
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Helper to safely parse int values (handles both String and num)
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    return OfferPreview(
      id: json['id'] as String,
      title: json['title'] as String,
      offerType: json['offerType'] as String,
      originalPrice: parsePrice(json['originalPrice']),
      discountedPrice: parsePrice(json['discountedPrice']),
      discountPercentage: parseInt(json['discountPercentage']),
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      isSponsored: json['isSponsored'] as bool? ?? false,
      imageUrl: firstImage?['url'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'offerType': offerType,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'discountPercentage': discountPercentage,
      'expiryDate': expiryDate.toIso8601String(),
      'isSponsored': isSponsored,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

