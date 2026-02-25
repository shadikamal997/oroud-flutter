/// Review model for shop reviews
/// 
/// Represents a customer review for a shop
/// Includes rating (1-5 stars) and optional comment
class Review {
  final String id;
  final int rating;
  final String? comment;
  final String userId;
  final String shopId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // User details (from relation)
  final String? userName;
  final String? userAvatarUrl;

  Review({
    required this.id,
    required this.rating,
    this.comment,
    required this.userId,
    required this.shopId,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatarUrl,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      userId: json['userId'] as String,
      shopId: json['shopId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userName: json['user']?['name'] as String?,
      userAvatarUrl: json['user']?['avatarUrl'] as String?,
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
    };
  }

  /// Calculate average rating from list of reviews
  static double calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<int>(0, (sum, review) => sum + review.rating);
    return sum / reviews.length;
  }

  /// Get rating distribution (count per star level)
  static Map<int, int> getRatingDistribution(List<Review> reviews) {
    final distribution = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final review in reviews) {
      distribution[review.rating] = (distribution[review.rating] ?? 0) + 1;
    }
    return distribution;
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
