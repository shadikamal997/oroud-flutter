import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../models/shop_analytics_model.dart';

// Analytics Service
class AnalyticsService {
  final ApiClient _apiClient;

  AnalyticsService(this._apiClient);

  Future<ShopAnalytics> getMyAnalytics() async {
    final response = await _apiClient.get('${Endpoints.shops}/me/analytics');
    return ShopAnalytics.fromJson(response.data);
  }
}

// Analytics Service Provider
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AnalyticsService(apiClient);
});

// Shop Analytics Provider
final shopAnalyticsProvider = FutureProvider<ShopAnalytics>((ref) async {
  final service = ref.read(analyticsServiceProvider);
  return service.getMyAnalytics();
});
