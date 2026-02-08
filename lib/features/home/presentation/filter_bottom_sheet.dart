import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Function(int?, String?, bool) onApply;
  final int? initialDiscount;
  final String? initialCategory;
  final bool initialPremium;

  const FilterBottomSheet({
    super.key,
    required this.onApply,
    this.initialDiscount,
    this.initialCategory,
    this.initialPremium = false,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _discount;
  String? _category;
  late bool _premiumOnly;

  final categories = [
    "Clothing",
    "Electronics",
    "Restaurants",
    "Cafes",
    "Beauty",
    "Home",
  ];

  @override
  void initState() {
    super.initState();
    _discount = widget.initialDiscount?.toDouble() ?? 0;
    _category = widget.initialCategory;
    _premiumOnly = widget.initialPremium;
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
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  });
                },
                child: const Text("Clear All"),
              ),
            ],
          ),
          const SizedBox(height: 20),

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
                  activeColor: const Color(0xFFF97316),
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
              activeColor: const Color(0xFFF97316),
              onChanged: (value) {
                setState(() {
                  _premiumOnly = value;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  _discount.toInt() > 0 ? _discount.toInt() : null,
                  _category,
                  _premiumOnly,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
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
        ],
      ),
    );
  }
}
