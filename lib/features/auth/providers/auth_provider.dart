import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../../../core/services/token_service.dart';
import '../../../core/api/endpoints.dart';

class AuthNotifier extends Notifier<bool> {
  final TokenService _tokenService = TokenService();

  @override
  bool build() {
    _checkLogin();
    return false;
  }

  Future<void> _checkLogin() async {
    final token = await _tokenService.getToken();
    if (token != null) {
      state = true;
    }
  }

  Future<void> login(String phone) async {
    final api = ref.read(apiClientProvider);

    final response = await api.post(
      Endpoints.login,
      data: {"phone": phone},
    );

    final token = response.data["access_token"];
    await _tokenService.saveToken(token);
    state = true;
  }

  Future<void> logout() async {
    await _tokenService.clear();
    state = false;
  }
}

final authProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
