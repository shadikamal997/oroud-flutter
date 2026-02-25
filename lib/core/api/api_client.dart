import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'interceptors.dart';
import '../services/token_service.dart';

class ApiClient {
  late final Dio dio;

  ApiClient() {
    final tokenService = TokenService();

    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(AuthInterceptor(tokenService));
  }

  Future<Response> get(String path, {Map<String, dynamic>? query}) {
    return dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return dio.patch(path, data: data);
  }

  Future<Response> delete(String path) {
    return dio.delete(path);
  }
}
