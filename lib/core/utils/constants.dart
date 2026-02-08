/// App-wide constants
class Constants {
  // Storage keys
  static const String selectedCityKey = 'selected_city';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String firstLaunchKey = 'first_launch';
  static const String fcmTokenKey = 'fcm_token';
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // UI measurements
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Image dimensions
  static const double offerCardHeight = 180.0;
  static const double shopLogoSize = 48.0;
  static const double crazyDealBannerHeight = 120.0;
  
  // Text limits
  static const int maxOfferTitleLength = 100;
  static const int maxDescriptionLength = 500;
  
  // Error messages
  static const String networkErrorMessage = 'Network error. Please check your connection.';
  static const String serverErrorMessage = 'Server error. Please try again later.';
  static const String unknownErrorMessage = 'An unexpected error occurred.';
}
