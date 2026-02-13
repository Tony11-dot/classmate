import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import 'auth_controller.dart';

import "../api/api_client.dart";
import "../api/auth_api.dart";

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();

  bool loading = false;
  String? err;

  Future<void> _login() async {
    setState(() {
      loading = true;
      err = null;
    });

    final api = AuthApi(ApiClient.instance);
    final res = await api.login(email: email.text.trim(), password: pass.text);

    if (!mounted) return;

    if (res.isOk) {
        await this.ref.read(authProvider.notifier).refresh();
      context.go("/app");
    } else {
      setState(() => err = res.error);
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: ListView(
                children: [
                  Text(
                    "Welcome back",
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: pass,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 14),

                  if (err != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        err!,
                        style: TextStyle(color: t.colorScheme.error),
                      ),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: loading ? null : _login,
                      child: Text(loading ? "Signing in…" : "Login"),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go("/register"),
                      child: const Text("Create account"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
