import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Notifier for managing app locale (language)
class LocaleNotifier extends Notifier<Locale?> {
  static const _languageKey = 'language_code';
  static const _languageSelectedKey = 'language_selected';
  bool _isInitialized = false;

  @override
  Locale? build() {
    _loadSavedLocale();
    return null;
  }

  Future<void> _loadSavedLocale() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_languageKey);
    if (savedLang != null) {
      state = Locale(savedLang);
    }
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    await prefs.setBool(_languageSelectedKey, true);
    state = locale;
  }

  bool get isArabic => state?.languageCode == 'ar';
  bool get isEnglish => state?.languageCode == 'en';
}

/// Provider for managing app locale
final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(() {
  return LocaleNotifier();
});

/// Helper class for locale management (for non-Riverpod contexts)
class LocaleHelper {
  static const _languageKey = 'language_code';
  static const _languageSelectedKey = 'language_selected';
  
  /// Load saved locale from SharedPreferences
  static Future<Locale?> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_languageKey);
    if (savedLang != null) {
      return Locale(savedLang);
    }
    return null;
  }
  
  /// Save locale to SharedPreferences
  static Future<void> saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, locale.languageCode);
    await prefs.setBool(_languageSelectedKey, true);
  }
  
  /// Check if a locale is Arabic
  static bool isArabic(Locale? locale) => locale?.languageCode == 'ar';
  
  /// Check if a locale is English
  static bool isEnglish(Locale? locale) => locale?.languageCode == 'en';
}
