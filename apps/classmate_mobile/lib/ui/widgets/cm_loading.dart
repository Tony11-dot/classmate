import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CmLoading — uses the real icon PNG so it matches the drawer exactly.
//  Falls back to a drawn version only when the asset is unavailable.
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
