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

  /// Sets Authorization header for subsequent requests.
  void setBearer(String? token) {
    if (token == null || token.isEmpty) {
      dio.options.headers.remove('Authorization');
    } else {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return dio.get(path, queryParameters: query, options: options);
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return dio.post(path, data: data, queryParameters: query, options: options);
  }

  Future<Response<dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return dio.patch(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? query,
    Options? options,
  }) {
    return dio.delete(
      path,
      data: data,
      queryParameters: query,
      options: options,
    );
  }
}
