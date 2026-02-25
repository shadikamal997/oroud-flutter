import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/endpoints.dart';
import '../models/claim_model.dart';

// 🎯 Claims API Provider
final claimsApiProvider = Provider<ClaimsApi>((ref) {
  return ClaimsApi();
});

class ClaimsApi {
  final _apiClient = ApiClient();

  // 📱 Get user's claims
  Future<List<Claim>> getMyClaims() async {
    try {
      final response = await _apiClient.get(Endpoints.myClaims);
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => Claim.fromJson(json)).toList();
      }
      
      throw Exception('Failed to load claims');
    } catch (e) {
      print('❌ Error fetching claims: $e');
      rethrow;
    }
  }

  // 🏪 Get claims for a specific offer (shop owner)
  Future<Map<String, dynamic>> getOfferClaims(String offerId) async {
    try {
      final response = await _apiClient.get(Endpoints.offerClaims(offerId));
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      
      throw Exception('Failed to load offer claims');
    } catch (e) {
      print('❌ Error fetching offer claims: $e');
      rethrow;
    }
  }

  // 🔥 Redeem a claim (shop owner)
  Future<Map<String, dynamic>> redeemClaim(String claimId) async {
    try {
      final response = await _apiClient.post(Endpoints.redeemClaim(claimId));
      
      if (response.statusCode == 200 && response.data != null) {
        return response.data;
      }
      
      throw Exception('Failed to redeem claim');
    } catch (e) {
      print('❌ Error redeeming claim: $e');
      rethrow;
    }
  }
}

// 🎯 My Claims State Provider
final myClaimsProvider = FutureProvider<List<Claim>>((ref) async {
  final claimsApi = ref.watch(claimsApiProvider);
  return await claimsApi.getMyClaims();
});

// 🏪 Offer Claims State Provider (for shop owners)
final offerClaimsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, offerId) async {
  final claimsApi = ref.watch(claimsApiProvider);
  return await claimsApi.getOfferClaims(offerId);
});
