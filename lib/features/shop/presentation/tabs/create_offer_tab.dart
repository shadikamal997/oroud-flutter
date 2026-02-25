import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/api/api_provider.dart';
import '../../providers/current_shop_provider.dart';
import '../../../../core/providers/category_providers.dart';
import '../../../../core/models/category_model.dart';
import '../../../../core/widgets/pro_upgrade_modal.dart';
import '../../providers/shop_dashboard_tab_provider.dart';
import '../../../../shared/services/image_upload_service.dart';
import '../../../offers/providers/feed_provider.dart';

class CreateOfferTab extends ConsumerStatefulWidget {
  const CreateOfferTab({super.key});

  @override
  ConsumerState<CreateOfferTab> createState() => _CreateOfferTabState();
}

class _CreateOfferTabState extends ConsumerState<CreateOfferTab> {
  // Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _maxClaimsController = TextEditingController();

  // State
  String _selectedOfferType = 'PERCENTAGE';
  DateTime? _validFrom;
  DateTime? _validUntil;
  DateTime? _expiryDate;
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImages = false;
  String? _selectedCategory;
  String? _selectedSubcategory;
  bool _isSubmitting = false;
  bool _isBoosted = false;
  List<Subcategory> _availableSubcategories = [];

  // Calculated discount percentage
  double get _discountPercentage {
    final original = double.tryParse(_originalPriceController.text) ?? 0;
    final discounted = double.tryParse(_discountedPriceController.text) ?? 0;
    
    if (original > 0 && discounted > 0 && discounted < original) {
      return ((original - discounted) / original) * 100;
    }
    return 0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _whatsappController.dispose();
    _maxClaimsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EE),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modern Header with Icon
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Create New Offer",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A2A2A),
                            fontFamily: 'serif',
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Attract more customers",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          const SizedBox(height: 24),

