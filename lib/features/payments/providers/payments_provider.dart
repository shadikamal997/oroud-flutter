import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_provider.dart';
import '../models/payment_models.dart';

class PaymentsService {
  final ApiClient _apiClient;

  PaymentsService(this._apiClient);

  /// Create promotion payment
  Future<PaymentResponse> promoteOffer(String offerId, PromotionTier tier) async {
    final request = PaymentRequest(
      offerId: offerId,
      tier: _getTierString(tier),
    );

    final response = await _apiClient.post(
      '/payments/promote',
      data: request.toJson(),
    );

    return PaymentResponse.fromJson(response.data);
  }

  /// Get payment history
  Future<List<PaymentHistory>> getPaymentHistory() async {
    final response = await _apiClient.get('/payments/history');
    final data = response.data as List;
    return data.map((json) => PaymentHistory.fromJson(json)).toList();
  }

  String _getTierString(PromotionTier tier) {
    switch (tier) {
      case PromotionTier.silver:
        return 'SILVER';
      case PromotionTier.gold:
        return 'GOLD';
      case PromotionTier.platinum:
        return 'PLATINUM';
    }
  }
}

// Payments Service Provider
final paymentsServiceProvider = Provider<PaymentsService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PaymentsService(apiClient);
});

// Payment History Provider
final paymentHistoryProvider = FutureProvider<List<PaymentHistory>>((ref) async {
  final service = ref.read(paymentsServiceProvider);
  return service.getPaymentHistory();
});
