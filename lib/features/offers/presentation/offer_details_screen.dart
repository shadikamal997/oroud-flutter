import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/offer_details_provider.dart';
import '../models/offer_model.dart';
import '../../auth/providers/auth_provider.dart';

/// Offer Details Screen
/// 
/// Shows full offer details with:
/// - Image gallery (carousel)
/// - Discount badge
/// - Original/discounted prices
/// - Offer type badge
/// - Countdown timer (for FLASH offers)
/// - Description and terms
/// - Claim button
/// - WhatsApp button
class OfferDetailsScreen extends ConsumerStatefulWidget {
  final String offerId;

  const OfferDetailsScreen({
    super.key,
    required this.offerId,
  });

  @override
  ConsumerState<OfferDetailsScreen> createState() => _OfferDetailsScreenState();
}

class _OfferDetailsScreenState extends ConsumerState<OfferDetailsScreen> {
  Timer? _countdownTimer;
  Duration? _remainingTime;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown(DateTime validUntil) {
    _countdownTimer?.cancel();
    
    void updateTimer() {
      final now = DateTime.now();
      if (now.isBefore(validUntil)) {
        setState(() {
          _remainingTime = validUntil.difference(now);
        });
      } else {
        setState(() {
          _remainingTime = Duration.zero;
        });
        _countdownTimer?.cancel();
      }
    }

    updateTimer();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => updateTimer());
  }

  @override
  Widget build(BuildContext context) {
    final offerAsync = ref.watch(offerDetailsProvider(widget.offerId));

    return offerAsync.when(
      data: (offer) {
        // Start countdown if FLASH offer
        if (offer.offerType == OfferType.FLASH && offer.validUntil != null) {
          if (_countdownTimer == null || !_countdownTimer!.isActive) {
            _startCountdown(offer.validUntil!);
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Offer Details'),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareOffer(context, offer),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Carousel
                _ImageCarousel(offer: offer),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Discount Badge + Offer Type
                      Row(
                        children: [
                          if (offer.discountPercentage != null)
                            _DiscountBadge(percentage: offer.discountPercentage!),
                          const SizedBox(width: 8),
                          _OfferTypeBadge(type: offer.offerType),
                          const Spacer(),
                          if (offer.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: Colors.amber[800],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'PRO',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        offer.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Shop Info (shop profile navigation removed)
                      Row(
                        children: [
                          CircleAvatar(
                              radius: 16,
                              backgroundImage: offer.shop.logoUrl.isNotEmpty
                                  ? CachedNetworkImageProvider(offer.shop.logoUrl)
                                  : null,
                              backgroundColor: Colors.grey[300],
                              child: offer.shop.logoUrl.isEmpty
                                  ? const Icon(Icons.store, size: 16)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              offer.shop.name,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Prices Section
                      _PricesSection(offer: offer),
                      const SizedBox(height: 16),

                      // Flash Countdown
                      if (offer.offerType == OfferType.FLASH &&
                          offer.validUntil != null &&
                          _remainingTime != null &&
                          _remainingTime! > Duration.zero)
                        _FlashCountdown(remainingTime: _remainingTime!),

                      // Limited Stock Counter
                      if (offer.offerType == OfferType.LIMITED && offer.maxClaims != null)
                        _LimitedStockCounter(
                          claimed: offer.claimedCount,
                          total: offer.maxClaims!,
                        ),

                      const SizedBox(height: 16),

                      // Description
                      if (offer.description != null && offer.description!.isNotEmpty) ...[
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          offer.description!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Category
                      Row(
                        children: [
                          Icon(Icons.category, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            offer.category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Expiry Date
                      Row(
                        children: [
                          Icon(Icons.event, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Valid until ${_formatDate(offer.expiryDate)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Action Buttons
                      _ActionButtons(offer: offer, offerId: widget.offerId),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Offer Details'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Offer Not Found'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Offer not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This offer may have expired or been removed',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _shareOffer(BuildContext context, Offer offer) {
    final String shareText = '''
🎉 ${offer.title}

💰 ${offer.discountPercentage != null ? '${offer.discountPercentage}% OFF' : 'Special Offer'}
📍 ${offer.shop.name}
⏰ Valid until ${_formatDate(offer.expiryDate)}

Check it out on Oroud App!
''';
    
    Share.share(
      shareText,
      subject: offer.title,
    );
  }
}

/// Modern Image Carousel Widget with Gradient Overlay
class _ImageCarousel extends StatelessWidget {
  final Offer offer;

  const _ImageCarousel({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CachedNetworkImage(
            imageUrl: offer.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[200]!,
                    Colors.grey[300]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey[200]!,
                    Colors.grey[300]!,
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.local_offer_rounded,
                  size: 70,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
        ),
        // Gradient overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Modern Gradient Discount Badge
class _DiscountBadge extends StatelessWidget {
  final double percentage;

  const _DiscountBadge({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5A6F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            '${percentage.toInt()}% OFF',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modern Gradient Offer Type Badge
class _OfferTypeBadge extends StatelessWidget {
  final OfferType type;

  const _OfferTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final config = _getBadgeConfig(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            config.color.withValues(alpha: 0.15),
            config.color.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: config.color.withValues(alpha: 0.4),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: config.color.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  _BadgeConfig _getBadgeConfig(OfferType type) {
    switch (type) {
      case OfferType.FLASH:
        return _BadgeConfig('⚡ FLASH SALE', Colors.orange);
      case OfferType.LIMITED:
        return _BadgeConfig('🔥 LIMITED', Colors.red);
      case OfferType.BOGO:
        return _BadgeConfig('🎁 BOGO', Colors.green);
      case OfferType.BUNDLE:
        return _BadgeConfig('📦 BUNDLE', Colors.blue);
      case OfferType.MYSTERY:
        return _BadgeConfig('🎲 MYSTERY', Colors.purple);
      case OfferType.EXCLUSIVE:
        return _BadgeConfig('⭐ EXCLUSIVE', Colors.amber);
      case OfferType.PERCENTAGE:
        return _BadgeConfig('DISCOUNT', AppColors.primary);
      case OfferType.FIXED:
        return _BadgeConfig('FIXED PRICE', AppColors.primary);
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color color;
  _BadgeConfig(this.label, this.color);
}

/// Prices Section
class _PricesSection extends StatelessWidget {
  final Offer offer;

  const _PricesSection({required this.offer});

  @override
  Widget build(BuildContext context) {
    if (offer.originalPrice == null && offer.discountedPrice == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Original Price (strikethrough)
        if (offer.originalPrice != null) ...[
          Text(
            'JOD ${offer.originalPrice!.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: 4),
        ],

        // Discounted Price (big bold)
        if (offer.discountedPrice != null)
          Text(
            'JOD ${offer.discountedPrice!.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
      ],
    );
  }
}

/// Flash Countdown Timer
class _FlashCountdown extends StatelessWidget {
  final Duration remainingTime;

  const _FlashCountdown({required this.remainingTime});

  @override
  Widget build(BuildContext context) {
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes.remainder(60);
    final seconds = remainingTime.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Text(
            'Ends in: ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

/// Limited Stock Counter
class _LimitedStockCounter extends StatelessWidget {
  final int claimed;
  final int total;

  const _LimitedStockCounter({
    required this.claimed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = total - claimed;
    final percentage = (claimed / total * 100).clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Only $remaining left!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[900],
                ),
              ),
              Text(
                '$claimed / $total claimed',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red[600]!),
            ),
          ),
        ],
      ),
    );
  }
}

/// Action Buttons (Claim + WhatsApp)
class _ActionButtons extends ConsumerWidget {
  final Offer offer;
  final String offerId;

  const _ActionButtons({
    required this.offer,
    required this.offerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authProvider);
    
    return Column(
      children: [
        // Modern Gradient Claim Button
        Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: offer.isSoldOut
                ? const LinearGradient(
                    colors: [Color(0xFF999999), Color(0xFFBBBBBB)],
                  )
                : const LinearGradient(
                    colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: offer.isSoldOut
                    ? Colors.grey.withValues(alpha: 0.2)
                    : const Color(0xFFB86E45).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: offer.isSoldOut
                  ? null
                  : () async {
                      // Check if user is logged in before claiming
                      if (!isLoggedIn) {
                        if (context.mounted) {
                          final shouldLogin = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: const Text('Login Required'),
                              content: const Text('Please sign in to claim this offer.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => Navigator.pop(context, true),
                                      borderRadius: BorderRadius.circular(12),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        child: Text(
                                          'Sign In',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          
                          if (shouldLogin == true && context.mounted) {
                            context.push('/welcome');
                          }
                        }
                        return;
                      }
                      
                      // User is logged in, proceed with claim
                      try {
                        await ref.read(claimOfferProvider(offerId))();
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Offer claimed successfully! 🎉'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to claim: $error'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      offer.isSoldOut ? Icons.block : Icons.card_giftcard_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      offer.isSoldOut ? 'SOLD OUT' : 'CLAIM OFFER',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Modern Gradient WhatsApp Button
        if (offer.whatsappNumber != null && offer.whatsappNumber!.isNotEmpty)
          Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF25D366).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openWhatsApp(context, offer.whatsappNumber!),
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Contact on WhatsApp',
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
      ],
    );
  }

  Future<void> _openWhatsApp(BuildContext context, String phoneNumber) async {
    final url = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
