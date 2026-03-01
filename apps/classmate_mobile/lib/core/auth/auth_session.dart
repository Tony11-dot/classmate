import 'package:flutter/foundation.dart';

import '../config/env.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSession extends ChangeNotifier {
  static const _kToken = 'auth_token_v2';

  AuthSession() {
    _init();
  }

  bool _ready = false;
  bool get ready => _ready;

  String? _token;
  String? get token => _token;
  bool get isLoggedIn => (_token != null && _token!.isNotEmpty);

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    // DEV: if missing token, auto-fill dev token so app works instantly
    if (_token == null || _token!.trim().isEmpty || _token == 'SIM_TOKEN') {
      _token = Env.devToken;
      await prefs.setString(_kToken, _token!);
    }
    _ready = true;
    // ignore: avoid_print
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

  Future<void> logout() => setToken(null);

  // dev helper
  Future<void> simLogin() => setToken('SIM_TOKEN');

  Future<void> devSetToken(String token) => setToken(token);

}
