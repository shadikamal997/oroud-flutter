import 'package:dio/dio.dart';
import '../services/token_service.dart';
import '../services/firebase_auth_service.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class AuthInterceptor extends Interceptor {
  final TokenService tokenService;
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  bool _isRefreshing = false; // 🔒 Prevent infinite refresh loop

  AuthInterceptor(this.tokenService);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // First, try to get Firebase ID token
      final firebaseToken = await _firebaseAuthService.getIdToken();
      
      if (firebaseToken != null) {
        // Use Firebase token if available
        options.headers["Authorization"] = "Bearer $firebaseToken";
        if (kDebugMode) {
          print('🔥 Using Firebase token for: ${options.path}');
        }
      } else {
        // Fall back to JWT token
        final token = await tokenService.getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
          if (kDebugMode) {
            print('🔑 Using JWT token for: ${options.path}');
          }
        }
      }
      
      handler.next(options);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in AuthInterceptor: $e');
      }
      handler.next(options);
    }
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      print('❌ API Error: ${err.message}');
      print('   Path: ${err.requestOptions.path}');
      print('   Status: ${err.response?.statusCode}');
      if (err.response?.data != null) {
        print('   Response: ${err.response?.data}');
      }
    }
    
    // Handle 401 Unauthorized - try to refresh token
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      if (kDebugMode) {
        print('🔄 401 Unauthorized - Attempting token refresh');
      }

      final refreshToken = await tokenService.getRefreshToken();

      if (refreshToken != null && !_isRefreshing) {
        _isRefreshing = true; // 🔒 Set refresh flag
        
        try {
          if (kDebugMode) {
            print('🔄 Calling /auth/refresh endpoint...');
          }

          // Create a new Dio instance for refresh request (avoid interceptor loop)
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: AppConfig.baseUrl,
              contentType: 'application/json',
            ),
          );

          final response = await refreshDio.post(
            '/auth/refresh',
            data: {'refresh_token': refreshToken},
          );

          final newAccessToken = response.data['access_token'];
          final newRefreshToken = response.data['refresh_token']; // 🔒 TOKEN ROTATION: Get new refresh token
          
          if (kDebugMode) {
            print('✅ Token refresh successful!');
          }

          // 🔒 Save new access token AND new refresh token
          await tokenService.saveToken(newAccessToken);
          if (newRefreshToken != null) {
            await tokenService.saveRefreshToken(newRefreshToken);
          }

          // 🔧 Check if request contains FormData (file upload)
          final isFormData = err.requestOptions.data is FormData;
          
          if (isFormData) {
            // ❌ Don't retry FormData requests (they can't be re-sent)
            // Token is refreshed, but let the caller retry the upload
            if (kDebugMode) {
              print('⚠️ FormData request detected - skipping auto-retry');
              print('💾 Token refreshed successfully. Please retry your upload.');
            }
            _isRefreshing = false;
            
            // Return a specific error so the upload widget knows to retry
            handler.reject(
              DioException(
                requestOptions: err.requestOptions,
                response: Response(
                  requestOptions: err.requestOptions,
                  statusCode: 401,
                  data: {'message': 'Token refreshed - please retry upload'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
            return;
          }

          // Retry original request with new token (non-FormData requests only)
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          if (kDebugMode) {
            print('🔄 Retrying original request: ${requestOptions.path}');
          }

          final cloneResponse = await Dio(
            BaseOptions(
              baseUrl: AppConfig.baseUrl,
              contentType: 'application/json',
            ),
          ).fetch(requestOptions);

          _isRefreshing = false;
          return handler.resolve(cloneResponse);
        } catch (refreshError) {
          _isRefreshing = false;
          
          if (kDebugMode) {
            print('❌ Token refresh failed: $refreshError');
            print('�️ Clearing invalid tokens - forcing re-authentication');
          }

          // Clear tokens and force re-authentication
          await tokenService.clear();
          
          // Return 401 to trigger logout in UI
          handler.reject(
            DioException(
              requestOptions: err.requestOptions,
              response: Response(
                requestOptions: err.requestOptions,
                statusCode: 401,
                data: {'message': 'Session expired - please login again'},
              ),
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
      } else {
        if (kDebugMode) {
          print('🔥 No refresh token available - clearing invalid tokens');
        }
        // Clear invalid token
        await tokenService.clear();
        
        // Force 401 to trigger logout
        handler.reject(
          DioException(
            requestOptions: err.requestOptions,
            response: Response(
              requestOptions: err.requestOptions,
              statusCode: 401,
              data: {'message': 'No valid session - please login'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        return;
      }
    }
    
    handler.next(err);
  }
}
