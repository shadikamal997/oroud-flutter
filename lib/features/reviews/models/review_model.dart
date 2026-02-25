class Review {
  final String id;
  final int rating;
  final String? comment;
  final String userId;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReviewUser? user; // For displaying review author info

  Review({
    required this.id,
    required this.rating,
    this.comment,
    required this.userId,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      rating: json['rating'],
      comment: json['comment'],
      userId: json['userId'] ?? json['user']?['id'],
      shopId: json['shopId'] ?? json['shop']?['id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? ReviewUser.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rating': rating,
      'comment': comment,
      'userId': userId,
      'shopId': shopId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (user != null) 'user': user!.toJson(),
    };
  }
}

class ReviewUser {
  final String id;
  final String? email;
  final String? phone;

  ReviewUser({
    required this.id,
    this.email,
    this.phone,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
    };
  }
}

class ShopReviewsResponse {
  final String shopId;
  final String shopName;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final List<Review> reviews;

  ShopReviewsResponse({
    required this.shopId,
    required this.shopName,
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
    required this.reviews,
  });

  factory ShopReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ShopReviewsResponse(
      shopId: json['shopId'],
      shopName: json['shopName'],
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'],
      ratingDistribution: Map<int, int>.from(
        (json['ratingDistribution'] as Map).map(
          (key, value) => MapEntry(int.parse(key.toString()), value as int),
        ),
      ),
      reviews: (json['reviews'] as List)
          .map((review) => Review.fromJson(review))
          .toList(),
    );
  }
}
