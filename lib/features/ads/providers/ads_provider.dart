import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../models/ad_model.dart';

// Provider for fetching active ads for a city (HOME_FEED placement)
final adsProvider = FutureProvider.family<List<Ad>, String>((ref, cityId) async {
  final apiClient = ref.read(apiClientProvider);

  try {
    final response = await apiClient.get('${Endpoints.ads}/active', query: {'cityId': cityId});

    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => Ad.fromJson(json)).toList();
  } catch (e) {
    // Return empty list on error to avoid breaking the feed
    return [];
  }
});

// Provider for fetching hero ads (HERO placement)
final heroAdsProvider = FutureProvider.family<List<Ad>, String>((ref, cityId) async {
  final apiClient = ref.read(apiClientProvider);

  try {
    final response = await apiClient.get('${Endpoints.ads}/hero', query: {'cityId': cityId});

    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => Ad.fromJson(json)).toList();
  } catch (e) {
    // Return empty list on error to avoid breaking the UI
    return [];
  }
});

// Provider for tracking ad clicks
final adClickProvider = FutureProvider.family<void, String>((ref, adId) async {
  final apiClient = ref.read(apiClientProvider);

  try {
    await apiClient.post('${Endpoints.ads}/$adId/click');
  } catch (e) {
    // Silently fail click tracking to avoid disrupting user experience
    // Failed to track ad click: $e
  }
});