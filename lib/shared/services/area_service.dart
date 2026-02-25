import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/area_model.dart';
import '../../core/api/api_provider.dart';
import '../../core/api/api_client.dart';

class AreaService {
  final ApiClient _apiClient;

  AreaService(this._apiClient);

  /// Get all areas for a specific city
  Future<List<Area>> getAreasByCity(String cityId) async {
    try {
      final response = await _apiClient.get(
        '/areas',
        query: {'cityId': cityId},
      );

      if (response.data is List) {
        return (response.data as List)
            .map((area) => Area.fromJson(area as Map<String, dynamic>))
            .toList();
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load areas: $e');
    }
  }

  /// Get all areas grouped by city
  Future<Map<String, List<Area>>> getAreasGroupedByCity() async {
    try {
      final response = await _apiClient.get('/areas/grouped');

      if (response.data is List) {
        final Map<String, List<Area>> grouped = {};

        for (final cityData in response.data) {
          final cityName = cityData['name'] as String;
          final areas = (cityData['areas'] as List)
              .map((area) => Area.fromJson(area as Map<String, dynamic>))
              .toList();

          grouped[cityName] = areas;
        }

        return grouped;
      }

      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Failed to load grouped areas: $e');
    }
  }
}

/// Provider for AreaService
final areaServiceProvider = Provider<AreaService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AreaService(apiClient);
});

/// FutureProvider to fetch areas for a specific city
/// Usage: ref.watch(areasByCityProvider(cityId))
final areasByCityProvider = FutureProvider.family<List<Area>, String>(
  (ref, cityId) async {
    final service = ref.read(areaServiceProvider);
    return service.getAreasByCity(cityId);
  },
);

/// FutureProvider for all areas grouped by city
final areasGroupedProvider = FutureProvider<Map<String, List<Area>>>(
  (ref) async {
    final service = ref.read(areaServiceProvider);
    return service.getAreasGroupedByCity();
  },
);
