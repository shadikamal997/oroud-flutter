import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class TokenService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    if (kDebugMode) {
      // Show first/last 20 chars for debugging
      final preview = token.length > 40 
        ? '${token.substring(0, 20)}...${token.substring(token.length - 20)}'
        : token;
      print('💾 TokenService: Saving new token: $preview');
    }
    await _storage.write(key: "jwt", value: token);
  }

  Future<void> saveRefreshToken(String refreshToken) async {
    if (kDebugMode) {
      // Show first/last 20 chars for debugging
      final preview = refreshToken.length > 40 
        ? '${refreshToken.substring(0, 20)}...${refreshToken.substring(refreshToken.length - 20)}'
        : refreshToken;
      print('💾 TokenService: Saving refresh token: $preview');
    }
    await _storage.write(key: "refresh_token", value: refreshToken);
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: "jwt");
    if (kDebugMode && token != null) {
      final preview = token.length > 40 
        ? '${token.substring(0, 20)}...${token.substring(token.length - 20)}'
        : token;
      print('🔑 TokenService: Retrieved token: $preview');
    }
    return token;
  }

  Future<String?> getRefreshToken() async {
    final refreshToken = await _storage.read(key: "refresh_token");
    if (kDebugMode && refreshToken != null) {
      final preview = refreshToken.length > 40 
        ? '${refreshToken.substring(0, 20)}...${refreshToken.substring(refreshToken.length - 20)}'
        : refreshToken;
      print('🔄 TokenService: Retrieved refresh token: $preview');
    }
    return refreshToken;
  }

  Future<void> clear() async {
    if (kDebugMode) {
      print('🗑️ TokenService: Clearing tokens from secure storage');
    }
    await _storage.delete(key: "jwt");
    await _storage.delete(key: "refresh_token"); // 🔒 Clear refresh token too
  }
  
  /// ⚠️ DANGER: Clears ALL secure storage (use for debugging only)
  Future<void> clearAll() async {
    if (kDebugMode) {
      print('💥 TokenService: Clearing ALL secure storage data');
    }
    await _storage.deleteAll();
  }
}
