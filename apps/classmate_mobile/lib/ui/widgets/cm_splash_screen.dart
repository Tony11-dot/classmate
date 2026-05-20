import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CmSplashScreen
//
//  Launch sequence (total ≈ 3 600 ms):
//    Phase 1 (0 %–28 %): the real blue CM icon (assets/images/icon_light.png)
//                        fades in from 0 → 100 % opacity while scaling
//                        from 0.85 → 1.0 with a tiny easeOutBack overshoot,
//                        landing centered on a pure-white background.
//    Phase 2 (28 %–34 %): brief hold — logo settles, fully visible.
//    Phase 3 (34 %–55 %): icon translates leftward as the "ClassMate"
//                         tagline types out character-by-character to its
//                         right. Both finish together. Cursor visible
//                         from the moment typing starts.
//    Phase 4 (55 %–93 %): final frame — cursor blinks softly for ~1.4 s
//                         alongside the fully-typed tagline.
//    Phase 5 (93 %–100%): everything fades out.
//
//  Renders the real PNG asset (not a painter approximation), so the
//  splash icon is always pixel-identical to the home-screen icon.
// ─────────────────────────────────────────────────────────────────────────────

class CmSplashScreen extends StatefulWidget {
  const CmSplashScreen({
    super.key,
    required this.onDone,
    this.duration = const Duration(milliseconds: 3600),
    this.iconSize = 120,
    this.tagline = 'ClassMate',
  });

  final VoidCallback onDone;
  final Duration duration;
  final double iconSize;
  /// Text typed to the right of the logo. Pass empty to disable.
  final String tagline;

  @override
  State<CmSplashScreen> createState() => _CmSplashScreenState();
}

class _CmSplashScreenState extends State<CmSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _cursorBlink;

  // Phase curves ──────────────────────────────────────────────────────────────
  late final Animation<double> _iconOpacity; // icon fades in
  late final Animation<double> _iconScale;   // icon scales 0.85 → 1
  late final Animation<double> _textReveal;  // chars typed
  late final Animation<double> _iconShift;   // icon slides left (0 → 1)
  late final Animation<double> _fadeOut;     // everything fades

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

    // Phase 1 — icon fades + scales in (0-28%).
    _iconOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.28, curve: Curves.easeOut),
    );
    _iconScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.00, 0.30, curve: Curves.easeOutBack),
      ),
    );

    // Phase 3 — typing + icon slide (34-55%).
    _textReveal = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.34, 0.55, curve: Curves.linear),
    );
    _iconShift = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.34, 0.55, curve: Curves.easeOutCubic),
    );

    _fadeOut = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.93, 1.00, curve: Curves.easeIn),
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
    final tagline = widget.tagline;
    final iconSize = widget.iconSize;

    // Pure white background, regardless of system theme — matches the
    // native splash so cold launch has no visible seam.
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_ctrl, _cursorBlink]),
        builder: (context, _) {
          final opacity = (1.0 - _fadeOut.value).clamp(0.0, 1.0);

          // Measure the rendered tagline width so the icon's leftward
          // shift puts the [icon | gap | text + cursor] cluster
          // perfectly centered when phase 3 finishes.
          //
          // Cluster width = iconSize + gap + textW + cursorRoom.
          // For the cluster's center to land at screen center, the
          // icon's center must end at -(cluster width)/2 + iconSize/2
          //                          = -(gap + textW + cursorRoom)/2.
          // The text wrapper (width textW + cursorRoom) sits to the
          // right of the icon + gap, so its center lands at
          // (iconSize + gap)/2 from screen center.
          final taglineStyle = _taglineStyle(context);
          final tp = TextPainter(
            text: TextSpan(text: tagline, style: taglineStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          final textW = tp.width;
          const gap = 16.0;
          const cursorRoom = 6.0;
          final shiftDistance = (gap + textW + cursorRoom) / 2;
          final textCenterX = (iconSize + gap) / 2;

          return Opacity(
            opacity: opacity,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // The real PNG icon. Center-anchored; slides left during
                // phase 3.
                Transform.translate(
                  offset: Offset(-shiftDistance * _iconShift.value, 0),
                  child: Opacity(
                    opacity: _iconOpacity.value,
                    child: Transform.scale(
                      scale: _iconScale.value,
                      child: Image.asset(
                        'assets/images/icon_light.png',
                        width: iconSize,
                        height: iconSize,
                        fit: BoxFit.contain,
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
                            style: taglineStyle,
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

  /// Bold black sans-serif. Cursor color follows this style.color, so
  /// flipping black ↔ blue here also flips the cursor.
  TextStyle _taglineStyle(BuildContext context) {
    return const TextStyle(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
      color: Colors.black,
      fontSize: 32,
      height: 1.0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Typing tagline — reveals chars left-to-right with a blinking cursor.
// ─────────────────────────────────────────────────────────────────────────────

class _TypingTagline extends StatelessWidget {
  const _TypingTagline({
    required this.text,
    required this.progress,
    required this.cursorOpacity,
    required this.style,
  });

  final String text;
  final double progress;
  final double cursorOpacity;
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
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Opacity(
                opacity: cursorOpacity,
                child: Container(
                  width: 3,
                  height: (style.fontSize ?? 32) * 0.92,
                  color: style.color,
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
