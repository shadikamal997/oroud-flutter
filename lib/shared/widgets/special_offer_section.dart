import 'package:flutter/material.dart';
import '../../features/offers/models/offer_model.dart';
import 'horizontal_offer_card.dart';
import 'package:oroud_app/core/theme/app_colors.dart';

/// Widget for displaying special offer sections with horizontal scroll
class SpecialOfferSection extends StatelessWidget {
  final String title;
  final String emoji;
  final List<Offer> offers;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final Color? titleColor;

  const SpecialOfferSection({
    super.key,
    required this.title,
    required this.emoji,
    required this.offers,
    this.isLoading = false,
    this.onRefresh,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show section if no offers and not loading
    if (!isLoading && offers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor ?? Colors.black87,
                    ),
                  ),
                ],
              ),
              if (offers.isNotEmpty && onRefresh != null)
                TextButton(
                  onPressed: onRefresh,
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: isLoading
              ? _buildLoadingState()
              : offers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        return HorizontalOfferCard(offer: offers[index]);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: 180,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'No offers in this section yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
