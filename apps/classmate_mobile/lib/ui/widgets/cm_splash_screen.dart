import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  CmSplashScreen
//
//  Launch sequence (total ≈ 5 000 ms):
//    Phase 1 (0 %–25 %):  icon fades in (0 → 100 % opacity) while scaling
//                         0.85 → 1.0 with easeOutBack. The icon is the
//                         ONLY child of the Row right now, so Center
//                         keeps it pinned at screen-center.
//    Phase 2 (25 %–30 %): brief hold — logo settles, fully visible.
//    Phase 3 (30 %–52 %): the gap to the text widens from 0 to its
//                         natural size, and "ClassMate" types out
//                         character-by-character. As the Row gets wider,
//                         Center re-balances the cluster → icon glides
//                         left naturally without any explicit slide
//                         animation. Cursor visible from the moment
//                         typing starts.
//    Phase 4 (52 %–90 %): final frame — cursor blinks softly for ~1.9 s
//                         alongside the fully-typed tagline.
//    Phase 5 (90 %–100%): the whole composition fades out to white.
//                         The next screen (login) renders the
//                         logo_light.png PNG centered, providing visual
//                         continuity at the hand-off.
//
//  No explicit Transform.translate for the icon slide — Row + Center
//  handle it implicitly, which sidesteps every centering bug we hit
//  with manual offset math.
// ─────────────────────────────────────────────────────────────────────────────

class CmSplashScreen extends StatefulWidget {
  const CmSplashScreen({
    super.key,
    required this.onDone,
    this.duration = const Duration(milliseconds: 5000),
    this.iconSize = 80,
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

  late final Animation<double> _iconOpacity;
  late final Animation<double> _iconScale;
  late final Animation<double> _textReveal;
  late final Animation<double> _fadeOut;

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

    _iconOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.00, 0.25, curve: Curves.easeOut),
    );
    _iconScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.00, 0.27, curve: Curves.easeOutBack),
      ),
    );

    _textReveal = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.30, 0.52, curve: Curves.linear),
    );

    _fadeOut = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.90, 1.00, curve: Curves.easeIn),
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
    final iconSize = widget.iconSize;
    final tagline = widget.tagline;
    final gap = iconSize * 0.16;
    final fontSize = iconSize * 0.42;
    final cursorWidth = 3.0;
    final cursorHeight = fontSize * 0.92;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([_ctrl, _cursorBlink]),
        builder: (context, _) {
          final fade = (1.0 - _fadeOut.value).clamp(0.0, 1.0);
          final reveal = _textReveal.value;
          final cursorOpacity = reveal > 0.001
              ? (math.sin(_cursorBlink.value * math.pi)).clamp(0.0, 1.0)
              : 0.0;

          // Character-by-character reveal of the tagline.
          final shownChars = (reveal * tagline.length).floor().clamp(0, tagline.length);
          final visibleText = tagline.substring(0, shownChars);

          // Center keeps whatever's inside the Row centered on screen.
          // Initially the Row contains ONLY the icon (gap=0, text empty,
          // no cursor), so the icon sits at screen-center. As phase 3
          // progresses the gap, text, and cursor materialise on the
          // right side of the Row, the Row grows wider, and Center
          // re-balances — the icon naturally glides left.
          return Opacity(
            opacity: fade,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon — always present so it can fade in over phase 1.
                  Opacity(
                    opacity: _iconOpacity.value,
                    child: Transform.scale(
                      scale: _iconScale.value,
                      child: SizedBox(
                        width: iconSize,
                        height: iconSize,
                        child: Image.asset(
                          'assets/images/icon_light.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // Gap — opens up only after typing starts. Width tweens
                  // smoothly from 0 to `gap` over the typing window, so
                  // the icon slides left gradually rather than snapping.
                  SizedBox(width: gap * reveal),
                  // Text — only joins the layout once typing actually
                  // starts. Before that the Row has no text widget at
                  // all, so the cluster width stays at iconSize and the
                  // icon stays centered.
                  if (reveal > 0) ...[
                    Text(
                      visibleText,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Colors.black,
                        fontSize: fontSize,
                        height: 1.0,
                      ),
                    ),
                    // Cursor — blinks softly via sine-wave opacity from
                    // the independent _cursorBlink controller.
                    Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Opacity(
                        opacity: cursorOpacity,
                        child: Container(
                          width: cursorWidth,
                          height: cursorHeight,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
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
