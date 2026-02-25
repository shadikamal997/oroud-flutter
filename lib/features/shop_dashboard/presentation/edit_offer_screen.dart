import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../shared/services/shop_service.dart';
import '../../../shared/services/image_upload_service.dart';
import 'package:oroud_app/core/theme/app_colors.dart';

/// Edit offer screen for shop owners
class EditOfferScreen extends ConsumerStatefulWidget {
  final String offerId;

  const EditOfferScreen({super.key, required this.offerId});

  @override
  ConsumerState<EditOfferScreen> createState() => _EditOfferScreenState();
}

class _EditOfferScreenState extends ConsumerState<EditOfferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();

  DateTime? _expiryDate;
  XFile? _selectedImage;
  String? _currentImageUrl;
  String? _subcategoryId;
  String _offerType = 'FIXED';
  bool _isLoading = false;
  bool _isLoadingOffer = true;
  int _calculatedDiscount = 0;

  @override
  void initState() {
    super.initState();
    _loadOfferData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadOfferData() async {
    try {
      final shopService = ref.read(shopServiceProvider);
      final offer = await shopService.getOfferById(widget.offerId);

      if (mounted) {
        setState(() {
          _titleController.text = offer['title'] ?? '';
          _descriptionController.text = offer['description'] ?? '';
          _originalPriceController.text = offer['originalPrice']?.toString() ?? '';
          _discountedPriceController.text = offer['discountedPrice']?.toString() ?? '';
          _expiryDate = offer['expiryDate'] != null
              ? DateTime.parse(offer['expiryDate'])
              : null;
          _currentImageUrl = offer['imageUrl'];
          _subcategoryId = offer['subcategoryId'];
          _offerType = offer['offerType'] ?? 'FIXED';
          _calculateDiscount();
          _isLoadingOffer = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load offer: $e')),
        );
        context.pop();
      }
    }
  }

  void _calculateDiscount() {
    final original = double.tryParse(_originalPriceController.text);
    final discounted = double.tryParse(_discountedPriceController.text);

    if (original != null && discounted != null && original > 0) {
      final discount = ((original - discounted) / original * 100).round();
      setState(() {
        _calculatedDiscount = discount.clamp(0, 100);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _updateOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_expiryDate == null) {
      _showError('Please select an expiry date');
      return;
    }

    // Validate discount percentage (1-90%)
    final original = double.tryParse(_originalPriceController.text);
    final discounted = double.tryParse(_discountedPriceController.text);

    if (original == null || discounted == null) {
      _showError('Please enter valid prices');
      return;
    }

    if (discounted >= original) {
      _showError('Discounted price must be less than original price');
      return;
    }

    final discountPercent = ((original - discounted) / original * 100);

    if (discountPercent < 1) {
      _showError('Discount must be at least 1%');
      return;
    }

    if (discountPercent > 90) {
      _showError('Discount cannot exceed 90%');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _currentImageUrl;

      // Upload new image if selected
      if (_selectedImage != null) {
        final imageUploadService = ref.read(imageUploadServiceProvider);
        imageUrl = await imageUploadService.uploadImageFromPath(_selectedImage!.path);
      }

      // Update offer through API
      final shopService = ref.read(shopServiceProvider);
      await shopService.updateOffer(
        offerId: widget.offerId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        originalPrice: original,
        discountedPrice: discounted,
        imageUrl: imageUrl,
        expiryDate: _expiryDate!,
        subcategoryId: _subcategoryId ?? '', // Preserve existing subcategory
        offerType: _offerType,
      );

      if (mounted) {
        _showSuccess('Offer updated successfully!');
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to update offer: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingOffer) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Offer'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Offer'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Image picker
            _buildImagePicker(),

            const SizedBox(height: 24),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Offer Title',
                hintText: 'e.g., 50% Off All Pizzas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                if (value.length < 5) {
                  return 'Title must be at least 5 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your offer...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                if (value.length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 16),

            // Original Price
            TextFormField(
              controller: _originalPriceController,
              decoration: const InputDecoration(
                labelText: 'Original Price',
                hintText: '100',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'SAR',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the original price';
                }
                final price = double.tryParse(value);
                if (price == null || price <= 0) {
                  return 'Please enter a valid price';
                }
                return null;
              },
              onChanged: (_) => _calculateDiscount(),
            ),

            const SizedBox(height: 16),

            // Discounted Price
            TextFormField(
              controller: _discountedPriceController,
              decoration: InputDecoration(
                labelText: 'Discounted Price',
                hintText: '50',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.local_offer),
                suffixText: 'SAR',
                helperText: _calculatedDiscount > 0
                    ? 'Discount: $_calculatedDiscount%'
                    : null,
                helperStyle: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the discounted price';
                }
                final discounted = double.tryParse(value);
                if (discounted == null || discounted <= 0) {
                  return 'Please enter a valid price';
                }
                final original = double.tryParse(_originalPriceController.text);
                if (original != null && discounted >= original) {
                  return 'Discounted price must be less than original';
                }
                return null;
              },
              onChanged: (_) => _calculateDiscount(),
            ),

            const SizedBox(height: 16),

            // Expiry Date
            InkWell(
              onTap: _selectExpiryDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _expiryDate == null
                      ? 'Select date'
                      : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                  style: TextStyle(
                    color: _expiryDate == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Update button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateOffer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Update Offer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: _selectedImage != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_selectedImage!.path),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            : _currentImageUrl != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _currentImageUrl!,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 48),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: _pickImage,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to change image',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
      ),
    );
  }
}