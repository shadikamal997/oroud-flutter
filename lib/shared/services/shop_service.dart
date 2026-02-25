import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_provider.dart';
import '../../core/api/endpoints.dart';
import '../models/shop_model.dart';

class ShopService {
  final ApiClient _apiClient;

  ShopService(this._apiClient);

  /// Get all shops (optionally filtered by city)
  Future<List<Shop>> getShops({String? cityId}) async {
    final response = await _apiClient.get(
      Endpoints.shops,
      query: cityId != null ? {'cityId': cityId} : null,
    );

    final data = response.data as List;
    return data.map((json) => Shop.fromJson(json)).toList();
  }

  /// Get a single shop by ID
  Future<Shop> getShop(String id) async {
    final response = await _apiClient.get('${Endpoints.shops}/$id');
    return Shop.fromJson(response.data);
  }

  /// Get my shop (for shop owners)
  Future<Shop?> getMyShop() async {
    try {
      final response = await _apiClient.get('${Endpoints.shops}/my-shop');
      if (response.data == null) {
        return null;
      }
      return Shop.fromJson(response.data);
    } catch (e) {
      // Shop not found
      return null;
    }
  }

  /// Register a new shop
  Future<Shop> registerShop({
    required String name,
    required String cityId,
    required String areaId,
    required double latitude,
    required double longitude,
    String? logoUrl,
  }) async {
    final response = await _apiClient.post(
      '${Endpoints.shops}/register',
      data: {
        'name': name,
        'cityId': cityId,
        'areaId': areaId,
        'latitude': latitude,
        'longitude': longitude,
        'logoUrl': ?logoUrl,
      },
    );

    return Shop.fromJson(response.data);
  }

  /// Create a new offer for the shop
  Future<Map<String, dynamic>> createOffer({
    required String title,
    required String description,
    required double originalPrice,
    required double discountedPrice,
    required String imageUrl,
    required DateTime expiryDate,
    required String subcategoryId,
    String offerType = 'FIXED',
  }) async {
    // 🔥 FIX: Backend expects imageUrls as array (1-5 images)
    final requestData = {
      'title': title,
      'description': description,
      'originalPrice': originalPrice,
      'discountedPrice': discountedPrice,
      'imageUrls': [imageUrl],  // ✅ Changed from imageUrl to imageUrls array
      'expiryDate': expiryDate.toIso8601String(),
      'subcategoryId': subcategoryId,
      'offerType': offerType,
    };
    
    print('📤 Creating offer with data: $requestData');
    
    final response = await _apiClient.post(
      Endpoints.offers,
      data: requestData,
    );

    print('✅ Offer created: ${response.data}');
    return response.data;
  }

  /// Get all categories with subcategories
  Future<List<dynamic>> getCategories() async {
    final response = await _apiClient.get('/categories/all');
    return response.data as List;
  }

  /// Get subcategories for a category
  Future<List<dynamic>> getSubcategories(String categoryId) async {
    final response = await _apiClient.get(
      '/categories/subcategories',
      query: {'categoryId': categoryId},
    );
    return response.data as List;
  }

  /// Get a single offer by ID
  Future<Map<String, dynamic>> getOfferById(String offerId) async {
    final response = await _apiClient.get('${Endpoints.offers}/$offerId');
    return response.data;
  }

  /// Update an existing offer
  Future<Map<String, dynamic>> updateOffer({
    required String offerId,
    required String title,
    required String description,
    required double originalPrice,
    required double discountedPrice,
    required String? imageUrl,
    required DateTime expiryDate,
    required String subcategoryId,
    String offerType = 'FIXED',
  }) async {
    final response = await _apiClient.patch(
      '${Endpoints.offers}/$offerId',
      data: {
        'title': title,
        'description': description,
        'originalPrice': originalPrice,
        'discountedPrice': discountedPrice,
        // ✅ Update uses imageUrl (singular) - backend has special handling
        'imageUrl': ?imageUrl,
        'expiryDate': expiryDate.toIso8601String(),
        'subcategoryId': subcategoryId,
        'offerType': offerType,
      },
    );

    return response.data;
  }
}

// Provider for ShopService
final shopServiceProvider = Provider<ShopService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ShopService(apiClient);
});
