import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/http/cm_api.dart';

enum _ResetMode { email, sms, admin }

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

  // Admin-mode state
  bool _lookingUp = false;
  String? _schoolName;
  List<_AdminOption> _admins = const [];
  _AdminOption? _pickedAdmin;
  final _pw1Ctrl = TextEditingController();
  final _pw2Ctrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _pw1Ctrl.dispose();
    _pw2Ctrl.dispose();
    super.dispose();
  }

  // ── Email / SMS submission ─────────────────────────────────────────────

  Future<void> _submitChannelReset() async {
    final identifier = _identifierCtrl.text.trim();
    if (identifier.isEmpty) {
      setState(() { _message = 'Enter your email or username to continue.'; _success = false; });
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
      setState(() {
        _success = true;
        _message = (raw is Map ? raw['message']?.toString() : null)
            ?? (_mode == _ResetMode.email
                ? 'If an account matches, we just sent a reset link to its email.'
                : 'If an account matches, we just sent a reset link to its phone.');
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _success = false; _message = 'Something went wrong. Check your connection and try again.'; });
    } finally {
      api.dispose();
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ── Admin-mode lookup + submission ─────────────────────────────────────

  Future<void> _lookupAdmins() async {
    final identifier = _identifierCtrl.text.trim();
    if (identifier.isEmpty) {
      setState(() { _message = 'Enter your email or username first.'; _success = false; });
      return;
    }
    setState(() {
      _lookingUp = true;
      _message = null;
      _admins = const [];
      _pickedAdmin = null;
      _schoolName = null;
    });

    final api = CMApi();
    try {
      final raw = await api.postJson('/auth/password-request/lookup', body: {'identifier': identifier});
      if (!mounted) return;
      final list = raw is Map ? raw['admins'] : null;
      final adminList = list is List
          ? list.whereType<Map>().map((m) => _AdminOption(
                id: m['id']?.toString() ?? '',
                name: m['name']?.toString() ?? '',
                email: m['email']?.toString(),
              )).where((a) => a.id.isNotEmpty).toList()
          : <_AdminOption>[];
      setState(() {
        _admins = adminList;
        _schoolName = raw is Map ? raw['schoolName']?.toString() : null;
        if (adminList.isEmpty) {
          _success = false;
          _message = "We couldn't find any admins for that account. Double-check the email or username and try again.";
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _success = false; _message = 'Look-up failed. Check your connection.'; });
    } finally {
      api.dispose();
      if (mounted) setState(() => _lookingUp = false);
    }
  }

  Future<void> _submitAdminRequest() async {
    final identifier = _identifierCtrl.text.trim();
    final adminId = _pickedAdmin?.id;
    final pw1 = _pw1Ctrl.text;
    final pw2 = _pw2Ctrl.text;
    if (adminId == null || adminId.isEmpty) {
      setState(() { _message = 'Pick an admin to send your request to.'; _success = false; });
      return;
    }
    if (pw1.length < 8) {
      setState(() { _message = 'Password must be at least 8 characters.'; _success = false; });
      return;
    }
    if (pw1 != pw2) {
      setState(() { _message = "The two passwords don't match."; _success = false; });
      return;
    }
    setState(() { _submitting = true; _message = null; });

    final api = CMApi();
    try {
      final raw = await api.postJson('/auth/password-request/submit', body: {
        'identifier': identifier,
        'adminId': adminId,
        'desiredPassword': pw1,
      });
      if (!mounted) return;
      setState(() {
        _success = true;
        _message = (raw is Map ? raw['message']?.toString() : null)
            ?? 'Request sent. Your admin will receive a notification.';
        // Clear sensitive fields after success.
        _pw1Ctrl.clear();
        _pw2Ctrl.clear();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _success = false; _message = 'Something went wrong. Try again.'; });
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

    String headerCopy;
    switch (_mode) {
      case _ResetMode.email:
        headerCopy = "Enter your email or username and we'll email you a reset link.";
        break;
      case _ResetMode.sms:
        headerCopy = "Enter your email or username and we'll text a reset link to the phone on your account.";
        break;
      case _ResetMode.admin:
        headerCopy = "If you don't have an email or phone on file, an admin from your school can approve a new password for you.";
        break;
    }

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
            Text('Reset your password',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(headerCopy,
                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.45)),
            const SizedBox(height: 24),

            // Mode picker
            SegmentedButton<_ResetMode>(
              segments: const [
                ButtonSegment(value: _ResetMode.email, label: Text('Email'), icon: Icon(Icons.mail_outline_rounded)),
                ButtonSegment(value: _ResetMode.sms,   label: Text('SMS'),   icon: Icon(Icons.sms_outlined)),
                ButtonSegment(value: _ResetMode.admin, label: Text('Admin'), icon: Icon(Icons.shield_outlined)),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() {
                _mode = s.first;
                _message = null;
                _admins = const [];
                _pickedAdmin = null;
                _schoolName = null;
              }),
            ),
            const SizedBox(height: 20),

            // Identifier field — used in every mode
            TextField(
              controller: _identifierCtrl,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email or username',
                prefixIcon: const Icon(Icons.alternate_email_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onSubmitted: (_) {
                if (_mode == _ResetMode.admin) _lookupAdmins();
                else _submitChannelReset();
              },
            ),
            const SizedBox(height: 20),

            // Per-mode body
            if (_mode != _ResetMode.admin) ...[
              FilledButton.icon(
                onPressed: _submitting ? null : _submitChannelReset,
                icon: _submitting
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(_mode == _ResetMode.email ? Icons.send_rounded : Icons.sms_rounded),
                label: Text(_mode == _ResetMode.email ? 'Email me a reset link' : 'Text me a reset link'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ] else ...[
              FilledButton.tonalIcon(
                onPressed: _lookingUp ? null : _lookupAdmins,
                icon: _lookingUp
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.search_rounded),
                label: const Text('Find my school\'s admins'),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
              if (_admins.isNotEmpty) ...[
                const SizedBox(height: 20),
                if (_schoolName != null && _schoolName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text('Choose an admin from $_schoolName:',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ),
                DropdownButtonFormField<_AdminOption>(
                  initialValue: _pickedAdmin,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Send request to',
                    prefixIcon: const Icon(Icons.shield_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  items: _admins.map((a) => DropdownMenuItem(
                    value: a,
                    child: Text(a.email != null && a.email!.isNotEmpty
                        ? '${a.name} (${a.email})' : a.name),
                  )).toList(),
                  onChanged: (v) => setState(() => _pickedAdmin = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pw1Ctrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'New password',
                    helperText: 'At least 8 characters. Stored hashed — your admin will not see it.',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pw2Ctrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Confirm new password',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onSubmitted: (_) => _submitAdminRequest(),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _submitting ? null : _submitAdminRequest,
                  icon: _submitting
                      ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_rounded),
                  label: const Text('Send password request'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
              ],
            ],

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
              _mode == _ResetMode.admin
                  ? 'Admin requests stay pending for up to 24 hours.'
                  : 'The link expires in 1 hour and can only be used once.',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminOption {
  const _AdminOption({required this.id, required this.name, this.email});
  final String id;
  final String name;
  final String? email;

  @override
  bool operator ==(Object other) => other is _AdminOption && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
