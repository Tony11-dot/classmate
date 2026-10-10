import 'package:flutter/material.dart';

/// Additive design tokens layered on top of the app's 20 hand-tuned
/// [ColorScheme]s (see theme_controller.dart). This carries only
/// *theme-agnostic* primitives — elevation, spacing, radii, motion — plus a
/// couple of universal signal colours (success green / attention amber) that
/// read correctly on every palette. It deliberately defines NO brand colour:
/// brand/surface/text always come from the active `ColorScheme`, so coffee,
/// matcha, nord, etc. keep their identity while every screen gains the same
/// depth and rhythm.
///
/// Access with `CmTokens.of(context)`. Registered as a [ThemeExtension] on both
/// the light and dark [ThemeData] in `_buildTheme`.
@immutable
class CmTokens extends ThemeExtension<CmTokens> {
  const CmTokens({
    required this.good,
    required this.onGood,
    required this.goodContainer,
    required this.onGoodContainer,
    required this.warn,
    required this.onWarn,
    required this.warnContainer,
    required this.onWarnContainer,
    required this.shadowSm,
    required this.shadowMd,
    required this.shadowLg,
  });

  // ── Universal signal colours (not the brand) ──────────────────────────────
  final Color good; // success / granted / positive
  final Color onGood;
  final Color goodContainer;
  final Color onGoodContainer;
  final Color warn; // attention / due-soon / pending
  final Color onWarn;
  final Color warnContainer;
  final Color onWarnContainer;

  // ── Elevation (soft, layered; neutral black-alpha so it suits any palette) ─
  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowMd;
  final List<BoxShadow> shadowLg;

  // ── Spacing scale (4-pt system) ───────────────────────────────────────────
  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;

  // ── Corner radii ──────────────────────────────────────────────────────────
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 28;

  // ── Motion ────────────────────────────────────────────────────────────────
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration medium = Duration(milliseconds: 240);
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;

  static CmTokens of(BuildContext context) =>
      Theme.of(context).extension<CmTokens>() ??
      CmTokens.fromBrightness(Theme.of(context).brightness);

  factory CmTokens.fromBrightness(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    BoxShadow s(double alpha, double blur, double spread, double dy) => BoxShadow(
          color: Colors.black.withValues(alpha: alpha),
          blurRadius: blur,
          spreadRadius: spread,
          offset: Offset(0, dy),
        );
    return CmTokens(
      // Light values sit at ≥4.6:1 on every light surface tint so signal text
      // ("94%", "due soon") and white-on-signal fills both pass WCAG AA.
      good: dark ? const Color(0xFF45D08A) : const Color(0xFF0F7D4D),
      onGood: dark ? const Color(0xFF04140B) : Colors.white,
      goodContainer: dark ? const Color(0xFF123024) : const Color(0xFFDCF5E9),
      onGoodContainer: dark ? const Color(0xFFBBF0D4) : const Color(0xFF0B5234),
      warn: dark ? const Color(0xFFE6A34A) : const Color(0xFF99600A),
      onWarn: dark ? const Color(0xFF231402) : Colors.white,
      warnContainer: dark ? const Color(0xFF3A2C13) : const Color(0xFFFBEEDB),
      onWarnContainer: dark ? const Color(0xFFF6DBB0) : const Color(0xFF6B4400),
      shadowSm: dark
          ? [s(0.40, 6, 0, 2)]
          : [s(0.05, 2, 0, 1), s(0.05, 6, 0, 2)],
      shadowMd: dark
          ? [s(0.50, 10, -2, 4), s(0.55, 28, -10, 14)]
          : [s(0.06, 6, 0, 2), s(0.14, 28, -8, 12)],
      shadowLg: dark
          ? [s(0.55, 24, -6, 10), s(0.65, 60, -20, 28)]
          : [s(0.14, 20, -6, 8), s(0.24, 56, -18, 28)],
    );
  }

  @override
  CmTokens copyWith({
    Color? good,
    Color? onGood,
    Color? goodContainer,
    Color? onGoodContainer,
    Color? warn,
    Color? onWarn,
    Color? warnContainer,
    Color? onWarnContainer,
    List<BoxShadow>? shadowSm,
    List<BoxShadow>? shadowMd,
    List<BoxShadow>? shadowLg,
  }) {
    return CmTokens(
      good: good ?? this.good,
      onGood: onGood ?? this.onGood,
      goodContainer: goodContainer ?? this.goodContainer,
      onGoodContainer: onGoodContainer ?? this.onGoodContainer,
      warn: warn ?? this.warn,
      onWarn: onWarn ?? this.onWarn,
      warnContainer: warnContainer ?? this.warnContainer,
      onWarnContainer: onWarnContainer ?? this.onWarnContainer,
      shadowSm: shadowSm ?? this.shadowSm,
      shadowMd: shadowMd ?? this.shadowMd,
      shadowLg: shadowLg ?? this.shadowLg,
    );
  }

  @override
  CmTokens lerp(ThemeExtension<CmTokens>? other, double t) {
    if (other is! CmTokens) return this;
    return CmTokens(
      good: Color.lerp(good, other.good, t)!,
      onGood: Color.lerp(onGood, other.onGood, t)!,
      goodContainer: Color.lerp(goodContainer, other.goodContainer, t)!,
      onGoodContainer: Color.lerp(onGoodContainer, other.onGoodContainer, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      onWarn: Color.lerp(onWarn, other.onWarn, t)!,
      warnContainer: Color.lerp(warnContainer, other.warnContainer, t)!,
      onWarnContainer: Color.lerp(onWarnContainer, other.onWarnContainer, t)!,
      shadowSm: BoxShadow.lerpList(shadowSm, other.shadowSm, t) ?? shadowSm,
      shadowMd: BoxShadow.lerpList(shadowMd, other.shadowMd, t) ?? shadowMd,
      shadowLg: BoxShadow.lerpList(shadowLg, other.shadowLg, t) ?? shadowLg,
    );
  }
}
