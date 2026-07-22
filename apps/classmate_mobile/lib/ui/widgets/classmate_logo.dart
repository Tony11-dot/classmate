import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart' show BrandTint;

/// Full ClassMate logo — loads the brand asset PNG directly.
/// Light mode → logo_light.png. Dark mode → logo_dark.png.
/// The PNG itself carries the icon + "ClassMate" wordmark together;
/// supply [height] or [width] and the other dimension scales to keep
/// the asset's aspect ratio.
///
/// On tinted themes (coffee, matcha, nord, …) the whole mark — monogram AND
/// wordmark, every glyph detail intact — is recoloured to the theme's brand
/// tint via srcIn, so the logo matches each theme. The clean light asset is
/// always the alpha source when tinting (the dark one carries a baked glow
/// that would flatten badly).
class ClassMateLogo extends StatelessWidget {
  const ClassMateLogo({super.key, this.height, this.width});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = BrandTint.of(context);
    return Image.asset(
      tint != null
          ? 'assets/images/logo_light.png'
          : isDark
              ? 'assets/images/logo_dark.png'
              : 'assets/images/logo_light.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
      color: tint,
      colorBlendMode: tint != null ? BlendMode.srcIn : null,
      errorBuilder: (_, _, _) => _FallbackIconMark(
          size: height ?? width ?? 28, isDark: isDark, color: tint),
    );
  }
}

/// Just the CM icon mark. Follows the theme's [BrandTint] unless an explicit
/// [color] is given.
class ClassMateIcon extends StatelessWidget {
  const ClassMateIcon({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = color ?? BrandTint.of(context);
    return Image.asset(
      tint != null
          ? 'assets/images/icon_light.png'
          : isDark
              ? 'assets/images/icon_dark.png'
              : 'assets/images/icon_light.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: tint,
      colorBlendMode: tint != null ? BlendMode.srcIn : null,
      errorBuilder: (_, _, _) => _FallbackIconMark(size: size, isDark: isDark, color: tint),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback CM mark — drawn from primitives if the PNG fails to load.
// ─────────────────────────────────────────────────────────────────────────────

class _FallbackIconMark extends StatelessWidget {
  const _FallbackIconMark({required this.size, required this.isDark, this.color});
  final double size;
  final bool isDark;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isDark ? Colors.white : Colors.black);
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
