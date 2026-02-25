// 🔥 Offer Type Enum
enum OfferType {
  PERCENTAGE,
  FIXED,
  BOGO,
  BUNDLE,
  FLASH,
  LIMITED,
  MYSTERY,
  EXCLUSIVE;

  static OfferType fromString(String type) {
    switch (type.toUpperCase()) {
      case 'PERCENTAGE':
        return OfferType.PERCENTAGE;
      case 'FIXED':
        return OfferType.FIXED;
      case 'BOGO':
        return OfferType.BOGO;
      case 'BUNDLE':
        return OfferType.BUNDLE;
      case 'FLASH':
        return OfferType.FLASH;
      case 'LIMITED':
        return OfferType.LIMITED;
      case 'MYSTERY':
        return OfferType.MYSTERY;
      case 'EXCLUSIVE':
        return OfferType.EXCLUSIVE;
      default:
        return OfferType.PERCENTAGE; // Safe fallback
    }
  }

  String toJsonString() {
    return toString().split('.').last;
  }
}

class Offer {
  final String id;
  final String title;
  final String? description;
  final String category; // 🔥 Mandatory
  final OfferType offerType; // 🔥 Mandatory
  
  // Prices now optional (depends on offer type)
  final double? originalPrice;
  final double? discountedPrice;
  final double? discountPercentage;
  
  final String imageUrl;
  final DateTime expiryDate;
  final bool isPremium;
  final Shop shop;

  // 🔥 New fields for advanced offer types
  final int? maxClaims; // For LIMITED offers
  final int claimedCount; // Track claims
  final DateTime? validFrom; // For FLASH offers
  final DateTime? validUntil; // For FLASH offers
  final String? whatsappNumber; // Direct contact

  Offer({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.offerType,
    this.originalPrice,
    this.discountedPrice,
    this.discountPercentage,
    required this.imageUrl,
    required this.expiryDate,
    required this.isPremium,
    required this.shop,
    this.maxClaims,
    this.claimedCount = 0,
    this.validFrom,
    this.validUntil,
    this.whatsappNumber,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    // 🔥 Safe parsing with null checks
    // Extract category from nested subcategory object
    final category = json['subcategory']?['category']?['name'] ?? 
                     json['category'] ?? 
                     'Other';
    
    // Parse shop first to get isPremium from it
    final shop = Shop.fromJson(json['shop'] ?? {});
    
    // Helper to safely parse price values (handles both String and num from backend)
    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return Offer(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Offer',
      description: json['description'],
      category: category,
      offerType: json['offerType'] != null 
          ? OfferType.fromString(json['offerType'])
          : OfferType.PERCENTAGE, // Safe fallback
      
      // Nullable prices - safely handle both String and num
      originalPrice: parsePrice(json['originalPrice']),
      discountedPrice: parsePrice(json['discountedPrice']),
      discountPercentage: parsePrice(json['discountPercentage']),
      
      imageUrl: json['imageUrl'] ?? '',
      expiryDate: json['expiryDate'] != null 
          ? DateTime.parse(json['expiryDate']) 
          : DateTime.now().add(Duration(days: 7)),
      isPremium: shop.isPremium, // Get from shop
      shop: shop,
      
      // Advanced fields
      maxClaims: json['maxClaims'],
      claimedCount: json['claimedCount'] ?? 0,
      validFrom: json['validFrom'] != null 
          ? DateTime.parse(json['validFrom']) 
          : null,
      validUntil: json['validUntil'] != null 
          ? DateTime.parse(json['validUntil']) 
          : null,
      whatsappNumber: json['whatsappNumber'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'category': category,
      'offerType': offerType.toJsonString(),
      if (originalPrice != null) 'originalPrice': originalPrice,
      if (discountedPrice != null) 'discountedPrice': discountedPrice,
      if (discountPercentage != null) 'discountPercentage': discountPercentage,
      'imageUrl': imageUrl,
      'expiryDate': expiryDate.toIso8601String(),
      'isPremium': isPremium,
      'shop': shop.toJson(),
      if (maxClaims != null) 'maxClaims': maxClaims,
      'claimedCount': claimedCount,
      if (validFrom != null) 'validFrom': validFrom!.toIso8601String(),
      if (validUntil != null) 'validUntil': validUntil!.toIso8601String(),
      if (whatsappNumber != null) 'whatsappNumber': whatsappNumber,
    };
  }

  // 🔥 Helper: Calculate remaining count for LIMITED offers
  int? get remainingClaims {
    if (maxClaims == null) return null;
    return maxClaims! - claimedCount;
  }

  // 🔥 Helper: Check if flash sale is active
  bool get isFlashActive {
    if (offerType != OfferType.FLASH || validFrom == null || validUntil == null) {
      return false;
    }
    final now = DateTime.now();
    return now.isAfter(validFrom!) && now.isBefore(validUntil!);
  }

  // 🔥 Helper: Check if limited offer is sold out
  bool get isSoldOut {
    if (maxClaims == null) return false;
    return claimedCount >= maxClaims!;
  }
}

class Shop {
  final String id;
  final String name;
  final String logoUrl;
  final int trustScore;
  final bool isPremium;
  final Area? area;

  Shop({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.trustScore,
    this.isPremium = false,
    this.area,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Shop',
      logoUrl: json['logoUrl']?.toString() ?? '',
      trustScore: (json['trustScore'] is int) 
          ? json['trustScore'] 
          : (json['trustScore'] is double) 
              ? (json['trustScore'] as double).toInt()
              : int.tryParse(json['trustScore']?.toString() ?? '50') ?? 50,
      isPremium: json['isPremium'] == true,
      area: json['area'] != null ? Area.fromJson(json['area'] as Map<String, dynamic>) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'trustScore': trustScore,
      'isPremium': isPremium,
      if (area != null) 'area': area!.toJson(),
    };
  }
}

class Area {
  final String id;
  final String name;
  final String? zone;

  Area({
    required this.id,
    required this.name,
    this.zone,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      zone: json['zone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (zone != null) 'zone': zone,
    };
  }
}
