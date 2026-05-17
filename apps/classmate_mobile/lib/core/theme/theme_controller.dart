import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);

class ThemeState {
  const ThemeState({
    required this.mode,
    required this.accent,
    required this.radius,
    required this.density,
    required this.textScale,
    required this.reduceMotion,
  });

  final ThemeMode mode;
  final Color accent;
  final double radius;
  final double density;
  final double textScale;
  final bool reduceMotion;

  ThemeState copyWith({
    ThemeMode? mode,
    Color? accent,
    double? radius,
    double? density,
    double? textScale,
    bool? reduceMotion,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      accent: accent ?? this.accent,
      radius: radius ?? this.radius,
      density: density ?? this.density,
      textScale: textScale ?? this.textScale,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

class ThemeController extends Notifier<ThemeState> {
  static const _kMode = 'ui_mode';
  static const _kAccent = 'ui_accent';
  static const _kRadius = 'ui_radius';
  static const _kDensity = 'ui_density';
  static const _kTextScale = 'ui_text_scale';
  static const _kReduceMotion = 'ui_reduce_motion';

  @override
  ThemeState build() {
    _load();
    return const ThemeState(
      mode: ThemeMode.system,
      accent: Color(0xFF0EA5E9),
      radius: 18.0,
      density: 0.0,
      textScale: 1.0,
      reduceMotion: false,
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final modeRaw = prefs.getString(_kMode) ?? 'system';
    final mode = switch (modeRaw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    final accent = Color(
      prefs.getInt(_kAccent) ?? const Color(0xFF0EA5E9).toARGB32(),
    );

    final radius = (prefs.getDouble(_kRadius) ?? 18.0)
        .clamp(8.0, 28.0)
        .toDouble();
    final density = (prefs.getDouble(_kDensity) ?? 0.0)
        .clamp(-1.0, 1.0)
        .toDouble();
    final textScale = (prefs.getDouble(_kTextScale) ?? 1.0)
        .clamp(0.9, 1.3)
        .toDouble();
    final reduceMotion = prefs.getBool(_kReduceMotion) ?? false;

    state = state.copyWith(
      mode: mode,
      accent: accent,
      radius: radius,
      density: density,
      textScale: textScale,
      reduceMotion: reduceMotion,
    );
  }

  Future<void> setMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      _ => 'system',
    });
  }

  Future<void> setAccent(Color c) async {
    state = state.copyWith(accent: c);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAccent, c.toARGB32());
  }

  Future<void> setRadius(double r) async {
    final v = r.clamp(8.0, 28.0).toDouble();
    state = state.copyWith(radius: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kRadius, v);
  }

  Future<void> setDensity(double d) async {
    final v = d.clamp(-1.0, 1.0).toDouble();
    state = state.copyWith(density: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kDensity, v);
  }

  Future<void> setTextScale(double s) async {
    final v = s.clamp(0.9, 1.3).toDouble();
    state = state.copyWith(textScale: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kTextScale, v);
  }

  Future<void> setReduceMotion(bool v) async {
    state = state.copyWith(reduceMotion: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReduceMotion, v);
  }
}

ThemeData buildTheme({required Brightness brightness, required ThemeState s}) {
  final scheme = ColorScheme.fromSeed(
    seedColor: s.accent,
    brightness: brightness,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    visualDensity: VisualDensity(horizontal: s.density, vertical: s.density),
  );

  final on = (brightness == Brightness.dark) ? Colors.white : Colors.black;

  final fixedTextTheme = base.textTheme.apply(
    bodyColor: on,
    displayColor: on,
    decorationColor: on,
  );

  final fixedPrimaryTextTheme = base.primaryTextTheme.apply(
    bodyColor: on,
    displayColor: on,
    decorationColor: on,
  );

  return base.copyWith(
    textTheme: fixedTextTheme,
    primaryTextTheme: fixedPrimaryTextTheme,
    scaffoldBackgroundColor: scheme.surface,
    // Use the iOS slide-in transition AND swipe-back gesture for every
    // MaterialPageRoute push on iOS. Without this, Material's default
    // transition gives iOS users an Android-style fade with no swipe-back
    // — surprising on a platform where edge-swipe-to-go-back is muscle
    // memory. Android keeps the platform default.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS:   CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      // Use the exact same surface color as the scaffold body so every
      // AppBar blends seamlessly with the page beneath it.
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(s.radius),
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(s.radius),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      textColor: on,
      iconColor: on,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(s.radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(s.radius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
