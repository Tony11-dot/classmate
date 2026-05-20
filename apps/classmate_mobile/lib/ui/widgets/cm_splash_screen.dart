import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CmSplashScreen
//
//  Launch sequence (total ≈ 6 500 ms):
//    Phase 1 (0 %–22 %): the real blue CM icon fades in from 0 → 100 %
//                        while scaling 0.85 → 1.0 with easeOutBack, landing
//                        centered on a pure-white background.
//    Phase 2 (22 %–28 %): brief hold — logo settles, fully visible.
//    Phase 3 (28 %–46 %): icon translates leftward as the "ClassMate"
//                         tagline types out character-by-character to its
//                         right. Both finish together. Cursor visible
//                         from the moment typing starts.
//    Phase 4 (46 %–88 %): final frame — cursor blinks softly for ~2.7 s
//                         alongside the fully-typed tagline.
//    Phase 5 (88 %–100%): the whole composition fades out to white. The
//                         next screen (login) renders the SAME
//                         [icon + "ClassMate"] composition centered, so
//                         the hand-off looks continuous without needing
//                         a Navigator-level Hero widget.
// ─────────────────────────────────────────────────────────────────────────────

class CmSplashScreen extends StatefulWidget {
  const CmSplashScreen({
    super.key,
    required this.onDone,
    this.duration = const Duration(milliseconds: 6500),
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
  late final Animation<double> _iconOpacity; // phase 1: icon fades in
  late final Animation<double> _iconScale;   // phase 1: icon scales 0.85 → 1
  late final Animation<double> _textReveal;  // phase 3: chars typed
  late final Animation<double> _iconShift;   // phase 3: icon slides left (0 → 1)
  late final Animation<double> _fadeOut;     // phase 5: whole composition fades

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

    // Phase 1 — icon fades + scales in (0-22%).
    _iconOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.22, curve: Curves.easeOut),
    );
    _iconScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.00, 0.24, curve: Curves.easeOutBack),
      ),
    );

    // Phase 3 — typing + icon slide (28-46%).
    _textReveal = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.28, 0.46, curve: Curves.linear),
    );
    _iconShift = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.28, 0.46, curve: Curves.easeOutCubic),
    );

    // Phase 5 — whole composition fades to white (88-100%). The next
    // screen renders the same [icon + "ClassMate"] layout centered so
    // the cut is invisible — no morph needed.
    _fadeOut = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.88, 1.00, curve: Curves.easeIn),
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
          // Measure the rendered tagline width so the icon's leftward
          // shift puts the [icon | gap | text + cursor] cluster
          // perfectly centered when phase 3 finishes.
          //
          // Cluster width = iconSize + gap + textW + cursorRoom.
          // For the cluster's center to land at screen center, the
          // icon's center must end at -(cluster width)/2 + iconSize/2
          //                          = -(gap + textW + cursorRoom)/2.
          final taglineStyle = _taglineStyle(context);
          final tp = TextPainter(
            text: TextSpan(text: tagline, style: taglineStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          final textW = tp.width;
          // Gap proportion matches ClassMateLogo (h * 0.16) so the
          // splash's final frame is visually identical to the static
          // logo widget used on login + the app bar.
          final gap = iconSize * 0.16;
          const cursorRoom = 6.0;
          final shiftDistance = (gap + textW + cursorRoom) / 2;
          final textCenterX = (iconSize + gap) / 2;

          final fade = (1.0 - _fadeOut.value).clamp(0.0, 1.0);

          return Opacity(
            opacity: fade,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
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

  /// Bold black sans-serif. Cursor color follows this style.color.
  /// Font size locked to iconSize * 0.42 so the splash's final frame
  /// matches the ClassMateLogo widget used on login + the app bar.
  TextStyle _taglineStyle(BuildContext context) {
    return TextStyle(
      fontWeight: FontWeight.w900,
      letterSpacing: -0.5,
      color: Colors.black,
      fontSize: widget.iconSize * 0.42,
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
