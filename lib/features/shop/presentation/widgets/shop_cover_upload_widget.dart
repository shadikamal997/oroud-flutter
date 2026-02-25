import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import '../../../../core/api/api_provider.dart';
import '../../../../shared/services/image_upload_service.dart';

/// Shop cover image upload widget
class ShopCoverUploadWidget extends ConsumerStatefulWidget {
  final String? currentCoverUrl;
  final String shopId;
  final Function(String) onCoverUpdated;

  const ShopCoverUploadWidget({
    super.key,
    this.currentCoverUrl,
    required this.shopId,
    required this.onCoverUpdated,
  });

  @override
  ConsumerState<ShopCoverUploadWidget> createState() =>
      _ShopCoverUploadWidgetState();
}

class _ShopCoverUploadWidgetState extends ConsumerState<ShopCoverUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 400,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _uploadCover();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadCover({bool isRetry = false}) async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      // Upload to backend
      final imageUploadService = ref.read(imageUploadServiceProvider);
      final coverUrl = await imageUploadService.uploadImage(_selectedImage!);

      // Update shop profile with new cover URL
      final api = ref.read(apiClientProvider);
      await api.put(
        '/shops/my-shop',
        data: {'coverUrl': coverUrl},
      );

      widget.onCoverUpdated(coverUrl);

      if (mounted) {
        // Clear selected image only on success
        setState(() {
          _isUploading = false;
          _selectedImage = null;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cover image updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Check if it's a token refresh error and retry once
      if (!isRetry && (e.toString().contains('401') || e.toString().contains('Token refreshed'))) {
        if (mounted) {
          // Wait a bit for token to be saved, then retry
          await Future.delayed(const Duration(milliseconds: 500));
          return _uploadCover(isRetry: true);
        }
      }
      
      if (mounted) {
        // Keep upload indicator off but keep selected image visible on error
        setState(() {
          _isUploading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload cover: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _uploadCover(),
            ),
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Choose Cover Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB86E45).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFFB86E45)),
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCC7F54).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: Color(0xFFCC7F54)),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (widget.currentCoverUrl != null && widget.currentCoverUrl!.isNotEmpty)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  title: const Text('Remove Cover'),
                  onTap: () {
                    Navigator.pop(context);
                    _removeCover();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeCover() async {
    setState(() => _isUploading = true);

    try {
      final api = ref.read(apiClientProvider);
      await api.put(
        '/shops/my-shop',
        data: {'coverUrl': null},
      );

      widget.onCoverUpdated('');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cover image removed'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove cover: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _showImageSourceDialog,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFB86E45).withOpacity(0.2),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Stack(
          children: [
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            else if (widget.currentCoverUrl != null && widget.currentCoverUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: widget.currentCoverUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFB86E45),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB86E45).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 36,
                        color: const Color(0xFFB86E45),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap to upload cover image',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PNG, JPG up to 5MB',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Upload indicator
            if (_isUploading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ),
            
            // Edit icon
            if (!_isUploading && widget.currentCoverUrl != null && widget.currentCoverUrl!.isNotEmpty)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
