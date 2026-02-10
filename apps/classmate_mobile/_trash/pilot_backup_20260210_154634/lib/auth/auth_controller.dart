import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../core/session.dart';

class AuthState {
  final bool ready;
  final bool loggedIn;
  final String? token;
  final String? error;

  const AuthState({
    required this.ready,
    required this.loggedIn,
    this.token,
    this.error,
  });

  AuthState copyWith({
    bool? ready,
    bool? loggedIn,
    String? token,
    String? error,
  }) {
    return AuthState(
      ready: ready ?? this.ready,
      loggedIn: loggedIn ?? this.loggedIn,
      token: token ?? this.token,
      error: error,
    );
  }
}

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return const AuthState(ready: false, loggedIn: false);
  }

  Future<void> _init() async {
    final t = await Session.getToken();
    if (t != null && t.isNotEmpty) {
      ApiClient.instance.setBearer(t);
      state = AuthState(ready: true, loggedIn: true, token: t);
      return;
    }

    // Auto-provision a pilot account (NO login screen)
    final rand = Random().nextInt(999999).toString().padLeft(6, '0');
    final email = 'pilot+$rand@classmate.test';
    final password = 'Passw0rd!';
    final name = 'Pilot Student $rand';

    final api = AuthApi(ApiClient.instance);
    final res = await api.register(
      email: email,
      password: password,
      name: name,
    );

    if (res.isOk) {
      final token = res.value!.token;
      state = AuthState(ready: true, loggedIn: true, token: token);
    } else {
      // Still allow demo UI (principal can click everything) but show error banner.
      state = AuthState(ready: true, loggedIn: false, error: res.error);
    }
  }

  Future<void> logout() async {
    await Session.clearAll();
    ApiClient.instance.setBearer(null);
    state = const AuthState(ready: true, loggedIn: false);
    _init();
  }
}
