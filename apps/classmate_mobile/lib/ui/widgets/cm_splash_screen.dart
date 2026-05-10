import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CmSplashScreen
//  Launch animation played once at startup:
//    Phase 1 (0 %–42 %): C arc draws itself in from 0° → full 288°
//    Phase 2 (38 %–70 %): M letterform reveals left → right (typing effect)
//    Phase 3 (70 %–82 %): brief hold — both marks fully visible
//    Phase 4 (82 %–100%): whole logo scales up slightly + fades out
//
//  Total duration: 2 100 ms (configurable via [duration]).
//  Call [onDone] to navigate away when the animation completes.
// ─────────────────────────────────────────────────────────────────────────────

class CmSplashScreen extends StatefulWidget {
  const CmSplashScreen({
    super.key,
    required this.onDone,
    this.duration = const Duration(milliseconds: 2100),
    this.iconSize = 96,
  });

  final VoidCallback onDone;
  final Duration duration;
  final double iconSize;

  @override
  State<CmSplashScreen> createState() => _CmSplashScreenState();
}

class _CmSplashScreenState extends State<CmSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Phase curves ──────────────────────────────────────────────────────────────
  late final Animation<double> _arcProgress;   // phase 1: C draws in
  late final Animation<double> _mReveal;        // phase 2: M types in
  late final Animation<double> _fadeOut;        // phase 4: logo fades out
  late final Animation<double> _scaleOut;       // phase 4: logo scales up

  @override
  void initState() {
    super.initState();

    // Lock orientation and hide system UI during splash.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward().whenComplete(() {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        widget.onDone();
      });

    _arcProgress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.42, curve: Curves.easeOutCubic),
    );

    _mReveal = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.38, 0.70, curve: Curves.easeOutCubic),
    );

    _fadeOut = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.82, 1.00, curve: Curves.easeIn),
    );

    _scaleOut = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.82, 1.00, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final opacity = (1.0 - _fadeOut.value).clamp(0.0, 1.0);
            return Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: _scaleOut.value,
                child: CustomPaint(
                  size: Size(widget.iconSize, widget.iconSize),
                  painter: _SplashMarkPainter(
                    arcProgress: _arcProgress.value,
                    mReveal: _mReveal.value,
                    color: fg,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Painter — pixel-perfect geometry shared with ClassMateIcon / CmLoading
// ─────────────────────────────────────────────────────────────────────────────

class _SplashMarkPainter extends CustomPainter {
  const _SplashMarkPainter({
    required this.arcProgress,
    required this.mReveal,
    required this.color,
  });

  final double arcProgress; // 0 → 1: how much of the C arc is drawn
  final double mReveal;     // 0 → 1: how much of the M is revealed L→R
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final S = size.width;
    final cx = S * 0.5, cy = S * 0.5;

    // ── Geometry (matches _CmPainter exactly) ───────────────────────────────
    final cMid = S * 0.375;
    final cStroke = S * 0.155;
    const gapDeg = 72.0;
    final startAngle = (gapDeg / 2) * math.pi / 180;
    final fullSweep = (360.0 - gapDeg) * math.pi / 180;

    final mHalfW = S * 0.185;
    final mHalfH = S * 0.235;
    final mLeft = cx - mHalfW;
    final mRight = cx + mHalfW;
    final mTop = cy - mHalfH;
    final mBottom = cy + mHalfH;
    final mStroke = S * 0.077;
    final lx = mLeft + mStroke / 2;
    final rx = mRight - mStroke / 2;
    final midY = mTop + (mBottom - mTop) * 0.42;

    // ── Phase 1: C arc draws in ──────────────────────────────────────────────
    if (arcProgress > 0.001) {
      final sweep = fullSweep * arcProgress;
      final arcPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = cStroke
        ..strokeCap = StrokeCap.butt
        ..isAntiAlias = true;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: cMid),
        startAngle,
        sweep,
        false,
        arcPaint,
      );
    }

    // ── Phase 2: M reveals left → right (clip expanding rightward) ──────────
    if (mReveal > 0.001) {
      final mPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = mStroke
        ..strokeCap = StrokeCap.butt
        ..strokeJoin = StrokeJoin.miter
        ..strokeMiterLimit = 8.0
        ..isAntiAlias = true;

      final mPath = Path()
        ..moveTo(lx, mBottom)
        ..lineTo(lx, mTop)
        ..lineTo(cx, midY)
        ..lineTo(rx, mTop)
        ..lineTo(rx, mBottom);

      // Clip rect grows from left to right as mReveal → 1.
      // Add half-stroke padding so the rightmost stroke is fully revealed.
      final clipRight = mLeft + (mRight - mLeft + mStroke) * mReveal;
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, 0, clipRight, S));
      canvas.drawPath(mPath, mPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SplashMarkPainter old) =>
      old.arcProgress != arcProgress ||
      old.mReveal != mReveal ||
      old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helper — overlay widget for use inside MaterialApp.builder
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] and overlays [CmSplashScreen] for the first app launch.
/// The overlay fades away as its animation completes.
///
/// Usage inside MaterialApp.builder:
///   builder: (ctx, child) => CmSplashOverlay(child: child ?? const SizedBox()),
class CmSplashOverlay extends StatefulWidget {
  const CmSplashOverlay({super.key, required this.child});
  final Widget child;

  @override
  State<CmSplashOverlay> createState() => _CmSplashOverlayState();
}

class _CmSplashOverlayState extends State<CmSplashOverlay> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_splashDone)
          CmSplashScreen(
            onDone: () {
              if (mounted) setState(() => _splashDone = true);
            },
          ),
      ],
    );
  }
}