          // SECTION 1 — Basic Info
          _buildSection(
            title: "Basic Information",
            child: Column(
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: "Offer Title",
                  hint: "e.g., 50% Off All Items",
                  required: true,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: "Description",
                  hint: "Describe your offer in detail",
                  maxLines: 3,
                  required: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SECTION 2 — Pricing
          _buildSection(
            title: "Pricing",
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _originalPriceController,
                        label: "Original Price",
                        hint: "0.00",
                        keyboardType: TextInputType.number,
                        required: true,
                        prefix: "JD",
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        controller: _discountedPriceController,
                        label: "Discounted Price",
                        hint: "0.00",
                        keyboardType: TextInputType.number,
                        required: true,
                        prefix: "JD",
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                if (_discountPercentage > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB86E45).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.discount,
                          color: Color(0xFFB86E45),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Discount: ${_discountPercentage.toStringAsFixed(1)}% OFF",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB86E45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SECTION 3 — Offer Type
          _buildSection(
            title: "Offer Type",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedOfferType,
                  decoration: InputDecoration(
                    labelText: "Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PERCENTAGE', child: Text('Percentage Discount')),
                    DropdownMenuItem(value: 'FIXED', child: Text('Fixed Amount Off')),
                    DropdownMenuItem(value: 'BOGO', child: Text('Buy One Get One')),
                    DropdownMenuItem(value: 'BUNDLE', child: Text('Bundle Deal')),
                    DropdownMenuItem(value: 'FLASH', child: Text('Flash Sale')),
                    DropdownMenuItem(value: 'LIMITED', child: Text('Limited Quantity')),
                    DropdownMenuItem(value: 'MYSTERY', child: Text('Mystery Deal')),
                    DropdownMenuItem(value: 'EXCLUSIVE', child: Text('Exclusive')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedOfferType = value!;
                      // Clear conditional fields when type changes
                      if (value != 'FLASH') {
                        _validFrom = null;
                        _validUntil = null;
                      }
                      if (value != 'LIMITED') {
                        _maxClaimsController.clear();
                      }
                    });
                  },
                ),

                // Expiry Date (Required for ALL offers)
                const SizedBox(height: 16),
                _buildDatePicker(
                  label: "Expiry Date *",
                  selectedDate: _expiryDate,
                  onTap: () => _selectDate(context, isStartDate: false, isExpiry: true),
                ),

                // Conditional fields for FLASH
                if (_selectedOfferType == 'FLASH') ...[
                  const SizedBox(height: 16),
                  _buildDatePicker(
                    label: "Valid From",
                    selectedDate: _validFrom,
                    onTap: () => _selectDate(context, isStartDate: true),
                  ),
                  const SizedBox(height: 12),
                  _buildDatePicker(
                    label: "Valid Until",
                    selectedDate: _validUntil,
                    onTap: () => _selectDate(context, isStartDate: false),
                  ),
                ],

                // Conditional field for LIMITED
                if (_selectedOfferType == 'LIMITED') ...[
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _maxClaimsController,
                    label: "Max Claims",
                    hint: "e.g., 100",
                    keyboardType: TextInputType.number,
                    required: true,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // SECTION 4 — Category
          _buildSection(
            title: "Category & Contact",
            child: _buildCategorySection(),
          ),

          const SizedBox(height: 16),

          // SECTION 4.5 — Boost Feature (PRO)
          _buildBoostSection(),

          const SizedBox(height: 16),

          // SECTION 5 — Images
          _buildSection(
            title: "Images",
            child: Column(
              children: [
                // Modern Selected Images Display
                if (_selectedImages.isNotEmpty) ...[
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.file(
                                    _selectedImages[index],
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              // Image number badge\n                              Positioned(\n                                top: 6,\n                                left: 6,\n                                child: Container(\n                                  padding: const EdgeInsets.symmetric(\n                                    horizontal: 8,\n                                    vertical: 4,\n                                  ),\n                                  decoration: BoxDecoration(\n                                    gradient: const LinearGradient(\n                                      colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],\n                                    ),\n                                    borderRadius: BorderRadius.circular(8),\n                                  ),\n                                  child: Text(\n                                    '${index + 1}',\n                                    style: const TextStyle(\n                                      color: Colors.white,\n                                      fontSize: 12,\n                                      fontWeight: FontWeight.bold,\n                                    ),\n                                  ),\n                                ),\n                              ),
                              // Remove button\n                              Positioned(\n                                top: 6,\n                                right: 6,\n                                child: GestureDetector(\n                                  onTap: () => _removeImage(index),\n                                  child: Container(\n                                    padding: const EdgeInsets.all(6),\n                                    decoration: BoxDecoration(\n                                      color: Colors.red.shade600,\n                                      shape: BoxShape.circle,\n                                      boxShadow: [\n                                        BoxShadow(\n                                          color: Colors.red.withValues(alpha: 0.4),\n                                          blurRadius: 6,\n                                          offset: const Offset(0, 2),\n                                        ),\n                                      ],\n                                    ),\n                                    child: const Icon(\n                                      Icons.close_rounded,\n                                      color: Colors.white,\n                                      size: 16,\n                                    ),\n                                  ),\n                                ),\n                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Modern Add Images Button
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFB86E45).withValues(alpha: 0.05),
                          const Color(0xFFCC7F54).withValues(alpha: 0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFB86E45).withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedImages.isEmpty
                                ? "Add up to 5 images"
                                : "Add more (${_selectedImages.length}/5)",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2A2A2A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Tap to select from gallery",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // MODERN GRADIENT SUBMIT BUTTON
          Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              gradient: _isSubmitting
                  ? const LinearGradient(
                      colors: [Color(0xFF999999), Color(0xFFBBBBBB)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFB86E45), Color(0xFFCC7F54)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _isSubmitting
                      ? Colors.grey.withValues(alpha: 0.2)
                      : const Color(0xFFB86E45).withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSubmitting ? null : _handleSubmit,
                borderRadius: BorderRadius.circular(16),
                child: Center(
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Text(
                              _isUploadingImages ? "Uploading images..." : "Creating offer...",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rocket_launch_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Create Offer",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  // Image picker methods
  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 images allowed'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      final remainingSlots = 5 - _selectedImages.length;
      final imagesToAdd = images.take(remainingSlots).toList();

      setState(() {
        _selectedImages.addAll(imagesToAdd.map((xfile) => File(xfile.path)));
      });

      if (images.length > remainingSlots) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Only $remainingSlots images added (max 5 total)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool required = false,
    String? prefix,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: required ? "$label *" : label,
        hintText: hint,
        prefixText: prefix != null ? "$prefix " : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate != null
              ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
              : "Select date",
          style: TextStyle(
            color: selectedDate != null ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStartDate, bool isExpiry = false}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        if (isExpiry) {
          // Set expiry to end of day (23:59:59) to ensure it's valid
          _expiryDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        } else if (isStartDate) {
          _validFrom = picked;
        } else {
          _validUntil = picked;
        }
      });
    }
  }

  Future<void> _handleSubmit() async {
    // Validation
    if (_titleController.text.trim().isEmpty) {
      _showError("Please enter offer title");
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError("Please enter offer description");
      return;
    }

    // 🔥 CRITICAL: Backend requires at least 1 image
    if (_selectedImages.isEmpty) {
      _showError("Please add at least 1 image for your offer");
      return;
    }

    final originalPrice = double.tryParse(_originalPriceController.text);
    final discountedPrice = double.tryParse(_discountedPriceController.text);

    if (originalPrice == null || originalPrice <= 0) {
      _showError("Please enter valid original price");
      return;
    }

    if (discountedPrice == null || discountedPrice <= 0) {
      _showError("Please enter valid discounted price");
      return;
    }

    if (discountedPrice >= originalPrice) {
      _showError("Discounted price must be less than original price");
      return;
    }

    if (_selectedSubcategory == null) {
      _showError("Please select a category and subcategory");
      return;
    }

    if (_expiryDate == null) {
      _showError("Please select an expiry date");
      return;
    }

    // Check offer limit for FREE users
    final shopAsync = ref.read(currentShopProvider);
    if (shopAsync.value != null) {
      final shop = shopAsync.value!;
      final isPro = shop.subscriptionPlan == 'PRO' && 
                    shop.subscriptionExpiresAt != null &&
                    shop.subscriptionExpiresAt!.isAfter(DateTime.now());
      
      if (!isPro && shop.offers.length >= 10) {
        if (!mounted) return;
        showProUpgradeModal(
          context,
          featureName: 'Create More Offers',
          description: 'FREE accounts are limited to 10 offers. Upgrade to PRO for unlimited offers!',
        );
        return;
      }
    }

    if (_whatsappController.text.trim().isEmpty) {
      _showError("Please enter WhatsApp number");
      return;
    }

    // Type-specific validation
    if (_selectedOfferType == 'FLASH') {
      if (_validFrom == null || _validUntil == null) {
        _showError("Please select valid from and until dates for flash sale");
        return;
      }
      if (_validUntil!.isBefore(_validFrom!)) {
        _showError("Valid until date must be after valid from date");
        return;
      }
    }

    if (_selectedOfferType == 'LIMITED') {
      final maxClaims = int.tryParse(_maxClaimsController.text);
      if (maxClaims == null || maxClaims <= 0) {
        _showError("Please enter valid max claims number");
        return;
      }
    }

    // Build payload
    final Map<String, dynamic> payload = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'offerType': _selectedOfferType,
      'subcategoryId': _selectedSubcategory,
      'expiryDate': _expiryDate!.toIso8601String(),
      'whatsappNumber': '+962${_whatsappController.text.trim()}',
    };

    // 🔥 Add pricing fields based on offer type
    if (_selectedOfferType == 'PERCENTAGE') {
      // For PERCENTAGE: send originalPrice and discountPercentage
      payload['originalPrice'] = originalPrice;
      payload['discountPercentage'] = _discountPercentage;
    } else if (_selectedOfferType == 'FIXED') {
      // For FIXED: send originalPrice and discountedPrice
      payload['originalPrice'] = originalPrice;
      payload['discountedPrice'] = discountedPrice;
    } else {
      // For other types (BOGO, BUNDLE, etc.): send both prices
      payload['originalPrice'] = originalPrice;
      payload['discountedPrice'] = discountedPrice;
    }

    if (_selectedOfferType == 'FLASH') {
      payload['validFrom'] = _validFrom!.toIso8601String();
      payload['validUntil'] = _validUntil!.toIso8601String();
    }

    if (_selectedOfferType == 'LIMITED') {
      payload['maxClaims'] = int.parse(_maxClaimsController.text);
    }

    setState(() => _isSubmitting = true);

    try {
      // Upload images first if any selected
      if (_selectedImages.isNotEmpty) {
        setState(() => _isUploadingImages = true);
        final imageUploadService = ImageUploadService(ref.read(apiClientProvider).dio);
        final List<String> uploadedUrls = [];

        for (final imageFile in _selectedImages) {
          try {
            final url = await imageUploadService.uploadImage(imageFile);
            uploadedUrls.add(url);
          } catch (e) {
            throw Exception('Failed to upload image: $e');
          }
        }

        setState(() => _isUploadingImages = false);
        
        // Add all uploaded images as imageUrls array
        payload['imageUrls'] = uploadedUrls;
      }

      final api = ref.read(apiClientProvider);
      await api.post('/offers', data: payload);

      if (!mounted) return;

      // Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Offer created successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh shop data
      ref.invalidate(currentShopProvider);
      
      // 🔥 Refresh home feed so new offer appears immediately
      ref.invalidate(feedProvider);

      // Clear form
      _clearForm();

      // Switch to My Offers tab (index 1)
      ref.read(shopDashboardTabProvider.notifier).setTab(1);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Offer created successfully!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError("Failed to create offer: ${e.toString()}");
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Widget _buildCategorySection() {
    final categoriesAsync = ref.watch(categoriesProvider);
    
    return categoriesAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'Error loading categories: $err',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (categories) => Column(
        children: [
          // Category Dropdown
          DropdownButtonFormField<String>(
            initialValue: _selectedCategory,
            decoration: InputDecoration(
              labelText: "Category *",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            hint: const Text("Select category"),
            items: categories.map((cat) {
              return DropdownMenuItem<String>(
                value: cat.id,
                child: Row(
                  children: [
                    if (cat.icon != null) Text(cat.icon!),
                    const SizedBox(width: 8),
                    Text(cat.name),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
                _selectedSubcategory = null; // Reset subcategory
                // Find selected category's subcategories
                final cat = categories.firstWhere((c) => c.id == value);
                _availableSubcategories = cat.subcategories;
              });
            },
          ),
          
          // Subcategory Dropdown (only if category selected)
          if (_selectedCategory != null && _availableSubcategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedSubcategory,
              decoration: InputDecoration(
                labelText: "Subcategory *",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              hint: const Text("Select subcategory"),
              items: _availableSubcategories.map((sub) {
                return DropdownMenuItem<String>(
                  value: sub.id,
                  child: Text(sub.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedSubcategory = value);
              },
            ),
          ],
          
          const SizedBox(height: 16),
          _buildTextField(
            controller: _whatsappController,
            label: "WhatsApp Number",
            hint: "e.g., 0791234567",
            keyboardType: TextInputType.phone,
            required: true,
            prefix: "+962",
          ),
        ],
      ),
    );
  }

  Widget _buildBoostSection() {
    final shopAsync = ref.watch(currentShopProvider);
    final shop = shopAsync.value;
    
    if (shop == null) return const SizedBox.shrink();
    
    final isPro = shop.subscriptionPlan == 'PRO' && 
                  shop.subscriptionExpiresAt != null &&
                  shop.subscriptionExpiresAt!.isAfter(DateTime.now());
    
    return _buildSection(
      title: "Boost Your Offer",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Boost This Offer",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (isPro) const SizedBox(width: 8),
                        if (isPro)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "PRO",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isPro
                          ? "Get your offer to the top of the feed"
                          : "PRO feature - Upgrade to boost offers",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isPro ? _isBoosted : false,
                onChanged: isPro
                    ? (value) {
                        setState(() => _isBoosted = value);
                      }
                    : (value) {
                        showProUpgradeModal(
                          context,
                          featureName: 'Boost Offer',
                          description: 'Get your offers to the top of the feed and reach more customers!',
                        );
                      },
                activeThumbColor: const Color(0xFFB86E45),
              ),
            ],
          ),
          if (_isBoosted && isPro) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFB86E45).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFB86E45).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.rocket_launch,
                    color: Color(0xFFB86E45),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This offer will appear at the top of feeds for maximum visibility",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _originalPriceController.clear();
    _discountedPriceController.clear();
    _whatsappController.clear();
    _maxClaimsController.clear();
    setState(() {
      _selectedOfferType = 'PERCENTAGE';
      _validFrom = null;
      _validUntil = null;
      _selectedCategory = null;
      _selectedSubcategory = null;
      _availableSubcategories = [];
      _isBoosted = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
