import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_session.dart';
import '../../l10n/app_localizations.dart';

/// Legal landing (Privacy · Terms · Delete account) — same URL the drawer uses.
const _legalUrl = 'https://tony11-dot.github.io/classmate-legal/';

/// One-time consent gate (Israel Privacy Amendment 13). Rendered on top of the
/// app shell when `authSession.consentRequired` is true, so a user must accept
/// the Privacy Policy + Terms once before continuing. School-provisioned users
/// (who never went through self-signup) get their per-account consent recorded
/// here; the acceptance is stored server-side via /account/consent.
///
/// Non-destructive: it only overlays; it never alters navigation or existing
/// screens. Disappears the moment consent is recorded.
class ConsentGate extends ConsumerWidget {
  const ConsentGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsConsent =
        ref.watch(authSessionProvider.select((s) => s.consentRequired));
    return Stack(
      children: [
        child,
        if (needsConsent) const _ConsentOverlay(),
      ],
    );
  }
}

class _ConsentOverlay extends ConsumerStatefulWidget {
  const _ConsentOverlay();

  @override
  ConsumerState<_ConsentOverlay> createState() => _ConsentOverlayState();
}

class _ConsentOverlayState extends ConsumerState<_ConsentOverlay> {
  bool _accepted = false;
  bool _guardian = false;
  bool _busy = false;

  Future<void> _openPolicy() async {
    final uri = Uri.parse(_legalUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {/* ignore — the acceptance itself doesn't depend on this */}
  }

  Future<void> _submit() async {
    if (!_accepted || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(authSessionProvider).acceptConsent(guardianConsent: _guardian);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    // Full-screen scrim — blocks interaction with the app underneath. A
    // PopScope prevents dismissing it with the system back button.
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.privacy_tip_outlined, size: 34, color: cs.primary),
                    const SizedBox(height: 14),
                    Text(
                      l.consentGateTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.consentGateBody,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 14),
                    TextButton.icon(
                      onPressed: _openPolicy,
                      icon: const Icon(Icons.open_in_new_rounded, size: 18),
                      label: Text(l.consentGateLink),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                    const SizedBox(height: 6),
                    CheckboxListTile(
                      value: _accepted,
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _accepted = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(l.consentGateAccept),
                    ),
                    CheckboxListTile(
                      value: _guardian,
                      onChanged: _busy
                          ? null
                          : (v) => setState(() => _guardian = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(l.consentGateGuardian),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: (_accepted && !_busy) ? _submit : null,
                        child: _busy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l.consentGateContinue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
