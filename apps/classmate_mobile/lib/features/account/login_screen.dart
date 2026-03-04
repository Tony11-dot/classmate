import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Simulate Login'),
          onPressed: () async {
            await ref.read(authSessionProvider).simLogin();
            await ref.read(authSessionProvider).setDisplayName('Tony');
            if (!context.mounted) return;
            context.go('/student/schedule');
          },
        ),
      ),
    );
  }
}
