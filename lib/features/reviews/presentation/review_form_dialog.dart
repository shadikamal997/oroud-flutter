import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/reviews_provider.dart';
import '../widgets/rating_widgets.dart';

/// Review Form Dialog - For creating/editing reviews
class ReviewFormDialog extends ConsumerStatefulWidget {
  final String shopId;
  final String shopName;
  final int? existingRating;
  final String? existingComment;

  const ReviewFormDialog({
    super.key,
    required this.shopId,
    required this.shopName,
    this.existingRating,
    this.existingComment,
  });

  @override
  ConsumerState<ReviewFormDialog> createState() => _ReviewFormDialogState();

  /// Show the dialog
  static Future<bool?> show(
    BuildContext context, {
    required String shopId,
    required String shopName,
    int? existingRating,
    String? existingComment,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ReviewFormDialog(
        shopId: shopId,
        shopName: shopName,
        existingRating: existingRating,
        existingComment: existingComment,
      ),
    );
  }
}

class _ReviewFormDialogState extends ConsumerState<ReviewFormDialog> {
  late int _rating;
  late TextEditingController _commentController;
  bool _isSubmitting = false;
  final List<XFile> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _rating = widget.existingRating ?? 0;
    _commentController = TextEditingController(text: widget.existingComment);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFiles != null) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
          // Limit to 5 images
          if (_selectedImages.length > 5) {
            _selectedImages.removeRange(5, _selectedImages.length);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Maximum 5 images allowed'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rating'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      List<String>? imageUrls;

      // Upload images if any
      if (_selectedImages.isNotEmpty) {
        final uploadService = ref.read(uploadServiceProvider);
        final imagePaths = _selectedImages.map((file) => file.path).toList();
        
        try {
          imageUrls = await uploadService.uploadImages(imagePaths);
          if (imageUrls.isEmpty && _selectedImages.isNotEmpty) {
            throw Exception('Failed to upload images');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload images: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          // Continue without images
          imageUrls = null;
        }
      }

      final service = ref.read(reviewsServiceProvider);
      await service.upsertReview(
        shopId: widget.shopId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        imageUrls: imageUrls,
      );

      if (mounted) {
        // Invalidate shop reviews to refresh
        ref.invalidate(shopReviewsProvider(widget.shopId));
        
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingRating != null
                  ? 'Review updated successfully'
                  : 'Review submitted successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingRating != null ? 'Edit Review' : 'Rate This Shop',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shop name
            Text(
              widget.shopName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Star rating selector
            const Text(
              'Your Rating',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Center(
              child: StarRatingSelector(
                initialRating: _rating,
                onRatingChanged: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Images section
            const Text(
              'Photos (Optional)',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (_selectedImages.isEmpty)
              OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Photos'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: _pickImages,
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add_photo_alternate),
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImages[index].path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selectedImages.length}/5 photos',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Comment field
            const Text(
              'Your Review (Optional)',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Share your experience...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.existingRating != null ? 'Update' : 'Submit'),
        ),
      ],
    );
  }
}
