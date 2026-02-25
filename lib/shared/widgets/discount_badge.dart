import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';

enum DiscountBadgeSize { regular, small }

class DiscountBadge extends StatelessWidget {
  final double? percentage; // 🔥 Now nullable
  final DiscountBadgeSize size;

  const DiscountBadge({
    super.key,
    this.percentage, // Optional
    this.size = DiscountBadgeSize.regular,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = size == DiscountBadgeSize.small;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 6 : 10,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
      ),
      child: Text(
        "-${(percentage ?? 0).toInt()}%", // 🔥 Handle null
        style: isSmall
            ? AppTextStyles.discount.copyWith(fontSize: 11)
            : AppTextStyles.discount,
      ),
    );
  }
}
