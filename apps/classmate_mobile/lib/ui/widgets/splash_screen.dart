import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/theme_controller.dart';
import 'ambient_symbols.dart';
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

  /// The user's saved theme, read directly from prefs (the theme
  /// controller hasn't loaded yet at splash time).
  AppTheme _theme = AppTheme.light;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _probe();
  }

  Future<void> _probe() async {
    bool light = false;
    AppTheme theme = AppTheme.light;
    try {
      await rootBundle.load('assets/animations/splash.json');
      light = true;
    } catch (_) {}
    bool reduceMotion = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      theme = appThemeFromName(prefs.getString('ui_mode'));
      reduceMotion = prefs.getBool('ui_reduce_motion') ?? false;
    } catch (_) {}
    if (mounted) {
      setState(() {
        _hasLottie = light;
        _theme = theme;
        _reduceMotion = reduceMotion;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final scheme = appThemeColorScheme(_theme, platformBrightness);
    // One source animation, always recoloured to the theme, so the background
    // is simply the theme's surface (white on Light, dark on Dark, tinted
    // elsewhere) — the animation melts into it.
    final bg = scheme.surface;

    if (_hasLottie == null) {
      // Probe still in flight — render a blank surface for one frame.
      // Same background the Lottie / CmSplashScreen will use so there
      // is no visible flash.
      return ColoredBox(color: bg);
    }
    if (_hasLottie == true) {
      return _LottieSplash(
        asset: 'assets/animations/splash.json',
        onComplete: widget.onComplete,
        scheme: scheme,
        background: bg,
        animateDecor: !_reduceMotion,
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
    required this.background,
    required this.animateDecor,
  });

  final String asset;
  final VoidCallback onComplete;
  final ColorScheme scheme;
  final Color background;
  final bool animateDecor;

  @override
  State<_LottieSplash> createState() => _LottieSplashState();
}

class _LottieSplashState extends State<_LottieSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  Uint8List? _bytes;

  // The colours baked into the shipped animations. Both the mark strokes AND
  // the "ClassMate" wordmark are drawn in a brand blue, so recolouring them to
  // the theme primary makes the whole animation — logo and text — adapt to the
  // active theme. `_navy` is the older export's blue; `_brandBlue` (#0F2BB6) is
  // the current launch animation's. The white canvas maps to the theme surface
  // so the animation melts into the themed background.
  static const _navy = [0.047, 0.098, 0.576];
  static const _brandBlue = [0.059, 0.169, 0.714];
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
      // One source animation, ALWAYS recoloured to the theme: the baked white
      // canvas becomes the theme surface (so the animation melts into the
      // themed background) and the navy mark becomes the theme primary. On the
      // plain Light theme (surface white, primary blue) this is near-identity,
      // so the original blue splash is preserved.
      final s = widget.scheme;
      final decoded = json.decode(raw);
      _recolor(decoded, from: _white, to: s.surface);
      _recolor(decoded, from: _navy, to: s.primary);
      // The current launch animation draws its mark + wordmark in _brandBlue,
      // which didn't match _navy and so never adapted — recolour it too.
      _recolor(decoded, from: _brandBlue, to: s.primary);
      // The monogram itself is an EMBEDDED PNG asset inside the Lottie —
      // vector recolouring can't reach it, so retint the bitmap's pixels
      // (srcIn keeps the alpha detail, replaces the colour).
      await _tintEmbeddedImages(decoded, s.primary);
      bytes = utf8.encode(json.encode(decoded));
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

  /// Retints every base64-embedded raster asset in the composition to [to]
  /// via srcIn (alpha preserved — the mark's shape survives, only the colour
  /// changes). Best-effort per image; a decode failure leaves that asset as
  /// shipped.
  static Future<void> _tintEmbeddedImages(dynamic doc, Color to) async {
    if (doc is! Map || doc['assets'] is! List) return;
    for (final asset in doc['assets'] as List) {
      if (asset is! Map) continue;
      final p = asset['p'];
      if (p is! String || !p.startsWith('data:image')) continue;
      try {
        final b64 = p.substring(p.indexOf(',') + 1);
        final srcBytes = base64Decode(b64);
        final codec = await ui.instantiateImageCodec(srcBytes);
        final image = (await codec.getNextFrame()).image;
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawImage(
          image,
          Offset.zero,
          Paint()..colorFilter = ColorFilter.mode(to, BlendMode.srcIn),
        );
        final tinted = await recorder
            .endRecording()
            .toImage(image.width, image.height);
        final png = await tinted.toByteData(format: ui.ImageByteFormat.png);
        image.dispose();
        tinted.dispose();
        if (png == null) continue;
        asset['p'] =
            'data:image/png;base64,${base64Encode(png.buffer.asUint8List())}';
      } catch (_) {
        // Leave this asset untinted.
      }
    }
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
          // Living background filling the dead space around the animation —
          // floating educational symbols, stars, curved lines, rings, dots
          // and soft blobs in the theme's colours, each with its own motion.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            builder: (context, t, child) =>
                Opacity(opacity: t, child: child),
            child: AmbientSymbols(
              scheme: s,
              animate: widget.animateDecor,
              seed: 3,
              density: 1.1,
            ),
          ),
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
