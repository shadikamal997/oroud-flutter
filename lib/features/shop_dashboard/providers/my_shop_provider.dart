import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/shop_service.dart';
import '../../../shared/models/shop_model.dart';

/// Provider to fetch and cache the current user's shop
final myShopProvider = FutureProvider<Shop?>((ref) async {
  final shopService = ref.watch(shopServiceProvider);
  return shopService.getMyShop();
});

/// Provider to manually refresh the shop data
final refreshMyShopProvider = Provider<void Function()>((ref) {
  return () => ref.invalidate(myShopProvider);
});
