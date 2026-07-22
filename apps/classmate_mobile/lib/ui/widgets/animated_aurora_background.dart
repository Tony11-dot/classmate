import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'ambient_symbols.dart';

/// A lively, theme-aware animated background: a slowly shifting gradient with
/// several drifting, colorful "aurora" blobs — plus a layer of floating
/// educational symbols (♪ ∫ π `</>` calculators, stars, curved lines…) —
/// painted behind content. Designed to feel alive (clear motion + real color)
/// while staying cheap and readable for foreground text/cards.
///
/// Honors reduce-motion (Settings → Appearance): when the app's
/// MediaQuery.disableAnimations flag is on, both the aurora and the symbols
/// freeze into a static composition.
///
/// Used full-screen on the login screen and the NOVA chat.
class AnimatedAuroraBackground extends StatefulWidget {
  const AnimatedAuroraBackground({
    super.key,
    required this.child,
    this.intensity = 1.0,
    this.symbols = true,
    this.symbolsSeed = 7,
    this.symbolsOpacity = 1.0,
  });

  /// Foreground content rendered above the animated layers.
  final Widget child;

  /// Multiplier for blob opacity / liveliness (0..1.5). Lower it where dense
  /// text sits on top (e.g. chat), raise it on sparse screens (e.g. login).
  final double intensity;

  /// Whether to scatter the floating educational symbols over the aurora.
  final bool symbols;

  /// Per-screen scatter layout — different screens, different sky.
  final int symbolsSeed;

  /// Opacity multiplier for the symbol layer (drop below 1 on busy screens).
  final double symbolsOpacity;

  @override
  State<AnimatedAuroraBackground> createState() =>
      _AnimatedAuroraBackgroundState();
}

class _AnimatedAuroraBackgroundState extends State<AnimatedAuroraBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Reduce-motion: the app-level MediaQuery flag (set from Settings) stops
    // the drift entirely — the background becomes a still composition.
    final animate = !MediaQuery.of(context).disableAnimations;
    if (animate && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!animate && _ctrl.isAnimating) {
      _ctrl.stop();
    }

    // A vivid palette: blend a few fixed accent hues toward the theme so it's
    // always colorful and lively, not just a faint tint of the primary.
    Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;
    final blobs = <Color>[
      mix(const Color(0xFF2563EB), cs.primary, 0.35), // brand blue
      const Color(0xFF7C3AED),                        // violet
      const Color(0xFF06B6D4),                        // cyan
      const Color(0xFFEC4899),                        // pink
      mix(const Color(0xFF22C55E), cs.tertiary, 0.4), // green
    ];

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value; // 0..1
          final angle = t * 2 * math.pi;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Base shifting gradient — a soft surface wash so the blobs read.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(math.cos(angle), math.sin(angle)),
                    end: Alignment(-math.cos(angle), -math.sin(angle)),
                    colors: isDark
                        ? [
                            const Color(0xFF0B1020),
                            Color.alphaBlend(
                                cs.primary.withValues(alpha: 0.20),
                                const Color(0xFF0B1020)),
                          ]
                        : [
                            Color.alphaBlend(
                                cs.primary.withValues(alpha: 0.10), cs.surface),
                            Color.alphaBlend(
                                const Color(0xFF7C3AED).withValues(alpha: 0.05),
                                cs.surface),
                          ],
                  ),
                ),
              ),
              // Drifting colored blobs.
              ExcludeSemantics(
                child: CustomPaint(
                  painter: _AuroraPainter(
                    t: t,
                    colors: blobs,
                    isDark: isDark,
                    intensity: widget.intensity,
                  ),
                ),
              ),
              // Floating educational symbols riding above the aurora —
              // the aurora already provides the blobs, so blobs: false.
              if (widget.symbols)
                ExcludeSemantics(
                  child: AmbientSymbols(
                    animate: animate,
                    seed: widget.symbolsSeed,
                    opacity: widget.symbolsOpacity,
                    blobs: false,
                  ),
                ),
              widget.child,
            ],
          );
        },
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter({
    required this.t,
    required this.colors,
    required this.isDark,
    required this.intensity,
  });

  final double t;
  final List<Color> colors;
  final bool isDark;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final baseAlpha = (isDark ? 0.42 : 0.34) * intensity;
    for (var i = 0; i < colors.length; i++) {
      final phase = t * 2 * math.pi + i * (2 * math.pi / colors.length);
      // Each blob drifts on its own slow elliptical path, with a little extra
      // wobble so the motion never looks like a single rigid rotation.
      final cx = size.width *
          (0.5 + 0.46 * math.cos(phase + i) + 0.05 * math.sin(phase * 2.3));
      final cy = size.height *
          (0.5 + 0.44 * math.sin(phase * 1.25 + i) + 0.05 * math.cos(phase * 1.9));
      final radius = size.shortestSide * (0.50 + 0.10 * math.sin(phase * 0.7));

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            colors[i].withValues(alpha: baseAlpha),
            colors[i].withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        )
        ..blendMode = BlendMode.plus // additive → richer where blobs overlap
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60);
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t || old.intensity != intensity || old.isDark != isDark;
}
