import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/theme_controller.dart';
import 'cm_splash_screen.dart';

/// Launch splash. If [assets/animations/splash.json] exists in the
/// bundle, render that Lottie animation full-screen and call
/// [onComplete] when it finishes. Otherwise fall back to the custom-
/// painted [CmSplashScreen] (C-arc + M + typing tagline).
///
/// The splash runs BEFORE the MaterialApp mounts, so it resolves the
/// user's saved theme straight from prefs and dresses itself to match:
/// themed background, the animation's baked white canvas + navy mark
/// recoloured to the theme's surface + primary, and soft decorative
/// shapes filling the dead space around the centred animation.
///
/// Used by main.dart before the main app mounts.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Async probe: which Lottie files exist in the bundle? We check
  /// once on init and decide which renderer to use. AssetBundle.load
  /// throws if the asset isn't declared in pubspec OR missing from the
  /// build, which is the signal to fall back to the custom painter.
  bool? _hasLottie;
  bool _hasDarkLottie = false;

  /// The user's saved theme, read directly from prefs (the theme
  /// controller hasn't loaded yet at splash time).
  AppTheme _theme = AppTheme.light;

  @override
  void initState() {
    super.initState();
    _probe();
  }

  Future<void> _probe() async {
    bool light = false, dark = false;
    AppTheme theme = AppTheme.light;
    try {
      await rootBundle.load('assets/animations/splash.json');
      light = true;
    } catch (_) {}
    try {
      await rootBundle.load('assets/animations/splash-dark.json');
      dark = true;
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      theme = appThemeFromName(prefs.getString('ui_mode'));
    } catch (_) {}
    if (mounted) {
      setState(() {
        _hasLottie = light;
        _hasDarkLottie = dark;
        _theme = theme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final scheme = appThemeColorScheme(_theme, platformBrightness);
    final tinted = appThemeIsTinted(_theme);
    // Tinted themes pin their own brightness; the defaults follow the OS.
    final isDark = tinted
        ? scheme.brightness == Brightness.dark
        : platformBrightness == Brightness.dark;
    final bg =
        tinted ? scheme.surface : (isDark ? Colors.black : Colors.white);

    if (_hasLottie == null) {
      // Probe still in flight — render a blank surface for one frame.
      // Same background the Lottie / CmSplashScreen will use so there
      // is no visible flash.
      return ColoredBox(color: bg);
    }
    if (_hasLottie == true) {
      return _LottieSplash(
        asset: isDark && _hasDarkLottie
            ? 'assets/animations/splash-dark.json'
            : 'assets/animations/splash.json',
        onComplete: widget.onComplete,
        scheme: scheme,
        tinted: tinted,
        isDark: isDark,
        background: bg,
      );
    }
    return CmSplashScreen(onDone: widget.onComplete);
  }
}

class _LottieSplash extends StatefulWidget {
  const _LottieSplash({
    required this.asset,
    required this.onComplete,
    required this.scheme,
    required this.tinted,
    required this.isDark,
    required this.background,
  });

  final String asset;
  final VoidCallback onComplete;
  final ColorScheme scheme;
  final bool tinted;
  final bool isDark;
  final Color background;

  @override
  State<_LottieSplash> createState() => _LottieSplashState();
}

class _LottieSplashState extends State<_LottieSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Uint8List? _bytes;

  // The two colours baked into the shipped animations: the navy mark and the
  // white canvas (the dark variant has white marks on transparency).
  static const _navy = [0.047, 0.098, 0.576];
  static const _white = [1.0, 1.0, 1.0];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
    _load();
  }

  Future<void> _load() async {
    Uint8List bytes;
    try {
      final raw = await rootBundle.loadString(widget.asset);
      if (widget.tinted) {
        // Recolour the composition to the theme: the baked white canvas
        // becomes the theme surface (so the animation melts into the themed
        // background), and the navy/white mark becomes the theme primary.
        final s = widget.scheme;
        final decoded = json.decode(raw);
        if (widget.isDark) {
          _recolor(decoded, from: _white, to: s.primary);
        } else {
          _recolor(decoded, from: _white, to: s.surface);
          _recolor(decoded, from: _navy, to: s.primary);
        }
        bytes = utf8.encode(json.encode(decoded));
      } else {
        bytes = utf8.encode(raw);
      }
    } catch (_) {
      // Any parsing hiccup → play the untouched asset rather than hanging.
      try {
        bytes = utf8.encode(await rootBundle.loadString(widget.asset));
      } catch (_) {
        widget.onComplete();
        return;
      }
    }
    if (mounted) setState(() => _bytes = bytes);
  }

  /// Recursively replaces static fill/stroke colours that match [from]
  /// (0..1 rgb, small tolerance) with [to], preserving any alpha component.
  static void _recolor(dynamic node, {
    required List<double> from,
    required Color to,
  }) {
    bool matches(List k) {
      if (k.length < 3) return false;
      for (var i = 0; i < 3; i++) {
        final v = k[i];
        if (v is! num) return false;
        if ((v.toDouble() - from[i]).abs() > 0.03) return false;
      }
      return true;
    }

    if (node is Map) {
      final ty = node['ty'];
      if ((ty == 'fl' || ty == 'st') && node['c'] is Map) {
        final k = node['c']['k'];
        if (k is List && matches(k)) {
          node['c']['k'] = [
            to.r,
            to.g,
            to.b,
            if (k.length > 3) k[3] else 1,
          ];
        }
      }
      for (final v in node.values) {
        _recolor(v, from: from, to: to);
      }
    } else if (node is List) {
      for (final v in node) {
        _recolor(v, from: from, to: to);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.scheme;
    return Scaffold(
      backgroundColor: widget.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Decorative shapes filling the dead space around the animation —
          // soft blobs + hairline rings in the theme's own colours, easing
          // in so the canvas never feels like a blank sheet.
          _SplashDecor(scheme: s, isDark: widget.isDark),
          if (_bytes != null)
            Center(
              child: Lottie.memory(
                _bytes!,
                controller: _ctrl,
                fit: BoxFit.contain,
                onLoaded: (composition) {
                  // Match the controller's duration to the Lottie's natural
                  // length so it plays end-to-end exactly once, then we hand
                  // control back to main.dart via onComplete.
                  _ctrl
                    ..duration = composition.duration
                    ..forward().whenComplete(widget.onComplete);
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// The ambient background art behind the splash animation: two large soft
/// gradient blobs anchored to opposite corners, two thin concentric rings,
/// and a sprinkle of small dots — all in theme colours at low opacity, all
/// easing in together so the entrance feels composed, not busy.
class _SplashDecor extends StatelessWidget {
  const _SplashDecor({required this.scheme, required this.isDark});

  final ColorScheme scheme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    // On the pure black/white default splashes the shapes stay quieter so
    // the brand animation keeps top billing.
    final blobAlpha = isDark ? 0.20 : 0.35;
    final ringAlpha = isDark ? 0.22 : 0.28;
    final dotAlpha = isDark ? 0.30 : 0.38;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => Opacity(
        opacity: t,
        child: Transform.scale(
          scale: 0.94 + 0.06 * t,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;
              return Stack(
                children: [
                  // Top-start blob.
                  Positioned(
                    top: -h * 0.16,
                    left: -w * 0.28,
                    child: _blob(w * 0.85, scheme.primary, blobAlpha),
                  ),
                  // Bottom-end blob.
                  Positioned(
                    bottom: -h * 0.18,
                    right: -w * 0.32,
                    child: _blob(w * 0.95, scheme.tertiary, blobAlpha),
                  ),
                  // Mid-right accent blob, smaller.
                  Positioned(
                    top: h * 0.16,
                    right: -w * 0.18,
                    child: _blob(w * 0.45, scheme.secondary, blobAlpha * 0.8),
                  ),
                  // Concentric hairline rings around the centre.
                  Positioned(
                    top: h * 0.10,
                    left: w * 0.06,
                    child: _ring(w * 0.20, scheme.primary, ringAlpha),
                  ),
                  Positioned(
                    bottom: h * 0.14,
                    left: w * 0.14,
                    child: _ring(w * 0.12, scheme.tertiary, ringAlpha),
                  ),
                  Positioned(
                    top: h * 0.22,
                    right: w * 0.10,
                    child: _ring(w * 0.09, scheme.secondary, ringAlpha),
                  ),
                  // Small floating dots.
                  Positioned(
                    top: h * 0.32,
                    left: w * 0.18,
                    child: _dot(8, scheme.primary, dotAlpha),
                  ),
                  Positioned(
                    bottom: h * 0.30,
                    right: w * 0.22,
                    child: _dot(10, scheme.tertiary, dotAlpha),
                  ),
                  Positioned(
                    bottom: h * 0.20,
                    left: w * 0.42,
                    child: _dot(6, scheme.secondary, dotAlpha),
                  ),
                  Positioned(
                    top: h * 0.14,
                    right: w * 0.34,
                    child: _dot(7, scheme.primary, dotAlpha),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _blob(double size, Color color, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: alpha),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      );

  Widget _ring(double size, Color color, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: alpha),
            width: 1.6,
          ),
        ),
      );

  Widget _dot(double size, Color color, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: alpha),
        ),
      );
}
