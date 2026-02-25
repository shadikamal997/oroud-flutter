import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/analytics_provider.dart';
import '../models/shop_analytics_model.dart';
import 'widgets/stat_card.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/analytics_line_chart.dart';
import 'widgets/analytics_bar_chart.dart';
import 'widgets/analytics_pie_chart.dart';
import 'package:oroud_app/core/theme/app_colors.dart';
import '../../../core/utils/helpers.dart';

enum DateRange { week, month, quarter }

class ShopAnalyticsScreen extends ConsumerStatefulWidget {
  const ShopAnalyticsScreen({super.key});

  @override
  ConsumerState<ShopAnalyticsScreen> createState() => _ShopAnalyticsScreenState();
}

class _ShopAnalyticsScreenState extends ConsumerState<ShopAnalyticsScreen> {
  DateRange _selectedRange = DateRange.week;

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(shopAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Shop Analytics'),
        backgroundColor: const Color(0xFFB86E45),
        actions: [
          // Date Range Selector
          PopupMenuButton<DateRange>(
            icon: const Icon(Icons.date_range),
            onSelected: (range) {
              setState(() => _selectedRange = range);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DateRange.week,
                child: Text('Last 7 Days'),
              ),
              const PopupMenuItem(
                value: DateRange.month,
                child: Text('Last 30 Days'),
              ),
              const PopupMenuItem(
                value: DateRange.quarter,
                child: Text('Last 90 Days'),
              ),
            ],
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (analytics) => _buildAnalyticsContent(context, analytics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading analytics: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(shopAnalyticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, ShopAnalytics analytics) {
    return RefreshIndicator(
      onRefresh: () async {
        // Refresh analytics
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Performance Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Stats Grid (2x2 layout to prevent overflow)
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.visibility,
                    label: 'Views',
                    value: Helpers.formatCount(analytics.totalViews),
                    color: Colors.blue,
                    subtitle: '30 days',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.favorite,
                    label: 'Saves',
                    value: Helpers.formatCount(analytics.totalSaves),
                    color: Colors.red,
                    subtitle: '30 days',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Second row of stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.touch_app,
                    label: 'Clicks',
                    value: Helpers.formatCount(analytics.totalClicks),
                    color: Colors.green,
                    subtitle: '30 days',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.rocket_launch,
                    label: 'Boosted',
                    value: '${analytics.boostedOffersCount}',
                    color: AppColors.primary,
                    subtitle: 'Premium',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Third row with remaining stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle,
                    label: 'Active',
                    value: '${analytics.activeOffersCount}/${analytics.totalOffersCount}',
                    color: Colors.teal,
                    subtitle: 'Total',
                  ),
                ),
                const SizedBox(width: 8),
                // Placeholder to maintain grid alignment
                Expanded(child: SizedBox()),
              ],
            ),

            const SizedBox(height: 16),

            // Date Range Chip
            Chip(
              label: Text(_getRangeLabel()),
              avatar: const Icon(Icons.calendar_today, size: 16),
            ),
            const SizedBox(height: 16),

            // Line Chart - Views Over Time
            AnalyticsLineChart(
              spots: _generateViewsData(analytics),
              title: 'Views Over Time',
              lineColor: Colors.blue,
              bottomTitles: _getBottomLabels(),
              maxY: _calculateMaxY(analytics.totalViews),
            ),

            const SizedBox(height: 16),

            // Bar Chart - Top Offers Performance
            if (analytics.topOffer != null) ...[
              AnalyticsBarChart(
                data: _generateTopOffersData(analytics),
                title: 'Top Offers Performance',
                barColor: AppColors.primary,
                maxY: _calculateMaxY(analytics.topOffer!.views),
              ),
              const SizedBox(height: 16),
            ],

            // Pie Chart - Offer Type Distribution
            AnalyticsPieChart(
              data: _generateOfferTypeData(analytics),
              title: 'Offer Type Distribution',
            ),

            const SizedBox(height: 16),

            // Top Performing Offer
            if (analytics.topOffer != null) ...[
              const Text(
                '🏆 Top Performing Offer',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildTopOfferCard(context, analytics.topOffer!),
            ] else ...[
              EmptyStateWidget(
                icon: Icons.emoji_events,
                title: 'No top offer yet',
                subtitle: 'Create offers and get engagement to see your top performer here',
                color: Colors.amber,
              ),
            ],

            const SizedBox(height: 24),

            // Call to Action
            if (analytics.boostedOffersCount == 0 &&
                analytics.activeOffersCount > 0) ...[
              _buildBoostCTA(context),
            ],
          ],
        ),
      ),
    );
  }

  // New helper methods for charts
  String _getRangeLabel() {
    switch (_selectedRange) {
      case DateRange.week:
        return 'Last 7 Days';
      case DateRange.month:
        return 'Last 30 Days';
      case DateRange.quarter:
        return 'Last 90 Days';
    }
  }

  int _getDaysCount() {
    switch (_selectedRange) {
      case DateRange.week:
        return 7;
      case DateRange.month:
        return 30;
      case DateRange.quarter:
        return 90;
    }
  }

  List<String> _getBottomLabels() {
    switch (_selectedRange) {
      case DateRange.week:
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case DateRange.month:
        return ['W1', 'W2', 'W3', 'W4'];
      case DateRange.quarter:
        return ['M1', 'M2', 'M3'];
    }
  }

  List<FlSpot> _generateViewsData(ShopAnalytics analytics) {
    final days = _getDaysCount();
    final baseValue = analytics.totalViews / days;
    
    return List.generate(
      _getBottomLabels().length,
      (index) {
        final variance = (index % 3) * 0.2 - 0.1;
        final value = baseValue * (1 + variance) * (index + 1) / _getBottomLabels().length;
        return FlSpot(index.toDouble(), value.clamp(0, double.infinity));
      },
    );
  }

  List<BarDataPoint> _generateTopOffersData(ShopAnalytics analytics) {
    if (analytics.topOffer == null) return [];
    
    // Generate mock data for top 5 offers
    final topOffer = analytics.topOffer!;
    return [
      BarDataPoint(label: 'Top\nOffer', value: topOffer.views.toDouble()),
      BarDataPoint(label: 'Offer\n#2', value: (topOffer.views * 0.8).toDouble()),
      BarDataPoint(label: 'Offer\n#3', value: (topOffer.views * 0.6).toDouble()),
      BarDataPoint(label: 'Offer\n#4', value: (topOffer.views * 0.4).toDouble()),
      BarDataPoint(label: 'Offer\n#5', value: (topOffer.views * 0.3).toDouble()),
    ];
  }

  List<PieDataPoint> _generateOfferTypeData(ShopAnalytics analytics) {
    // Mock data - in real app, this would come from analytics
    final total = analytics.totalOffersCount.toDouble();
    if (total == 0) return [];

    return [
      PieDataPoint(
        label: 'Percentage',
        value: total * 0.4,
        color: Colors.blue,
        percentage: 40,
      ),
      PieDataPoint(
        label: 'Fixed Price',
        value: total * 0.3,
        color: Colors.green,
        percentage: 30,
      ),
      PieDataPoint(
        label: 'BOGO',
        value: total * 0.2,
        color: Colors.orange,
        percentage: 20,
      ),
      PieDataPoint(
        label: 'Other',
        value: total * 0.1,
        color: Colors.purple,
        percentage: 10,
      ),
    ];
  }

  double _calculateMaxY(int value) {
    if (value == 0) return 100;
    final max = value * 1.2;
    return ((max / 10).ceil() * 10).toDouble();
  }

  Widget _buildTopOfferCard(BuildContext context, TopOffer offer) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Offer Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                offer.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 40),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Offer Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildMiniStat(Icons.visibility, offer.views),
                      const SizedBox(width: 12),
                      _buildMiniStat(Icons.favorite, offer.saves),
                      const SizedBox(width: 12),
                      _buildMiniStat(Icons.touch_app, offer.clicks),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${offer.discountPercentage.toStringAsFixed(0)}% OFF',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          Helpers.formatCount(value),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[800],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildBoostCTA(BuildContext context) {
    return Card(
      color: AppColors.warning.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.rocket_launch, color: AppColors.warning, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get More Views!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Boost your offers to reach more customers',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to boost offers
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Boost Now'),
            ),
          ],
        ),
      ),
    );
  }
}
