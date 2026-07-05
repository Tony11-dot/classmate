import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CmLoading — the CM monogram draws itself on, then settles into the REAL
//  brand icon (icon_light / icon_dark per theme):
//    1. The C strokes in from its top-right tip, sweeping over the top and
//       down the left to the bottom edge.
//    2. The M rises from its bottom-left corner up the stem, down into the
//       valley, up to the top-right and down the right stem.
//    3. The painted strokes cross-fade into the actual icon PNG — so the
//       resting frame is pixel-identical to the mark used everywhere else —
//       hold, fade, loop.
//  Glyph geometry is traced from the 512px icon; small tracing error is
//  invisible because the PNG takes over for the finished frame.
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
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static double _seg(double v, double from, double to) =>
      ((v - from) / (to - from)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = widget.color;
    final strokeColor =
        tint ?? (isDark ? Colors.white : const Color(0xFF1B2B9E));

    return ExcludeSemantics(
      child: SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) {
          final v = _ctrl.value;
          final cT = Curves.easeInOutCubic.transform(_seg(v, 0.00, 0.36));
          final mT = Curves.easeInOutCubic.transform(_seg(v, 0.32, 0.64));
          final xT = _seg(v, 0.66, 0.78); // strokes → real icon
          final fT = _seg(v, 0.90, 1.00); // fade to restart
          final strokesOpacity =
              ((1 - (_assetFailed ? 0 : xT)) * (1 - fT)).clamp(0.0, 1.0);
          final iconOpacity =
              (_assetFailed ? 0.0 : xT * (1 - fT)).clamp(0.0, 1.0);

          return Stack(
            fit: StackFit.expand,
            children: [
              Opacity(
                opacity: strokesOpacity,
                child: CustomPaint(
                  painter: _CmDrawPainter(
                    cProgress: cT,
                    mProgress: mT,
                    color: strokeColor,
                    glow: isDark && tint == null,
                  ),
                ),
              ),
              Opacity(
                opacity: iconOpacity,
                child: Image.asset(
                  isDark
                      ? 'assets/images/icon_dark.png'
                      : 'assets/images/icon_light.png',
                  fit: BoxFit.contain,
                  color: tint,
                  colorBlendMode: tint != null ? BlendMode.srcIn : null,
                  errorBuilder: (_, _, _) {
                    // Asset missing — strokes carry the whole loop instead.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _assetFailed = true);
                    });
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    ),
    );
  }
}

/// Progressive stroke-reveal of the CM mark, in the icon's own 512-unit space.
class _CmDrawPainter extends CustomPainter {
  const _CmDrawPainter({
    required this.cProgress,
    required this.mProgress,
    required this.color,
    required this.glow,
  });

  final double cProgress;
  final double mProgress;
  final Color color;
  final bool glow;

  // Traced from assets/images/icon_light.png (512×512) — circle fitted
  // through the ring's outer extremes, M measured from pixel row scans.
  static const _cCenter = Offset(237, 253);
  static const _cRadius = 144.0; // stroke centerline
  static const _cStroke = 44.0;
  static const _cStartDeg = -43.0; // top-right tip
  static const _cSweepDeg = -243.0; // counterclockwise → bottom tip
  static const _mStroke = 42.0;
  static final Path _mPath = Path()
    ..moveTo(203, 340) // bottom-left corner — where the M starts drawing
    ..lineTo(203, 199)
    ..lineTo(297, 304)
    ..lineTo(400, 188)
    ..lineTo(400, 418);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide / 512.0;
    canvas.save();
    canvas.translate(
      (size.width - size.shortestSide) / 2,
      (size.height - size.shortestSide) / 2,
    );
    canvas.scale(s);

    void strokes(Paint paint) {
      if (cProgress > 0) {
        canvas.drawArc(
          Rect.fromCircle(center: _cCenter, radius: _cRadius),
          _cStartDeg * math.pi / 180,
          _cSweepDeg * math.pi / 180 * cProgress,
          false,
          paint..strokeWidth = _cStroke,
        );
      }
      if (mProgress > 0) {
        for (final metric in _mPath.computeMetrics()) {
          canvas.drawPath(
            metric.extractPath(0, metric.length * mProgress),
            paint..strokeWidth = _mStroke,
          );
        }
      }
    }

    if (glow) {
      // Soft halo behind the white strokes — matches icon_dark's glow.
      strokes(
        Paint()
          ..color = color.withValues(alpha: 0.55)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt
          ..strokeJoin = StrokeJoin.miter
          ..strokeMiterLimit = 8
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 16)
          ..isAntiAlias = true,
      );
    }
    strokes(
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeJoin = StrokeJoin.miter
        ..strokeMiterLimit = 8
        ..isAntiAlias = true,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_CmDrawPainter old) =>
      old.cProgress != cProgress ||
      old.mProgress != mProgress ||
      old.color != color ||
      old.glow != glow;
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
