import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../api/auth_api.dart';
import '../core/session.dart';

class AuthState {
  final bool isLoggedIn;
  final String? token;
  const AuthState({required this.isLoggedIn, this.token});
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _load();
    return const AuthState(isLoggedIn: false);
  }

  Future<void> _load() async {
    final t = await Session.getToken();
    if (t != null && t.isNotEmpty) {
      ApiClient.instance.setBearer(t);
      state = AuthState(isLoggedIn: true, token: t);
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final api = AuthApi(ApiClient.instance);
    final res = await api.login(email: email, password: password);

    if (res.isOk) {
      final t = res.value!.token;
      ApiClient.instance.setBearer(t);
      state = AuthState(isLoggedIn: true, token: t);
      return null;
    }
    return res.error ?? 'Login failed';
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final api = AuthApi(ApiClient.instance);
    final res = await api.register(
      email: email,
      password: password,
      name: name,
    );

    if (res.isOk) {
      final t = res.value!.token;
      ApiClient.instance.setBearer(t);
      state = AuthState(isLoggedIn: true, token: t);
      return null;
    }
    return res.error ?? 'Register failed';
  }

  Future<void> logout() async {
    await Session.clearAll();
    ApiClient.instance.setBearer(null);
    state = const AuthState(isLoggedIn: false);
  }
}
