import 'dart:ui';

import 'package:flutter/material.dart';

/// A surface card with optional **liquid glass** — a real frosted backdrop
/// blur, a translucent fill, an accent-leaning hairline and a soft specular
/// top highlight. Set [glass] `true` to enable it (kept opt-in so existing
/// solid cards are unchanged). Honors Reduce Transparency / high-contrast by
/// falling back to an opaque surface — matching ClassNotes' `dsGlass`, which
/// applies glass to the FUNCTIONAL layer only (content stays opaque).
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 18,
    this.color,
    this.gradient,
    this.border,
    this.boxShadow,
    this.glass = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  /// Backdrop blur radius when [glass] is on.
  final double blurSigma;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  /// When true, the card frosts the content behind it (liquid glass).
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Derive a solid fill:
    //   1. If an explicit color was passed, use it.
    //   2. If a gradient was passed (legacy), use the first stop.
    //   3. Fall back to surfaceContainerLow.
    final Color baseFill;
    if (color != null) {
      baseFill = color!.withValues(alpha: 1.0);
    } else if (gradient is LinearGradient) {
      baseFill = (gradient as LinearGradient).colors.first.withValues(alpha: 1.0);
    } else if (gradient is RadialGradient) {
      baseFill = (gradient as RadialGradient).colors.first.withValues(alpha: 1.0);
    } else {
      baseFill = cs.surfaceContainerLow;
    }

    // Reduce-transparency / high-contrast users get the opaque card.
    final reduceTransparency = MediaQuery.of(context).highContrast;

    if (!glass || reduceTransparency) {
      final resolvedBorder = border ?? Border.all(color: cs.outlineVariant);
      return ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: baseFill,
            borderRadius: borderRadius,
            border: resolvedBorder,
            boxShadow: boxShadow,
          ),
          child: Padding(padding: padding, child: child),
        ),
      );
    }

    // ── Liquid glass ──────────────────────────────────────────────────────
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassFill = baseFill.withValues(alpha: isDark ? 0.58 : 0.66);
    final resolvedBorder = border ??
        Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.5),
          width: 0.6,
        );

    return DecoratedBox(
      // Shadow lives outside the clip so it isn't blurred away.
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: boxShadow),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: glassFill,
              borderRadius: borderRadius,
              border: resolvedBorder,
              // Faint accent-tinted specular sheen from the top.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.primary.withValues(alpha: isDark ? 0.10 : 0.07),
                  cs.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
