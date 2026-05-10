import 'package:flutter/material.dart';
import 'cm_splash_screen.dart';

/// Launch splash — delegates to [CmSplashScreen] which plays the full
/// C-arc-draws-in → M-reveals-left-to-right animation.
///
/// Used by main.dart before the main app mounts.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return CmSplashScreen(onDone: onComplete);
  }
}
