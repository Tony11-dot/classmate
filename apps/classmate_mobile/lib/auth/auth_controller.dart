import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
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
    if (t != null && t.trim().isNotEmpty) {
      ApiClient.instance.setBearer(t.trim());
      state = AuthState(ready: true, loggedIn: true, token: t.trim());
      return;
    }
    state = const AuthState(ready: true, loggedIn: false);
  }

  /// Call after login/register success (or app resume) to re-sync state from Session.
  Future<void> refresh() async {
    state = state.copyWith(ready: false, error: null);
    await _init();
  }

  Future<void> logout() async {
    await Session.clearAll();
    ApiClient.instance.dio.options.headers.remove('Authorization');
    state = const AuthState(ready: true, loggedIn: false);
  }
}

  Future<void> logout() async {
    await Session.clearAll();

    // Clear auth header safely
    ApiClient.instance.dio.options.headers.remove('Authorization');

    state = const AuthState(ready: true, loggedIn: false);
    _init();
  }
}
