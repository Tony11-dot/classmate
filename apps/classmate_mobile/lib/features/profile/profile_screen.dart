import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Profile\n(Coming soon)',
            textAlign: TextAlign.center,
            style: t.textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
