import 'package:flutter/material.dart';

/// Full-screen animated splash that plays a logo reveal sequence and then
/// calls [onComplete].
///
/// **Sequence (total ≈ 2800 ms)**
/// | Phase | Range | What happens |
/// |---|---|---|
/// | Fade-in | 0 – 800 ms | Logo fades from 0→1 and scales 0.85→1.0 (easeOutCubic) |
/// | Settle | 800 – 1100 ms | Logo sits still |
/// | Typewriter | 1100 – 2300 ms | If [showWordmark] is true, the [wordmark] string types letter-by-letter with a blinking cursor |
/// | Hold | 2300 – 2800 ms | Everything pauses, then [onComplete] fires |
///
/// Because the logo PNGs already embed the full wordmark, [showWordmark]
/// defaults to `false`. Pass `showWordmark: true` with a custom [wordmark]
/// only when using a plain icon asset that does not include text.
class ClassMateSplash extends StatefulWidget {
  const ClassMateSplash({
    super.key,
    required this.onComplete,
    this.assetPath,
    this.backgroundColor,
    this.logoSize = 140,
    this.brightness,
    this.showWordmark = false,
    this.wordmark = 'ClassMate',
  });

  /// Called once when the animation finishes.
  final VoidCallback onComplete;

  /// Override the logo asset path. If null, auto-picks [logo_dark/light.png]
  /// based on [brightness] (or the current theme).
  final String? assetPath;

  /// Background color of the splash. Defaults to [ColorScheme.surface].
  final Color? backgroundColor;

  /// Height/width of the logo image.
  final double logoSize;

  /// Force a specific brightness instead of inheriting from the theme.
  final Brightness? brightness;

  /// When true, a typewriter animation appends [wordmark] text beside the
  /// logo after the logo settles. Keep false (default) when the logo asset
  /// already includes its wordmark.
  final bool showWordmark;

  /// Text typed out letter-by-letter when [showWordmark] is true.
  final String wordmark;

  @override
  State<ClassMateSplash> createState() => _ClassMateSplashState();
}

class _ClassMateSplashState extends State<ClassMateSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Phase boundaries (normalised 0–1 over the full 2800 ms duration).
  static const double _fadeEnd = 0.286;      // 800 / 2800
  static const double _settleEnd = 0.393;    // 1100 / 2800
  static const double _typeEnd = 0.821;      // 2300 / 2800
  // hold: 0.821 → 1.0, then onComplete

  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _typeAnim; // 0→1 controls how many chars show
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0, _fadeEnd, curve: Curves.easeOutCubic),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0, _fadeEnd, curve: Curves.easeOutCubic),
      ),
    );

    _typeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(_settleEnd, _typeEnd, curve: Curves.linear),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_completed) {
        _completed = true;
        widget.onComplete();
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _visibleWordmark(double t) {
    if (!widget.showWordmark || widget.wordmark.isEmpty) return '';
    final chars =
        (t * widget.wordmark.length).floor().clamp(0, widget.wordmark.length);
    return widget.wordmark.substring(0, chars);
  }

  bool _showCursor(double rawValue) {
    if (!widget.showWordmark) return false;
    // The cursor blinks after typewriter starts; freeze it solid on the last char.
    final t = _typeAnim.value;
    if (t >= 1.0) return false;
    // Blink: toggle every ~250 ms relative to the 2800 ms total.
    final blinkCycles = (rawValue * 2800 / 250).floor();
    return blinkCycles.isEven;
  }

  @override
  Widget build(BuildContext context) {
    final brightness =
        widget.brightness ?? Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final bg = widget.backgroundColor ??
        Theme.of(context).colorScheme.surface;

    final assetPath = widget.assetPath ??
        (isDark
            ? 'assets/images/logo_dark.png'
            : 'assets/images/logo_light.png');

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final visible = _visibleWordmark(_typeAnim.value);
        final cursor = _showCursor(_ctrl.value);

        return ColoredBox(
          color: bg,
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      assetPath,
                      width: widget.logoSize,
                      height: widget.logoSize,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    if (widget.showWordmark && visible.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Text(
                        cursor ? '$visible|' : visible,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
