import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/endpoints.dart';

class UploadService {
  final ApiClient _apiClient;

  UploadService(this._apiClient);

  /// Upload a single image file
  /// Returns the URL of the uploaded image
  Future<String> uploadImage(String filePath) async {
    final fileName = filePath.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
      ),
    });

    final response = await _apiClient.post(
      Endpoints.uploadImage,
      data: formData,
    );

    // Backend returns { url: 'https://...' } or { secure_url: 'https://...' }
    return response.data['url'] ?? response.data['secure_url'];
  }

  /// Upload multiple images
  /// Returns list of URLs
  Future<List<String>> uploadImages(List<String> filePaths) async {
    final urls = <String>[];
    
    for (final filePath in filePaths) {
      try {
        final url = await uploadImage(filePath);
        urls.add(url);
      } catch (e) {
        // Log error but continue with other images
        print('Failed to upload image: $filePath, error: $e');
      }
    }
    
    return urls;
  }
}
