import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_session.dart';

class Session {
  static Future<void> set(String key, String value) =>
      _s.write(key: key, value: value);
  static Future<String?> get(String key) => _s.read(key: key);
  static const _kToken = 'cm_token';
  static const _kEmail = 'cm_email';
  static const _kRole = 'cm_role';
  static const _kSessionJson = 'cm_session_json';

  static const FlutterSecureStorage _s = FlutterSecureStorage();

  // Used by AuthApi
  static Future<void> save(AuthSession s) async {
    await _s.write(key: _kToken, value: s.accessToken);
    if (s.email != null) await _s.write(key: _kEmail, value: s.email);
    if (s.role != null) await _s.write(key: _kRole, value: s.role);
    await _s.write(key: _kSessionJson, value: jsonEncode(s.toJson()));
  }

  static Future<void> clear() async {
    await _s.delete(key: _kToken);
    await _s.delete(key: _kEmail);
    await _s.delete(key: _kRole);
    await _s.delete(key: _kSessionJson);
  }

  static Future<String?> token() => _s.read(key: _kToken);
  static Future<String?> email() => _s.read(key: _kEmail);
  static Future<String?> role() => _s.read(key: _kRole);

  static Future<bool> isLoggedIn() async {
    final t = await token();
    return t != null && t.isNotEmpty;
  }
}
