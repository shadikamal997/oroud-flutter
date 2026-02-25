import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  Locale? selectedLocale;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (selectedLocale == null) {
      // Auto-detect device language (default to Arabic for Jordan)
      final deviceLocale = Localizations.localeOf(context);
      selectedLocale = deviceLocale.languageCode == 'ar'
          ? const Locale('ar')
          : const Locale('ar'); // Default to Arabic since this is Jordan-focused app
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = selectedLocale?.languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Icon
              const Icon(
                Icons.language,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                isArabic ? 'اختر لغتك' : 'Choose Your Language',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                isArabic
                    ? 'يمكنك تغيير اللغة في أي وقت من الإعدادات'
                    : 'You can change the language anytime from settings',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 48),

              // English Button
              _buildLanguageButton(
                language: 'English',
                nativeText: 'English',
                flag: '🇬🇧',
                locale: const Locale('en'),
                isSelected: selectedLocale?.languageCode == 'en',
              ),
              const SizedBox(height: 16),

              // Arabic Button
              _buildLanguageButton(
                language: 'العربية',
                nativeText: 'Arabic',
                flag: '🇯🇴',
                locale: const Locale('ar'),
                isSelected: selectedLocale?.languageCode == 'ar',
              ),
              const SizedBox(height: 48),

              // Continue Button
              ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isArabic ? 'استمرار' : 'Continue',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required String language,
    required String nativeText,
    required String flag,
    required Locale locale,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          selectedLocale = locale;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            // Flag
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),

            // Language name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black87,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    nativeText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),

            // Selected indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    if (selectedLocale == null) return;

    // Save locale using the Notifier
    await ref.read(localeProvider.notifier).setLocale(selectedLocale!);

    // Navigate to main app
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }
}
