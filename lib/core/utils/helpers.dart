import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Helper utility functions
class Helpers {
  /// Format date to readable string
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }
  
  /// Format expiry countdown
  static String formatExpiryCountdown(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    
    if (difference.isNegative) {
      return 'Expired';
    }
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Expires soon';
    }
  }
  
  /// Format discount percentage
  static String formatDiscount(double percentage) {
    return '${percentage.toStringAsFixed(0)}% OFF';
  }
  
  /// Format large numbers with K/M suffix
  static String formatCount(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }
  
  /// Calculate distance string
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).toStringAsFixed(0)}m away';
    } else {
      return '${distanceInKm.toStringAsFixed(1)}km away';
    }
  }
  
  /// Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Validate phone number (simple validation)
  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{7,14}$');
    return phoneRegex.hasMatch(phone);
  }
  
  /// Check if device has small screen (< 360px width)
  /// Used for responsive font scaling on small devices (iPhone SE, old Android)
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
  
  /// Get responsive font size that scales down on small screens
  /// Example: responsiveFontSize(context, 24, 20) → 24 on normal, 20 on small
  static double responsiveFontSize(BuildContext context, double normalSize, double smallSize) {
    return isSmallScreen(context) ? smallSize : normalSize;
  }
}
