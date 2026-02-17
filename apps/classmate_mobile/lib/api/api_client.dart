import "package:dio/dio.dart";
import "env.dart";
import '../core/api_config.dart';

class ApiClient {
  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: '${ApiConfig.baseUrl}/api', //  Env.apiRoot, // IMPORTANT: includes /api
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {"Content-Type": "application/json"},
      ),
    );
  }

  late final Dio dio;

  static final ApiClient instance = ApiClient._internal();

  void setBearer(String token) {
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) {
    return dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> patch(String path, {dynamic data}) {
    return dio.patch(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return dio.delete(path, data: data);
  }
}
