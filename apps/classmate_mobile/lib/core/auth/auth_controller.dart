import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_session.dart';

final authSessionProvider = Provider<AuthSession>((ref) {
  final session = AuthSession();
  ref.onDispose(session.dispose);
  return session;
});

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref),
);

class AuthController {
  AuthController(this.ref);
  final Ref ref;

  Future<void> logout(BuildContext context) async {
    await ref.read(authSessionProvider).logout();
  }
}
