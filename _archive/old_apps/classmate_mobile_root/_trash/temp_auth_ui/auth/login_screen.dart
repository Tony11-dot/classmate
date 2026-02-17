import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_client.dart';
import '../../api/auth_api.dart';
import '../../core/result.dart';
import '../../core/auth_session.dart';
import '../../app/app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.auth});
  final AuthController auth;

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
    final Result<AuthSession> res = await api.login(
      email: _email.text,
      password: _password.text,
    );

    if (!mounted) return;

    if (res.isOk) {
      await widget.auth.setToken(res.value!.token);
      if (!mounted) return;
      context.go('/home');
      return;
    }

    setState(() {
      _loading = false;
      _error = res.error ?? 'Login failed';
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(title: const Text('ClassMate')),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Sign in',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _loading ? null : _submit(),
              decoration: const InputDecoration(labelText: 'Password'),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? 'Signing in...' : 'Sign in'),
            ),

            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : () => context.push('/register'),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
