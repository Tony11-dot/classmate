import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth_session.dart';
export 'auth_session.dart' show authSessionProvider, AuthSession;

final authControllerProvider = Provider<AuthController>(
  (ref) => AuthController(ref),
);

class AuthController {
  AuthController(this.ref);
  final Ref ref;

  Future<void> logout(BuildContext context) async {
    await ref.read(authSessionProvider).logout();
    if (context.mounted) context.go('/login');
  }
}
