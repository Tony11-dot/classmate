import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'cm_splash_screen.dart';

/// Launch splash. If [assets/animations/splash.json] exists in the
/// bundle, render that Lottie animation full-screen and call
/// [onComplete] when it finishes. Otherwise fall back to the custom-
/// painted [CmSplashScreen] (C-arc + M + typing tagline).
///
/// Used by main.dart before the main app mounts.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Async probe: does the Lottie file exist in the bundle? We check
  /// once on init and decide which renderer to use. AssetBundle.load
  /// throws if the asset isn't declared in pubspec OR missing from the
  /// build, which is the signal to fall back to the custom painter.
  bool? _hasLottie;

  @override
  void initState() {
    super.initState();
    _probeLottie();
  }

  Future<void> _probeLottie() async {
    try {
      await rootBundle.load('assets/animations/splash.json');
      if (mounted) setState(() => _hasLottie = true);
    } catch (_) {
      if (mounted) setState(() => _hasLottie = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasLottie == null) {
      // Probe still in flight — render a blank surface for one frame.
      // Same background the Lottie / CmSplashScreen will use so there
      // is no visible flash.
      final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
      return ColoredBox(color: isDark ? Colors.black : Colors.white);
    }
    if (_hasLottie == true) {
      return _LottieSplash(onComplete: widget.onComplete);
    }
    return CmSplashScreen(onDone: widget.onComplete);
  }
}

class _LottieSplash extends StatefulWidget {
  const _LottieSplash({required this.onComplete});
  final VoidCallback onComplete;

  @override
  State<_LottieSplash> createState() => _LottieSplashState();
}

class _LottieSplashState extends State<_LottieSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Center(
        child: Lottie.asset(
          'assets/animations/splash.json',
          controller: _ctrl,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            // Match the controller's duration to the Lottie's natural
            // length so it plays end-to-end exactly once, then we hand
            // control back to main.dart via onComplete.
            _ctrl
              ..duration = composition.duration
              ..forward().whenComplete(widget.onComplete);
          },
        ),
      ),
    );
  }
}
