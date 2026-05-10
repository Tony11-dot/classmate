import 'package:flutter/material.dart';

import '../widgets/animations/loading_spinner.dart';
import '../widgets/animations/splash_screen.dart';

/// Preview screen for [ClassMateSplash] and [ClassMateLoader].
///
/// Opens with the splash animation; once it completes, it switches to a
/// screen showing the loading spinner. A "Replay Splash" button restarts
/// the whole sequence.
class AnimationDemoScreen extends StatefulWidget {
  const AnimationDemoScreen({super.key});

  @override
  State<AnimationDemoScreen> createState() => _AnimationDemoScreenState();
}

class _AnimationDemoScreenState extends State<AnimationDemoScreen> {
  bool _showingSplash = true;
  int _splashKey = 0; // increment to force a fresh splash widget

  void _onSplashComplete() {
    if (!mounted) return;
    setState(() => _showingSplash = false);
  }

  void _replaySplash() {
    setState(() {
      _showingSplash = true;
      _splashKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_showingSplash) {
      return ClassMateSplash(
        key: ValueKey(_splashKey),
        onComplete: _onSplashComplete,
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text(
          'Animation Demo',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Spinner preview ──────────────────────────────────────────────
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cs.outlineVariant),
              ),
              alignment: Alignment.center,
              child: ClassMateLoader(
                size: 80,
                arcColor: cs.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'ClassMateLoader',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 48),

            // ── Replay button ────────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _replaySplash,
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text('Replay Splash'),
            ),
          ],
        ),
      ),
    );
  }
}
