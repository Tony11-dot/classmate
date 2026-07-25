import 'package:flutter/material.dart';

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

    final resolvedBorder = border ?? Border.all(color: cs.outlineVariant);

    return ClipRRect(
      borderRadius: borderRadius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: borderRadius,
          border: resolvedBorder,
          boxShadow: boxShadow,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
