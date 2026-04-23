import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 14,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final resolvedColor = color ?? cs.surface.withValues(alpha: isDark ? 0.68 : 0.72);
    final resolvedGradient = gradient ?? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        cs.surface.withValues(alpha: isDark ? 0.78 : 0.86),
        cs.surfaceContainerHigh.withValues(alpha: isDark ? 0.54 : 0.62),
      ],
    );
    final resolvedBorder = border ?? Border.all(
      color: cs.outlineVariant.withValues(alpha: isDark ? 0.28 : 0.22),
    );
    final resolvedShadow = boxShadow ?? [
      BoxShadow(
        blurRadius: 28,
        spreadRadius: -10,
        offset: const Offset(0, 14),
        color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.12),
      ),
      BoxShadow(
        blurRadius: 18,
        spreadRadius: -14,
        offset: const Offset(0, -2),
        color: cs.primary.withValues(alpha: isDark ? 0.16 : 0.08),
      ),
    ];

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: resolvedColor,
            gradient: resolvedGradient,
            borderRadius: borderRadius,
            border: resolvedBorder,
            boxShadow: resolvedShadow,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.10 : 0.22),
                        Colors.white.withValues(alpha: isDark ? 0.03 : 0.08),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.24, 0.8],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}