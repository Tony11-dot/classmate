import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController(text: 'Tony Aboud');
    final school = TextEditingController(text: 'Demo High School');
    final grade = TextEditingController(text: '10');

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: school,
              decoration: const InputDecoration(labelText: 'School'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: grade,
              decoration: const InputDecoration(labelText: 'Grade'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/schedule'),
                child: const Text('Create & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
