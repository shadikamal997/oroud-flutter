import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

class DiscountBadge extends StatelessWidget {
  final double percentage;

  const DiscountBadge({super.key, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentRed,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "-${percentage.toInt()}%",
        style: AppTextStyles.discount,
      ),
    );
  }
}
