import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:oroud_app/core/theme/app_colors.dart';
import '../../../shared/widgets/discount_badge.dart';
import '../../../shared/widgets/login_prompt_bottom_sheet.dart';
import '../models/offer_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/api/api_provider.dart';
import '../providers/offer_save_provider.dart';
import '../../reviews/widgets/rating_widgets.dart';
import '../../reviews/presentation/review_form_dialog.dart';
import '../../reviews/presentation/reviews_bottom_sheet.dart';
import '../../reviews/providers/reviews_provider.dart';
import '../../auth/providers/auth_provider.dart';

class OfferDetailScreen extends ConsumerStatefulWidget {
  final Offer offer;

  const OfferDetailScreen({super.key, required this.offer});

  @override
  ConsumerState<OfferDetailScreen> createState() =>
      _OfferDetailScreenState();
}

class _OfferDetailScreenState extends ConsumerState<OfferDetailScreen> {
  @override
  void initState() {
    super.initState();
    _trackView();
    // Removed force logout - user should be properly logged out through normal flow
  }

  void _trackView() {
    try {
      final api = ref.read(apiClientProvider);
      api.post('/offers/${widget.offer.id}/analytics', data: {'type': 'view'});
    } catch (e) {
      // Silent fail for analytics
    }
  }

  void _handleSave() async {
    // Check if user is logged in
    final isLoggedIn = ref.read(authProvider);
    if (!isLoggedIn) {
      LoginPromptBottomSheet.show(
        context,
        title: "Save Your Favorites",
        message: "Sign in to save offers and access them anytime",
        icon: Icons.bookmark,
      );
      return;
    }

    try {
      // Use the new savedOffersIdsProvider to toggle save state
      final savedIds = ref.read(savedOffersIdsProvider);
      final wasSaved = savedIds.contains(widget.offer.id);
      
      await ref.read(savedOffersIdsProvider.notifier).toggleSave(widget.offer.id);

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !wasSaved ? "Saved successfully ❤️" : "Removed from saved",
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            backgroundColor: !wasSaved ? AppColors.primary : Colors.grey,
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleClick() async {
    try {
      final api = ref.read(apiClientProvider);
      api.post('/offers/${widget.offer.id}/analytics', data: {'type': 'click'});

      // Open in maps
      final url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${widget.offer.shop.name}",
      );
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Handle error
    }
  }

  void _forceLogout() async {
    try {
      await ref.read(authProvider.notifier).logout();
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: _buildContent(context),
              ),
            ],
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFFB86E45),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: Color(0xFFB86E45)),
            onPressed: () async {
              await Share.share(
                "Check this offer: ${widget.offer.title}",
              );
            },
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: widget.offer.imageUrl,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
            ),
            // Gradient overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            if (widget.offer.discountPercentage != null)
              Positioned(
                top: 60,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${widget.offer.discountPercentage}% OFF",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    final remaining = widget.offer.expiryDate.difference(DateTime.now());

    if (remaining.isNegative) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF757575), Color(0xFF616161)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            SizedBox(width: 6),
            Text(
              "Expired",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFB86E45).withValues(alpha: 0.15),
            const Color(0xFFCC7F54).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB86E45).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer_rounded,
            color: Color(0xFFB86E45),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "Ends in $hours h $minutes m",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFFB86E45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Price Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.offer.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'serif',
                    letterSpacing: 0.3,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 14),
                // Modern pricing display
                if (widget.offer.discountedPrice != null || widget.offer.originalPrice != null)
                  Row(
                    children: [
                      if (widget.offer.discountedPrice != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFB86E45).withValues(alpha: 0.15),
                                const Color(0xFFCC7F54).withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${widget.offer.discountedPrice!.toStringAsFixed(2)} JOD",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFB86E45),
                            ),
                          ),
                        ),
                      if (widget.offer.discountedPrice != null && widget.offer.originalPrice != null)
                        const SizedBox(width: 12),
                      if (widget.offer.originalPrice != null && widget.offer.discountedPrice != null)
                        Text(
                          "${widget.offer.originalPrice!.toStringAsFixed(2)} JOD",
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 14),
                _buildCountdown(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Offer Details Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB86E45).withValues(alpha: 0.08),
                  const Color(0xFFCC7F54).withValues(alpha: 0.12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFB86E45).withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Offer Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        fontFamily: 'serif',
                        color: Color(0xFFB86E45),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  "Limited time offer. Visit the shop before expiry date.",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Shop Info Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.store_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.offer.shop.name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'serif',
                          color: Color(0xFF2C2C2C),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Shop Rating Section
                _buildShopRatingSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Shop rating section with rating display and review button
  Widget _buildShopRatingSection() {
    final shopReviewsAsync = ref.watch(shopReviewsProvider(widget.offer.shop.id));

    return shopReviewsAsync.when(
      data: (reviewsData) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Rating display (tappable to see all reviews)
            InkWell(
              onTap: () => ReviewsBottomSheet.show(context, widget.offer.shop.id),
              child: Row(
                children: [
                  if (reviewsData.totalReviews > 0)
                    RatingBadge(
                      rating: reviewsData.averageRating,
                      reviewCount: reviewsData.totalReviews,
                    )
                  else
                    const Text(
                      'No reviews yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(width: 8),
                  if (reviewsData.totalReviews > 0)
                    Text(
                      'Tap to see reviews',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Modern Gradient Rate This Shop button
            Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB86E45).withValues(alpha: 0.1),
                    const Color(0xFFCC7F54).withValues(alpha: 0.15),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB86E45).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ReviewFormDialog.show(
                      context,
                      shopId: widget.offer.shop.id,
                      shopName: widget.offer.shop.name,
                    ).then((success) {
                      if (success == true) {
                        // Refresh reviews
                        ref.invalidate(shopReviewsProvider(widget.offer.shop.id));
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: Color(0xFFB86E45),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Rate This Shop',
                          style: TextStyle(
                            color: Color(0xFFB86E45),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final savedIds = ref.watch(savedOffersIdsProvider);
    final isSaved = savedIds.contains(widget.offer.id);
    
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFB86E45).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleClick,
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.card_giftcard_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Get This Offer",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSaved ? Colors.red.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleSave,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Icon(
                    isSaved ? Icons.favorite : Icons.favorite_border,
                    color: isSaved ? Colors.red : Colors.grey[600],
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
