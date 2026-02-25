import 'package:flutter/material.dart';
import 'package:oroud_app/core/theme/app_colors.dart';

/// Consistent colors used throughout shop dashboard
class ShopColors {
  static const primary = AppColors.primary; // Orange
  static const secondary = Color(0xFFE91E63); // Pink
  static const success = Color(0xFF4CAF50); // Green
  static const error = Color(0xFFF44336); // Red
  static const warning = Color(0xFFFF9800); // Amber
  static const info = Color(0xFF2196F3); // Blue

  // Semantic colors
  static const activeColor = Color(0xFF4CAF50);
  static const expiredColor = Color(0xFF9E9E9E);
  static const inactiveColor = Color(0xFFFF9800);
  static const premiumColor = Color(0xFFFFD700);
}

/// Consistent text styles
class ShopTextStyles {
  static const heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  static const subheading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}

/// Consistent spacing values
class ShopSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

/// Consistent border radius values
class ShopBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  
  static BorderRadius get smallRadius => BorderRadius.circular(sm);
  static BorderRadius get mediumRadius => BorderRadius.circular(md);
  static BorderRadius get largeRadius => BorderRadius.circular(lg);
  static BorderRadius get extraLargeRadius => BorderRadius.circular(xl);
}

/// Consistent card decoration
class ShopCardDecoration {
  static BoxDecoration get standard => BoxDecoration(
        color: Colors.white,
        borderRadius: ShopBorderRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get elevated => BoxDecoration(
        color: Colors.white,
        borderRadius: ShopBorderRadius.mediumRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get premium => BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ShopColors.premiumColor.withOpacity(0.2),
            ShopColors.premiumColor.withOpacity(0.05),
          ],
        ),
        borderRadius: ShopBorderRadius.mediumRadius,
        border: Border.all(
          color: ShopColors.premiumColor.withOpacity(0.3),
          width: 2,
        ),
      );
}

/// Consistent button styles
class ShopButtonStyle {
  static ButtonStyle get primary => ElevatedButton.styleFrom(
        backgroundColor: ShopColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: ShopSpacing.lg,
          vertical: ShopSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: ShopBorderRadius.mediumRadius,
        ),
        elevation: 2,
      );

  static ButtonStyle get secondary => ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(
          horizontal: ShopSpacing.lg,
          vertical: ShopSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: ShopBorderRadius.mediumRadius,
        ),
        elevation: 0,
      );

  static ButtonStyle get outlined => OutlinedButton.styleFrom(
        foregroundColor: ShopColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: ShopSpacing.lg,
          vertical: ShopSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: ShopBorderRadius.mediumRadius,
        ),
        side: const BorderSide(color: ShopColors.primary, width: 2),
      );
}

/// Icon sizes
class ShopIconSizes {
  static const double sm = 16.0;
  static const double md = 24.0;
  static const double lg = 32.0;
  static const double xl = 48.0;
}

/// Common durations for animations
class ShopAnimationDurations {
  static const fast = Duration(milliseconds: 200);
  static const normal = Duration(milliseconds: 300);
  static const slow = Duration(milliseconds: 500);
}
