import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/http/cm_api.dart';

enum _ResetChannel { email, sms }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _identifierCtrl = TextEditingController();
  _ResetChannel _channel = _ResetChannel.email;
  bool _submitting = false;
  String? _message;
  bool _success = false;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final identifier = _identifierCtrl.text.trim();
    if (identifier.isEmpty) {
      setState(() {
        _message = 'Enter your email or username to continue.';
        _success = false;
      });
      return;
    }
    setState(() {
      _submitting = true;
      _message = null;
    });

    final api = CMApi();
    try {
      final raw = await api.postJson('/auth/forgot-password', body: {
        'identifier': identifier,
        'channel': _channel == _ResetChannel.email ? 'email' : 'sms',
      });
      if (!mounted) return;
      setState(() {
        _success = true;
        _message = (raw is Map ? raw['message']?.toString() : null)
            ?? (_channel == _ResetChannel.email
                ? 'If an account matches, we just sent a reset link to its email.'
                : 'If an account matches, we just sent a reset link to its phone.');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _success = false;
        _message = 'Something went wrong. Check your connection and try again.';
      });
    } finally {
      api.dispose();
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isEmail = _channel == _ResetChannel.email;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            Text(
              'Reset your password',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              isEmail
                  ? "Enter your email or username and we'll email you a link to set a new password."
                  : "Enter your email or username and we'll text a link to the phone on your account.",
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.45),
            ),
            const SizedBox(height: 24),

            // Channel picker
            SegmentedButton<_ResetChannel>(
              segments: const [
                ButtonSegment(value: _ResetChannel.email, label: Text('Email'), icon: Icon(Icons.mail_outline_rounded)),
                ButtonSegment(value: _ResetChannel.sms,   label: Text('SMS'),   icon: Icon(Icons.sms_outlined)),
              ],
              selected: {_channel},
              onSelectionChanged: (s) => setState(() {
                _channel = s.first;
                _message = null;
              }),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _identifierCtrl,
              autofocus: true,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email or username',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(isEmail ? Icons.send_rounded : Icons.sms_rounded),
              label: Text(isEmail ? 'Email me a reset link' : 'Text me a reset link'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
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
                    Icon(
                      _success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                      color: _success ? cs.tertiary : cs.error,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _message!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _success ? cs.onTertiaryContainer : cs.onErrorContainer,
                          height: 1.4,
                        ),
                      ),
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
    );
  }
}
