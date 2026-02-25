import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shop_dashboard_tab_provider.dart';
import 'tabs/profile_tab.dart';
import 'tabs/my_offers_tab.dart';
import 'tabs/create_offer_tab.dart';
import 'tabs/analytics_tab.dart';
import 'tabs/notifications_tab.dart';

class ShopDashboardScreen extends ConsumerWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(shopDashboardTabProvider);
    
    final tabs = const [
      ProfileTab(),
      MyOffersTab(),
      CreateOfferTab(),
      AnalyticsTab(),
      NotificationsTab(),
    ];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      body: IndexedStack(
        index: currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.store,
                  label: "Profile",
                  index: 0,
                  ref: ref,
                ),
                _buildNavItem(
                  icon: Icons.local_offer,
                  label: "My Offers",
                  index: 1,
                  ref: ref,
                ),
                _buildNavItem(
                  icon: Icons.add_circle,
                  label: "Create",
                  index: 2,
                  ref: ref,
                ),
                _buildNavItem(
                  icon: Icons.bar_chart,
                  label: "Analytics",
                  index: 3,
                  ref: ref,
                ),
                _buildNavItem(
                  icon: Icons.notifications,
                  label: "Notify",
                  index: 4,
                  ref: ref,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required WidgetRef ref,
  }) {
    final currentIndex = ref.watch(shopDashboardTabProvider);
    final isSelected = currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(shopDashboardTabProvider.notifier).setTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFFB86E45) : Colors.grey[400],
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFB86E45) : Colors.grey[400],
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
