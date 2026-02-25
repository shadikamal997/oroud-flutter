import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/payment_models.dart';
import '../providers/payments_provider.dart';

class PromoteOfferDialog extends ConsumerStatefulWidget {
  final String offerId;
  final String offerTitle;

  const PromoteOfferDialog({
    super.key,
    required this.offerId,
    required this.offerTitle,
  });

  @override
  ConsumerState<PromoteOfferDialog> createState() => _PromoteOfferDialogState();
}

class _PromoteOfferDialogState extends ConsumerState<PromoteOfferDialog> {
  PromotionPlan? _selectedPlan;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.rocket_launch, color: Color(0xFFE91E63)),
          SizedBox(width: 8),
          Text('Promote Offer'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Boost "${widget.offerTitle}" to reach more customers',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ...PromotionPlan.plans.map((plan) => _buildPlanCard(plan)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedPlan == null || _isProcessing
              ? null
              : _handlePromote,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE91E63),
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Continue to Payment'),
        ),
      ],
    );
  }

  Widget _buildPlanCard(PromotionPlan plan) {
    final isSelected = _selectedPlan?.tier == plan.tier;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Card(
        color: isSelected ? const Color(0xFFE91E63).withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFFE91E63)
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<PromotionPlan>(
                value: plan,
                groupValue: _selectedPlan,
                onChanged: (value) => setState(() => _selectedPlan = value),
                activeColor: const Color(0xFFE91E63),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isSelected
                                ? const Color(0xFFE91E63)
                                : Colors.black,
                          ),
                        ),
                        Text(
                          '${plan.price.toStringAsFixed(0)} JOD',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isSelected
                                ? const Color(0xFFE91E63)
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.days} days • ${plan.weight}x boost',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePromote() async {
    if (_selectedPlan == null) return;

    setState(() => _isProcessing = true);

    try {
      final service = ref.read(paymentsServiceProvider);
      final response = await service.promoteOffer(
        widget.offerId,
        _selectedPlan!.tier,
      );

      if (!mounted) return;

      // Close dialog
      Navigator.pop(context);

      // Open payment URL in browser
      final uri = Uri.parse(response.paymentUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complete payment in browser to activate boost'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw Exception('Could not launch payment URL');
      }
    } catch (e) {
      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Helper function to show the dialog
void showPromoteOfferDialog(
  BuildContext context, {
  required String offerId,
  required String offerTitle,
}) {
  showDialog(
    context: context,
    builder: (context) => PromoteOfferDialog(
      offerId: offerId,
      offerTitle: offerTitle,
    ),
  );
}
