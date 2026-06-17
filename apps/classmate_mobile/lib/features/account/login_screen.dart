import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/auth/biometric_service.dart';
import '../../ui/widgets/classmate_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 540));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
  }

  String _routeFor(dynamic session) =>
      session.isTeacherLike ? '/teacher/schedule' : '/schedule';

  String _friendlyError(Object e, AppLocalizations l) {
    final raw = e.toString().toLowerCase();
    if (raw.contains('socket') || raw.contains('connection refused') || raw.contains('network')) {
      return l.loginConnectionError;
    }
    if (raw.contains('timeout')) return l.loginTimeoutError;
    return e.toString().replaceFirst('Exception: ', '');
  }

  /// Tapping a biometric icon. The icons are ALWAYS shown; if the user hasn't
  /// attached Face ID / fingerprint (in Profile) on this device, we show an
  /// error telling them how, otherwise we challenge and sign them in.
  Future<void> _biometricSignIn() async {
    if (_loading) return;
    final l = AppLocalizations.of(context)!;
    final bio = ref.read(biometricServiceProvider);
    // Nothing attached on this device → guide them to Profile.
    if (!await bio.isEnabled()) {
      if (!mounted) return;
      setState(() => _error = l.biometricNotSetUp);
      return;
    }
    final ok = await bio.authenticate(l.biometricReason);
    if (!ok || !mounted) return;
    final creds = await bio.readCredentials();
    if (creds == null) {
      setState(() => _error = l.biometricNotSetUp);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final session = ref.read(authSessionProvider);
      await session.login(identifier: creds.identifier, password: creds.password);
      if (!mounted) return;
      GoRouter.of(context).go(_routeFor(session));
    } catch (e) {
      // Stored credentials are stale (e.g. password changed) — forget them so
      // the user re-enrolls in Profile.
      await bio.clear();
      if (!mounted) return;
      setState(() => _error = l.biometricLoginFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = AppLocalizations.of(context)!;
    final identifier = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _error = l.loginEmptyFieldsError);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final session = ref.read(authSessionProvider);
      await session.login(identifier: identifier, password: password);
      if (!mounted) return;
      GoRouter.of(context).go(_routeFor(session));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e, l));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    cs.surface,
                    Color.alphaBlend(cs.primary.withValues(alpha: 0.10), cs.surface),
                  ]
                : [
                    Color.alphaBlend(cs.primary.withValues(alpha: 0.06), cs.surface),
                    cs.surface,
                  ],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _LoginCard(
                        emailCtrl: _emailCtrl,
                        passwordCtrl: _passwordCtrl,
                        emailFocus: _emailFocus,
                        passwordFocus: _passwordFocus,
                        loading: _loading,
                        obscure: _obscure,
                        error: _error,
                        onToggleObscure: () => setState(() => _obscure = !_obscure),
                        onSubmit: _submit,
                        onBiometricSignIn: _biometricSignIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.emailFocus,
    required this.passwordFocus,
    required this.loading,
    required this.obscure,
    required this.error,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onBiometricSignIn,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final bool loading;
  final bool obscure;
  final String? error;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onBiometricSignIn;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: const ClassMateLogo(height: 96)),
          const SizedBox(height: 18),
          Text(
            l.loginWelcomeTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.loginWelcomeSubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),

          _LoginField(
            controller: emailCtrl,
            focusNode: emailFocus,
            label: l.loginEmailLabel,
            icon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => passwordFocus.requestFocus(),
          ),
          const SizedBox(height: 12),
          _LoginField(
            controller: passwordCtrl,
            focusNode: passwordFocus,
            label: l.loginPasswordLabel,
            icon: Icons.lock_outline_rounded,
            obscure: obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            suffix: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
              onPressed: onToggleObscure,
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: loading ? null : () => GoRouter.of(context).push('/forgot-password'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l.loginForgotPasswordLink,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: error != null
                ? Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: cs.error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              error!,
                              style: TextStyle(color: cs.onErrorContainer, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: loading ? null : onSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: loading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: cs.onPrimary,
                        ),
                      )
                    : Text(
                        key: const ValueKey('label'),
                        l.loginSignIn,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
              ),
            ),
          ),

          // Biometric quick sign-in — always shown for everyone (iOS + Android).
          // Tapping a method you've set up in Profile signs you straight in;
          // tapping one you haven't attached shows a hint.
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Divider(color: cs.outlineVariant.withValues(alpha: 0.6))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l.biometricOrSignInWith,
                  style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
              Expanded(child: Divider(color: cs.outlineVariant.withValues(alpha: 0.6))),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BiometricIcon(
                icon: Icons.face_rounded,
                tooltip: l.biometricFaceId,
                onTap: loading ? null : onBiometricSignIn,
              ),
              const SizedBox(width: 22),
              _BiometricIcon(
                icon: Icons.fingerprint_rounded,
                tooltip: l.biometricFingerprint,
                onTap: loading ? null : onBiometricSignIn,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Minimal circular biometric icon button (Face ID / fingerprint). Always
/// shown on the login card regardless of platform; the tap handler decides
/// whether the method is set up.
class _BiometricIcon extends StatelessWidget {
  const _BiometricIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: CircleBorder(
          side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.7)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(icon, size: 26, color: cs.primary),
          ),
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.suffix,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autocorrect: false,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: cs.onSurfaceVariant, size: 18),
        suffixIcon: suffix,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.4),
        ),
      ),
    );
  }
}
