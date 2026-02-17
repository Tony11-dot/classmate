import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemePreset { appleClean, sharpContrast, softFriendly }

class ThemeState {
  final ThemeMode mode;
  final ThemePreset preset;
  final Color accent;
  final double radius;
  final double density;

  const ThemeState({
    required this.mode,
    required this.preset,
    required this.accent,
    required this.radius,
    required this.density,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    ThemePreset? preset,
    Color? accent,
    double? radius,
    double? density,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      preset: preset ?? this.preset,
      accent: accent ?? this.accent,
      radius: radius ?? this.radius,
      density: density ?? this.density,
    );
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    return const ThemeState(
      mode: ThemeMode.system,
      preset: ThemePreset.appleClean,
      accent: Color(0xFF3B82F6),
      radius: 14,
      density: 0,
    );
  }

  void setMode(ThemeMode m) => state = state.copyWith(mode: m);
  void setPreset(ThemePreset p) => state = state.copyWith(preset: p);
  void setAccent(Color c) => state = state.copyWith(accent: c);
  void setRadius(double r) => state = state.copyWith(radius: r);
  void setDensity(double d) => state = state.copyWith(density: d);

  ThemeData theme(Brightness b) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: b,
      colorScheme: ColorScheme.fromSeed(seedColor: state.accent, brightness: b),
      visualDensity: VisualDensity(
        horizontal: state.density,
        vertical: state.density,
      ),
    );

    final r = BorderRadius.circular(state.radius);
    final cs = base.colorScheme;

    final bool highContrast = state.preset == ThemePreset.sharpContrast;
    final bool soft = state.preset == ThemePreset.softFriendly;

    return base.copyWith(
      scaffoldBackgroundColor: soft
          ? (b == Brightness.dark
                ? const Color(0xFF0B0F14)
                : const Color(0xFFF6F7FB))
          : base.scaffoldBackgroundColor,
      cardTheme: CardThemeData(
        elevation: highContrast ? 2 : 1,
        color: soft
            ? (b == Brightness.dark ? const Color(0xFF121A24) : Colors.white)
            : null,
        shape: RoundedRectangleBorder(borderRadius: r),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: cs.onSurface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: soft
            ? (b == Brightness.dark
                  ? const Color(0xFF0F1722)
                  : const Color(0xFFF1F3F8))
            : null,
        border: OutlineInputBorder(borderRadius: r),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: soft
            ? (b == Brightness.dark ? const Color(0xFF0F1722) : Colors.white)
            : null,
      ),
    );
  }
}
