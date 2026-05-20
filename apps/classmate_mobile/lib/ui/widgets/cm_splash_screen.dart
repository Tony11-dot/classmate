import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CmSplashScreen
//
//  Launch sequence (total ≈ 4 000 ms):
//    Phase 1 (0 %–28 %): C arc draws itself in from 0° → full 288°.
//                        Simultaneously M fades + scales in (5 %–28 %), so
//                        the C feels like it's encircling the M as both
//                        materialise together.
//    Phase 2 (28 %–32 %): brief settle — logo holds, centered.
//    Phase 3 (32 %–50 %): icon translates leftward as the "ClassMate"
//                         tagline types out character-by-character to its
//                         right. Cursor appears immediately.
//    Phase 4 (50 %–95 %): final frame — cursor blinks for ~2 s alongside
//                         the fully-typed tagline.
//    Phase 5 (95 %–100%): everything fades out.
//
//  Cursor blink is driven by an independent ticker so it stays alive
//  during AND after the typing phase finishes, until the fade-out.
//
//  Call [onDone] to navigate away when the animation completes.
// ─────────────────────────────────────────────────────────────────────────────

class CmSplashScreen extends StatefulWidget {
  const CmSplashScreen({
    super.key,
    required this.onDone,
    this.duration = const Duration(milliseconds: 4000),
    this.iconSize = 96,
    this.tagline = 'ClassMate',
  });

  final VoidCallback onDone;
  final Duration duration;
  final double iconSize;
  /// Text typed to the right of the logo. Defaults to the app name.
  /// Pass empty to disable the typing phase entirely.
  final String tagline;

  @override
  State<CmSplashScreen> createState() => _CmSplashScreenState();
}

class _CmSplashScreenState extends State<CmSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  // Independent blink — runs on its own loop so the cursor keeps
  // pulsing even when the main timeline isn't ticking that frame.
  late final AnimationController _cursorBlink;

  // Phase curves ──────────────────────────────────────────────────────────────
  late final Animation<double> _arcProgress;   // C draws in
  late final Animation<double> _mOpacity;       // M fades in
  late final Animation<double> _mScale;         // M scales 0.85 → 1.0
  late final Animation<double> _textReveal;     // chars typed
  late final Animation<double> _iconShift;      // icon slides left (0 → 1)
  late final Animation<double> _fadeOut;        // everything fades

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward().whenComplete(() {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        widget.onDone();
      });

    _cursorBlink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);

    // Phase 1 — C arc draws (0-28%) AND M fades+scales in (5-28%) in parallel.
    _arcProgress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.28, curve: Curves.easeOutCubic),
    );
    _mOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.05, 0.28, curve: Curves.easeOut),
    );
    _mScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.05, 0.30, curve: Curves.easeOutBack),
      ),
    );

    // Phase 3 — typing + icon slide. Linear for typing so per-char pacing
    // is even; easeOutCubic for the slide so the icon decelerates nicely
    // into its final left-aligned spot.
    _textReveal = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.32, 0.50, curve: Curves.linear),
    );
    _iconShift = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.32, 0.50, curve: Curves.easeOutCubic),
    );

    _fadeOut = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.95, 1.00, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _cursorBlink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final tagline = widget.tagline;
    final iconSize = widget.iconSize;

    return Scaffold(
      backgroundColor: bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([_ctrl, _cursorBlink]),
        builder: (_, _) {
          final opacity = (1.0 - _fadeOut.value).clamp(0.0, 1.0);

          // Estimate the rendered text width so the icon's leftward
          // shift is exactly half of the tagline width — that keeps the
          // [icon + text] cluster perfectly centered on screen during
          // and after the slide.
          final tp = TextPainter(
            text: TextSpan(
              text: tagline,
              style: _taglineStyle(context, fg),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          final textW = tp.width;
          const gap = 14.0;
          final shiftDistance = (textW + gap) / 2;

          // Layout math (centered around screen X = 0):
          //   Cluster (final) = [icon | gap | text], width = iconSize + gap + textW.
          //   Icon CENTER at:   -(gap + textW) / 2  →  this is shiftDistance.
          //   Text CENTER at:   (iconSize + gap) / 2.
          // The icon animates from 0 → -shiftDistance over phase 3.
          // The text stays at its final centered position throughout
          // phase 3 and characters reveal in-place via the typing widget.
          const cursorRoom = 6.0;
          final textCenterX = (iconSize + gap) / 2;

          return Opacity(
            opacity: opacity,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Transform.translate(
                  offset: Offset(-shiftDistance * _iconShift.value, 0),
                  child: SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: CustomPaint(
                      painter: _SplashMarkPainter(
                        arcProgress: _arcProgress.value,
                        mOpacity: _mOpacity.value,
                        mScale: _mScale.value,
                        color: fg,
                      ),
                    ),
                  ),
                ),
                if (tagline.isNotEmpty)
                  Transform.translate(
                    offset: Offset(textCenterX, 0),
                    child: SizedBox(
                      width: textW + cursorRoom,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Opacity(
                          opacity: _textReveal.value > 0 ? 1.0 : 0.0,
                          child: _TypingTagline(
                            text: tagline,
                            progress: _textReveal.value,
                            cursorOpacity: _textReveal.value > 0.001
                                ? (math.sin(_cursorBlink.value * math.pi)).clamp(0.0, 1.0)
                                : 0.0,
                            color: fg,
                            style: _taglineStyle(context, fg),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  TextStyle _taglineStyle(BuildContext context, Color color) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: color,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Painter — C arc + M letterform with independent opacity / scale.
// ─────────────────────────────────────────────────────────────────────────────

class _SplashMarkPainter extends CustomPainter {
  const _SplashMarkPainter({
    required this.arcProgress,
    required this.mOpacity,
    required this.mScale,
    required this.color,
  });

  final double arcProgress; // 0 → 1: how much of the C arc is drawn
  final double mOpacity;    // 0 → 1: M opacity (replaces the old clip reveal)
  final double mScale;      // 0.85 → 1: M scale-in for a subtle "punch" feel
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

    // ── Phase 1a: C arc draws in ─────────────────────────────────────────────
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

    // ── Phase 1b: M fades + scales in (no clip — full letter, just opacity) ─
    if (mOpacity > 0.001) {
      final mPaint = Paint()
        ..color = color.withValues(alpha: mOpacity)
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

      // Scale the M around its own center for the "punch" effect.
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(mScale);
      canvas.translate(-cx, -cy);
      canvas.drawPath(mPath, mPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SplashMarkPainter old) =>
      old.arcProgress != arcProgress ||
      old.mOpacity != mOpacity ||
      old.mScale != mScale ||
      old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Typing tagline — reveals chars left-to-right with a blinking cursor.
// ─────────────────────────────────────────────────────────────────────────────

class _TypingTagline extends StatelessWidget {
  const _TypingTagline({
    required this.text,
    required this.progress,
    required this.cursorOpacity,
    required this.color,
    required this.style,
  });

  final String text;
  final double progress;     // 0 → 1 across the typing phase
  final double cursorOpacity; // 0 → 1 from the blink controller
  final Color color;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final shown = (progress * text.length).floor().clamp(0, text.length);
    final visible = text.substring(0, shown);

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: visible),
          // "|" cursor as its own span so the blink opacity doesn't
          // affect the already-typed characters.
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Opacity(
                opacity: cursorOpacity,
                child: Container(
                  width: 2.5,
                  height: (style.fontSize ?? 24) * 0.95,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Helper — overlay widget for use inside MaterialApp.builder
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps [child] and overlays [CmSplashScreen] for the first app launch.
/// The overlay fades away as its animation completes.
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
