import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';

class SearchService {
  final ApiClient _apiClient;

  SearchService(this._apiClient);

  /// Search for shops and offers
  Future<Map<String, dynamic>> search({
    required String query,
    String type = 'ALL', // ALL, SHOPS, OFFERS
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      Endpoints.search,
      query: {
        'query': query,
        'type': type,
        'page': page,
        'limit': limit,
      },
    );
    return response.data;
  }

  /// Get search suggestions (autocomplete)
  Future<List<String>> getSuggestions(String query) async {
    final response = await _apiClient.get(
      Endpoints.search,
      query: {
        'query': query,
        'type': 'ALL',
        'limit': 5,
      },
    );
    
    final data = response.data;
    final suggestions = <String>[];
    
    // Extract shop names
    if (data['shops'] != null) {
      for (var shop in data['shops']) {
        suggestions.add(shop['name'] as String);
      }
    }
    
    // Extract offer titles
    if (data['offers'] != null) {
      for (var offer in data['offers']) {
        suggestions.add(offer['title'] as String);
      }
    }
    
    return suggestions;
  }
}
