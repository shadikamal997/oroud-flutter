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
}
