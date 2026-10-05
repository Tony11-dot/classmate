import 'package:flutter/material.dart';

import '../../core/theme/cm_tokens.dart';

/// A clean, solid-color card with consistent Material 3 styling.
///
/// Glass in this app is NATIVE (iOS UIGlassEffect via `NativeGlassView`) and is
/// reserved for the FUNCTIONAL layer — nav pill, toolbars, drawer, buttons —
/// exactly like ClassNotes. Content cards like this one stay opaque. The
/// [blurSigma] and [gradient] params are accepted for API compatibility but are
/// not applied — pass [color] for the fill.
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 0,
    this.color,
    this.gradient,
    this.border,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final Color fill;
    if (color != null) {
      fill = color!.withValues(alpha: 1.0);
    } else if (gradient is LinearGradient) {
      fill = (gradient as LinearGradient).colors.first.withValues(alpha: 1.0);
    } else if (gradient is RadialGradient) {
      fill = (gradient as RadialGradient).colors.first.withValues(alpha: 1.0);
    } else {
      fill = cs.surfaceContainerLow;
    }

    // UI overhaul: the classic full-strength outline read as a heavy box on
    // every screen. Callers that pass the stock `outlineVariant` edge (most of
    // them) now get a soft hairline, and the card gains the shared soft
    // elevation — painted OUTSIDE the clip so it is actually visible.
    final BoxBorder resolvedBorder;
    final b = border;
    if (b == null ||
        (b is Border && b.isUniform && b.top.color == cs.outlineVariant)) {
      resolvedBorder = Border.all(
        color: cs.outlineVariant.withValues(alpha: 0.4),
        width: 0.8,
      );
    } else {
      resolvedBorder = b;
    }
    // Screens use a primaryContainer card as their page header ("hero"). Give
    // those a gentle diagonal wash + deeper shadow so they read as the top of
    // the page rather than one more flat slab.
    final isHero = color != null && fill == cs.primaryContainer;
    final shadow = boxShadow ??
        (isHero ? CmTokens.of(context).shadowMd : CmTokens.of(context).shadowSm);

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: shadow),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            gradient: isHero
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      fill,
                      Color.alphaBlend(cs.primary.withValues(alpha: 0.14), fill),
                    ],
                  )
                : null,
            borderRadius: borderRadius,
            border: isHero && b == null ? null : resolvedBorder,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
