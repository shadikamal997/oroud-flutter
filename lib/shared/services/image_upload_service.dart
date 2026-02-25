import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_provider.dart';

/// Service for uploading images to Cloudinary via backend
class ImageUploadService {
  final Dio _dio;
  
  // Max file size: 5MB
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  ImageUploadService(this._dio);

  /// Upload image to Cloudinary through backend API
  Future<String> uploadImage(File imageFile) async {
    try {
      // Validate file size
      final fileSize = await imageFile.length();
      if (fileSize > maxFileSizeBytes) {
        throw Exception('Image size must be less than 5MB (current: ${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB)');
      }

      // Create form data with the image file
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Send request through Dio (auth interceptor will add token automatically)
      final response = await _dio.post(
        '/upload/image',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return Cloudinary secure URL
        return response.data['imageUrl'];
      } else {
        throw Exception('Upload failed: ${response.statusCode} - ${response.data}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Upload failed: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload image from XFile path (for image_picker)
  Future<String> uploadImageFromPath(String imagePath) async {
    final file = File(imagePath);
    return uploadImage(file);
  }
}

/// Provider for ImageUploadService
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ImageUploadService(apiClient.dio);
});
