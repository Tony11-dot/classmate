import 'package:flutter/cupertino.dart'; // CupertinoPageTransitionsBuilder moved here in Flutter 3.44 (decouple-page-transition-builders)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(
  ThemeController.new,
);

/// The app's curated theme lineup.
///
/// Instead of a light/dark toggle plus a free accent picker, the whole look is
/// chosen as one cohesive, hand-tuned palette (à la coffee-mode blogs). Each
/// theme bakes in its own perfect accent, surfaces and text colours, and
/// declares a [Brightness] so the brand logo / loader / status bar are always
/// the right variant for it — light themes get the dark wordmark, dark themes
/// get the white one, no per-theme wiring needed.
///
/// [system] is the only value that isn't a fixed palette: it follows the OS
/// between the plain [light] and [dark] defaults.
enum AppTheme {
  system,
  // Light family
  light,
  coffee,
  matcha,
  rose,
  // Dark family
  dark,
  midnight,
  nord,
  forest,
}

class ThemeState {
  const ThemeState({
    required this.theme,
    required this.radius,
    required this.density,
    required this.textScale,
    required this.reduceMotion,
  });

  final AppTheme theme;
  final double radius;
  final double density;
  final double textScale;
  final bool reduceMotion;

  ThemeState copyWith({
    AppTheme? theme,
    double? radius,
    double? density,
    double? textScale,
    bool? reduceMotion,
  }) {
    return ThemeState(
      theme: theme ?? this.theme,
      radius: radius ?? this.radius,
      density: density ?? this.density,
      textScale: textScale ?? this.textScale,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

class ThemeController extends Notifier<ThemeState> {
  static const _kMode = 'ui_mode';
  static const _kRadius = 'ui_radius';
  static const _kDensity = 'ui_density';
  static const _kTextScale = 'ui_text_scale';
  static const _kReduceMotion = 'ui_reduce_motion';

  @override
  ThemeState build() {
    _load();
    return const ThemeState(
      theme: AppTheme.light,
      radius: 18.0,
      density: 0.0,
      textScale: 1.0,
      reduceMotion: false,
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Default to light when the user has never picked one. Old builds stored
    // 'light' / 'dark' / 'coffee' / 'system' — the enum names still match, so
    // existing choices survive; the retired free-accent pref is ignored.
    final modeRaw = prefs.getString(_kMode) ?? 'light';
    final theme = AppTheme.values
        .where((t) => t.name == modeRaw)
        .firstOrNull ??
        AppTheme.light;

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
      theme: theme,
      radius: radius,
      density: density,
      textScale: textScale,
      reduceMotion: reduceMotion,
    );
  }

  Future<void> setTheme(AppTheme theme) async {
    state = state.copyWith(theme: theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, theme.name);
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

// ─────────────────────────────────────────────────────────────────────────────
//  Palettes
// ─────────────────────────────────────────────────────────────────────────────

/// One theme's colour recipe: a seed + brightness (which drives the whole
/// Material 3 tonal system, and the logo / loader / status-bar variant), plus
/// optional overrides that repaint the neutral surfaces and text into the
/// theme's own aesthetic (the way coffee turns the greys into latte + espresso).
class _Palette {
  const _Palette({
    required this.brightness,
    required this.seed,
    this.overrides,
  });

  final Brightness brightness;
  final Color seed;

  /// Repaints [base] into the theme's bespoke surfaces/text. When null the raw
  /// Material 3 tonal scheme is used as-is (the plain Light / Dark defaults).
  final ColorScheme Function(ColorScheme base)? overrides;

  bool get isTinted => overrides != null;

  ColorScheme scheme() {
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);
    return overrides?.call(base) ?? base;
  }
}

const _skySeed = Color(0xFF0EA5E9);

// ── Light family ─────────────────────────────────────────────────────────────

const _lightPalette = _Palette(brightness: Brightness.light, seed: _skySeed);

/// Warm sepia latte + espresso — a coffee-mode-blog page.
final _coffeePalette = _Palette(
  brightness: Brightness.light,
  seed: const Color(0xFF9B6B43),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFFF3E9D8),
    onSurface: const Color(0xFF3B2F25),
    onSurfaceVariant: const Color(0xFF6A5B4B),
    surfaceContainerLowest: const Color(0xFFFBF4E7),
    surfaceContainerLow: const Color(0xFFF6ECDC),
    surfaceContainer: const Color(0xFFEFE4D1),
    surfaceContainerHigh: const Color(0xFFE9DCC7),
    surfaceContainerHighest: const Color(0xFFE2D4BC),
    outline: const Color(0xFFA1907B),
    outlineVariant: const Color(0xFFCDBBA0),
    primaryContainer: const Color(0xFFF0DAC2),
    onPrimaryContainer: const Color(0xFF3D2A18),
    secondaryContainer: const Color(0xFFEBD9C4),
    onSecondaryContainer: const Color(0xFF362619),
  ),
);

/// Soft green-tea: pistachio cream surfaces, deep fern accent.
final _matchaPalette = _Palette(
  brightness: Brightness.light,
  seed: const Color(0xFF4F7942),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFFF1F4E7),
    onSurface: const Color(0xFF2B3327),
    onSurfaceVariant: const Color(0xFF586353),
    surfaceContainerLowest: const Color(0xFFF8FAEF),
    surfaceContainerLow: const Color(0xFFEDF1E0),
    surfaceContainer: const Color(0xFFE6EBD6),
    surfaceContainerHigh: const Color(0xFFDFE5CC),
    surfaceContainerHighest: const Color(0xFFD7DEC1),
    outline: const Color(0xFF8A9578),
    outlineVariant: const Color(0xFFC4CCAF),
    primaryContainer: const Color(0xFFDCE9C4),
    onPrimaryContainer: const Color(0xFF25341A),
    secondaryContainer: const Color(0xFFDEE7CC),
    onSecondaryContainer: const Color(0xFF283420),
  ),
);

