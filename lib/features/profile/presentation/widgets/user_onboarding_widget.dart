import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oroud_app/core/theme/app_colors.dart';

/// User onboarding widget with tips and welcome flow
class UserOnboardingWidget extends StatefulWidget {
  final String onboardingKey;
  final List<OnboardingStep> steps;
  final VoidCallback? onComplete;

  const UserOnboardingWidget({
    super.key,
    required this.onboardingKey,
    required this.steps,
    this.onComplete,
  });

  @override
  State<UserOnboardingWidget> createState() => _UserOnboardingWidgetState();
}

class _UserOnboardingWidgetState extends State<UserOnboardingWidget> {
  int _currentStep = 0;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _checkIfCompleted();
  }

  Future<void> _checkIfCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final completed =
        prefs.getBool('onboarding_${widget.onboardingKey}') ?? false;
    if (completed && mounted) {
      setState(() => _isVisible = false);
    }
  }

  Future<void> _markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_${widget.onboardingKey}', true);
    if (mounted) {
      setState(() => _isVisible = false);
      widget.onComplete?.call();
    }
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _markComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _skip() {
    _markComplete();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final step = widget.steps[_currentStep];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress
          Row(
            children: [
              if (step.icon != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    step.icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Step ${_currentStep + 1} of ${widget.steps.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: _skip,
                color: Colors.grey[600],
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / widget.steps.length,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Text(
            step.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),

          if (step.action != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: step.action,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: Text(step.actionLabel ?? 'Try it'),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Navigation buttons
          Row(
            children: [
              if (_currentStep > 0)
                TextButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Back'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: _skip,
                child: const Text('Skip'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _currentStep < widget.steps.length - 1
                      ? 'Next'
                      : 'Done',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Onboarding step model
class OnboardingStep {
  final String title;
  final String description;
  final IconData? icon;
  final VoidCallback? action;
  final String? actionLabel;

  OnboardingStep({
    required this.title,
    required this.description,
    this.icon,
    this.action,
    this.actionLabel,
  });
}
