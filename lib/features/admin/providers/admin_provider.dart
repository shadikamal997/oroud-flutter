import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_provider.dart';

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(ref.read(apiClientProvider));
});

// Admin Shops Provider
final adminShopsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(adminServiceProvider);
  return service.getAllShops();
});

// Admin Offers Provider
final adminOffersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(adminServiceProvider);
  return service.getAllOffers();
});

// Admin Reports Provider
final adminReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = ref.read(adminServiceProvider);
  return service.getAllReports();
});

// Admin Service
class AdminService {
  final ApiClient _apiClient;

  AdminService(this._apiClient);

  Future<List<Map<String,dynamic>>> getAllShops() async {
    final response = await _apiClient.get('/admin/shops');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getAllOffers() async {
    final response = await _apiClient.get('/admin/offers');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getAllReports() async {
    final response = await _apiClient.get('/admin/reports');
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> verifyShop(String shopId) async {
    await _apiClient.patch('/admin/shops/$shopId/verify');
  }

  Future<void> blockShop(String shopId) async {
    await _apiClient.patch('/admin/shop/$shopId/block');
  }

  Future<void> unblockShop(String shopId) async {
    await _apiClient.patch('/admin/shop/$shopId/unblock');
  }

  Future<void> deleteOffer(String offerId) async {
    await _apiClient.delete('/admin/offer/$offerId');
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiClient.get('/admin/stats');
    return response.data;
  }
}
