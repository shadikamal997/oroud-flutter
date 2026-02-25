import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_provider.dart';

class SubscriptionService {
  final ApiClient _apiClient;

  SubscriptionService(this._apiClient);

  /// Get subscription status for a shop
  Future<Map<String, dynamic>> getSubscriptionStatus(String shopId) async {
    final response = await _apiClient.get('/shops/$shopId/subscription');
    return response.data as Map<String, dynamic>;
  }

  /// Upgrade shop to PRO subscription
  Future<Map<String, dynamic>> upgradeSubscription(String shopId) async {
    final response = await _apiClient.post('/shops/$shopId/upgrade');
    return response.data as Map<String, dynamic>;
  }
}

// Provider for SubscriptionService
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SubscriptionService(apiClient);
});
