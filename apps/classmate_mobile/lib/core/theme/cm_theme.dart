import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'cm_tokens.dart';

class CMTheme {
  static ThemeData light({Color? accent}) {
    final a = accent ?? CMTokens.accent;

    final cs = ColorScheme(
      brightness: Brightness.light,
      primary: a,
      onPrimary: Colors.white,
      secondary: CMTokens.accent2,
      onSecondary: Colors.white,
      error: CMTokens.bad,
      onError: Colors.white,
      background: CMTokens.paper,
      onBackground: CMTokens.ink,
      surface: CMTokens.paper2,
      onSurface: CMTokens.ink,
      surfaceVariant: const Color(0xFFEFF1F7),
      onSurfaceVariant: const Color(0xFF253149),
      outline: const Color(0x2B22304A),
      shadow: const Color(0x33000000),
      inverseSurface: CMTokens.ink,
      onInverseSurface: CMTokens.paper2,
      inversePrimary: a,
      tertiary: const Color(0xFF34D399),
      onTertiary: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    final text = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w800, letterSpacing: -0.6),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
    );

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onBackground,
        titleTextStyle: text.titleMedium?.copyWith(
          color: cs.onBackground,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surface.withOpacity(0.85),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CMTokens.radiusLg),
          side: BorderSide(color: cs.outline.withOpacity(0.35)),
        ),
        margin: const EdgeInsets.all(0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surface.withOpacity(0.75),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CMTokens.radiusMd),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.45)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CMTokens.radiusMd),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CMTokens.radiusMd),
          borderSide: BorderSide(color: cs.primary.withOpacity(0.85), width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CMTokens.radiusMd)),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(CMTokens.radiusMd)),
          side: BorderSide(color: cs.outline.withOpacity(0.45)),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      dividerTheme: DividerThemeData(color: cs.outline.withOpacity(0.25), thickness: 1),
    );
  }

  static ThemeData dark({Color? accent}) {
    final a = accent ?? CMTokens.accent;

    final cs = ColorScheme(
      brightness: Brightness.dark,
      primary: a,
      onPrimary: Colors.white,
      secondary: CMTokens.accent2,
      onSecondary: Colors.white,
      error: CMTokens.bad,
      onError: Colors.white,
      background: CMTokens.night,
      onBackground: const Color(0xFFEAF0FF),
      surface: CMTokens.night2,
      onSurface: const Color(0xFFEAF0FF),
      surfaceVariant: const Color(0xFF151C2B),
      onSurfaceVariant: const Color(0xFFB9C3DB),
      outline: const Color(0x3B7C8AAE),
      shadow: const Color(0x66000000),
      inverseSurface: const Color(0xFFF6F7FB),
      onInverseSurface: CMTokens.ink,
      inversePrimary: a,
      tertiary: const Color(0xFF34D399),
      onTertiary: Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: cs.background,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

    final text = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w800, letterSpacing: -0.6),
      titleLarge: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, letterSpacing: -0.2),
      bodyLarge: GoogleFonts.inter(fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.inter(fontWeight: FontWeight.w500),
      labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
    );

    return base.copyWith(
      textTheme: text,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onBackground,
        titleTextStyle: text.titleMedium?.copyWith(
          color: cs.onBackground,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surface.withOpacity(0.72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CMTokens.radiusLg),
          side: BorderSide(color: cs.outline.withOpacity(0.35)),
        ),
        margin: const EdgeInsets.all(0),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surface.withOpacity(0.65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CMTokens.radiusMd),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.45)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CMTokens.radiusMd),
          borderSide: BorderSide(color: cs.outline.withOpacity(0.35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CMTokens.radiusMd),
          borderSide: BorderSide(color: cs.primary.withOpacity(0.9), width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dividerTheme: DividerThemeData(color: cs.outline.withOpacity(0.25), thickness: 1),
    );
  }

  static Widget heroBackground({required Widget child, required bool dark}) {
    final colors = dark ? CMTokens.heroGradientDark : CMTokens.heroGradientLight;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: child,
    );
  }

  static Color glassBorder(ColorScheme cs) =>
      cs.outline.withOpacity(cs.brightness == Brightness.dark ? 0.35 : 0.30);

  static Color glassFill(ColorScheme cs) =>
      (cs.brightness == Brightness.dark ? cs.surface : cs.surface).withOpacity(
        cs.brightness == Brightness.dark ? 0.62 : 0.72,
      );

  static ImageFilter glassBlur({double sigma = CMTokens.blurMd}) =>
      ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
}
