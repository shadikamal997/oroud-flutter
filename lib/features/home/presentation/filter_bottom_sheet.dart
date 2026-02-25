import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/services/city_service.dart';
import '../../../shared/services/area_service.dart';
import '../../../shared/models/city_model.dart';
import '../../../shared/models/area_model.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  final Function(int?, String?, bool, String?, String?, double?, double?, bool, bool, String?) onApply;
  final int? initialDiscount;
  final String? initialCategory;
  final bool initialPremium;
  final String? initialCityId;
  final String? initialAreaId;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final bool initialEndingSoon;
  final bool initialVerifiedOnly;
  final String? initialSortBy;

  const FilterBottomSheet({
    super.key,
    required this.onApply,
    this.initialDiscount,
    this.initialCategory,
    this.initialPremium = false,
    this.initialCityId,
    this.initialAreaId,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialEndingSoon = false,
    this.initialVerifiedOnly = false,
    this.initialSortBy,
  });

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late double _discount;
  String? _category;
  late bool _premiumOnly;
  late bool _endingSoon;
  late bool _verifiedOnly;
  String? _selectedCityId;
  String? _selectedAreaId;
  late double _minPrice;
  late double _maxPrice;
  String? _sortBy;
  List<City> _cities = [];
  List<Area> _areas = [];
  bool _loadingCities = true;
  bool _loadingAreas = false;

  final categories = [
    "Clothing",
    "Electronics",
    "Restaurants",
    "Cafes",
    "Beauty",
    "Home",
  ];

  final sortOptions = [
    {"value": "newest", "label": "Newest First"},
    {"value": "popular", "label": "Most Popular"},
    {"value": "endingSoon", "label": "Ending Soon"},
    {"value": "highestDiscount", "label": "Highest Discount"},
  ];

  @override
  void initState() {
    super.initState();
    _discount = widget.initialDiscount?.toDouble() ?? 0;
    _category = widget.initialCategory;
    _premiumOnly = widget.initialPremium;
    _endingSoon = widget.initialEndingSoon;
    _verifiedOnly = widget.initialVerifiedOnly;
    _selectedCityId = widget.initialCityId;
    _selectedAreaId = widget.initialAreaId;
    _minPrice = widget.initialMinPrice ?? 0;
    _maxPrice = widget.initialMaxPrice ?? 1000;
    _sortBy = widget.initialSortBy;
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cityService = ref.read(cityServiceProvider);
      final cities = await cityService.getCities();
      setState(() {
        _cities = cities;
        _loadingCities = false;
      });
      
      // If there's a selected city, load its areas
      if (_selectedCityId != null) {
        _loadAreas(_selectedCityId!);
      }
    } catch (e) {
      setState(() {
        _loadingCities = false;
      });
    }
  }

  Future<void> _loadAreas(String cityId) async {
    setState(() {
      _loadingAreas = true;
      _selectedAreaId = null; // Reset area when city changes
    });

    try {
      final areaService = ref.read(areaServiceProvider);
      final areas = await areaService.getAreasByCity(cityId);
      setState(() {
        _areas = areas;
        _loadingAreas = false;
      });
    } catch (e) {
      setState(() {
        _areas = [];
        _loadingAreas = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fixed Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filters",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _discount = 0;
                      _category = null;
                      _premiumOnly = false;
                      _endingSoon = false;
                      _verifiedOnly = false;
                      _selectedCityId = null;
                      _selectedAreaId = null;
                      _minPrice = 0;
                      _maxPrice = 1000;
                      _areas = [];
                    });
                  },
                  child: const Text("Clear All"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Scrollable Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

          // City Dropdown
          const Text(
            "City",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _loadingCities
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text("Loading cities..."),
                      ],
                    ),
                  )
                : DropdownButton<String>(
                    value: _selectedCityId,
                    hint: const Text("Select City"),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _cities
                        .map(
                          (city) => DropdownMenuItem(
                            value: city.id,
                            child: Text(city.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCityId = value;
                      });
                      if (value != null) {
                        _loadAreas(value);
                      } else {
                        setState(() {
                          _areas = [];
                          _selectedAreaId = null;
                        });
                      }
                    },
                  ),
          ),

          const SizedBox(height: 20),

          // Area Dropdown (only show if city is selected)
          if (_selectedCityId != null) ...[
            const Text(
              "Area",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _loadingAreas
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text("Loading areas..."),
                        ],
                      ),
                    )
                  : DropdownButton<String>(
                      value: _selectedAreaId,
                      hint: const Text("Select Area (Optional)"),
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _areas
                          .map(
                            (area) => DropdownMenuItem(
                              value: area.id,
                              child: Text(area.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAreaId = value;
                        });
                      },
                    ),
            ),
            const SizedBox(height: 20),
          ],

          // Discount Slider
          const Text(
            "Minimum Discount",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _discount,
                  min: 0,
                  max: 80,
                  divisions: 8,
                  label: "${_discount.toInt()}%",
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() {
                      _discount = value;
                    });
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: Text(
                  "${_discount.toInt()}%",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Category Dropdown
          const Text(
            "Category",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _category,
              hint: const Text("Select Category"),
              isExpanded: true,
              underline: const SizedBox(),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // Premium Toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text("Premium Shops Only"),
              subtitle: const Text("Verified shops with high trust score"),
              value: _premiumOnly,
              activeThumbColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _premiumOnly = value;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Verified Shops Toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text("Verified Shops Only"),
              subtitle: const Text("Show only verified businesses"),
              value: _verifiedOnly,
              activeThumbColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _verifiedOnly = value;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Ending Soon Toggle
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SwitchListTile(
              title: const Text("Ending Soon"),
              subtitle: const Text("Offers ending within 48 hours"),
              value: _endingSoon,
              activeThumbColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  _endingSoon = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),

          // Price Range
          const Text(
            "Price Range (JD)",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Min", style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_minPrice.toInt()} JD",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Max", style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_maxPrice.toInt()} JD",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 1000,
            divisions: 20,
            activeColor: AppColors.primary,
            labels: RangeLabels(
              "${_minPrice.toInt()} JD",
              "${_maxPrice.toInt()} JD",
            ),
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),

          const SizedBox(height: 24),

          // Sort Options
          const Text(
            "Sort By",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sortOptions.map((option) {
              final isSelected = _sortBy == option["value"];
              return ChoiceChip(
                label: Text(option["label"] as String),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _sortBy = selected ? option["value"] as String : null;
                  });
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Fixed Apply Button at Bottom
          Container(
            padding: EdgeInsets.fromLTRB(
              20, 
              12, 
              20, 
              MediaQuery.of(context).viewInsets.bottom + 20
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _discount.toInt() > 0 ? _discount.toInt() : null,
                    _category,
                    _premiumOnly,
                    _selectedCityId,
                    _selectedAreaId,
                    _minPrice > 0 ? _minPrice : null,
                    _maxPrice < 1000 ? _maxPrice : null,
                    _endingSoon,
                    _verifiedOnly,
                    _sortBy,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Apply Filters",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
