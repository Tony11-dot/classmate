import 'dart:io' show Platform;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStore {
  static const _kToken = 'auth_token';

  const TokenStore();

  // ---- Public API (new style) ----

  Future<String?> readToken() async {
    if (Platform.isMacOS) {
      final p = await SharedPreferences.getInstance();
      return p.getString(_kToken);
    }
    const s = FlutterSecureStorage();
    return s.read(key: _kToken);
  }

  Future<void> writeToken(String token) async {
    if (Platform.isMacOS) {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kToken, token);
      return;
    }
    const s = FlutterSecureStorage();
    await s.write(key: _kToken, value: token);
  }

  Future<void> clearToken() async {
    if (Platform.isMacOS) {
      final p = await SharedPreferences.getInstance();
      await p.remove(_kToken);
      return;
    }
    const s = FlutterSecureStorage();
    await s.delete(key: _kToken);
  }

  // ---- Compatibility layer (so old code still works) ----

  Future<String?> read({required String key}) => readToken();

  Future<void> write({required String key, required String value}) =>
      writeToken(value);

  Future<void> delete({required String key}) => clearToken();
}
