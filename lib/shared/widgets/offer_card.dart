import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/offers/models/offer_model.dart';
import '../../core/api/api_provider.dart';
import 'discount_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OfferCard extends ConsumerWidget {
  final Offer offer;

  const OfferCard({super.key, required this.offer});

  void _trackClick(WidgetRef ref) {
    try {
      final api = ref.read(apiClientProvider);
      api.post('/offers/${offer.id}/analytics', data: {'type': 'click'});
    } catch (e) {
      // Silent fail for analytics
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () {
          _trackClick(ref);
          context.push(
            '/offer/${offer.id}',
            extra: offer,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: offer.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Icon(Icons.error),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: DiscountBadge(
                    percentage: offer.discountPercentage,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                offer.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
