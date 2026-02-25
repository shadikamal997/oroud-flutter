import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Service for direct uploads to Cloudinary (unsigned)
/// No backend proxy - Flutter uploads directly to Cloudinary
class CloudinaryService {
  // TODO: Replace with your actual Cloudinary credentials
  static const String cloudName = 'YOUR_CLOUD_NAME'; // e.g., 'oroud-marketplace'
  static const String uploadPreset = 'YOUR_UNSIGNED_PRESET'; // Create in Cloudinary settings

  /// Upload image directly to Cloudinary using unsigned preset
  /// 
  /// Returns the secure_url from Cloudinary response
  /// 
  /// Example response:
  /// {
  ///   "secure_url": "https://res.cloudinary.com/...",
  ///   "public_id": "abc123",
  ///   "width": 1200,
  ///   "height": 800
  /// }
  Future<String> uploadImage(File imageFile) async {
    try {
      // Direct Cloudinary upload URL
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add unsigned preset (required for unsigned uploads)
      request.fields['upload_preset'] = uploadPreset;

      // Optional: Add folder organization
      // request.fields['folder'] = 'oroud/shops';

      // Optional: Add tags for categorization
      // request.fields['tags'] = 'shop,profile';

      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Send request to Cloudinary
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decoded = jsonDecode(responseData);

        // Return the secure_url from Cloudinary
        return decoded['secure_url'] as String;
      } else {
        final errorData = await response.stream.bytesToString();
        throw Exception(
          'Cloudinary upload failed: ${response.statusCode} - $errorData',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload to Cloudinary: $e');
    }
  }

  /// Upload image from path (for image_picker XFile)
  Future<String> uploadImageFromPath(String imagePath) async {
    final file = File(imagePath);
    return uploadImage(file);
  }

  /// Upload with progress tracking (optional enhancement)
  /// 
  /// Usage:
  /// ```dart
  /// await cloudinaryService.uploadImageWithProgress(
  ///   file,
  ///   onProgress: (progress) => print('Upload progress: $progress%'),
  /// );
  /// ```
  Future<String> uploadImageWithProgress(
    File imageFile, {
    Function(double)? onProgress,
  }) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;

      final fileSize = await imageFile.length();
      final stream = http.ByteStream(imageFile.openRead());

      // Track upload progress (simplified - real implementation needs chunking)

      request.files.add(
        http.MultipartFile(
          'file',
          stream,
          fileSize,
          filename: imageFile.path.split('/').last,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decoded = jsonDecode(responseData);
        
        onProgress?.call(100.0);
        return decoded['secure_url'] as String;
      } else {
        final errorData = await response.stream.bytesToString();
        throw Exception(
          'Cloudinary upload failed: ${response.statusCode} - $errorData',
        );
      }
    } catch (e) {
      throw Exception('Failed to upload to Cloudinary: $e');
    }
  }
}

/// Provider for CloudinaryService
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  return CloudinaryService();
});
