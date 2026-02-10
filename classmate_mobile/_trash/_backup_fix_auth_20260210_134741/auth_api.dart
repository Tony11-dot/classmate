import 'package:dio/dio.dart';
import '../core/auth_session.dart';
import '../core/result.dart';
import '../core/session.dart';
import 'api_client.dart';

class AuthApi {
  AuthApi(this._api);
  final ApiClient _api;

  String _dioMessage(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;

    String details = '';
    if (data is Map && data.isNotEmpty) {
      final msg = data['message'] ?? data['error'] ?? data['detail'];
      details = msg == null ? data.toString() : msg.toString();
    } else if (data != null) {
      details = data.toString();
    } else {
      details = e.message ?? e.error?.toString() ?? 'Unknown network error';
    }

    return 'HTTP ${status ?? '-'}: $details';
  }

  Future<Result<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _api.post(
        '/auth/login',
        data: {'email': email.trim(), 'password': password},
      );

      final session = AuthSession.fromJson(res.data);
      await Session.save(session);
      _api.setBearer(session.accessToken);
      return Result.ok(session);
    } on DioException catch (e) {
      return Result.err(_dioMessage(e));
    } catch (e) {
      return Result.err(e.toString());
    }
  }

  Future<Result<AuthSession>> register({
    required String email,
    required String password,
    String? fullName,
    String? role,
  }) async {
    try {
      final payload = <String, dynamic>{
        'email': email.trim(),
        'password': password,
      };
      if (fullName != null && fullName.trim().isNotEmpty)
        payload['fullName'] = fullName.trim();
      if (role != null && role.trim().isNotEmpty) payload['role'] = role.trim();

      final res = await _api.post('/auth/register', data: payload);

      final session = AuthSession.fromJson(res.data);
      await Session.save(session);
      _api.setBearer(session.accessToken);
      return Result.ok(session);
    } on DioException catch (e) {
      return Result.err(_dioMessage(e));
    } catch (e) {
      return Result.err(e.toString());
    }
  }
}