/// Rosé (à la Rosé Pine Dawn): warm paper surfaces, muted mauve text, rose
/// accent.
final _rosePalette = _Palette(
  brightness: Brightness.light,
  seed: const Color(0xFFB4637A),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFFFAF4ED),
    onSurface: const Color(0xFF575279),
    onSurfaceVariant: const Color(0xFF797593),
    surfaceContainerLowest: const Color(0xFFFFFAF3),
    surfaceContainerLow: const Color(0xFFF7F0E8),
    surfaceContainer: const Color(0xFFF2E9E1),
    surfaceContainerHigh: const Color(0xFFEADFD4),
    surfaceContainerHighest: const Color(0xFFE3D6C9),
    outline: const Color(0xFFA79C93),
    outlineVariant: const Color(0xFFDDD0C4),
    primaryContainer: const Color(0xFFF4DDE3),
    onPrimaryContainer: const Color(0xFF54293A),
    secondaryContainer: const Color(0xFFEBDDE0),
    onSecondaryContainer: const Color(0xFF433045),
  ),
);

// ── Dark family ──────────────────────────────────────────────────────────────

const _darkPalette = _Palette(brightness: Brightness.dark, seed: _skySeed);

/// Deep ocean navy with a periwinkle accent.
final _midnightPalette = _Palette(
  brightness: Brightness.dark,
  seed: const Color(0xFF6D8BFF),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFF0E1428),
    onSurface: const Color(0xFFDCE2F4),
    onSurfaceVariant: const Color(0xFF9AA6C6),
    surfaceContainerLowest: const Color(0xFF0A0F20),
    surfaceContainerLow: const Color(0xFF141B33),
    surfaceContainer: const Color(0xFF18203B),
    surfaceContainerHigh: const Color(0xFF212A48),
    surfaceContainerHighest: const Color(0xFF2B3556),
    outline: const Color(0xFF48557A),
    outlineVariant: const Color(0xFF2E3A5C),
    primary: const Color(0xFF8FA6FF),
    onPrimary: const Color(0xFF10193A),
    primaryContainer: const Color(0xFF283A72),
    onPrimaryContainer: const Color(0xFFDBE3FF),
    secondaryContainer: const Color(0xFF25304F),
    onSecondaryContainer: const Color(0xFFCED6F2),
  ),
);

/// Nord — the arctic polar-night slate with a frost-blue accent.
final _nordPalette = _Palette(
  brightness: Brightness.dark,
  seed: const Color(0xFF88C0D0),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFF2E3440),
    onSurface: const Color(0xFFECEFF4),
    onSurfaceVariant: const Color(0xFFC8CFDC),
    surfaceContainerLowest: const Color(0xFF272C36),
    surfaceContainerLow: const Color(0xFF323846),
    surfaceContainer: const Color(0xFF3B4252),
    surfaceContainerHigh: const Color(0xFF434C5E),
    surfaceContainerHighest: const Color(0xFF4C566A),
    outline: const Color(0xFF616E88),
    outlineVariant: const Color(0xFF434C5E),
    primary: const Color(0xFF88C0D0),
    onPrimary: const Color(0xFF22303A),
    primaryContainer: const Color(0xFF3B4252),
    onPrimaryContainer: const Color(0xFFD8DEE9),
    secondaryContainer: const Color(0xFF3B4252),
    onSecondaryContainer: const Color(0xFFE5E9F0),
  ),
);

