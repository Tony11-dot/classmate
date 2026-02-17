import 'package:flutter/material.dart';

import '../../api/api_client.dart';
import '../../api/auth_api.dart';
import '../../core/session.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final api = AuthApi(ApiClient.instance);
    final res = await api.register(
      email: _email.text.trim(),
      password: _password.text,
      fullName: _name.text.trim().isEmpty ? null : _name.text.trim(),
    );

    if (!mounted) return;

    if (res.isOk && res.value != null) {
      final session = res.value!;
      await Session.set(
        token: session.token,
        role: session.role,
        email: session.email,
      );
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }

    setState(() {
      _loading = false;
      _error = res.error ?? 'Register failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Full name (optional)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                child: Text(_loading ? 'Creating…' : 'Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
