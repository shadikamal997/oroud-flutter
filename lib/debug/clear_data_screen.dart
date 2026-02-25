import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/services/token_service.dart';
import '../features/auth/providers/auth_provider.dart';

class ClearDataScreen extends ConsumerWidget {
  const ClearDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clear App Data'),
        backgroundColor: Colors.red[700],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete_forever,
                size: 80,
                color: Colors.red[700],
              ),
              const SizedBox(height: 24),
              const Text(
                'Clear All App Data',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This will:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text('• Logout your account'),
              const Text('• Clear all cached data'),
              const Text('• Clear authentication tokens'),
              const Text('• Reset the app to fresh state'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  // Show confirmation dialog
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm'),
                      content: const Text(
                        'Are you sure you want to clear all app data?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Clear Data',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && context.mounted) {
                    // Clear all tokens
                    final tokenService = TokenService();
                    await tokenService.clearAll();

                    // Logout
                    ref.read(authProvider.notifier).logout();

                    // Show success message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All data cleared successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      // Navigate to welcome screen
                      context.go('/welcome');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Clear All Data',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
