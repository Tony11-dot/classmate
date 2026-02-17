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
    final msg = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : e.message;
    return 'HTTP ${status ?? '-'}: ${msg ?? 'Request failed'}';
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
      await Session.saveAuth(
        token: session.token,
        role: session.role ?? '',
        email: session.email ?? email.trim(),
        name: session.name ?? '',
      );
      _api.setBearer(session.token);
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
    required String
    name, // REQUIRED by backend (your curl showed name validation)
  }) async {
    try {
      final res = await _api.post(
        '/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'name': name.trim(),
        },
      );

      final session = AuthSession.fromJson(res.data);
      await Session.saveAuth(
        token: session.token,
        role: session.role ?? '',
        email: session.email ?? email.trim(),
        name: session.name ?? name.trim(),
      );
      _api.setBearer(session.token);
      return Result.ok(session);
    } on DioException catch (e) {
      return Result.err(_dioMessage(e));
    } catch (e) {
      return Result.err(e.toString());
    }
  }

  Future<Result<Map<String, dynamic>>> me() async {
    try {
      final res = await _api.get('/auth/me');
      if (res.data is Map<String, dynamic>)
        return Result.ok(res.data as Map<String, dynamic>);
      return Result.err(
        'Unexpected /auth/me response: ${res.data.runtimeType}',
      );
    } on DioException catch (e) {
      return Result.err(_dioMessage(e));
    } catch (e) {
      return Result.err(e.toString());
    }
  }
}
