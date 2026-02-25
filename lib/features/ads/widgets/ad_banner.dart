import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../shared/models/ad_model.dart';
import '../providers/ad_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AdBanner extends ConsumerWidget {
  final AdPlacement placement;
  final String? cityId;
  final double height;

  const AdBanner({
    super.key,
    required this.placement,
    this.cityId,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adStream = placement == AdPlacement.HERO
        ? (cityId != null
            ? ref.watch(cityHeroAdsProvider(cityId))
            : ref.watch(heroAdsProvider))
        : (cityId != null
            ? ref.watch(cityFeedAdsProvider(cityId))
            : ref.watch(feedAdsProvider));

    return adStream.when(
      data: (ads) {
        if (ads.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show first active ad
        final ad = ads.first;
        return Container(
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: GestureDetector(
              onTap: () => _onAdTap(ref, ad),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Ad Image
                  CachedNetworkImage(
                    imageUrl: ad.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  ),

                  // Gradient overlay for text
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),

                  // Ad title
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      ad.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Ad indicator
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Ad',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  void _onAdTap(WidgetRef ref, AdModel ad) async {
    // Track the click
    await ref.read(adActionsProvider).trackAdClick(ad.id);

    // Open the redirect URL
    if (ad.redirectUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(ad.redirectUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        print('Failed to launch URL: $e');
      }
    }
  }
}

// Multiple ads carousel widget
class AdCarousel extends ConsumerWidget {
  final AdPlacement placement;
  final String? cityId;
  final double height;

  const AdCarousel({
    super.key,
    required this.placement,
    this.cityId,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adStream = placement == AdPlacement.HERO
        ? (cityId != null
            ? ref.watch(cityHeroAdsProvider(cityId))
            : ref.watch(heroAdsProvider))
        : (cityId != null
            ? ref.watch(cityFeedAdsProvider(cityId))
            : ref.watch(feedAdsProvider));

    return adStream.when(
      data: (ads) {
        if (ads.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: height,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: PageView.builder(
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () => _onAdTap(ref, ad),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: ad.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Text(
                            ad.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${index + 1}/${ads.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => Container(
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  void _onAdTap(WidgetRef ref, AdModel ad) async {
    await ref.read(adActionsProvider).trackAdClick(ad.id);

    if (ad.redirectUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(ad.redirectUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        print('Failed to launch URL: $e');
      }
    }
  }
}