/// Forest (à la Everforest) — cosy pine surfaces, sage-green accent, warm text.
final _forestPalette = _Palette(
  brightness: Brightness.dark,
  seed: const Color(0xFFA7C080),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFF2D353B),
    onSurface: const Color(0xFFD3C6AA),
    onSurfaceVariant: const Color(0xFFA6B0A0),
    surfaceContainerLowest: const Color(0xFF272E33),
    surfaceContainerLow: const Color(0xFF323C41),
    surfaceContainer: const Color(0xFF374247),
    surfaceContainerHigh: const Color(0xFF3D484D),
    surfaceContainerHighest: const Color(0xFF475258),
    outline: const Color(0xFF56635F),
    outlineVariant: const Color(0xFF3D484D),
    primary: const Color(0xFFA7C080),
    onPrimary: const Color(0xFF283026),
    primaryContainer: const Color(0xFF425047),
    onPrimaryContainer: const Color(0xFFD8E8B4),
    secondaryContainer: const Color(0xFF3A4740),
    onSecondaryContainer: const Color(0xFFD3E0C0),
  ),
);

_Palette _concretePalette(AppTheme theme) => switch (theme) {
      AppTheme.system || AppTheme.light => _lightPalette,
      AppTheme.coffee => _coffeePalette,
      AppTheme.matcha => _matchaPalette,
      AppTheme.rose => _rosePalette,
      AppTheme.dark => _darkPalette,
      AppTheme.midnight => _midnightPalette,
      AppTheme.nord => _nordPalette,
      AppTheme.forest => _forestPalette,
    };

/// Whether a concrete theme is a dark palette (used for the status bar / logo
/// variant). [AppTheme.system] is resolved by the OS, not here.
bool appThemeIsDark(AppTheme theme) =>
    _concretePalette(theme).brightness == Brightness.dark;

// ─────────────────────────────────────────────────────────────────────────────
//  Theme building
// ─────────────────────────────────────────────────────────────────────────────

/// Resolves [s] into the `theme` / `darkTheme` / `themeMode` trio for
/// [MaterialApp]. Every concrete theme is a fixed palette, so both slots hold
/// the same [ThemeData] and `themeMode` just pins its brightness; only
/// [AppTheme.system] hands the plain Light and Dark defaults to the OS.
({ThemeData light, ThemeData dark, ThemeMode mode}) resolveAppTheme(
  ThemeState s,
) {
  if (s.theme == AppTheme.system) {
    return (
      light: _buildTheme(_lightPalette, s),
      dark: _buildTheme(_darkPalette, s),
      mode: ThemeMode.system,
    );
  }
  final p = _concretePalette(s.theme);
  final td = _buildTheme(p, s);
  return (
    light: td,
    dark: td,
    mode: p.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
  );
}

ThemeData _buildTheme(_Palette p, ThemeState s) {
  final scheme = p.scheme();
  final brightness = p.brightness;

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    // App-wide UI typeface: Cabinet Grotesk (bundled). Arabic/Hebrew have no
    // Cabinet glyphs and fall back to the platform / CanvasKit Noto fonts.
    fontFamily: 'CabinetGrotesk',
    visualDensity: VisualDensity(horizontal: s.density, vertical: s.density),
  );

  // Tinted themes (coffee, matcha, rosé, …) carry a bespoke text colour in the
  // scheme; the plain Light / Dark defaults keep pure black / white so they
  // look exactly as before.
  final on = p.isTinted
      ? scheme.onSurface
      : ((brightness == Brightness.dark) ? Colors.white : Colors.black);

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
    // Native iOS slide + finger-following swipe-back for EVERY pushed route
    // (MaterialPageRoute and CupertinoPage alike) — so swipe-back works on
    // every detail screen, NOVA thread, classroom, etc., for free. Top-level
    // TABS override this with a fade via _fadeRoute in router.dart.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS:   CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
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
    // ── Liquid-glass menus everywhere ────────────────────────────────────
    // Every PopupMenuButton (three-dots), DropdownButton and Menu shares one
    // rounded, hairline-bordered, tint-free surface so lists look consistent.
    popupMenuTheme: PopupMenuThemeData(
      color: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      textStyle: TextStyle(color: on, fontWeight: FontWeight.w600),
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        )),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        )),
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
