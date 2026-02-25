import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/offers/models/offer_model.dart';
import '../../core/api/api_provider.dart';
import '../../features/offers/providers/offer_save_provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'discount_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

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
      clipBehavior: Clip.antiAlias,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                // Background Image
                // 🔒 FIX #15: Add memory optimization to prevent memory spikes
                CachedNetworkImage(
                  imageUrl: offer.imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  memCacheWidth: 600, // Limit cached image width to 600px
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
                
                // 🎨 Gradient Overlay for readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                
                // 🏷 Offer Type Badge (Top Left)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildOfferTypeBadge(offer.offerType),
                ),
                
                // ⏳ Flash Countdown (Top Right)
                if (offer.offerType == OfferType.FLASH && offer.validUntil != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildCountdown(offer.validUntil!),
                  )
                else if (offer.discountPercentage != null)
                  // Show discount badge if not flash offer
                  Positioned(
                    top: 12,
                    right: 12,
                    child: DiscountBadge(
                      percentage: offer.discountPercentage,
                    ),
                  ),
                
                // 🎯 Limited Counter (Bottom Right)
                // 🔥 Modern Gradient Limited Counter
                if (offer.offerType == OfferType.LIMITED && offer.maxClaims != null)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 15),
                            const SizedBox(width: 5),
                            Text(
                              "${offer.remainingClaims ?? 0} left",
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                // ❤️ Save Button (Bottom Left)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Consumer(
                    builder: (context, ref, child) {
                      final isLoggedIn = ref.watch(authProvider);
                      if (!isLoggedIn) return const SizedBox.shrink();
                      
                      final savedIds = ref.watch(savedOffersIdsProvider);
                      final isSaved = savedIds.contains(offer.id);
                      
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.red : Colors.grey[600],
                            size: 20,
                          ),
                          onPressed: () async {
                            try {
                              await ref.read(savedOffersIdsProvider.notifier).toggleSave(offer.id);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isSaved ? 'Removed from favorites' : 'Added to favorites',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: const Color(0xFFB86E45),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      offer.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                    
                    // 💬 Modern Gradient WhatsApp Quick Button
                    if (offer.whatsappNumber != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          onTap: () {
                            launchUrl(
                              Uri.parse("https://wa.me/${offer.whatsappNumber}"),
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF25D366).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  "Contact Shop",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
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

  // 🏷 Modern Gradient Offer Type Badge Builder
  Widget _buildOfferTypeBadge(OfferType type) {
    List<Color> gradientColors;
    IconData icon;

    switch (type) {
      case OfferType.FLASH:
        gradientColors = [const Color(0xFFFF6B6B), const Color(0xFFEE5A6F)];
        icon = Icons.flash_on;
        break;
      case OfferType.LIMITED:
        gradientColors = [const Color(0xFFFF9800), const Color(0xFFFF5722)];
        icon = Icons.local_fire_department;
        break;
      case OfferType.BOGO:
        gradientColors = [const Color(0xFF9C27B0), const Color(0xFF673AB7)];
        icon = Icons.redeem;
        break;
      case OfferType.MYSTERY:
        gradientColors = [const Color(0xFF424242), const Color(0xFF212121)];
        icon = Icons.help_outline;
        break;
      case OfferType.EXCLUSIVE:
        gradientColors = [const Color(0xFFFFB300), const Color(0xFFFFA000)];
        icon = Icons.star;
        break;
      case OfferType.BUNDLE:
        gradientColors = [const Color(0xFF66BB6A), const Color(0xFF43A047)];
        icon = Icons.card_giftcard;
        break;
      case OfferType.FIXED:
        gradientColors = [const Color(0xFF42A5F5), const Color(0xFF1E88E5)];
        icon = Icons.local_offer;
        break;
      case OfferType.PERCENTAGE:
        gradientColors = [const Color(0xFFB86E45), const Color(0xFFCC7F54)];
        icon = Icons.percent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            type.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ⏳ Modern Gradient Flash Countdown Builder
  Widget _buildCountdown(DateTime end) {
    final remaining = end.difference(DateTime.now());

    if (remaining.isNegative) {
      return const SizedBox.shrink();
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_rounded, color: Colors.white, size: 15),
          const SizedBox(width: 5),
          Text(
            "${hours}h ${minutes}m",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
