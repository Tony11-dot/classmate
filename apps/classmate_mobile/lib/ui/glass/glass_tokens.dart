import 'package:flutter/material.dart';

/// Design tokens for the Liquid Glass system (iOS 26 look).
///
/// One source of truth for every glass surface in the app. The values are
/// lifted from the bottom pill nav — the one component that already looked
/// right — so adopting these tokens makes every other surface match it.
///
/// Layering rules (mirrors Apple's HIG):
///  • Glass is for the FLOATING FUNCTIONAL LAYER only — bars, pills, floating
///    controls, overlays. Content (cards, lists) stays opaque.
///  • Never stack glass on glass.
///  • Tint sparingly; prominence comes from [GlassStyle.prominent], not color.
class GlassTokens {
  GlassTokens._();

  // ── Blur ────────────────────────────────────────────────────────────────
  /// Backdrop blur sigmas per style (used on non-iOS / inline surfaces where
  /// the native UIVisualEffectView isn't available or is too heavy).
  static const double sigmaThin = 18;
  static const double sigmaRegular = 30;
  static const double sigmaProminent = 40;

  // ── Tint (the translucent wash over the blur) ───────────────────────────
  /// Matches the pill nav's proven recipe (app_shell pillTint):
  /// surface @ 0.45 dark / 0.52 light reads as native systemMaterial.
  static Color tint(ColorScheme cs, Brightness b, {double boost = 0}) =>
      cs.surface.withValues(
        alpha: ((b == Brightness.dark ? 0.45 : 0.52) + boost).clamp(0.0, 1.0),
      );

  /// Slightly denser wash for text-heavy floating surfaces (menus, sheets).
  static Color tintProminent(ColorScheme cs, Brightness b) =>
      tint(cs, b, boost: 0.18);

  // ── Hairline border ─────────────────────────────────────────────────────
  /// The 1px specular rim that sells the material (pill nav recipe).
  static Color hairline(Brightness b) => b == Brightness.dark
      ? Colors.white.withValues(alpha: 0.12)
      : Colors.black.withValues(alpha: 0.06);

  // ── Shadow (lift off the content layer) ─────────────────────────────────
  static List<BoxShadow> shadow(Brightness b) => [
        BoxShadow(
          color: Colors.black
              .withValues(alpha: b == Brightness.dark ? 0.32 : 0.12),
          blurRadius: 22,
          offset: const Offset(0, 8),
        ),
      ];

  /// Subtler shadow for small inline glass (chips, field triggers).
  static List<BoxShadow> shadowInline(Brightness b) => [
        BoxShadow(
          color: Colors.black
              .withValues(alpha: b == Brightness.dark ? 0.20 : 0.07),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  // ── Press physics ────────────────────────────────────────────────────────
  /// Native-feeling press scale + spring (Apple-ish resistance).
  static const double pressScale = 0.965;
  static const Duration pressIn = Duration(milliseconds: 90);
  static const Duration pressOut = Duration(milliseconds: 260);
  static const Curve pressOutCurve = Curves.easeOutBack;
}

/// Concentric radius scale.
///
/// HIG concentricity: a nested element's radius = parent radius − the gap
/// between them, so both curves share a center. Instead of hardcoding
/// 10/12/14/16/22/24 per screen, derive everything from the user's theme
/// radius (ThemeState.radius, default 18) and the container chain.
class CMRadii {
  CMRadii._();

  /// Outermost floating surfaces: sheets, the pill nav, overlays.
  static double outer(BuildContext context) => _base(context) + 6; // 24 @ 18

  /// Standard cards / dialogs / menus.
  static double card(BuildContext context) => _base(context); // 18

  /// Inputs & field triggers (nested one level inside a card: −4 gap).
  static double field(BuildContext context) => _base(context) - 4; // 14

  /// Small nested elements: chips, icon boxes (−8).
  static double chip(BuildContext context) => _base(context) - 8; // 10

  /// Full capsule.
  static const double capsule = 999;

  /// Concentric child radius for an arbitrary parent radius and inset gap.
  static double concentric(double parentRadius, double gap) =>
      (parentRadius - gap).clamp(0.0, double.infinity);

  static double _base(BuildContext context) {
    // ThemeState.radius flows into cardTheme's shape — read it back from the
    // theme so widgets don't need the controller.
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      final r = shape.borderRadius;
      if (r is BorderRadius) return r.topLeft.x;
    }
    return 18;
  }
}
