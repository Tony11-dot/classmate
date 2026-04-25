import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps the content in the real iOS UIVisualEffectView on iOS.
/// On all other platforms it falls back to Flutter BackdropFilter.
///
/// Usage:
///   NativeGlassView(
///     borderRadius: 28,
///     child: myWidget,
///   )
class NativeGlassView extends StatelessWidget {
  const NativeGlassView({
    super.key,
    required this.child,
    this.borderRadius = 0.0,
    this.style = NativeGlassStyle.thin,
    this.fallbackColor,
  });

  final Widget child;
  final double borderRadius;
  final NativeGlassStyle style;

  /// Tint colour layered on top of the blur (used on all platforms).
  final Color? fallbackColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = fallbackColor ??
        (isDark
            ? Colors.black.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.45));

    if (Platform.isIOS) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // Native UIVisualEffectView fills the bounds
            Positioned.fill(
              child: UiKitView(
                viewType: 'cm_native_glass_view',
                creationParams: {
                  'cornerRadius': borderRadius,
                  'style': style.name,
                },
                creationParamsCodec: const StandardMessageCodec(),
              ),
            ),
            // Thin colour tint layer
            Positioned.fill(
              child: ColoredBox(color: tint),
            ),
            // Content
            child,
          ],
        ),
      );
    }

    // Android / other — best-effort BackdropFilter approximation.
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: ColoredBox(
          color: tint,
          child: child,
        ),
      ),
    );
  }
}

enum NativeGlassStyle {
  thin,
  ultraThin,
  regular,
}
