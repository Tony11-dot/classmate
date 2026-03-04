import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_session.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    refreshListenable: ref.watch(authSessionProvider),
    initialLocation: '/login',
    redirect: (context, state) {
      final session = ref.read(authSessionProvider);

      if (!session.ready) return null;

      final isLogin = state.matchedLocation == '/login';
      final loggedIn = session.isLoggedIn;

      if (!loggedIn && !isLogin) return '/login';
      if (loggedIn && isLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const SizedBox.shrink(),
      ),
      GoRoute(path: '/', builder: (context, state) => const SizedBox.shrink()),
    ],
  );
});
