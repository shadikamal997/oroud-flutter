import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/services/token_service.dart';
import '../../../core/services/firebase_auth_service.dart';
import '../../../core/api/endpoints.dart';
import '../../profile/providers/user_profile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthNotifier extends Notifier<bool> {
  final TokenService _tokenService = TokenService();
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  bool _isInitialized = false;

  @override
  bool build() {
    _initializeAuth();
    return false;
  }

  Future<void> _initializeAuth() async {
    if (_isInitialized) return;
    _isInitialized = true;
    
    // Check Firebase auth state first
    final firebaseUser = _firebaseAuthService.currentUser;
    if (firebaseUser != null) {
      print('🔥 Firebase user found - user already logged in');
      state = true;
      return;
    }
    
    // Fall back to checking JWT token (for traditional auth)
    final token = await _tokenService.getToken();
    if (token != null) {
      print('🔐 JWT token found in storage - user already logged in');
      state = true;
    } else {
      print('🔓 No user session found - user needs to login');
      state = false;
    }
  }

  Future<void> register(
    String email,
    String password, {
    String? name,
    String? role,
    String? shopName,
    String? phone,
    String? cityId,
    String? areaId,
    double? latitude,
    double? longitude,
    String? logoUrl,
  }) async {
    try {
      final api = ref.read(apiClientProvider);

      final data = {
        "email": email,
        "password": password,
        if (name != null) "name": name,
        if (role != null) "role": role,
        if (shopName != null) "shopName": shopName,
        if (phone != null) "phone": phone,
        if (cityId != null) "cityId": cityId,
        if (areaId != null) "areaId": areaId,
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
        if (logoUrl != null) "logoUrl": logoUrl,
      };

      final response = await api.post(
        Endpoints.register,
        data: data,
      );

      final token = response.data["access_token"];
      final refreshToken = response.data["refresh_token"]; // 🔒 Get refresh token
      await _tokenService.saveToken(token);
      if (refreshToken != null) {
        await _tokenService.saveRefreshToken(refreshToken); // 🔒 Store refresh token
      }
      state = true;
      
      // Invalidate user profile to fetch fresh data
      ref.invalidate(userProfileProvider);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final message = e.response?.data['message'] ?? 'Registration failed';
        if (message.toLowerCase().contains('email')) {
          throw Exception('This email is already registered. Please use a different email or sign in.');
        } else if (message.toLowerCase().contains('phone')) {
          throw Exception('This phone number is already registered. Please use a different number.');
        } else {
          throw Exception(message);
        }
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid information provided. Please check all fields.');
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      } else {
        throw Exception('Registration failed. Please try again.');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred. Please try again.');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final api = ref.read(apiClientProvider);

      print("🔐 Attempting login for: $email");
      final response = await api.post(
        Endpoints.login,
        data: {
          "email": email,
          "password": password,
        },
      );

      final token = response.data["access_token"];
      final refreshToken = response.data["refresh_token"]; // 🔒 Get refresh token
      final user = response.data["user"];
      
      print("✅ Login successful!");
      print("   User ID: ${user['id']}");
      print("   Role: ${user['role']}");
      print("   Token received: ${token != null ? '✓' : '✗'}");
      print("   Refresh token received: ${refreshToken != null ? '✓' : '✗'}");
      
      await _tokenService.saveToken(token);
      if (refreshToken != null) {
        await _tokenService.saveRefreshToken(refreshToken); // 🔒 Store refresh token
      }
      state = true;
      
      // Invalidate user profile to fetch fresh data
      ref.invalidate(userProfileProvider);
    } catch (e) {
      print("❌ Login failed: $e");
      rethrow;
    }
  }

  Future<void> registerShop({
    required String shopName,
    required String email,
    required String phone,
    required String password,
    required String cityId,
    required String areaId,
    double? latitude,
    double? longitude,
  }) async {
    return register(
      email,
      password,
      phone: phone,
      role: 'SHOP',
      shopName: shopName,
      cityId: cityId,
      areaId: areaId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<void> logout() async {
    await _tokenService.clear();
    await _firebaseAuthService.signOut();
    state = false;
    
    // Invalidate user profile to prevent cached data from causing issues
    ref.invalidate(userProfileProvider);
  }

  // ========== FIREBASE AUTHENTICATION METHODS ==========

  /// Sign in with Firebase email/password, then authenticate with backend
  Future<void> signInWithFirebase(String email, String password) async {
    try {
      print("🔥 Signing in with Firebase email/password...");
      
      // Sign in to Firebase
      final userCredential = await _firebaseAuthService.signInWithEmailPassword(email, password);
      
      // Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Authenticate with backend using Firebase token
      await _authenticateWithBackend(idToken);
    } catch (e) {
      print("❌ Firebase sign in failed: $e");
      rethrow;
    }
  }

  /// Register with Firebase email/password, then register with backend
  Future<void> registerWithFirebase(
    String email,
    String password, {
    String? name,
    String? role,
    String? shopName,
    String? phone,
    String? cityId,
    String? areaId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      print("🔥 Registering with Firebase email/password...");
      
      // Create Firebase account
      final userCredential = await _firebaseAuthService.signUpWithEmailPassword(email, password);
      
      // Send email verification
      await _firebaseAuthService.sendEmailVerification();
      
      // Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Register with backend
      await _registerWithBackend(
        idToken,
        email: email,
        name: name,
        role: role,
        shopName: shopName,
        phone: phone,
        cityId: cityId,
        areaId: areaId,
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      print("❌ Firebase registration failed: $e");
      rethrow;
    }
  }

  /// Google Sign-In with Firebase, then authenticate with backend
  Future<void> signInWithGoogle() async {
    try {
      print("🔵 Starting Google Sign-In...");
      
      // Sign in with Google
      final userCredential = await _firebaseAuthService.signInWithGoogle();
      
      // Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Authenticate with backend
      await _authenticateWithBackend(idToken, provider: 'GOOGLE');
    } catch (e) {
      print("❌ Google Sign-In failed: $e");
      rethrow;
    }
  }

  /// Apple Sign-In with Firebase, then authenticate with backend
  Future<void> signInWithApple() async {
    try {
      print("🍎 Starting Apple Sign-In...");
      
      // Check if Apple Sign-In is available
      final isAvailable = await _firebaseAuthService.isAppleSignInAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign-In is only available on iOS and macOS');
      }
      
      // Sign in with Apple
      final userCredential = await _firebaseAuthService.signInWithApple();
      
      // Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Authenticate with backend
      await _authenticateWithBackend(idToken, provider: 'APPLE');
    } catch (e) {
      print("❌ Apple Sign-In failed: $e");
      rethrow;
    }
  }

  /// Phone authentication - Step 1: Send verification code
  Future<void> sendPhoneVerificationCode(
    String phoneNumber,
    Function(String verificationId) onCodeSent,
    Function(String error) onError,
  ) async {
    try {
      print("📱 Sending phone verification code to $phoneNumber");
      
      await _firebaseAuthService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: onCodeSent,
        verificationFailed: onError,
        verificationCompleted: (credential) async {
          // Auto-verification completed (Android only)
          final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
          final idToken = await userCredential.user?.getIdToken();
          if (idToken != null) {
            await _authenticateWithBackend(idToken, provider: 'PHONE');
          }
        },
      );
    } catch (e) {
      print("❌ Phone verification failed: $e");
      rethrow;
    }
  }

  /// Phone authentication - Step 2: Verify code and sign in
  Future<void> verifyPhoneCode(String verificationId, String smsCode) async {
    try {
      print("🔑 Verifying phone code...");
      
      // Verify code and sign in to Firebase
      final userCredential = await _firebaseAuthService.signInWithPhoneCredential(
        verificationId,
        smsCode,
      );
      
      // Get Firebase ID token
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      // Authenticate with backend
      await _authenticateWithBackend(idToken, provider: 'PHONE');
    } catch (e) {
      print("❌ Phone verification failed: $e");
      rethrow;
    }
  }

  /// Authenticate with backend using Firebase ID token
  Future<void> _authenticateWithBackend(String idToken, {String? provider}) async {
    try {
      final api = ref.read(apiClientProvider);

      print("🔗 Authenticating with backend using Firebase token...");
      final response = await api.post(
        Endpoints.firebaseAuth,
        data: {
          "firebaseToken": idToken,
        },
      );
      
      print("✅ Backend authentication successful!");
      
      // Extract JWT tokens from backend response
      final accessToken = response.data["access_token"] as String?;
      final refreshToken = response.data["refresh_token"] as String?;
      
      if (accessToken == null || refreshToken == null) {
        throw Exception('Backend did not return access or refresh tokens');
      }
      
      // Save JWT tokens
      await _tokenService.saveToken(accessToken);
      await _tokenService.saveRefreshToken(refreshToken);
      
      state = true;
      
      // Invalidate user profile to fetch fresh data
      ref.invalidate(userProfileProvider);
    } catch (e) {
      print("❌ Backend authentication failed: $e");
      rethrow;
    }
  }

  /// Register with backend using Firebase ID token
  Future<void> _registerWithBackend(
    String idToken, {
    String? email,
    String? name,
    String? role,
    String? shopName,
    String? phone,
    String? cityId,
    String? areaId,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final api = ref.read(apiClientProvider);

      final data = {
        "firebaseToken": idToken,
        if (email != null) "email": email,
        if (name != null) "name": name,
        if (role != null) "role": role,
        if (shopName != null) "shopName": shopName,
        if (phone != null) "phone": phone,
        if (cityId != null) "cityId": cityId,
        if (areaId != null) "areaId": areaId,
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
      };

      print("🔗 Registering with backend using Firebase token...");
      final response = await api.post(
        Endpoints.firebaseAuth,
        data: data,
      );
      
      print("✅ Backend registration successful!");
      
      // Extract JWT tokens from backend response
      final accessToken = response.data["access_token"] as String?;
      final refreshToken = response.data["refresh_token"] as String?;
      
      if (accessToken == null || refreshToken == null) {
        throw Exception('Backend did not return access or refresh tokens');
      }
      
      // Save JWT tokens
      await _tokenService.saveToken(accessToken);
      await _tokenService.saveRefreshToken(refreshToken);
      
      state = true;
      
      // Invalidate user profile to fetch fresh data
      ref.invalidate(userProfileProvider);
    } catch (e) {
      print("❌ Backend registration failed: $e");
      rethrow;
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
