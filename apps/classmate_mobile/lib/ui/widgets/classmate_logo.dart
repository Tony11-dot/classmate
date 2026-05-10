import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Full ClassMate logo — real image asset.
/// Light mode → logo_light.png (black).  Dark mode → logo_dark.png (white).
/// Supply either [height] or [width] — the other dimension scales to maintain
/// the asset's aspect ratio (BoxFit.contain).
class ClassMateLogo extends StatelessWidget {
  const ClassMateLogo({super.key, this.height, this.width});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark
          ? 'assets/images/logo_dark.png'
          : 'assets/images/logo_light.png',
      height: height,
      width: width,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
          _FallbackLogo(height: height ?? 28, isDark: isDark),
    );
  }
}

/// Just the CM icon mark.
class ClassMateIcon extends StatelessWidget {
  const ClassMateIcon({super.key, this.size = 24, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark
          ? 'assets/images/icon_dark.png'
          : 'assets/images/icon_light.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Apply color tint if requested (e.g. in drawer button)
      color: color,
      colorBlendMode: color != null ? BlendMode.srcIn : null,
      errorBuilder: (_, __, ___) => _FallbackIcon(size: size, isDark: isDark, color: color),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback drawn versions (used if image assets aren't present yet)
// ─────────────────────────────────────────────────────────────────────────────

class _FallbackLogo extends StatelessWidget {
  const _FallbackLogo({required this.height, required this.isDark});
  final double height;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isDark ? Colors.white : Colors.black;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: height, height: height, child: CustomPaint(painter: _CmPainter(color: color))),
        SizedBox(width: height * 0.30),
        Text('ClassMate', style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: height * 0.84, letterSpacing: -0.5, height: 1)),
      ],
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.size, required this.isDark, this.color});
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
    final cPaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = cStroke..strokeCap = StrokeCap.butt..isAntiAlias = true;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: cMid), startAngle, sweepAngle, false, cPaint);
    final mHalfW = S * 0.185, mHalfH = S * 0.235;
    final mLeft = cx - mHalfW, mRight = cx + mHalfW;
    final mTop = cy - mHalfH, mBottom = cy + mHalfH;
    final mStroke = S * 0.077;
    final lx = mLeft + mStroke / 2, rx = mRight - mStroke / 2;
    final midY = mTop + (mBottom - mTop) * 0.42;
    final mPaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = mStroke..strokeCap = StrokeCap.butt..strokeJoin = StrokeJoin.miter..strokeMiterLimit = 8.0..isAntiAlias = true;
    canvas.drawPath(Path()..moveTo(lx, mBottom)..lineTo(lx, mTop)..lineTo(cx, midY)..lineTo(rx, mTop)..lineTo(rx, mBottom), mPaint);
  }

  @override
  bool shouldRepaint(_CmPainter old) => old.color != color;
}
