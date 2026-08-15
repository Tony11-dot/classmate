import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart' show BrandTint;

/// Full ClassMate logo — the `logo_light.png` open-book mark + "ClassMate"
/// wordmark. Supply [height] or [width] and the other dimension scales to
/// keep the asset's aspect ratio.
///
/// The mark is a two-tone brand asset (navy strokes + a light-blue book base,
/// navy wordmark). On light backgrounds it renders in its TRUE brand colours;
/// flattening it to a single tint via srcIn (as we used to) collapsed the
/// two-tone into one blue blob and hid the new identity. On dark themes those
/// navy tones would disappear, so there — and only there — the whole mark is
/// recoloured to the theme's [onSurface] (a light tone) so it stays legible.
class ClassMateLogo extends StatelessWidget {
  const ClassMateLogo({super.key, this.height, this.width});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = scheme.brightness == Brightness.dark;
    return Image.asset(
      'assets/images/logo_light.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
      // Light themes: no filter → true brand colours. Dark themes: recolour to
      // a legible light tone.
      color: isDark ? scheme.onSurface : null,
      colorBlendMode: isDark ? BlendMode.srcIn : null,
      errorBuilder: (_, _, _) => _FallbackIconMark(
        size: height ?? width ?? 28,
        color: isDark ? scheme.onSurface : scheme.primary,
      ),
    );
  }
}

/// Just the CM icon mark — the single blue `icon_light.png` recoloured to the
/// theme's [BrandTint] (the theme primary) unless an explicit [color] is given.
class ClassMateIcon extends StatelessWidget {
  const ClassMateIcon({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint =
        color ?? BrandTint.of(context) ?? Theme.of(context).colorScheme.primary;
    return Image.asset(
      'assets/images/icon_light.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: tint,
      colorBlendMode: BlendMode.srcIn,
      errorBuilder: (_, _, _) => _FallbackIconMark(size: size, color: tint),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback CM mark — drawn from primitives if the PNG fails to load.
// ─────────────────────────────────────────────────────────────────────────────

class _FallbackIconMark extends StatelessWidget {
  const _FallbackIconMark({required this.size, this.color});
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return SizedBox(width: size, height: size, child: CustomPaint(painter: _CmPainter(color: c)));
  }
}

class _CmPainter extends CustomPainter {
  const _CmPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final S = size.width;
    final cx = S * 0.5, cy = S * 0.5;
    final cMid = S * 0.375, cStroke = S * 0.155;
    const gapDeg = 72.0;
    final startAngle = (gapDeg / 2) * math.pi / 180;
    final sweepAngle = (360.0 - gapDeg) * math.pi / 180;
    final cPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = cStroke
      ..strokeCap = StrokeCap.butt
      ..isAntiAlias = true;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: cMid), startAngle, sweepAngle, false, cPaint);

    final mHalfW = S * 0.185, mHalfH = S * 0.235;
    final mLeft = cx - mHalfW, mRight = cx + mHalfW;
    final mTop = cy - mHalfH, mBottom = cy + mHalfH;
    final mStroke = S * 0.077;
    final lx = mLeft + mStroke / 2, rx = mRight - mStroke / 2;
    final midY = mTop + (mBottom - mTop) * 0.42;
    final mPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = mStroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter
      ..strokeMiterLimit = 8.0
      ..isAntiAlias = true;
    canvas.drawPath(
      Path()
        ..moveTo(lx, mBottom)
        ..lineTo(lx, mTop)
        ..lineTo(cx, midY)
        ..lineTo(rx, mTop)
        ..lineTo(rx, mBottom),
      mPaint,
    );
  }

  @override
  bool shouldRepaint(_CmPainter old) => old.color != color;
}
