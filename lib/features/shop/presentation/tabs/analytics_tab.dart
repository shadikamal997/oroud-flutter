import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/shop_model.dart';
import '../../providers/current_shop_provider.dart';

class AnalyticsTab extends ConsumerWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shopAsync = ref.watch(currentShopProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      body: SafeArea(
        child: shopAsync.when(
          loading: () => Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Unable to load analytics",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => ref.refresh(currentShopProvider),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Center(
                          child: Text(
                            "Retry",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          data: (shop) {
            if (shop == null) {
              return const Center(
                child: Text(
                  "Loading analytics...",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return _buildAnalyticsContent(context, shop);
          },
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, Shop shop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            "Shop Analytics",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2A2A2A),
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Track your performance and growth",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // SECTION 1 — Overview Stats (List Style)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildStatRow(
                  icon: Icons.local_offer,
                  label: "Active Offers",
                  value: shop.offersCount.toString(),
                  color: const Color(0xFFB86E45),
                  isFirst: true,
                ),
                _buildDivider(),
                _buildStatRow(
                  icon: Icons.people,
                  label: "Followers",
                  value: shop.followersCount.toString(),
                  color: Colors.blue,
                ),
                _buildDivider(),
                _buildStatRow(
                  icon: Icons.star,
                  label: "Rating",
                  value: shop.rating.toStringAsFixed(1),
                  color: Colors.amber,
                ),
                _buildDivider(),
                _buildStatRow(
                  icon: Icons.chat_bubble,
                  label: "Reviews",
                  value: shop.reviewCount.toString(),
                  color: Colors.green,
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // SECTION 2 — Performance Insight
          _buildInsightCard(shop),

          const SizedBox(height: 16),

          // SECTION 3 — Placeholder for Future Charts
          _buildChartsPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        isFirst ? 16 : 12,
        16,
        isLast ? 16 : 12,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey[200],
      ),
    );
  }

  Widget _buildInsightCard(Shop shop) {
    String insightMessage;
    IconData insightIcon;
    Color insightColor;

    // Dynamic insight logic
    if (shop.offersCount == 0) {
      insightMessage = "Create your first offer to start getting visibility and attract customers.";
      insightIcon = Icons.lightbulb_outline;
      insightColor = Colors.orange;
    } else if (shop.followersCount < 10) {
      insightMessage = "Grow your followers by posting flash offers and engaging with customers.";
      insightIcon = Icons.trending_up;
      insightColor = Colors.blue;
    } else if (shop.rating >= 4.0) {
      insightMessage = "Great job! Your shop has strong customer trust. Keep up the excellent work.";
      insightIcon = Icons.celebration;
      insightColor = Colors.green;
    } else if (shop.rating < 3.0 && shop.reviewCount > 0) {
      insightMessage = "Focus on improving customer satisfaction to boost your rating.";
      insightIcon = Icons.warning_amber_rounded;
      insightColor = Colors.orange;
    } else {
      insightMessage = "You're doing well! Continue creating offers to grow your shop.";
      insightIcon = Icons.thumb_up;
      insightColor = const Color(0xFFB86E45);
    }

    return Container(
      padding: const EdgeInsets.all(16), // Reduced from 20 to 16
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10), // Reduced from 12 to 10
            decoration: BoxDecoration(
              color: insightColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              insightIcon,
              color: insightColor,
              size: 24, // Reduced from 28 to 24
            ),
          ),
          const SizedBox(width: 12), // Reduced from 16 to 12
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Performance Insight",
                  style: TextStyle(
                    fontSize: 13, // Reduced from 14 to 13
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4), // Reduced from 6 to 4
                Text(
                  insightMessage,
                  style: TextStyle(
                    fontSize: 12, // Reduced from 13 to 12
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20), // Reduced from 24 to 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart,
                color: Color(0xFFB86E45),
                size: 24, // Reduced from 28 to 24
              ),
              const SizedBox(width: 12),
              const Text(
                "Performance Trends",
                style: TextStyle(
                  fontSize: 16, // Reduced from 18 to 16
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced from 20 to 16
          Container(
            height: 100, // Reduced from 120 to 100
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[200]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insights,
                    size: 40, // Reduced from 48 to 40
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8), // Reduced from 12 to 8
                  Text(
                    "Detailed charts coming soon",
                    style: TextStyle(
                      fontSize: 13, // Reduced from 14 to 13
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 2), // Reduced from 4 to 2
                  Text(
                    "Track views, clicks, and conversions",
                    style: TextStyle(
                      fontSize: 11, // Reduced from 12 to 11
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
