import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../models/shop_model.dart';

/// Public shop provider - Fetches any shop by ID (public endpoint)
/// 
/// Used for viewing shops that are not owned by current user
/// Supports viewing without authentication (public profiles)
final publicShopProvider =
    FutureProvider.autoDispose.family<Shop, String>((ref, shopId) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get('/shops/$shopId');
  
  return Shop.fromJson(response.data);
});
