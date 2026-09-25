import 'package:flutter/material.dart';
import '../../ui/widgets/cm_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/http/cm_api.dart';
import '../../l10n/app_localizations.dart';

enum _ResetMode { email, sms }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _identifierCtrl = TextEditingController();
  _ResetMode _mode = _ResetMode.email;
  bool _submitting = false;
  String? _message;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    // Auto-fill the identifier when the user is already logged in (e.g.
    // they tapped "Forgot password?" from inside the Change Password sheet
    // on Profile). Saves them retyping their own email/username.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final session = ref.read(authSessionProvider);
      if (session.isLoggedIn && _identifierCtrl.text.isEmpty) {
        final email = session.email.trim();
        _identifierCtrl.text = email;
      }
    });
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    super.dispose();
  }

  // ── Email / SMS submission ─────────────────────────────────────────────

  Future<void> _submitChannelReset() async {
    final l = AppLocalizations.of(context)!;
    final identifier = _identifierCtrl.text.trim();
    if (identifier.isEmpty) {
      setState(() { _message = l.forgotPasswordEmptyError; _success = false; });
      return;
    }
    setState(() { _submitting = true; _message = null; });

    final api = CMApi();
    try {
      final raw = await api.postJson('/auth/forgot-password', body: {
        'identifier': identifier,
        'channel': _mode == _ResetMode.email ? 'email' : 'sms',
      });
      if (!mounted) return;
      // Server returns { ok, code, sent, message }. `sent` drives the
      // success colouring; the message is rendered as-is and varies per
      // outcome (no email on file, not verified, etc.).
      final m = raw is Map ? raw : const <String, dynamic>{};
      setState(() {
        _success = m['sent'] == true;
        _message = m['message']?.toString() ?? l.forgotPasswordEmailSent;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _success = false; _message = l.commonError; });
    } finally {
      api.dispose();
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final headerCopy = _mode == _ResetMode.email
        ? "Enter your email or username and we'll email you a reset link."
        : "Enter your email or username and we'll text a reset link to the phone on your account.";

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: AppLocalizations.of(context)!.a11yBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            // Same width budget the desktop shell uses for its main column.
            // Below this width the column fills the viewport like on mobile.
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              children: [
            Text(AppLocalizations.of(context)!.forgotPasswordTitle,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(headerCopy,
                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.45)),
            const SizedBox(height: 24),

            // Mode picker
            SegmentedButton<_ResetMode>(
              segments: [
                ButtonSegment(value: _ResetMode.email, label: Text(AppLocalizations.of(context)!.forgotPasswordModeEmail), icon: const Icon(Icons.mail_outline_rounded)),
                ButtonSegment(value: _ResetMode.sms,   label: Text(AppLocalizations.of(context)!.forgotPasswordModeSms),   icon: const Icon(Icons.sms_outlined)),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() {
                _mode = s.first;
                _message = null;
              }),
            ),
            const SizedBox(height: 20),

            // Identifier field — the account is always identified by email or
            // username; in SMS mode the link is texted to the phone ON that
            // account (web QA #72: make the field reflect the selected mode
            // instead of always looking like a bare "Email" input).
            TextField(
              controller: _identifierCtrl,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.loginEmailLabel,
                helperText: _mode == _ResetMode.sms
                    ? AppLocalizations.of(context)!.forgotPasswordSmsHelper
                    : null,
                prefixIcon: Icon(_mode == _ResetMode.sms
                    ? Icons.sms_outlined
                    : Icons.alternate_email_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onSubmitted: (_) => _submitChannelReset(),
            ),
            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: _submitting ? null : _submitChannelReset,
              icon: _submitting
                  ? const CmLoading(size: 16, color: Colors.white)
                  : Icon(_mode == _ResetMode.email ? Icons.send_rounded : Icons.sms_rounded),
              label: Text(_mode == _ResetMode.email
                  ? AppLocalizations.of(context)!.forgotPasswordEmailButton
                  : AppLocalizations.of(context)!.forgotPasswordSmsButton),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            ),

            if (_message != null) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (_success ? cs.tertiaryContainer : cs.errorContainer).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _success ? cs.tertiary : cs.error),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                        color: _success ? cs.tertiary : cs.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_message!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _success ? cs.onTertiaryContainer : cs.onErrorContainer,
                            height: 1.4,
                          )),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text(
              'The link expires in 1 hour and can only be used once.',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
