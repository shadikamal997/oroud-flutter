import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProUpgradeModal extends ConsumerWidget {
  final String featureName;
  final String description;

  const ProUpgradeModal({
    Key? key,
    required this.featureName,
    this.description = 'Upgrade to PRO to unlock this feature',
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Immediately navigate to the PRO upgrade screen instead of showing modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close any existing modal
      }
      context.push('/pro-upgrade', extra: {
        'featureName': featureName,
        'description': description,
      });
    });

    // Return empty container since we're navigating away
    return const SizedBox.shrink();
  }
}

/// Helper function to show PRO upgrade modal (now navigates to separate screen)
void showProUpgradeModal(
  BuildContext context, {
  required String featureName,
  String? description,
}) {
  // Navigate to PRO upgrade screen instead of showing modal
  context.push('/pro-upgrade', extra: {
    'featureName': featureName,
    'description': description ?? 'Upgrade to PRO to unlock this feature',
  });
}
