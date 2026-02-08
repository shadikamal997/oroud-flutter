/// Environment configuration for Oroud app
class Env {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:3000/api';
  
  // For production, use your deployed backend URL:
  // static const String apiBaseUrl = 'https://api.oroud.com/api';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Firebase configuration (to be filled later)
  static const String firebaseProjectId = '';
  
  // AdMob IDs (to be filled with your AdMob account)
  static const String androidBannerAdUnitId = '';
  static const String iosBannerAdUnitId = '';
  
  // Feature flags
  static const bool enableAds = true;
  static const bool enablePushNotifications = true;
  
  // App metadata
  static const String appName = 'Oroud';
  static const String appVersion = '1.0.0';
}
