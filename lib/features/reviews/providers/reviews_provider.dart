import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/upload_service.dart';
import '../models/review_model.dart';

// Reviews Service
class ReviewsService {
  final ApiClient _apiClient;

  ReviewsService(this._apiClient);

  /// Create or update a review
  Future<Review> upsertReview({
    required String shopId,
    required int rating,
    String? comment,
    List<String>? imageUrls,
  }) async {
    final response = await _apiClient.post(
      '/reviews',
      data: {
        'shopId': shopId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        if (imageUrls != null && imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      },
    );

    return Review.fromJson(response.data);
  }

  /// Get all reviews for a shop
  Future<ShopReviewsResponse> getShopReviews(String shopId) async {
    final response = await _apiClient.get('/reviews/shop/$shopId');
    return ShopReviewsResponse.fromJson(response.data);
  }

  /// Get current user's reviews
  Future<List<Review>> getMyReviews() async {
    final response = await _apiClient.get('/reviews/my-reviews');
    return (response.data as List)
        .map((review) => Review.fromJson(review))
        .toList();
  }

  /// Delete a review
  Future<void> deleteReview(String reviewId) async {
    await _apiClient.delete('/reviews/$reviewId');
  }
}

// Provider for ReviewsService
final reviewsServiceProvider = Provider<ReviewsService>((ref) {
  return ReviewsService(ApiClient());
});

// Provider for UploadService
final uploadServiceProvider = Provider<UploadService>((ref) {
  return UploadService(ApiClient());
});

// Provider for shop reviews (takes shopId as parameter)
final shopReviewsProvider =
    FutureProvider.family<ShopReviewsResponse, String>((ref, shopId) async {
  final service = ref.read(reviewsServiceProvider);
  return service.getShopReviews(shopId);
});

// Provider for user's own reviews
final myReviewsProvider = FutureProvider<List<Review>>((ref) async {
  final service = ref.read(reviewsServiceProvider);
  return service.getMyReviews();
});
