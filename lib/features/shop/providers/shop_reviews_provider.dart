import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../models/review_model.dart';

/// Shop reviews provider - Fetches reviews for a specific shop
/// 
/// Returns list of reviews sorted by most recent first
final shopReviewsProvider =
    FutureProvider.autoDispose.family<List<Review>, String>((ref, shopId) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get('/reviews', query: {'shopId': shopId});
  
  final reviews = (response.data as List)
      .map((json) => Review.fromJson(json as Map<String, dynamic>))
      .toList();
  
  // Sort by most recent first
  reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  
  return reviews;
});

/// Check if current user has reviewed a shop
/// 
/// Returns the user's review if it exists, null otherwise
final userShopReviewProvider =
    FutureProvider.autoDispose.family<Review?, String>((ref, shopId) async {
  try {
    final api = ref.read(apiClientProvider);
    final response = await api.get('/reviews/my-review', query: {'shopId': shopId});
    
    if (response.data != null) {
      return Review.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  } catch (e) {
    // No review found or not authenticated
    return null;
  }
});

/// Average rating for a shop
/// 
/// Calculated from all reviews
final shopAverageRatingProvider =
    FutureProvider.autoDispose.family<double, String>((ref, shopId) async {
  final reviews = await ref.watch(shopReviewsProvider(shopId).future);
  return Review.calculateAverageRating(reviews);
});
