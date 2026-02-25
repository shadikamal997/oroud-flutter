import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../shared/services/shop_service.dart';
import '../../../shared/services/image_upload_service.dart';
import '../../../shared/models/area_model.dart';
import '../../../shared/models/city_model.dart';
import '../../../core/api/api_provider.dart';
import 'package:oroud_app/core/theme/app_colors.dart';
import '../../offers/models/offer_model.dart' show OfferType;
import '../../categories/providers/category_provider.dart';
import 'package:intl/intl.dart';

/// 🚀 Campaign Builder - Professional Offer Creation
class CampaignBuilderScreen extends ConsumerStatefulWidget {
  const CampaignBuilderScreen({super.key});

  @override
  ConsumerState<CampaignBuilderScreen> createState() => _CampaignBuilderScreenState();
}

class _CampaignBuilderScreenState extends ConsumerState<CampaignBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 1️⃣ Campaign Identity
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _descriptionLength = 0;
  
  // 2️⃣ Smart Pricing Engine
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  double _calculatedDiscount = 0;
  double _customerSaves = 0;
  String _offerScore = '';
  
  // 3️⃣ Offer Type
  OfferType? _selectedOfferType;
  DateTime? _validFrom;
  DateTime? _validUntil;
  final _maxClaimsController = TextEditingController();
  
  // 4️⃣ Location Targeting
  List<City> _cities = [];
  String? _selectedCityId;
  String? _selectedCityName;
  List<Area> _areas = [];
  Area? _selectedArea;
  bool _loadingCities = false;
  bool _loadingAreas = false;
  
  // 5️⃣ Category Engine
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  
  // 6️⃣ Visual Gallery (1-5 images)
  final List<XFile> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  
  // 7️⃣ Contact Layer
  final _whatsappController = TextEditingController();
  bool _showWhatsAppButton = true;
  
  // 8️⃣ Terms & Conditions
  final _termsController = TextEditingController();
  bool _termsExpanded = false;
  
  // 9️⃣ Sponsored Boost
  bool _wantsBoost = false;
  String? _boostDuration;
  String? _boostType;
  int? _selectedRadiusKm;
  
  // System
  DateTime? _expiryDate;
  bool _isLoading = false;
  final bool _inStock = true;
  
  // Campaign Strength
  double _campaignStrength = 0;

  @override
  void initState() {
    super.initState();
    _originalPriceController.addListener(_calculatePricing);
    _discountedPriceController.addListener(_calculatePricing);
    _descriptionController.addListener(() {
      setState(() {
        _descriptionLength = _descriptionController.text.length;
        _updateCampaignStrength();
      });
    });
    _fetchCities();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _maxClaimsController.dispose();
    _whatsappController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  // 🔥 Fetch Cities
  Future<void> _fetchCities() async {
    setState(() => _loadingCities = true);
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get('/cities');
      setState(() {
        _cities = (response.data as List)
            .map((json) => City.fromJson(json as Map<String, dynamic>))
            .toList();
        _loadingCities = false;
      });
    } catch (e) {
      setState(() => _loadingCities = false);
    }
  }

  // 🔥 Fetch Areas (filtered by city)
  Future<void> _fetchAreas(String cityId) async {
    setState(() => _loadingAreas = true);
    try {
      final api = ref.read(apiClientProvider);
      final response = await api.get('/areas?cityId=$cityId');
      setState(() {
        _areas = (response.data as List)
            .map((json) => Area.fromJson(json as Map<String, dynamic>))
            .toList();
        _loadingAreas = false;
      });
    } catch (e) {
      setState(() => _loadingAreas = false);
    }
  }

  // 🔥 Calculate Pricing & Offer Score
  void _calculatePricing() {
    final original = double.tryParse(_originalPriceController.text) ?? 0;
    final discounted = double.tryParse(_discountedPriceController.text) ?? 0;
    
    if (original > 0 && discounted > 0 && discounted < original) {
      final discount = ((original - discounted) / original) * 100;
      final saves = original - discounted;
      
      setState(() {
        _calculatedDiscount = discount;
        _customerSaves = saves;
        
        // Offer Score Logic
        if (discount < 10) {
          _offerScore = 'Low Engagement';
        } else if (discount < 40) {
          _offerScore = 'Good Engagement';
        } else {
          _offerScore = 'High Engagement 🔥';
        }
        
        _updateCampaignStrength();
      });
    } else {
      setState(() {
        _calculatedDiscount = 0;
        _customerSaves = 0;
        _offerScore = '';
      });
    }
  }

  // 🔥 Campaign Strength Meter
  void _updateCampaignStrength() {
    double strength = 0;
    
    // Discount size (0-25 points)
    if (_calculatedDiscount > 0) {
      strength += (_calculatedDiscount / 100) * 25;
      if (strength > 25) strength = 25;
    }
    
    // Description length (0-25 points)
    if (_descriptionLength > 0) {
      strength += (_descriptionLength / 300) * 25;
      if (strength > 50) strength = 50;
    }
    
    // Image count (0-25 points)
    strength += (_selectedImages.length / 5) * 25;
    
    // Offer type selected (0-25 points)
    if (_selectedOfferType != null) {
      if (_selectedOfferType == OfferType.FLASH || _selectedOfferType == OfferType.LIMITED) {
        strength += 25; // Urgency types get full points
      } else {
        strength += 15; // Normal types get less
      }
    }
    
    setState(() {
      _campaignStrength = strength > 100 ? 100 : strength;
    });
  }

  // 🔥 Pick Multiple Images (Max 5)
  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      _showError('Maximum 5 images allowed');
      return;
    }
    
    final List<XFile> images = await _picker.pickMultiImage();
    
    if (images.isNotEmpty) {
      final int available = 5 - _selectedImages.length;
      final List<XFile> toAdd = images.take(available).toList();
      
      setState(() {
        _selectedImages.addAll(toAdd);
        _updateCampaignStrength();
      });
      
      if (images.length > available) {
        _showError('Added $available images. Maximum 5 total.');
      }
    }
  }

  // 🔥 Remove Image
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
      _updateCampaignStrength();
    });
  }

  // 🔥 Launch Campaign (Submit)
  Future<void> _launchCampaign() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Please fill all required fields');
      return;
    }

    if (_selectedImages.isEmpty) {
      _showError('Please add at least 1 image');
      return;
    }

    if (_expiryDate == null) {
      _showError('Please select an expiry date');
      return;
    }

    if (_selectedSubcategoryId == null) {
      _showError('Please select a category and subcategory');
      return;
    }

    if (_selectedOfferType == null) {
      _showError('Please select an offer type');
      return;
    }

    if (_selectedCityId == null || _selectedArea == null) {
      _showError('Please select city and area');
      return;
    }

    // Type-specific validation
    if (_selectedOfferType == OfferType.PERCENTAGE || _selectedOfferType == OfferType.FIXED) {
      final original = double.tryParse(_originalPriceController.text);
      final discounted = double.tryParse(_discountedPriceController.text);
      
      if (original == null || discounted == null || discounted >= original) {
        _showError('Please enter valid prices');
        return;
      }
    }

    if (_selectedOfferType == OfferType.LIMITED) {
      final maxClaims = int.tryParse(_maxClaimsController.text);
      if (maxClaims == null || maxClaims <= 0) {
        _showError('Limited offers require Max Claims');
        return;
      }
    }

    if (_selectedOfferType == OfferType.FLASH) {
      if (_validFrom == null || _validUntil == null) {
        _showError('Flash deals require start and end time');
        return;
      }
      if (_validUntil!.isBefore(_validFrom!)) {
        _showError('End time must be after start time');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Upload images
      final imageUploadService = ref.read(imageUploadServiceProvider);
      final imageUrls = <String>[];
      
      for (final image in _selectedImages) {
        final url = await imageUploadService.uploadImage(File(image.path));
        imageUrls.add(url);
      }

      // Prepare offer data
      final offerData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'subcategoryId': _selectedSubcategoryId,
        'offerType': _selectedOfferType!.name,
        'imageUrls': imageUrls,
        'expiryDate': _expiryDate!.toIso8601String(),
        'areaId': _selectedArea!.id,
        'inStock': _inStock,
      };

      // Add pricing based on offer type
      if (_selectedOfferType == OfferType.PERCENTAGE) {
        offerData['original Price'] = double.parse(_originalPriceController.text);
        offerData['discountPercentage'] = _calculatedDiscount.toInt();
      } else if (_selectedOfferType == OfferType.FIXED) {
        offerData['originalPrice'] = double.parse(_originalPriceController.text);
        offerData['discountedPrice'] = double.parse(_discountedPriceController.text);
      }

      // Add optional fields
      if (_selectedOfferType == OfferType.LIMITED) {
        offerData['maxClaims'] = int.parse(_maxClaimsController.text);
      }

      if (_selectedOfferType == OfferType.FLASH) {
        offerData['validFrom'] = _validFrom!.toIso8601String();
        offerData['validUntil'] = _validUntil!.toIso8601String();
      }

      if (_whatsappController.text.trim().isNotEmpty) {
        offerData['whatsappNumber'] = _whatsappController.text.trim();
      }

      if (_termsController.text.trim().isNotEmpty) {
        offerData['terms'] = _termsController.text.trim();
      }

      // Create offer
      final shopService = ref.read(shopServiceProvider);
      await shopService.createOffer(
        title: offerData['title'] as String,
        description: offerData['description'] as String,
        originalPrice: (offerData['originalPrice'] ?? offerData['original Price']) as double,
        discountedPrice: offerData['discountedPrice'] != null 
          ? offerData['discountedPrice'] as double
          : ((offerData['originalPrice'] ?? offerData['original Price']) as double) * (1 - ((offerData['discountPercentage'] ?? 0) as int) / 100),
        imageUrl: (offerData['imageUrls'] as List).first as String,
        expiryDate: DateTime.parse(offerData['expiryDate'] as String),
        subcategoryId: offerData['subcategoryId'] as String,
        offerType: offerData['offerType'] as String,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🚀 Campaign Launched Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚀 Create New Campaign'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Campaign Strength Meter
            _buildCampaignStrengthMeter(),
            const SizedBox(height: 24),
            
            // 1️⃣ Campaign Identity
            _buildSectionHeader('1️⃣ Campaign Identity'),
            const SizedBox(height: 12),
            _buildCampaignIdentity(),
            const SizedBox(height: 24),
            
            // 2️⃣ Smart Pricing Engine
            _buildSectionHeader('2️⃣ Smart Pricing Engine'),
            const SizedBox(height: 12),
            _buildSmartPricingEngine(),
            const SizedBox(height: 24),
            
            // 3️⃣ Offer Type (Campaign Mode)
            _buildSectionHeader('3️⃣ Campaign Type'),
            const SizedBox(height: 12),
            _buildOfferTypeSelector(),
            const SizedBox(height: 24),
            
            // 4️⃣ Location Targeting
            _buildSectionHeader('4️⃣ Location Targeting'),
            const SizedBox(height: 12),
            _buildLocationTargeting(),
            const SizedBox(height: 24),
            
            // 5️⃣ Category Engine
            _buildSectionHeader('5️⃣ Category Engine'),
            const SizedBox(height: 12),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            
            // 6️⃣ Visual Gallery
            _buildSectionHeader('6️⃣ Visual Gallery (Max 5 Images)'),
            const SizedBox(height: 12),
            _buildVisualGallery(),
            const SizedBox(height: 24),
            
            // 7️⃣ Contact Layer
            _buildSectionHeader('7️⃣ Contact Layer'),
            const SizedBox(height: 12),
            _buildContactLayer(),
            const SizedBox(height: 24),
            
            // 8️⃣ Terms & Conditions
            _buildSectionHeader('8️⃣ Terms & Conditions (Optional)'),
            const SizedBox(height: 12),
            _buildTermsSection(),
            const SizedBox(height: 24),
            
            // 9️⃣ Sponsored Boost (Upsell)
            _buildSectionHeader('9️⃣ Want More Visibility? (Optional)'),
            const SizedBox(height: 12),
            _buildSponsoredBoost(),
            const SizedBox(height: 32),
            
            // 🚀 Launch Button
            _buildLaunchButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 🔥 Campaign Strength Meter
  Widget _buildCampaignStrengthMeter() {
    Color strengthColor;
    String strengthLabel;
    
    if (_campaignStrength < 30) {
      strengthColor = Colors.red;
      strengthLabel = 'Weak';
    } else if (_campaignStrength < 70) {
      strengthColor = Colors.orange;
      strengthLabel = 'Good';
    } else {
      strengthColor = Colors.green;
      strengthLabel = 'Strong';
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [strengthColor.withOpacity(0.1), strengthColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: strengthColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Campaign Strength',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Text(
                strengthLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: strengthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _campaignStrength / 100,
              minHeight: 10,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on: Discount size, Description, Images, Offer type',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // 🔥 Section Header
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // 1️⃣ Campaign Identity
  Widget _buildCampaignIdentity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        TextFormField(
          controller: _titleController,
          maxLength: 100,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          decoration: const InputDecoration(
            labelText: '🏷️ Campaign Title *',
            helperText: 'Clear, short, benefit-driven headline',
            border: OutlineInputBorder(),
            counterText: '',
          ),
          validator: (value) {
            if (value == null || value.trim().length < 5) {
              return 'Title must be at least 5 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Live Preview Card
        if (_titleController.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Live Preview:',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  _titleController.text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedCityName ?? 'City'} • ${_selectedArea?.name ?? 'Area'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        
        // Description
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          maxLength: 300,
          decoration: InputDecoration(
            labelText: '📝 Description *',
            helperText: 'Mention brand, urgency, and stock',
            border: const OutlineInputBorder(),
            counterText: '$_descriptionLength / 300 characters',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Description is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '💡 Tips: • Mention brand • Highlight urgency • Note stock availability',
            style: TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // 2️⃣ Smart Pricing Engine
  Widget _buildSmartPricingEngine() {
    final showPricing = _selectedOfferType == OfferType.PERCENTAGE || 
                        _selectedOfferType == OfferType.FIXED;
    
    if (!showPricing) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '💡 Select PERCENTAGE or FIXED offer type to configure pricing',
          style: TextStyle(fontSize: 13),
        ),
      );
    }
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _originalPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Original Price (JD) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (showPricing) {
                    final price = double.tryParse(value ?? '');
                    if (price == null || price <= 0) {
                      return 'Required';
                    }
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _discountedPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Discounted Price (JD) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_offer),
                ),
                validator: (value) {
                  if (showPricing) {
                    final price = double.tryParse(value ?? '');
                    if (price == null || price <= 0) {
                      return 'Required';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Live Calculation Box
        if (_calculatedDiscount > 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _calculatedDiscount < 10 ? Colors.orange[100]! : 
                  _calculatedDiscount > 40 ? Colors.green[100]! : Colors.blue[100]!,
                  Colors.white,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _calculatedDiscount < 10 ? Colors.orange : 
                       _calculatedDiscount > 40 ? Colors.green : Colors.blue,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "You're offering:",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      '${_calculatedDiscount.toStringAsFixed(0)}% OFF 🔥',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Customer saves:'),
                    Text(
                      '${_customerSaves.toStringAsFixed(2)} JD',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Offer Score:'),
                    Text(
                      _offerScore,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _calculatedDiscount < 10 ? Colors.orange :
                               _calculatedDiscount > 40 ? Colors.green : Colors.blue,
                      ),
                    ),
                  ],
                ),
                if (_calculatedDiscount < 10)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '⚠️ Warning: Discount below 10% may have low engagement',
                      style: TextStyle(fontSize: 11, color: Colors.orange),
                    ),
                  ),
                if (_calculatedDiscount > 40)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      '🎯 High Attraction! This will get noticed.',
                      style: TextStyle(fontSize: 11, color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  // 3️⃣ Offer Type Selector (Interactive Cards)
  Widget _buildOfferTypeSelector() {
    return Column(
      children: [
        _buildOfferTypeCard(
          type: OfferType.PERCENTAGE,
          icon: Icons.percent,
          title: 'PERCENTAGE',
          subtitle: 'Standard discount offer',
        ),
        const SizedBox(height: 12),
        _buildOfferTypeCard(
          type: OfferType.FIXED,
          icon: Icons.local_offer,
          title: 'FIXED PRICE',
          subtitle: 'Set specific prices',
        ),
        const SizedBox(height: 12),
        _buildOfferTypeCard(
          type: OfferType.FLASH,
          icon: Icons.flash_on,
          title: '⚡ FLASH DEAL',
          subtitle: 'Short-time promotion with countdown',
          requiresTimeRange: true,
        ),
        const SizedBox(height: 12),
        _buildOfferTypeCard(
          type: OfferType.LIMITED,
          icon: Icons.trending_up,
          title: '🔥 LIMITED STOCK',
          subtitle: 'Limited quantity available',
          requiresMaxClaims: true,
        ),
        const SizedBox(height: 12),
        _buildOfferTypeCard(
          type: OfferType.BOGO,
          icon: Icons.redeem,
          title: 'BOGO',
          subtitle: 'Buy One Get One',
        ),
        const SizedBox(height: 12),
        _buildOfferTypeCard(
          type: OfferType.BUNDLE,
          icon: Icons.card_giftcard,
          title: 'BUNDLE',
          subtitle: 'Package deal',
        ),
        const SizedBox(height: 12),
        _buildOfferTypeCard(
          type: OfferType.MYSTERY,
          icon: Icons.help_outline,
          title: 'MYSTERY',
          subtitle: 'Surprise offer',
        ),
        const SizedBox(height: 12),
        _buildOfferTypeCard(
          type: OfferType.EXCLUSIVE,
          icon: Icons.star,
          title: 'EXCLUSIVE',
          subtitle: 'Special members only',
        ),
      ],
    );
  }

  Widget _buildOfferTypeCard({
    required OfferType type,
    required IconData icon,
    required String title,
    required String subtitle,
    bool requiresTimeRange = false,
    bool requiresMaxClaims = false,
  }) {
    final isSelected = _selectedOfferType == type;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOfferType = type;
          _updateCampaignStrength();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
            
            // Flash Deal Time Range
            if (isSelected && requiresTimeRange) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                '⚡ Configure Flash Deal Timing',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _validFrom = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _validFrom == null
                            ? 'Start Time'
                            : DateFormat('MMM d, HH:mm').format(_validFrom!),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _validUntil = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _validUntil == null
                            ? 'End Time'
                            : DateFormat('MMM d, HH:mm').format(_validUntil!),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '📍 Customers will see countdown timer',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
            
            // Limited Stock Max Claims
            if (isSelected && requiresMaxClaims) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                '🔥 Set Inventory Limit',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _maxClaimsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Claims *',
                  hintText: 'e.g., 25',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '📍 "Only ${_maxClaimsController.text.isEmpty ? 'X' : _maxClaimsController.text} customers can claim this"',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              const SizedBox(height: 4),
              const Text(
                '🎯 Urgency engine activated',
                style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 4️⃣ Location Targeting
  Widget _buildLocationTargeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'City *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_city),
          ),
          initialValue: _selectedCityId,
          items: _cities.map((city) {
            return DropdownMenuItem(
              value: city.id,
              child: Text(city.name),
            );
          }).toList(),
          onChanged: _loadingCities
              ? null
              : (cityId) async {
                  final city = _cities.firstWhere((c) => c.id == cityId);
                  setState(() {
                    _selectedCityId = cityId;
                    _selectedCityName = city.name;
                    _selectedArea = null;
                    _areas = [];
                  });
                  if (cityId != null) {
                    await _fetchAreas(cityId);
                  }
                },
          validator: (value) {
            if (value == null) return 'Please select a city';
            return null;
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Area *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.place),
          ),
          initialValue: _selectedArea?.id,
          items: _areas.map((area) {
            return DropdownMenuItem(
              value: area.id,
              child: Text(area.name),
            );
          }).toList(),
          onChanged: _loadingAreas
              ? null
              : (areaId) {
                  setState(() {
                    _selectedArea = _areas.firstWhere((a) => a.id == areaId);
                  });
                },
          validator: (value) {
            if (value == null) return 'Please select an area';
            return null;
          },
        ),
        const SizedBox(height: 12),
        if (_selectedCityId != null && _selectedArea != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.visibility, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Visible in: $_selectedCityName → ${_selectedArea!.name}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.radar, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '🎯 Radius Targeting (optional)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Target customers within a specific distance from your shop',
                style: TextStyle(fontSize: 11, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('1 km'),
                    selected: _selectedRadiusKm == 1,
                    onSelected: (selected) {
                      setState(() => _selectedRadiusKm = selected ? 1 : null);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('3 km'),
                    selected: _selectedRadiusKm == 3,
                    onSelected: (selected) {
                      setState(() => _selectedRadiusKm = selected ? 3 : null);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('5 km'),
                    selected: _selectedRadiusKm == 5,
                    onSelected: (selected) {
                      setState(() => _selectedRadiusKm = selected ? 5 : null);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('10 km'),
                    selected: _selectedRadiusKm == 10,
                    onSelected: (selected) {
                      setState(() => _selectedRadiusKm = selected ? 10 : null);
                    },
                  ),
                  ChoiceChip(
                    label: const Text('City-wide'),
                    selected: _selectedRadiusKm == null,
                    onSelected: (selected) {
                      setState(() => _selectedRadiusKm = null);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5️⃣ Category Engine
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer(
          builder: (context, ref, child) {
            final categoriesAsync = ref.watch(categoriesProvider);
            return categoriesAsync.when(
              data: (categories) {
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Category *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      initialValue: _selectedCategoryId,
                      items: categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (categoryId) {
                        setState(() {
                          _selectedCategoryId = categoryId;
                          _selectedSubcategoryId = null;
                        });
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a category';
                        return null;
                      },
                    ),
                    if (_selectedCategoryId != null) ...[
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final selectedCategory = categories.firstWhere(
                            (c) => c.id == _selectedCategoryId,
                          );
                          return DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Subcategory *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.subdirectory_arrow_right),
                            ),
                            initialValue: _selectedSubcategoryId,
                            items: selectedCategory.subcategories
                                .map((sub) => DropdownMenuItem(
                                      value: sub.id,
                                      child: Text(sub.name),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSubcategoryId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null) return 'Please select a subcategory';
                              return null;
                            },
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Failed to load categories: $error'),
            );
          },
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'ℹ️ This helps your offer appear in the right feed',
            style: TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // 6️⃣ Visual Gallery (Multi-Image)
  Widget _buildVisualGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Images Grid
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_selectedImages[index].path),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Cover',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        const SizedBox(height: 12),
        
        // Add Images Button
        OutlinedButton.icon(
          onPressed: _selectedImages.length < 5 ? _pickImages : null,
          icon: const Icon(Icons.add_photo_alternate),
          label: Text(
            _selectedImages.isEmpty
                ? 'Add Images (Minimum 1) *'
                : 'Add More Images (${_selectedImages.length}/5)',
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 8),
        
        // Rules & Hints
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📸 Gallery Rules:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                '• Minimum: 1 image (required)',
                style: TextStyle(fontSize: 11),
              ),
              const Text(
                '• Maximum: 5 images',
                style: TextStyle(fontSize: 11),
              ),
              const Text(
                '• First image = Cover Image',
                style: TextStyle(fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                '🔜 Hold to reorder (coming soon)',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7️⃣ Contact Layer
  Widget _buildContactLayer() {
    return Column(
      children: [
        TextFormField(
          controller: _whatsappController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'WhatsApp Number (Optional)',
            hintText: '+962 XX XXX XXXX',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: _showWhatsAppButton,
          onChanged: (value) {
            setState(() {
              _showWhatsAppButton = value;
            });
          },
          title: const Text('Show WhatsApp Chat Button on Offer Page'),
          subtitle: const Text('Allow customers to contact you directly'),
          activeThumbColor: AppColors.primary,
        ),
      ],
    );
  }

  // 8️⃣ Terms & Conditions
  Widget _buildTermsSection() {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Terms & Conditions'),
          trailing: Icon(
            _termsExpanded ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            setState(() {
              _termsExpanded = !_termsExpanded;
            });
          },
        ),
        if (_termsExpanded)
          TextFormField(
            controller: _termsController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter terms and conditions here...',
              border: OutlineInputBorder(),
            ),
          ),
      ],
    );
  }

  // 9️⃣ Sponsored Boost (Upsell)
  Widget _buildSponsoredBoost() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[50]!, Colors.white],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚀 Want More Visibility?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Boost your campaign to appear at the top of feeds',
            style: TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          
          // Boost Options
          Column(
            children: [
              _buildBoostOption(
                'Feed Boost - 3 Days',
                '5 JD',
                'feed',
                '3',
              ),
              const Divider(height: 1),
              _buildBoostOption(
                'Feed Boost - 7 Days',
                '8 JD',
                'feed',
                '7',
              ),
              const Divider(height: 1),
              _buildBoostOption(
                'Slider Boost - 3 Days',
                '8 JD',
                'slider',
                '3',
              ),
              const Divider(height: 1),
              _buildBoostOption(
                'Slider Boost - 7 Days',
                '12 JD',
                'slider',
                '7',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '💡 You can boost after creating the campaign',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // 🔥 Launch Button
  Widget _buildLaunchButton() {
    // Expiry Date Picker
    return Column(
      children: [
        // Expiry Date
        OutlinedButton.icon(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now().add(const Duration(days: 7)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _expiryDate = date;
              });
            }
          },
          icon: const Icon(Icons.calendar_today),
          label: Text(
            _expiryDate == null
                ? 'Select Expiry Date *'
                : 'Expires: ${DateFormat('MMM d, yyyy').format(_expiryDate!)}',
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 16),
        
        // Launch Button
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _launchCampaign,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch, size: 24),
                      SizedBox(width: 8),
                      Text(
                        '🚀 Launch Campaign',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoostOption(String title, String price, String type, String duration) {
    final isSelected = _wantsBoost && _boostType == type && _boostDuration == duration;
    
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            // Deselect
            _wantsBoost = false;
            _boostType = null;
            _boostDuration = null;
          } else {
            // Select
            _wantsBoost = true;
            _boostType = type;
            _boostDuration = duration;
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? AppColors.primary : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
