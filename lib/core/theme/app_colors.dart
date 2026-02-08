import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFF97316);
  static const Color primaryDark = Color(0xFFEA580C);
  static const Color accentRed = Color(0xFFDC2626);

  static const Color background = Color(0xFFFAFAFA);
  static const Color card = Colors.white;

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color borderLight = Color(0xFFF1F3F5);

  static const LinearGradient headerGradient = LinearGradient(
    colors: [
      Color(0xFFF97316),
      Color(0xFFFB923C),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
