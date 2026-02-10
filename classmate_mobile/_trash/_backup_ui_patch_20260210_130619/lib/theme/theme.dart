import 'package:flutter/material.dart';

enum ThemePreset { soft, sharp }

class ThemeBundle {
  final ThemeData light;
  final ThemeData dark;
  final ThemeMode mode;

  const ThemeBundle({
    required this.light,
    required this.dark,
    required this.mode,
  });
}

ThemeData _base({
  required Brightness brightness,
  required Color seed,
  required double radius,
  required double density,
  required ThemePreset preset,
}) {
  final cs = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

  final text = (preset == ThemePreset.sharp)
      ? const TextTheme()
      : const TextTheme();

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: cs,
    textTheme: text,
    visualDensity: VisualDensity(horizontal: density, vertical: density),
    scaffoldBackgroundColor: cs.surface,
    cardTheme: CardThemeData(
      elevation: preset == ThemePreset.sharp ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: cs.surface,
      surfaceTintColor: cs.surface,
      foregroundColor: cs.onSurface,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerHighest.withOpacity(
        brightness == Brightness.dark ? 0.35 : 0.55,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
  );
}

ThemeBundle buildTheme({
  required ThemeMode mode,
  required Color seed,
  required double radius,
  required double density,
  required ThemePreset preset,
}) {
  return ThemeBundle(
    mode: mode,
    light: _base(
      brightness: Brightness.light,
      seed: seed,
      radius: radius,
      density: density,
      preset: preset,
    ),
    dark: _base(
      brightness: Brightness.dark,
      seed: seed,
      radius: radius,
      density: density,
      preset: preset,
    ),
  );
}
