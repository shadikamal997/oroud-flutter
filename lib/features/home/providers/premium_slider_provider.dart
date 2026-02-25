import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';

/// Premium slider offers provider
/// Fetches offers from GET /api/offers/home-slider
/// Shows max 5 offers in carousel rotation
final premiumSliderOffersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final dio = Dio();
    final response = await dio.get(
      '${ApiConfig.baseUrl}/offers/home-slider',
    );

    if (response.statusCode == 200) {
      // Backend returns array of offers directly
      if (response.data is List) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    }
    return [];
  } catch (e) {
    print('❌ Error fetching premium slider offers: $e');
    return [];
  }
});

/// Refresh premium slider offers
final refreshPremiumSliderProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(premiumSliderOffersProvider);
  };
});
