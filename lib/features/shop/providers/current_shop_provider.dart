import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/api/api_provider.dart';
import '../models/shop_model.dart';

/// Current shop provider - Fetches /shops/my-shop
/// Auto-refreshes when user profile changes
/// Backend will auto-create shop and convert USER to SHOP if needed
/// 🔒 FIX #12A: Removed autoDispose to prevent rebuild storms on tab switching
final currentShopProvider = FutureProvider<Shop?>((ref) async {
  try {
    if (kDebugMode) {
      print('🚀 currentShopProvider: Calling /shops/my-shop...');
    }
    
    final api = ref.read(apiClientProvider);
    final response = await api.get('/shops/my-shop');
    
    if (kDebugMode) {
      print('✅ Shop API response received');
      print('   Status: ${response.statusCode}');
      print('   Data keys: ${response.data?.keys?.toList()}');
      print('   Shop ID: ${response.data?['id']}');
      print('   Shop Name: ${response.data?['name']}');
    }
    
    final shop = Shop.fromJson(response.data);
    
    if (kDebugMode) {
      print('✅ Shop parsed successfully: ${shop.name}');
    }
    
    return shop;
  } on DioException catch (e) {
    if (kDebugMode) {
      print('❌ Shop API DioException:');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
    }
    
    // Handle 401 Unauthorized - user not logged in
    if (e.response?.statusCode == 401) {
      if (kDebugMode) {
        print('   → Returning null (401 Unauthorized)');
      }
      return null;
    }
    // Handle SHOP_NOT_INITIALIZED error or 404
    if (e.response?.statusCode == 404 || 
        e.response?.data?['error'] == 'SHOP_NOT_INITIALIZED') {
      if (kDebugMode) {
        print('   → Returning null (Shop not found)');
      }
      return null;
    }
    rethrow;
  } catch (e, stack) {
    if (kDebugMode) {
      print('❌ Shop API generic error: $e');
      print('   Stack: $stack');
    }
    rethrow;
  }
});

/// My offers provider - Lists offers for current shop
/// 🔒 FIX #12A: Removed autoDispose - persists across tab switches
final myOffersProvider = FutureProvider<List<dynamic>>((ref) async {
  final shop = await ref.watch(currentShopProvider.future);
  
  if (shop == null) return [];

  final api = ref.read(apiClientProvider);
  final response = await api.get('/offers', query: {'shopId': shop.id});
  
  return response.data as List;
});

/// Shop analytics provider
/// 🔒 FIX #12A: Removed autoDispose - persists across tab switches
final myShopAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final shop = await ref.watch(currentShopProvider.future);
  
  if (shop == null) {
    return {};
  }

  final api = ref.read(apiClientProvider);
  final response = await api.get('/shops/me/analytics');
  
  return response.data as Map<String, dynamic>;
});

/// Advanced 30-day analytics provider
/// 🔒 FIX #12A: Removed autoDispose - persists across tab switches
final shopAdvancedAnalyticsProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, shopId) async {
    final api = ref.read(apiClientProvider);
    final response = await api.get('/shops/$shopId/analytics');
    
    return response.data as Map<String, dynamic>;
  },
);
