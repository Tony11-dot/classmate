import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CmLoading — the branded loading indicator.
//  Renders the Lottie dots spinner (light/dark variants) when bundled;
//  falls back to the spinning icon PNG, then to a drawn version.
//  A `color` tint forces the PNG path (Lotties can't be tinted).
// ─────────────────────────────────────────────────────────────────────────────

class CmLoading extends StatefulWidget {
  const CmLoading({super.key, this.size = 48, this.color});

  final double size;
  final Color? color;

  @override
  State<CmLoading> createState() => _CmLoadingState();
}

class _CmLoadingState extends State<CmLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _assetFailed = false;
  bool _lottieFailed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = widget.color;

    if (_assetFailed) {
      return AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CmSpinPainter(
            turns: _ctrl.value,
            color: tint ?? (isDark ? Colors.white : Colors.black),
          ),
        ),
      );
    }

    if (tint == null && !_lottieFailed) {
      // Lottie dots spinner. The artwork lives on an 800x600 canvas with the
      // dots occupying only ~200x200 at its center, so BoxFit.contain in a
      // `size` box would render them microscopically. Instead render the
      // canvas at 4x/3x the target size and center-crop to `size` — the dots'
      // center coincides with the canvas center, so the crop stays centered.
      final s = widget.size;
      return SizedBox(
        width: s,
        height: s,
        child: ClipRect(
          child: OverflowBox(
            maxWidth: s * 4,
            maxHeight: s * 3,
            child: Lottie.asset(
              isDark
                  ? 'assets/animations/loading-dark.json'
                  : 'assets/animations/loading-light.json',
              width: s * 4,
              height: s * 3,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) setState(() => _lottieFailed = true);
                });
                return SizedBox(width: s, height: s);
              },
            ),
          ),
        ),
      );
    }

    return RotationTransition(
      turns: _ctrl,
      child: Image.asset(
        isDark
            ? 'assets/images/icon_dark.png'
            : 'assets/images/icon_light.png',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        color: tint,
        colorBlendMode: tint != null ? BlendMode.srcIn : null,
        errorBuilder: (_, __, ___) {
          // Asset missing — switch to drawn fallback on next frame.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _assetFailed = true);
          });
          return SizedBox(width: widget.size, height: widget.size);
        },
      ),
    );
  }
}

/// Drawn fallback: C arc spins around static M (same proportions as icon PNG).
class _CmSpinPainter extends CustomPainter {
  const _CmSpinPainter({required this.turns, required this.color});
  final double turns;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final S = size.width;
    final cx = S * 0.5, cy = S * 0.5;
    const gapRad = 72.0 * math.pi / 180;
    final startAngle = gapRad / 2 + turns * 2 * math.pi;
    final sweepAngle = 2 * math.pi - gapRad;

    // C arc — rotates
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: S * 0.375),
      startAngle, sweepAngle, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = S * 0.155
        ..strokeCap = StrokeCap.butt
        ..isAntiAlias = true,
    );

    // M letterform — static
    final mHalfW = S * 0.185, mHalfH = S * 0.235, mStroke = S * 0.077;
    final lx = cx - mHalfW + mStroke / 2, rx = cx + mHalfW - mStroke / 2;
    final mTop = cy - mHalfH, mBottom = cy + mHalfH;
    final midY = mTop + (mBottom - mTop) * 0.42;
    canvas.drawPath(
      Path()
        ..moveTo(lx, mBottom)
        ..lineTo(lx, mTop)
        ..lineTo(cx, midY)
        ..lineTo(rx, mTop)
        ..lineTo(rx, mBottom),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = mStroke
        ..strokeCap = StrokeCap.butt
        ..strokeJoin = StrokeJoin.miter
        ..strokeMiterLimit = 8.0
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_CmSpinPainter old) =>
      old.turns != turns || old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Full-screen loading overlay
// ─────────────────────────────────────────────────────────────────────────────

class CmLoadingScreen extends StatelessWidget {
  const CmLoadingScreen({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CmLoading(size: 56),
          if (message != null) ...[
            const SizedBox(height: 20),
            Text(message!, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 14)),
          ],
        ],
      ),
    );
  }
}
