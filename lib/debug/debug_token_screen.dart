import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/token_service.dart';
import '../features/shop/providers/current_shop_provider.dart';

/// 🔧 DEBUG SCREEN - Use this to test shop authentication
/// 
/// Add this to your router temporarily:
/// GoRoute(path: '/debug-token', builder: (context, state) => const DebugTokenScreen()),
///
class DebugTokenScreen extends ConsumerStatefulWidget {
  const DebugTokenScreen({super.key});

  @override
  ConsumerState<DebugTokenScreen> createState() => _DebugTokenScreenState();
}

class _DebugTokenScreenState extends ConsumerState<DebugTokenScreen> {
  final TokenService _tokenService = TokenService();
  String? _currentToken;
  bool _loading = false;
  
  // ✅ This is a VALID token for shadikamal2221@gmail.com / Sami shop
  static const String VALID_TEST_TOKEN = 
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJmZDdmNGM4NS03ODk0LTQxYzUtYmFiMS03MDVjZmM3MzVmZTUiLCJyb2xlIjoiU0hPUCIsImVtYWlsIjoic2hhZGlrYW1hbDIyMjFAZ21haWwuY29tIiwiaWF0IjoxNzcwOTg5MzU0LCJleHAiOjE3NzE1OTQxNTR9.AUARMJXHafJJmPKftA5Hvmj6COwR1823pOLR8tS0KqQ';

  @override
  void initState() {
    super.initState();
    _loadCurrentToken();
  }

  Future<void> _loadCurrentToken() async {
    final token = await _tokenService.getToken();
    setState(() => _currentToken = token);
  }

  Future<void> _setValidToken() async {
    setState(() => _loading = true);
    try {
      await _tokenService.saveToken(VALID_TEST_TOKEN);
      await _loadCurrentToken();
      
      // Invalidate providers to refresh
      ref.invalidate(currentShopProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Valid token set! (Shop UI removed)'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _clearToken() async {
    setState(() => _loading = true);
    try {
      await _tokenService.clear();
      await _loadCurrentToken();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Token cleared'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Debug Token'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🔑 Current Token Status:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _currentToken != null ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _currentToken != null ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      _currentToken != null
                          ? '✅ Token exists\n${_currentToken!.substring(0, 50)}...'
                          : '❌ No token found',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: _currentToken != null ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _setValidToken,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Set Valid Test Token'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _clearToken,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Clear Token'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    '📝 Instructions:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Tap "Set Valid Test Token" above\n'
                    '2. App will refresh with valid token\n'
                    '3. Shop UI has been removed from frontend\n'
                    '4. Backend shop providers still work correctly',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '💡 This token is for: shadikamal2221@gmail.com\n'
                      'Shop: Sami shop\n'
                      'Valid for 7 days',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
