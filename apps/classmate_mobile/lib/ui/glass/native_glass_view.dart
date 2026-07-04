import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
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
            ? Colors.black
            : Colors.white);

    if (!kIsWeb && Platform.isIOS) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            // Native UIVisualEffectView fills the bounds. The system materials
            // resolve against the view's trait collection — i.e. the OS
            // appearance, NOT the Flutter theme — so we pass the app's
            // brightness down and the Swift side overrides the interface
            // style. Without this, dark-mode-in-app on a light-mode phone
            // rendered a white glass bar. Keyed by brightness so an in-app
            // theme flip recreates the platform view with the right style.
            Positioned.fill(
              child: UiKitView(
                key: ValueKey('cm_glass_${isDark ? 'dark' : 'light'}'),
                viewType: 'cm_native_glass_view',
                creationParams: {
                  'cornerRadius': borderRadius,
                  'style': style.name,
                  'dark': isDark,
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
