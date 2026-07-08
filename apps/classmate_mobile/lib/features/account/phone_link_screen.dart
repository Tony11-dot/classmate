// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../ui/widgets/cm_loading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/http/cm_api.dart';
import '../../l10n/app_localizations.dart';

/// Post-login 2FA linking step: shown when the freshly signed-in account has
/// no phone number on file. Sends a 6-digit SMS to the number the user types
/// (POST /me/verify/sms/start with newValue — set + verify in one step) and
/// links it on confirm. The same number may back several accounts (parents /
/// siblings share phones) — the server only global-uniques email, not phone.
class PhoneLinkScreen extends ConsumerStatefulWidget {
  const PhoneLinkScreen({super.key});

  /// Returns true if the logged-in user has no phone linked yet.
  static Future<bool> needsLink(String token) async {
    try {
      final raw = await CMApi(token: token).getJson('/me/verify/status');
      if (raw is! Map) return false;
      final phone = raw['phone'];
      return phone == null || '$phone'.trim().isEmpty;
    } catch (_) {
      // Status read failed (offline / cold start) — never block the login.
      return false;
    }
  }

  @override
  ConsumerState<PhoneLinkScreen> createState() => _PhoneLinkScreenState();
}

class _PhoneLinkScreenState extends ConsumerState<PhoneLinkScreen> {
  final TextEditingController _phoneCtl = TextEditingController();
  final TextEditingController _codeCtl = TextEditingController();
  bool _sending = false;
  bool _verifying = false;
  String? _sentTo; // E.164 the code went to; null = phone entry stage

  @override
  void dispose() {
    _phoneCtl.dispose();
    _codeCtl.dispose();
    super.dispose();
  }

  CMApi get _api =>
      CMApi(token: (ref.read(authSessionProvider).token ?? '').trim());

  /// Normalizes local input to E.164. "05x…" → "+9725x…"; digits without a
  /// "+" get the IL country code — the app's launch market.
  String _normalize(String raw) {
    var v = raw.trim().replaceAll(RegExp(r'[\s\-().]'), '');
    if (v.isEmpty) return '';
    if (v.startsWith('00')) v = '+${v.substring(2)}';
    if (v.startsWith('+')) return v;
    if (v.startsWith('0')) return '+972${v.substring(1)}';
    return '+972$v';
  }

  Future<void> _sendCode() async {
    final l = AppLocalizations.of(context)!;
    final phone = _normalize(_phoneCtl.text);
    if (phone.length < 11) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.phoneLinkInvalid)));
      return;
    }
    setState(() => _sending = true);
    try {
      await _api.postJson('/me/verify/sms/start', body: {'newValue': phone});
      setState(() => _sentTo = phone);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _confirm() async {
    final l = AppLocalizations.of(context)!;
    final code = _codeCtl.text.trim();
    if (code.length != 6 || _sentTo == null) return;
    setState(() => _verifying = true);
    try {
      await _api.postJson('/me/verify/sms/confirm',
          body: {'code': code, 'newValue': _sentTo});
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.phoneLinkDone)));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final codeStage = _sentTo != null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.phonelink_lock_rounded, size: 56, color: cs.primary),
              const SizedBox(height: 18),
              Text(
                l.phoneLinkTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                codeStage
                    ? l.phoneLinkCodeSent(_sentTo!)
                    : l.phoneLinkSubtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant, height: 1.4),
              ),
              const SizedBox(height: 26),
              if (!codeStage)
                TextField(
                  controller: _phoneCtl,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l.phoneLinkFieldLabel,
                    hintText: '+972 50 123 4567',
                    prefixIcon: const Icon(Icons.phone_rounded),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _sendCode(),
                )
              else
                TextField(
                  controller: _codeCtl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 10,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    labelText: l.phoneLinkCodeLabel,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _confirm(),
                ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: (_sending || _verifying)
                    ? null
                    : codeStage
                        ? _confirm
                        : _sendCode,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: (_sending || _verifying)
                    ? const CmLoading(size: 20)
                    : Text(
                        codeStage ? l.phoneLinkVerify : l.phoneLinkSend,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
              ),
              if (codeStage)
                TextButton(
                  onPressed: _sending
                      ? null
                      : () {
                          setState(() => _sentTo = null);
                          _codeCtl.clear();
                        },
                  child: Text(l.phoneLinkResend),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  l.phoneLinkLater,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
