import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oroud_app/core/theme/app_colors.dart';

/// Onboarding tip widget for guiding new shop owners
class OnboardingTip extends StatefulWidget {
  final String tipKey;
  final String title;
  final String message;
  final IconData? icon;
  final Color? color;
  final String? actionLabel;
  final VoidCallback? onAction;

  const OnboardingTip({
    super.key,
    required this.tipKey,
    required this.title,
    required this.message,
    this.icon,
    this.color,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<OnboardingTip> createState() => _OnboardingTipState();
}

class _OnboardingTipState extends State<OnboardingTip> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _checkVisibility();
  }

  Future<void> _checkVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool('tip_dismissed_${widget.tipKey}') ?? false;
    if (dismissed && mounted) {
      setState(() => _isVisible = false);
    }
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tip_dismissed_${widget.tipKey}', true);
    if (mounted) {
      setState(() => _isVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    final effectiveColor = widget.color ?? AppColors.primary;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              effectiveColor.withOpacity(0.1),
              effectiveColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: effectiveColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: effectiveColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: effectiveColor.withOpacity(0.9),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: _dismiss,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                        ),
                        if (widget.actionLabel != null &&
                            widget.onAction != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: widget.onAction,
                            style: TextButton.styleFrom(
                              foregroundColor: effectiveColor,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: Text(widget.actionLabel!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
