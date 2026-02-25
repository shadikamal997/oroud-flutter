import '../models/city_model.dart';
import '../../core/api/api_provider.dart';
import '../../core/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CityService {
  final ApiClient _apiClient;

  CityService(this._apiClient);

  Future<List<City>> getCities() async {
    try {
      final response = await _apiClient.get('/cities');
      return (response.data as List)
          .map((city) => City.fromJson(city))
          .toList();
    } catch (e) {
      throw Exception('Failed to load cities: $e');
    }
  }
}

final cityServiceProvider = Provider<CityService>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CityService(apiClient);
});
