import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reviews_provider.dart';
import '../models/review_model.dart';
import '../widgets/rating_widgets.dart';
import 'package:intl/intl.dart';

/// Reviews Bottom Sheet - Shows all reviews for a shop
class ReviewsBottomSheet extends ConsumerWidget {
  final String shopId;

  const ReviewsBottomSheet({
    super.key,
    required this.shopId,
  });

  /// Show the bottom sheet
  static void show(BuildContext context, String shopId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReviewsBottomSheet(shopId: shopId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(shopReviewsProvider(shopId));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: reviewsAsync.when(
                  data: (reviewsData) => _buildReviewsList(
                    context,
                    scrollController,
                    reviewsData,
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) => Center(
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewsList(
    BuildContext context,
    ScrollController scrollController,
    ShopReviewsResponse reviewsData,
  ) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // Header with shop name and stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reviewsData.shopName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Overall rating
                Row(
                  children: [
                    Text(
                      reviewsData.averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StarRatingDisplay(
                            rating: reviewsData.averageRating,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${reviewsData.totalReviews} reviews',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Rating distribution
                _buildRatingDistribution(reviewsData),
                const Divider(height: 32),
              ],
            ),
          ),
        ),

        // Reviews list
        if (reviewsData.reviews.isEmpty)
          const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No reviews yet.\nBe the first to review!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final review = reviewsData.reviews[index];
                return _ReviewCard(review: review);
              },
              childCount: reviewsData.reviews.length,
            ),
          ),
      ],
    );
  }

  Widget _buildRatingDistribution(ShopReviewsResponse reviewsData) {
    return Column(
      children: [5, 4, 3, 2, 1].map((stars) {
        final count = reviewsData.ratingDistribution[stars] ?? 0;
        final percentage = reviewsData.totalReviews > 0
            ? (count / reviewsData.totalReviews)
            : 0.0;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text('$stars'),
              const SizedBox(width: 4),
              const Icon(Icons.star, size: 14, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Colors.amber),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 30,
                child: Text(
                  '$count',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and rating
          Row(
            children: [ Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user?.email ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, yyyy').format(review.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              StarRatingDisplay(
                rating: review.rating.toDouble(),
                size: 16,
              ),
            ],
          ),

          // Comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
