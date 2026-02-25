import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_provider.dart';
import '../../../offers/models/offer_model.dart';

/// Provider to fetch premium slider offers from home-slider endpoint
final premiumSliderOffersProvider = FutureProvider<List<Offer>>((ref) async {
  final apiService = ref.read(apiClientProvider);
  
  try {
    final response = await apiService.get('/offers/home-slider');
    
    if (response.data is List) {
      return (response.data as List)
          .map((json) => Offer.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  } catch (e) {
    // Return empty list if there are no slider offers yet
    return [];
  }
});
