import 'package:flutter/material.dart';

import 'cm_glass.dart';
import 'glass_tokens.dart';
import 'native_glass_view.dart';

/// GlassEffectContainer equivalent: a row of actions sharing ONE glass
/// capsule, split by hairline dividers — like grouped UIBarButtonItems /
/// ToolbarItemGroup in native iOS 26 toolbars.
///
/// Rules it enforces automatically:
///  • one glass surface for the whole group (never glass-on-glass)
///  • concentric segment shape inside the capsule
///  • segments animate in/out with a fluid width+fade morph, so a group
///    growing from 2 to 3 actions visually "splits" its capsule the way
///    native toolbars do (AnimatedSize; instant under Reduce Motion).
class GlassCapsuleGroup extends StatelessWidget {
  const GlassCapsuleGroup({
    super.key,
    required this.children,
    this.height = 44,
    this.spacing = 0,
    this.style = NativeGlassStyle.regular,
  });

  /// Typically [GlassCapsuleAction]s. A widget being added/removed morphs the
  /// capsule width smoothly.
  final List<Widget> children;
  final double height;
  final double spacing;
  final NativeGlassStyle style;

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final b = Theme.of(context).brightness;

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0)
            spacing > 0
                ? SizedBox(width: spacing)
                : VerticalDivider(
                    width: 1,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                    color: GlassTokens.hairline(b),
                  ),
          children[i],
        ],
      ],
    );

    return CMGlass(
      capsule: true,
      style: style,
      child: SizedBox(
        height: height,
        child: reduceMotion
            ? row
            : AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: row,
              ),
      ),
    );
  }
}

/// A single action inside a [GlassCapsuleGroup] — icon (or any child) with
/// native press physics and a haptic.
class GlassCapsuleAction extends StatelessWidget {
  const GlassCapsuleAction({
    super.key,
    required this.child,
    this.onTap,
    this.tooltip,
    this.minWidth = 44,
  });

  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    Widget out = GlassPressable(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: minWidth),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: child,
          ),
        ),
      ),
    );
    if (tooltip != null) out = Tooltip(message: tooltip!, child: out);
    return out;
  }
}

/// Fluid morph between glass elements across layout changes — the
/// `.glassEffectID(_:in:)` + `@Namespace` equivalent, built on Hero's
/// rect-tween flight (which follows MediaQuery.disableAnimations via the
/// page-transition duration).
///
/// Give two glass elements on either side of a transition the same [id]
/// within one [GlassMorphScope]; the material flies/morphs between them.
class GlassMorphScope extends StatelessWidget {
  const GlassMorphScope({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => HeroControllerScope(
        controller: MaterialApp.createMaterialHeroController(),
        child: child,
      );
}

class GlassMorph extends StatelessWidget {
  const GlassMorph({super.key, required this.id, required this.child});

  final Object id;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'cm_glass_morph_$id',
      // Keep the glass look during flight instead of the default fade-stack.
      flightShuttleBuilder: (a, animation, b, c, toContext) =>
          FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
        child: toContext.widget,
      ),
      child: child,
    );
  }
}
