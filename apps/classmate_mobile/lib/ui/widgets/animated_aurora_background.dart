import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A lightweight, theme-aware animated background: a soft shifting gradient
/// with slowly drifting colored "aurora" blobs painted behind content.
///
/// Cheap enough to sit under a full screen (single repaint via one painter),
/// and subtle enough to keep foreground text/cards readable. Used on the
/// login screen and the NOVA chat screen to make them feel alive.
class AnimatedAuroraBackground extends StatefulWidget {
  const AnimatedAuroraBackground({
    super.key,
    required this.child,
    this.intensity = 1.0,
  });

  /// Foreground content rendered above the animated layers.
  final Widget child;

  /// Multiplier for blob opacity (0..1.5). Lower it where readability matters.
  final double intensity;

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
      duration: const Duration(seconds: 18),
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

    // A small palette pulled from the theme so it always matches branding.
    final blobs = <Color>[
      cs.primary,
      cs.secondary,
      cs.tertiary,
    ];

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value; // 0..1
          return Stack(
            fit: StackFit.expand,
            children: [
              // Base shifting gradient.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      math.cos(t * 2 * math.pi),
                      math.sin(t * 2 * math.pi),
                    ),
                    end: Alignment(
                      -math.cos(t * 2 * math.pi),
                      -math.sin(t * 2 * math.pi),
                    ),
                    colors: isDark
                        ? [
                            cs.surface,
                            Color.alphaBlend(
                                cs.primary.withValues(alpha: 0.14), cs.surface),
                          ]
                        : [
                            Color.alphaBlend(
                                cs.primary.withValues(alpha: 0.08), cs.surface),
                            cs.surface,
                          ],
                  ),
                ),
              ),
              // Drifting colored blobs.
              CustomPaint(
                painter: _AuroraPainter(
                  t: t,
                  colors: blobs,
                  isDark: isDark,
                  intensity: widget.intensity,
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
    final baseAlpha = (isDark ? 0.22 : 0.16) * intensity;
    for (var i = 0; i < colors.length; i++) {
      final phase = t * 2 * math.pi + i * (2 * math.pi / colors.length);
      // Each blob drifts on its own slow elliptical path.
      final cx = size.width * (0.5 + 0.42 * math.cos(phase + i));
      final cy = size.height * (0.5 + 0.40 * math.sin(phase * 1.3 + i));
      final radius = size.shortestSide * (0.45 + 0.08 * math.sin(phase * 0.7));

      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            colors[i].withValues(alpha: baseAlpha),
            colors[i].withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter old) =>
      old.t != t ||
      old.intensity != intensity ||
      old.isDark != isDark;
}
