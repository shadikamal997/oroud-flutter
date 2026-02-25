import '../../core/api/api_client.dart';
import '../../core/api/endpoints.dart';

class CategoryService {
  final ApiClient _apiClient;

  CategoryService(this._apiClient);

  /// Get all categories
  Future<List<dynamic>> getAllCategories() async {
    final response = await _apiClient.get(Endpoints.categories);
    return response.data as List<dynamic>;
  }

  /// Get followed categories
  Future<List<dynamic>> getFollowedCategories() async {
    final response = await _apiClient.get('${Endpoints.categories}/following');
    return response.data as List<dynamic>;
  }

  /// Follow a category
  Future<void> followCategory(String category) async {
    await _apiClient.post('${Endpoints.followCategory}/$category/follow');
  }

  /// Unfollow a category
  Future<void> unfollowCategory(String category) async {
    await _apiClient.delete('${Endpoints.followCategory}/$category/follow');
  }
}
