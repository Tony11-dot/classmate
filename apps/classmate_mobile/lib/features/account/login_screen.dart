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

  // Biometric quick sign-in. `_biometricAvailable` = device has enrolled
  // biometrics; `_biometricEnrolled` = we have saved credentials to unlock.
  bool _biometricAvailable = false;
  bool _biometricEnrolled = false;

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
    _initBiometric();
  }

  Future<void> _initBiometric() async {
    final bio = ref.read(biometricServiceProvider);
    final available = await bio.isAvailable();
    final enrolled = available && await bio.hasStoredCredentials();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometricEnrolled = enrolled;
    });
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

  /// Unlock with a stored credential set behind a biometric challenge.
  Future<void> _biometricSignIn() async {
    final l = AppLocalizations.of(context)!;
    final bio = ref.read(biometricServiceProvider);
    final ok = await bio.authenticate(l.biometricReason);
    if (!ok || !mounted) return;
    final creds = await bio.readCredentials();
    if (creds == null) {
      setState(() {
        _biometricEnrolled = false;
        _error = l.biometricLoginFailed;
      });
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
      // the user falls back to a normal password sign-in.
      await bio.clear();
      if (!mounted) return;
      setState(() {
        _biometricEnrolled = false;
        _error = l.biometricLoginFailed;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Verify the typed credentials by signing in, then save them behind a
  /// biometric challenge so future sign-ins can use Face ID / fingerprint.
  Future<void> _enableBiometric() async {
    final l = AppLocalizations.of(context)!;
    final identifier = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _error = l.biometricEnterCredsFirst);
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final session = ref.read(authSessionProvider);
      await session.login(identifier: identifier, password: password);
      final bio = ref.read(biometricServiceProvider);
      final ok = await bio.authenticate(l.biometricEnableReason);
      if (ok) {
        await bio.saveCredentials(identifier: identifier, password: password);
      }
      if (!mounted) return;
      GoRouter.of(context).go(_routeFor(session));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = _friendlyError(e, l));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// After a successful password sign-in, offer to enable biometric unlock.
  Future<void> _maybeOfferBiometricEnroll(String identifier, String password) async {
    if (!_biometricAvailable || _biometricEnrolled) return;
    final l = AppLocalizations.of(context)!;
    final accept = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l.biometricEnrollTitle),
        content: Text(l.biometricEnrollBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.biometricEnrollNo)),
          FilledButton(onPressed: () => Navigator.pop(d, true), child: Text(l.biometricEnrollYes)),
        ],
      ),
    );
    if (accept != true || !mounted) return;
    final bio = ref.read(biometricServiceProvider);
    final ok = await bio.authenticate(l.biometricEnableReason);
    if (ok) await bio.saveCredentials(identifier: identifier, password: password);
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
      await _maybeOfferBiometricEnroll(identifier, password);
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
                        biometricAvailable: _biometricAvailable,
                        biometricEnrolled: _biometricEnrolled,
                        onToggleObscure: () => setState(() => _obscure = !_obscure),
                        onSubmit: _submit,
                        onBiometricSignIn: _biometricSignIn,
                        onEnableBiometric: _enableBiometric,
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
    required this.biometricAvailable,
    required this.biometricEnrolled,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onBiometricSignIn,
    required this.onEnableBiometric,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final bool loading;
  final bool obscure;
  final String? error;
  final bool biometricAvailable;
  final bool biometricEnrolled;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onBiometricSignIn;
  final VoidCallback onEnableBiometric;

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

          if (biometricAvailable) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: loading
                    ? null
                    : (biometricEnrolled ? onBiometricSignIn : onEnableBiometric),
                icon: const Icon(Icons.fingerprint_rounded, size: 20),
                label: Text(biometricEnrolled ? l.biometricSignIn : l.biometricEnable),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.8)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],

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
        ],
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
