/// Model for user's own reviews (with shop details)
class UserReview {
  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReviewShop shop;

  UserReview({
    required this.id,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.shop,
  });

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      shop: ReviewShop.fromJson(json['shop']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'shop': shop.toJson(),
    };
  }
}

/// Shop details included in user review
class ReviewShop {
  final String id;
  final String name;
  final String? logoUrl;
  final String location;

  ReviewShop({
    required this.id,
    required this.name,
    this.logoUrl,
    required this.location,
  });

  factory ReviewShop.fromJson(Map<String, dynamic> json) {
    return ReviewShop(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logoUrl'],
      location: json['location'] ?? 'Unknown Location',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (logoUrl != null) 'logoUrl': logoUrl,
      'location': location,
    };
  }
}
