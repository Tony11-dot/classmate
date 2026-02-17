import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemePreset { minimal, iosCards, sharpContrast }

@immutable
class ThemeState {
  final ThemeMode mode;
  final ThemePreset preset;
  final Color seed;
  final double radius;
  final double density;

  const ThemeState({
    required this.mode,
    required this.preset,
    required this.seed,
    required this.radius,
    required this.density,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    ThemePreset? preset,
    Color? seed,
    double? radius,
    double? density,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      preset: preset ?? this.preset,
      seed: seed ?? this.seed,
      radius: radius ?? this.radius,
      density: density ?? this.density,
    );
  }
}

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return const ThemeState(
      mode: ThemeMode.system,
      preset: ThemePreset.iosCards,
      seed: Colors.blue,
      radius: 14,
      density: 0,
    );
  }

  void setMode(ThemeMode m) => state = state.copyWith(mode: m);
  void setPreset(ThemePreset p) => state = state.copyWith(preset: p);
  void setSeed(Color c) => state = state.copyWith(seed: c);
  void setRadius(double r) => state = state.copyWith(radius: r);
  void setDensity(double d) => state = state.copyWith(density: d);
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);

ThemeData buildTheme(ThemeState s, Brightness b) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: b,
    colorSchemeSeed: s.seed,
  );

  double presetRadius;
  double presetDensity;
  double cardElevation;
  double dividerThickness;

  switch (s.preset) {
    case ThemePreset.minimal:
      presetRadius = 10;
      presetDensity = -0.3;
      cardElevation = 0;
      dividerThickness = 1;
      break;
    case ThemePreset.iosCards:
      presetRadius = 16;
      presetDensity = 0.0;
      cardElevation = 0.6;
      dividerThickness = 0.0;
      break;
    case ThemePreset.sharpContrast:
      presetRadius = 8;
      presetDensity = -0.1;
      cardElevation = 0.0;
      dividerThickness = 1.2;
      break;
  }

  // user tweaks
  final radius = (presetRadius + (s.radius - 14)).clamp(6, 22).toDouble();
  final density = (presetDensity + s.density).clamp(-2, 2).toDouble();

  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(radius),
  );

  final scheme = base.colorScheme.copyWith(
    surface: b == Brightness.dark
        ? const Color(0xFF0B0B0F)
        : base.colorScheme.surface,
    surfaceContainerHighest: b == Brightness.dark
        ? const Color(0xFF141420)
        : base.colorScheme.surfaceContainerHighest,
  );

  return base.copyWith(
    colorScheme: scheme,
    visualDensity: VisualDensity(horizontal: density, vertical: density),
    dividerTheme: DividerThemeData(thickness: dividerThickness, space: 1),
    cardTheme: CardThemeData(
      shape: shape,
      elevation: cardElevation,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(shape: MaterialStatePropertyAll(shape)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(shape: MaterialStatePropertyAll(shape)),
    ),
  );
}
