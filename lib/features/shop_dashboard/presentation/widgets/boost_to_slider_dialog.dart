import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/api_config.dart';

/// Boost to Premium Slider Dialog
/// Shows 3 package options: 2-day, 3-day, 7-day
class BoostToSliderDialog extends ConsumerStatefulWidget {
  final String offerId;
  final String offerTitle;

  const BoostToSliderDialog({
    super.key,
    required this.offerId,
    required this.offerTitle,
  });

  @override
  ConsumerState<BoostToSliderDialog> createState() => _BoostToSliderDialogState();
}

class _BoostToSliderDialogState extends ConsumerState<BoostToSliderDialog> {
  String? _selectedPackage;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _packages = [
    {
      'type': 'TWO_DAYS',
      'name': '2-Day Package',
      'price': 3,
      'impressions': 1000,
      'days': 2,
      'color': Colors.blue[600],
      'icon': Icons.flash_on,
    },
    {
      'type': 'THREE_DAYS',
      'name': '3-Day Package',
      'price': 5,
      'impressions': 1500,
      'days': 3,
      'color': Colors.orange[600],
      'icon': Icons.trending_up,
    },
    {
      'type': 'SEVEN_DAYS',
      'name': '7-Day Package',
      'price': 9,
      'impressions': 3500,
      'days': 7,
      'color': Colors.purple[600],
      'icon': Icons.diamond,
      'recommended': true,
    },
  ];

  Future<void> _purchasePackage() async {
    if (_selectedPackage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a package')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'access_token');

      if (token == null) {
        throw Exception('Not authenticated');
      }

      final dio = Dio();
      final response = await dio.post(
        '${ApiConfig.baseUrl}/offers/${widget.offerId}/purchase-slider',
        data: {
          'packageType': _selectedPackage,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        
        Navigator.of(context).pop(true); // Return true to indicate success
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${response.data['message'] ?? 'Boost activated successfully!'}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Failed to activate boost';
      
      if (e is DioException) {
        if (e.response?.data != null) {
          errorMessage = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMessage;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[600]!, Colors.orange[800]!],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Boost to Premium Slider',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.offerTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Info Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Get guaranteed impressions on the home screen premium slider',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Package Selection
            const Text(
              'Select a Package',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            ..._packages.map((package) => _buildPackageCard(package)),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _purchasePackage,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.orange[600],
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                _selectedPackage == null
                                    ? 'Select Package'
                                    : 'Activate Boost',
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    final bool isSelected = _selectedPackage == package['type'];
    final bool isRecommended = package['recommended'] ?? false;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = package['type'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? package['color'].withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? package['color'] : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      package['icon'],
                      color: package['color'],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            package['name'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? package['color'] : Colors.black87,
                            ),
                          ),
                          Text(
                            '${package['days']} days • ${package['impressions']} impressions',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${package['price']} JD',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: package['color'],
                      ),
                    ),
                  ],
                ),
                if (isSelected) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: package['color'].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: package['color'], size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your offer will appear in the premium slider rotation',
                            style: TextStyle(
                              fontSize: 12,
                              color: package['color'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            if (isRecommended)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange[600]!, Colors.orange[800]!],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
