import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../core/auth/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailCtrl = TextEditingController(text: 'teacher1@classmate.app');
  final TextEditingController _passwordCtrl = TextEditingController(text: 'dev');
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primaryContainer.withValues(alpha: 0.65),
              cs.surface,
              cs.secondaryContainer.withValues(alpha: 0.55),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            children: [
              Text('Classmate', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 1.8, fontWeight: FontWeight.w800, color: cs.primary)),
              const SizedBox(height: 12),
              Text(l.loginTitle, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(l.loginSubtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 22),
              LiquidGlassCard(
                color: cs.surface.withValues(alpha: 0.78),
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer.withValues(alpha: 0.22),
                    cs.surface.withValues(alpha: 0.78),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.loginSignIn, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),
                    TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: l.loginEmailLabel)),
                    const SizedBox(height: 14),
                    TextField(controller: _passwordCtrl, obscureText: true, decoration: InputDecoration(labelText: l.loginPasswordLabel)),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(_error!, style: TextStyle(color: cs.error, fontWeight: FontWeight.w600)),
                    ],
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: _loading
                          ? null
                          : () async {
                              setState(() {
                                _loading = true;
                                _error = null;
                              });
                              try {
                                final session = ref.read(authSessionProvider);
                                await session.login(
                                  email: _emailCtrl.text,
                                  password: _passwordCtrl.text,
                                );
                                if (!mounted) return;
                                final router = GoRouter.of(this.context);
                                router.go(session.isTeacherLike ? '/teacher/home' : '/schedule');
                              } catch (error) {
                                if (!mounted) return;
                                setState(() => _error = error.toString());
                              } finally {
                                if (mounted) setState(() => _loading = false);
                              }
                            },
                      icon: _loading ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.login_rounded),
                      label: Text(_loading ? l.loginSigningIn : l.loginSignIn),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
