import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../models/offer_model.dart';

/// Offer Details Provider
/// 
/// Fetches full details for a single offer
/// Used in Offer Details Screen
final offerDetailsProvider =
    FutureProvider.family<Offer, String>((ref, offerId) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get('/offers/$offerId');
  return Offer.fromJson(response.data);
});

/// Claim Offer Provider
/// 
/// Claims an offer
final claimOfferProvider = Provider.family<Future<void> Function(), String>((ref, offerId) {
  return () async {
    final api = ref.read(apiClientProvider);
    await api.post('/offers/$offerId/claim');
    
    // Refresh offer details to show updated claim count
    ref.invalidate(offerDetailsProvider(offerId));
  };
});
