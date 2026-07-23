import 'package:flutter/material.dart';

import 'ambient_symbols.dart';

/// A calm, theme-aware full-screen background: a soft SOLID wash of the
/// currently-selected theme colour (the accent gently blended over the theme
/// surface) with a quiet layer of floating educational symbols (♪ ∫ π `</>`
/// calculators, stars, curved lines…) painted on top. No moving gradient, no
/// drifting "aurora" spotlights — just one steady tinted surface + the symbols.
///
/// Honors reduce-motion (Settings → Appearance): when the app's
/// MediaQuery.disableAnimations flag is on, the symbol layer freezes into a
/// static composition.
///
/// Used full-screen on the login screen and the NOVA chat.
class AnimatedAuroraBackground extends StatelessWidget {
  const AnimatedAuroraBackground({
    super.key,
    required this.child,
    this.intensity = 1.0,
    this.symbols = true,
    this.symbolsSeed = 7,
    this.symbolsOpacity = 1.0,
  });

  /// Foreground content rendered above the background layers.
  final Widget child;

  /// Kept for source compatibility with existing call sites; the solid wash is
  /// intentionally uniform, so this no longer drives any animation.
  final double intensity;

  /// Whether to scatter the floating educational symbols over the wash.
  final bool symbols;

  /// Per-screen scatter layout — different screens, different sky.
  final int symbolsSeed;

  /// Opacity multiplier for the symbol layer (drop below 1 on busy screens).
  final double symbolsOpacity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Reduce-motion: the app-level MediaQuery flag (set from Settings) freezes
    // the symbol drift into a still composition.
    final animate = !MediaQuery.of(context).disableAnimations;

    // The soft solid: a gentle veil of the selected theme's accent over its
    // surface. Just enough tint to read as "the theme colour", never so much
    // that foreground text/cards lose contrast.
    final soft = Color.alphaBlend(
      cs.primary.withValues(alpha: isDark ? 0.16 : 0.08),
      cs.surface,
    );

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: soft),
          if (symbols)
            ExcludeSemantics(
              child: AmbientSymbols(
                animate: animate,
                seed: symbolsSeed,
                opacity: symbolsOpacity,
                blobs: false,
              ),
            ),
          child,
        ],
      ),
    );
  }
}
