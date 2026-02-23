import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'token_store.dart';
import '../api/api_client.dart';
import '../config/env.dart';

const _kToken = 'auth_token';

final secureStorageProvider = Provider<TokenStore>((ref) => const TokenStore());

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthState {
  const AuthState({
    required this.ready,
    required this.token,
    required this.email,
    required this.role,
    required this.error,
  });

  final bool ready;
  final String? token;
  final String? email;
  final String? role; // normalized: parent/admin/teacher/student
  final String? error;

  bool get isAuthed => (token ?? '').isNotEmpty;

  AuthState copyWith({
    bool? ready,
    String? token,
    String? email,
    String? role,
    String? error,
  }) {
    return AuthState(
      ready: ready ?? this.ready,
      token: token ?? this.token,
      email: email ?? this.email,
      role: role ?? this.role,
      error: error,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _load();
    return const AuthState(
      ready: false,
      token: null,
      email: null,
      role: null,
      error: null,
    );
  }

  Future<void> _load() async {
    final storage = ref.read(secureStorageProvider);
    final t = await storage.read(key: _kToken);
    state = state.copyWith(ready: true, token: t, error: null);

    if (t != null && t.isNotEmpty) {
      await refreshMe();
    }
  }

  Future<String?> token() async => state.token;

  ApiClient _api() {
    return ApiClient(baseUrl: Env.apiBaseUrl, tokenProvider: token);
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: _kToken);
    state = state.copyWith(token: null, email: null, role: null, error: null);
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(error: null);

    final res = await _api().post(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      state = state.copyWith(error: 'Login failed (${res.statusCode})');
      return;
    }

    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final t = (j['token'] ?? j['accessToken'] ?? '') as String;

    if (t.isEmpty) {
      state = state.copyWith(error: 'Login failed (no token)');
      return;
    }

    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _kToken, value: t);
        try { print("[AUTH] login success tokenLen="); } catch (_) {}
state = state.copyWith(token: t, error: null);

    await refreshMe();
  }

  String? _mapRoleFromMeJson(Map<String, dynamic> j) {
    final u = j['user'];
    String raw = '';

    if (u is Map && u['roles'] is List && (u['roles'] as List).isNotEmpty) {
      raw = (u['roles'] as List).first.toString();
    } else {
      raw = (j['role'] ?? (u is Map ? u['role'] : null) ?? '').toString();
    }

    final norm = raw.toLowerCase();
    if (norm.contains('parent')) return 'parent';
    if (norm.contains('admin')) return 'admin';
    if (norm.contains('teacher')) return 'teacher';
    if (norm.contains('student')) return 'student';
    return null;
  }

  Future<void> refreshMe() async {
    final res = await _api().get('/api/auth/me');

    if (res.statusCode == 401) {
      await logout();
      return;
    }
    if (res.statusCode < 200 || res.statusCode >= 300) return;

    final j = jsonDecode(res.body) as Map<String, dynamic>;
    final u = j['user'];

    final email = (j['email'] ?? (u is Map ? u['email'] : null))?.toString();
    final role = _mapRoleFromMeJson(j);

    state = state.copyWith(email: email, role: role, error: null);
  }
}
