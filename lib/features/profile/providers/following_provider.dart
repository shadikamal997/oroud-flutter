import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../../offers/models/offer_model.dart';
import 'package:flutter/foundation.dart';

final followingShopsProvider = FutureProvider<List<Shop>>((ref) async {
  try {
    final api = ref.read(apiClientProvider);
    final response = await api.get(Endpoints.followingShops);

    debugPrint('📍 Following shops response status: ${response.statusCode}');
    debugPrint('📍 Following shops response data type: ${response.data.runtimeType}');
    
    // Handle empty or null responses (401, etc.)
    if (response.data == null || response.data is String && (response.data as String).isEmpty) {
      debugPrint('⚠️ Empty or null response - user may not be authenticated or has no followed shops');
      return [];
    }

    debugPrint('📍 Following shops response data: ${response.data}');

    // Handle Map response with 'data' field
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      
      // Check if it's an error response
      if (map.containsKey('success') && map['success'] == false) {
        throw Exception(map['message'] ?? 'Request failed');
      }
      
      // Get the data array
      final data = map['data'] as List;
      debugPrint('📍 Number of followed shops: ${data.length}');
      return data.map((e) => Shop.fromJson(e as Map<String, dynamic>)).toList();
    } 
    // Handle direct List response (backward compatibility)
    else if (response.data is List) {
      final data = response.data as List;
      debugPrint('📍 Direct list response, length: ${data.length}');
      return data.map((e) => Shop.fromJson(e as Map<String, dynamic>)).toList();
    } 
    else {
      debugPrint('❌ Unexpected response type: ${response.data.runtimeType}');
      throw Exception('Unexpected response format');
    }
  } catch (e, stack) {
    debugPrint('❌ Error in followingShopsProvider: $e');
    debugPrint('❌ Stack trace: $stack');
    rethrow;
  }
});
