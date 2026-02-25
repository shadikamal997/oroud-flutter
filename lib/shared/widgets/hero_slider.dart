import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api/api_provider.dart';
import '../../features/ads/models/ad_model.dart';
import '../../features/ads/providers/ads_provider.dart';
import 'package:oroud_app/core/theme/app_colors.dart';

class HeroSlider extends ConsumerStatefulWidget {
  final String cityId;

  const HeroSlider({super.key, required this.cityId});

  @override
  ConsumerState<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends ConsumerState<HeroSlider> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_controller.hasClients) {
        final adsAsync = ref.read(heroAdsProvider(widget.cityId));
        adsAsync.whenData((ads) {
          if (ads.isNotEmpty && mounted) {
            final nextPage = (_currentIndex + 1) % ads.length;
            _controller.animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        });
      }
    });
  }

  void _handleAdTap(Ad ad) async {
    // Track click
    try {
      await ref.read(apiClientProvider).post('/ads/${ad.id}/click');
    } catch (e) {
      // Silently fail - don't disrupt user experience
    }

    // Launch URL
    final url = Uri.parse(ad.redirectUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final adsAsync = ref.watch(heroAdsProvider(widget.cityId));

    return adsAsync.when(
      data: (ads) {
        if (ads.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            SizedBox(
              height: 180,
              child: PageView.builder(
                controller: _controller,
                itemCount: ads.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final ad = ads[index];
                  return GestureDetector(
                    onTap: () => _handleAdTap(ad),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          ad.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                ads.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppColors.primary
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
      loading: () => const SizedBox.shrink(), // Don't show loading for hero ads
      error: (_, _) => const SizedBox.shrink(), // Silently fail
    );
  }
}
