import 'package:flutter_riverpod/flutter_riverpod.dart';

// Simple provider to control the shop dashboard tab index
final shopDashboardTabProvider = NotifierProvider<ShopDashboardTabController, int>(
  ShopDashboardTabController.new,
);

class ShopDashboardTabController extends Notifier<int> {
  @override
  int build() => 0;
  
  void setTab(int index) {
    state = index;
  }
}
