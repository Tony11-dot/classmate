import 'package:flutter/foundation.dart';

import '../config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSession extends ChangeNotifier {
  static const _kToken = 'auth_token_v2';
  static const _kDisplayName = 'auth_display_name_v1';

  AuthSession() {
    _init();
  }

  bool _ready = false;
  bool get ready => _ready;

  String? _token;
  String? _displayName;

  String? get token => _token;
  String get displayName => (_displayName ?? '').trim();

  bool get isLoggedIn => (_token != null && _token!.isNotEmpty);

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();

    _displayName = (prefs.getString(_kDisplayName) ?? '').trim();

    final saved = prefs.getString(_kToken);
    if (saved != null) {
      final s = saved.trim();
      final isJwtish = s.split('.').length >= 3;
      final isEmailish = s.contains('@') && s.contains('.');
      if (isEmailish && !isJwtish) {
        await prefs.remove(_kToken);
        _token = null;
      } else {
        _token = s;
      }
    } else {
      _token = null;
    }

    // DEV: only auto-fill when Env.devToken is a real JWT-ish token.
    // If Env.devToken is empty (or email-ish), keep token empty so x-dev-* headers are used.
    if (_token == null || _token!.isEmpty || _token == 'SIM_TOKEN') {
      final dt = Env.devToken.trim();
      final dtIsJwtish = dt.split('.').length >= 3;
      final dtIsEmailish = dt.contains('@') && dt.contains('.');
      if (dt.isNotEmpty && dtIsJwtish && !dtIsEmailish) {
        _token = dt;
        await prefs.setString(_kToken, _token!);
      } else {
        _token = null;
        await prefs.remove(_kToken);
      }
    }

    _ready = true;
    // ignore: avoid_print
    print('AuthSession token=${_token ?? 'NULL'}');
    notifyListeners();
  }

  Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_kToken);
      _token = null;
    } else {
      await prefs.setString(_kToken, token);
      _token = token;
    }
    notifyListeners();
  }

  Future<void> setDisplayName(String? name) async {
    final prefs = await SharedPreferences.getInstance();
    final v = (name ?? '').trim();
    _displayName = v;
    if (v.isEmpty) {
      await prefs.remove(_kDisplayName);
    } else {
      await prefs.setString(_kDisplayName, v);
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await setToken(null);
    await setDisplayName(null);
  }

  // dev helper
  Future<void> simLogin() => setToken('SIM_TOKEN');

  Future<void> devSetToken(String token) => setToken(token);
}
