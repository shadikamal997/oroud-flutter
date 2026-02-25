import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/api/endpoints.dart';
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider to fetch and cache user profile
final userProfileProvider = FutureProvider<User?>((ref) async {
  // Only fetch profile if user is logged in
  final isLoggedIn = ref.watch(authProvider);
  if (!isLoggedIn) {
    return null;
  }

  try {
    final api = ref.read(apiClientProvider);
    final response = await api.get(Endpoints.profile);

    if (response.data != null) {
      if (kDebugMode) {
        print('✅ Profile API Response: ${response.data}');
      }
      return User.fromJson(response.data);
    }
    return null;
  } catch (e) {
    if (kDebugMode) {
      print('⚠️ Profile fetch failed: $e');
    }
    
    // 🔥 FIX: Rethrow 401 errors so main_shell can handle logout
    // The error handler in main_shell will logout and redirect to welcome
    if (e.toString().contains('401')) {
      if (kDebugMode) {
        print('🔥 401 Unauthorized - rethrowing for logout');
      }
      rethrow; // Let main_shell error handler logout user
    }
    
    // For other errors, rethrow so UI can show error state
    rethrow;
  }
});

/// Provider to manually refresh user profile
final refreshUserProfileProvider = Provider<void Function()>((ref) {
  return () => ref.invalidate(userProfileProvider);
});
