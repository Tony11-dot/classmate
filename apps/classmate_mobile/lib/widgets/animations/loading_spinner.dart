import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A static CM-monogram icon with a continuous arc sweeping around it.
///
/// The icon asset is chosen automatically based on [Theme.of(context).brightness]
/// (dark → [icon_dark.png] on light backgrounds; light → [icon_light.png] on dark
/// backgrounds) unless [brightness] is supplied explicitly.
///
/// The arc is drawn by [_SpinArcPainter] and never warps the underlying PNG.
class ClassMateLoader extends StatefulWidget {
  const ClassMateLoader({
    super.key,
    this.size = 80,
    this.arcColor,
    this.strokeWidth = 3,
    this.brightness,
  });

  /// Diameter of the whole widget (icon + arc share the same bounding box).
  final double size;

  /// Color of the spinning arc. Defaults to [ColorScheme.onSurface].
  final Color? arcColor;

  /// Stroke width of the spinning arc in logical pixels.
  final double strokeWidth;

  /// Force a specific brightness instead of inheriting from the theme.
  final Brightness? brightness;

  @override
  State<ClassMateLoader> createState() => _ClassMateLoaderState();
}

class _ClassMateLoaderState extends State<ClassMateLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness =
        widget.brightness ?? Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final arcColor =
        widget.arcColor ?? Theme.of(context).colorScheme.onSurface;

    // The icon sits pixel-perfect in the center; the CustomPaint arc is drawn
    // on top in a Stack so neither layer distorts the other.
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Static icon — never rotated, never scaled beyond natural size.
          Image.asset(
            isDark
                ? 'assets/images/icon_dark.png'
                : 'assets/images/icon_light.png',
            width: widget.size * 0.52,
            height: widget.size * 0.52,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
          ),
          // Spinning arc drawn over the full bounding box.
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, child) => CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _SpinArcPainter(
                progress: _ctrl.value,
                color: arcColor,
                strokeWidth: widget.strokeWidth,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints a single arc that sweeps continuously around the icon.
///
/// The arc covers ~240° of the circle; a ~120° gap trails behind the leading
/// edge, giving a clean "comet tail" effect.
class _SpinArcPainter extends CustomPainter {
  const _SpinArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  static const double _sweepDeg = 240;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Leading edge angle in radians (rotates once per cycle).
    final leadAngle = progress * 2 * math.pi - math.pi / 2;
    final sweepRad = _sweepDeg * math.pi / 180;
    final startAngle = leadAngle - sweepRad;

    canvas.drawArc(
      rect,
      startAngle,
      sweepRad,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_SpinArcPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
