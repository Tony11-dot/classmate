import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/http/cm_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import '../../ui/widgets/phone_field.dart';

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

  // Phone the requester provides so the admin can call/text to verify
  // identity before approving. Auto-filled from the user's stored phone
  // when the lookup returns one.
  final _phoneCtrl = TextEditingController();
  String _dialCode = kDefaultDialCode;

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
    _pw1Ctrl.dispose();
    _pw2Ctrl.dispose();
    _phoneCtrl.dispose();
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
      final m = raw is Map ? raw : const <String, dynamic>{};
      final list = m['admins'];
      final adminList = list is List
          ? list.whereType<Map>().map((mm) => _AdminOption(
                id: mm['id']?.toString() ?? '',
                name: mm['name']?.toString() ?? '',
                email: mm['email']?.toString(),
              )).where((a) => a.id.isNotEmpty).toList()
          : <_AdminOption>[];
      final blocked = m['blocked']?.toString();
      // Pre-fill the phone field from the user's stored phone (if any). Saves
      // them retyping their own number; they can still change it before
      // sending.
      final currentPhone = m['currentPhone']?.toString();
      if (currentPhone != null && currentPhone.isNotEmpty) {
        final split = splitE164(currentPhone);
        _dialCode = split.dialCode;
        _phoneCtrl.text = split.localDigits;
      }
      setState(() {
        _admins = adminList;
        _schoolName = m['schoolName']?.toString();
        if (adminList.isEmpty) {
          _success = false;
          _message = switch (blocked) {
            'no_school' =>
              "This account isn't linked to a school yet, so we can't route it to an admin.",
            'no_user' || _ =>
              "We couldn't find an account with that email or username.",
          };
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
      final phoneE164 = joinE164(_dialCode, _phoneCtrl.text);
      final raw = await api.postJson('/auth/password-request/submit', body: {
        'identifier': identifier,
        'adminId': adminId,
        'desiredPassword': pw1,
        if (phoneE164 != null) 'phone': phoneE164,
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
        headerCopy = "Backup recovery — your admin approves a new password after verifying who you are. If your account has an email or phone, we'll also message it the moment a request is filed so you can reject it with one tap.";
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
                ButtonSegment(value: _ResetMode.admin, label: Text(AppLocalizations.of(context)!.forgotPasswordModeAdmin), icon: const Icon(Icons.shield_outlined)),
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
                labelText: AppLocalizations.of(context)!.loginEmailLabel,
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
                label: Text(_mode == _ResetMode.email
                    ? AppLocalizations.of(context)!.forgotPasswordEmailButton
                    : AppLocalizations.of(context)!.forgotPasswordSmsButton),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ] else ...[
              FilledButton.tonalIcon(
                onPressed: _lookingUp ? null : _lookupAdmins,
                icon: _lookingUp
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.search_rounded),
                label: Text(AppLocalizations.of(context)!.forgotPasswordFindAdmins),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
              if (_admins.isNotEmpty) ...[
                const SizedBox(height: 20),
                if (_schoolName != null && _schoolName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(AppLocalizations.of(context)!.forgotPasswordChooseAdmin(_schoolName ?? ''),
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ),
                LiquidGlassDropdown<String>(
                  label: AppLocalizations.of(context)!.forgotPasswordSendRequestTo,
                  value: _pickedAdmin?.id ?? '',
                  searchHint: 'Search admins…',
                  items: [
                    LiquidGlassDropdownItem(value: '', label: AppLocalizations.of(context)!.forgotPasswordChooseAdminDash),
                    ..._admins.map((a) => LiquidGlassDropdownItem(
                      value: a.id,
                      label: a.email != null && a.email!.isNotEmpty
                          ? '${a.name} (${a.email})'
                          : a.name,
                    )),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _pickedAdmin = v.isEmpty
                          ? null
                          : _admins.firstWhere((a) => a.id == v, orElse: () => _admins.first);
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Phone field — auto-filled from user record if any, surfaced
                // to the admin on their request card so they can call/text
                // the requester to verify identity before approving.
                PhoneField(
                  controller: _phoneCtrl,
                  dialCode: _dialCode,
                  onDialCodeChanged: (v) => setState(() => _dialCode = v),
                  labelText: AppLocalizations.of(context)!.forgotPasswordYourPhone,
                  helperText: AppLocalizations.of(context)!.forgotPasswordPhoneHelper,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _pw1Ctrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.adminEditUserNewPasswordLabel,
                    helperText: AppLocalizations.of(context)!.forgotPasswordNewPasswordHelper,
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
                    labelText: AppLocalizations.of(context)!.adminEditUserConfirmPasswordLabel,
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
                  label: Text(AppLocalizations.of(context)!.forgotPasswordSendRequest),
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
