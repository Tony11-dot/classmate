import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../http/cm_api.dart';

/// Launch-time update prompt — the "a new version is ready, tap to update"
/// card every big app shows on the first open after a release.
///
/// On start it asks the public `/version` endpoint for the latest shipped
/// mobile build and compares it against this binary's own build number
/// (read from the platform, so it can never drift from pubspec). When the
/// installed build is behind, a card is shown ONCE per new build (persisted
/// in prefs) with an Update button that jumps to the store:
/// Play listing on Android, TestFlight (env-steerable to the App Store page
/// at public launch) on iOS.
///
/// Rendered as its own overlay inside MaterialApp.builder — above the router,
/// the desktop chrome and every pushed route — so it needs no Navigator and
/// can never be covered. Web is skipped: a browser refresh already serves the
/// newest bundle. Any failure here is swallowed; an update nudge must never
/// affect launch.
class UpdateGate extends StatefulWidget {
  const UpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  static const String _shownForBuildKey = 'update_prompt_shown_for_build';

  bool _visible = false;
  String _storeUrl = '';

  @override
  void initState() {
    super.initState();
    // Off the launch path: let the splash/first frame settle first.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(seconds: 2), _check);
    });
  }

  Future<void> _check() async {
    if (kIsWeb || !mounted) return;
    try {
      final info = await PackageInfo.fromPlatform();
      final current = int.tryParse(info.buildNumber.trim()) ?? 0;
      if (current <= 0) return;

      final raw = await CMApi().getJson('/version');
      final mobile = raw is Map && raw['mobile'] is Map
          ? Map<String, dynamic>.from(raw['mobile'] as Map)
          : const <String, dynamic>{};
      final latest = (mobile['latestBuild'] as num?)?.toInt() ?? 0;
      if (latest <= current) return;

      // "First time after the update" — surface each new build exactly once,
      // not on every open.
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getInt(_shownForBuildKey) == latest) return;
      await prefs.setInt(_shownForBuildKey, latest);

      final url = (Platform.isIOS ? mobile['iosUrl'] : mobile['androidUrl'])
          ?.toString()
          .trim();
      if (!mounted || url == null || url.isEmpty) return;
      setState(() {
        _visible = true;
        _storeUrl = url;
      });
    } catch (_) {
      // Best-effort — cold server, no network, bad payload: just stay quiet.
    }
  }

  Future<void> _openStore() async {
    final url = _storeUrl;
    if (mounted) setState(() => _visible = false);
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_visible) _promptOverlay(context),
      ],
    );
  }

  Widget _promptOverlay(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.45 * t),
            child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Material(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.primaryContainer,
                      ),
                      alignment: Alignment.center,
                      child: Icon(Icons.system_update_rounded,
                          size: 30, color: scheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l?.updatePromptTitle ?? 'Update available',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l?.updatePromptBody ??
                          'A new version of ClassMate is ready. Update now to get the latest features and fixes.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _openStore,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(l?.updatePromptUpdate ?? 'Update'),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _visible = false),
                      child: Text(
                        l?.updatePromptLater ?? 'Not now',
                        style: TextStyle(color: scheme.onSurfaceVariant),
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
