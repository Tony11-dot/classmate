import 'package:flutter/material.dart';

import 'ambient_symbols.dart';

/// A calm, theme-aware background: a soft SOLID wash of the currently-selected
/// theme colour with the floating educational symbols (♪ ∫ π `</>` calculators,
/// stars, curved lines…) drifting on top. No moving gradient, no spotlight
/// blobs — just the theme colour and the symbols.
///
/// Replaces the busier animated aurora background on the login screen and the
/// NOVA thread, where a plain themed surface reads calmer and keeps foreground
/// text/cards perfectly legible.
///
/// Honors reduce-motion (Settings → Appearance): when
/// `MediaQuery.disableAnimations` is set, the symbol field freezes into a
/// static composition (same layout, no movement).
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({
    super.key,
    required this.child,
    this.symbolsSeed = 7,
    this.symbolsOpacity = 1.0,
  });

  /// Foreground content rendered above the background layers.
  final Widget child;

  /// Per-screen scatter layout — different screens, different sky.
  final int symbolsSeed;

  /// Opacity multiplier for the symbol layer (drop below 1 on busy screens
  /// like the chat thread so the symbols stay quiet under the text).
  final double symbolsOpacity;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final animate = !MediaQuery.of(context).disableAnimations;

    // Soft SOLID wash of the selected theme colour over the surface — present
    // enough to read as "themed", light enough for text/cards to sit on.
    final base = Color.alphaBlend(
      cs.primary.withValues(alpha: isDark ? 0.16 : 0.07),
      cs.surface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(color: base),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Symbols only — no gradient blobs (blobs: false), so nothing
          // "spotlights". The symbols carry all the life.
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
