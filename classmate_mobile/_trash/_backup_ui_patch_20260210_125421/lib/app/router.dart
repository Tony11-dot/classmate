import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_state.dart';
import '../auth/login_screen.dart';
import '../features/dashboard/home_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/app',
    redirect: (context, state) {
      final goingLogin = state.matchedLocation == '/login';
      if (!auth.isLoggedIn && !goingLogin) return '/login';
      if (auth.isLoggedIn && goingLogin) return '/app';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/app', builder: (context, state) => const HomeShell()),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Route error: ${state.error}'))),
  );
});
