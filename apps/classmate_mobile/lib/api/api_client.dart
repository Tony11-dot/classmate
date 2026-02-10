import 'package:dio/dio.dart';
import 'env.dart';

class ApiClient {
  ApiClient._(this.dio);

  final Dio dio;

  static final ApiClient instance = ApiClient._(
    Dio(
      BaseOptions(
        baseUrl: Env.apiRoot,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    ),
  );

  void setBearer(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response<dynamic>> get(String path, {Map<String, dynamic>? query}) {
    return dio.get(path, queryParameters: query);
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) {
    return dio.post(path, data: data);
  }

  Future<Response<dynamic>> patch(String path, {dynamic data}) {
    return dio.patch(path, data: data);
  }
}
