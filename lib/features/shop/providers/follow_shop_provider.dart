import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import 'public_shop_provider.dart';

/// Check if user is following a specific shop
final isFollowingShopProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, shopId) async {
  try {
    final api = ref.read(apiClientProvider);
    final response = await api.get('/shops/$shopId/is-following');
    return response.data['isFollowing'] == true;
  } catch (e) {
    return false;
  }
});

/// Toggle follow/unfollow for a shop
final toggleFollowProvider = Provider.family<Future<void> Function(), String>((ref, shopId) {
  return () async {
    final api = ref.read(apiClientProvider);
    final isFollowing = await ref.read(isFollowingShopProvider(shopId).future);
    
    if (isFollowing) {
      await api.delete('/shops/$shopId/follow');
    } else {
      await api.post('/shops/$shopId/follow');
    }
    
    // Refresh states
    ref.invalidate(isFollowingShopProvider(shopId));
    ref.invalidate(publicShopProvider(shopId));
  };
});
