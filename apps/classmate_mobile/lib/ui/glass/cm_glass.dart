import 'dart:ui' show ImageFilter;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'glass_tokens.dart';
import 'native_glass_view.dart';

/// The one true glass surface (Liquid Glass, iOS 26).
///
/// Replaces every ad-hoc translucent `BoxDecoration` / alpha-gradient in the
/// app. Two render paths:
///  • [CMGlass.floating] — big floating chrome (bars, pills, overlays, sheet
///    bodies). On iOS this is REAL glass via [NativeGlassView]
///    (UIVisualEffectView); elsewhere a BackdropFilter approximation.
///  • [CMGlass] (inline) — small elements (field triggers, chips, capsules).
///    Always BackdropFilter — platform views are too heavy to scatter through
///    scrolling content.
///
/// Accessibility: when the OS asks for high contrast (the closest Flutter
/// signal to Reduce Transparency) the surface renders as a SOLID themed fill —
/// same shape, no translucency — so legibility never depends on the blur.
class CMGlass extends StatelessWidget {
  const CMGlass({
    super.key,
    required this.child,
    this.radius,
    this.capsule = false,
    this.style = NativeGlassStyle.regular,
    this.prominent = false,
    this.border = true,
    this.shadow = false,
    this.tint,
  }) : _floating = false;

  /// Floating chrome variant — real native glass on iOS.
  const CMGlass.floating({
    super.key,
    required this.child,
    this.radius,
    this.style = NativeGlassStyle.regular,
    this.prominent = false,
    this.border = true,
    this.shadow = true,
    this.tint,
  })  : capsule = false,
        _floating = true;

  final Widget child;

  /// Corner radius. Defaults to [CMRadii.card] (inline) / [CMRadii.outer]
  /// (floating). Ignored when [capsule] is true.
  final double? radius;
  final bool capsule;
  final NativeGlassStyle style;

  /// Denser wash for text-heavy surfaces (menus, sheets).
  final bool prominent;
  final bool border;
  final bool shadow;

  /// Optional tint override (e.g. a subtle primary wash on a selected chip).
  final Color? tint;

  final bool _floating;

  double _sigma() => switch (style) {
        NativeGlassStyle.ultraThin => GlassTokens.sigmaThin,
        NativeGlassStyle.thin => GlassTokens.sigmaThin,
        NativeGlassStyle.regular =>
          prominent ? GlassTokens.sigmaProminent : GlassTokens.sigmaRegular,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final b = theme.brightness;
    final highContrast = MediaQuery.maybeOf(context)?.highContrast ?? false;

    final r = capsule
        ? CMRadii.capsule
        : radius ?? (_floating ? CMRadii.outer(context) : CMRadii.card(context));
    final borderRadius = BorderRadius.circular(r);

    final wash = tint ??
        (prominent
            ? GlassTokens.tintProminent(cs, b)
            : GlassTokens.tint(cs, b));

    Widget surface;
    if (highContrast) {
      // Reduce Transparency / high contrast: solid, no blur — never let
      // legibility depend on what happens to be behind the glass.
      surface = ColoredBox(color: cs.surfaceContainerHigh, child: child);
    } else if (_floating && !kIsWeb && !capsule) {
      // Real UIVisualEffectView on iOS (BackdropFilter fallback inside on
      // Android/web). One platform view per floating surface is fine; never
      // use this path for repeated inline elements. NativeGlassView stacks
      // blur + tint + child internally and clips to the radius itself.
      surface = NativeGlassView(
        borderRadius: r,
        style: style,
        fallbackColor: wash,
        child: child,
      );
    } else {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigma(), sigmaY: _sigma()),
        child: ColoredBox(color: wash, child: child),
      );
    }

    Widget out = ClipRRect(borderRadius: borderRadius, child: surface);

    if (border || shadow) {
      out = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadow
              ? (_floating
                  ? GlassTokens.shadow(b)
                  : GlassTokens.shadowInline(b))
              : null,
        ),
        child: border
            ? Container(
                foregroundDecoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(color: GlassTokens.hairline(b)),
                ),
                child: out,
              )
            : out,
      );
    }
    return out;
  }
}

/// Native press physics for tappable glass — the `.interactive()` equivalent.
///
/// Scale-down on touch, spring-back with a slight overshoot on release, and a
/// selection haptic. Honors Reduce Motion (`MediaQuery.disableAnimations`):
/// the scale animation is skipped entirely, the haptic and tap still fire.
class GlassPressable extends StatefulWidget {
  const GlassPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.haptic = true,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool haptic;
  final bool enabled;

  @override
  State<GlassPressable> createState() => _GlassPressableState();
}

class _GlassPressableState extends State<GlassPressable> {
  bool _down = false;

  void _set(bool down) {
    if (_down == down) return;
    setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final interactive =
        widget.enabled && (widget.onTap != null || widget.onLongPress != null);

    Widget out = widget.child;
    if (!reduceMotion) {
      out = AnimatedScale(
        scale: _down ? GlassTokens.pressScale : 1.0,
        duration: _down ? GlassTokens.pressIn : GlassTokens.pressOut,
        curve: _down ? Curves.easeOut : GlassTokens.pressOutCurve,
        child: out,
      );
    }
    if (!interactive) return out;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: () {
        if (widget.haptic) HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      onLongPress: widget.onLongPress == null
          ? null
          : () {
              if (widget.haptic) HapticFeedback.mediumImpact();
              _set(false);
              widget.onLongPress!.call();
            },
      child: out,
    );
  }
}
