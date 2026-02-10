import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_client.dart';
import '../../api/auth_api.dart';
import '../../core/session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    final res = await api.login(
      email: _email.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;

    if (res.isOk && res.value != null) {
      final session = res.value!;
      if (session.token.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Login returned empty token';
        });
        return;
      }

      await Session.set(
        token: session.token,
        role: session.role,
        email: session.email,
      );
      // Router gate should take over; just pop to root.
      if (mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
      return;
    }

    setState(() {
      _loading = false;
      _error = res.error ?? 'Login failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                child: Text(_loading ? 'Logging in…' : 'Login'),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading
                  ? null
                  : () => Navigator.of(context).pushNamed('/register'),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
