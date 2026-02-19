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
        : (e.message ?? 'Request failed');
    return 'HTTP ${status ?? '-'}: $msg';
  }

  Future<Result<AuthSession>> register({
    required String email,
    required String password,
    required String name,
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
      final s = AuthSession.fromJson(res.data);

      final role = (s.roles.isNotEmpty) ? s.roles.first : '';
      await Session.saveAuth(
        token: s.token,
        role: role,
        email: s.email ?? email.trim(),
        name: s.name ?? name.trim(),
      );
      _api.setBearer(s.token);
      return Result.ok(s);
    } on DioException catch (e) {
      return Result.err(_dioMessage(e));
    } catch (e) {
      return Result.err(e.toString());
    }
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
      final s = AuthSession.fromJson(res.data);

      final role = (s.roles.isNotEmpty) ? s.roles.first : '';
      await Session.saveAuth(
        token: s.token,
        role: role,
        email: s.email ?? email.trim(),
        name: s.name ?? '',
      );
      _api.setBearer(s.token);
      return Result.ok(s);
    } on DioException catch (e) {
      return Result.err(_dioMessage(e));
    } catch (e) {
      return Result.err(e.toString());
    }
  }
}
