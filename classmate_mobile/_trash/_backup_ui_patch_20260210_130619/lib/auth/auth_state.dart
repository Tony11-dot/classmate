import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthState {
  final bool isLoggedIn;
  final String? token;
  const AuthState({required this.isLoggedIn, this.token});
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  static const _kToken = 'classmate_token';
  final _store = const FlutterSecureStorage();

  @override
  AuthState build() {
    _load();
    return const AuthState(isLoggedIn: false);
  }

  Future<void> _load() async {
    final t = await _store.read(key: _kToken);
    if (t != null && t.isNotEmpty) {
      state = AuthState(isLoggedIn: true, token: t);
    }
  }

  Future<void> loginMock({required String email}) async {
    // Replace this with real API auth later.
    final fake = 'dev-token:${DateTime.now().millisecondsSinceEpoch}:$email';
    await _store.write(key: _kToken, value: fake);
    state = AuthState(isLoggedIn: true, token: fake);
  }

  Future<void> logout() async {
    await _store.delete(key: _kToken);
    state = const AuthState(isLoggedIn: false);
  }
}
