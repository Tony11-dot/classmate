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
      mode: ThemeMode.light,
      accent: Color(0xFF0EA5E9),
      radius: 18.0,
      density: 0.0,
      textScale: 1.0,
      reduceMotion: false,
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    // Default to light mode when the user has never picked one.
    // Anyone who explicitly chose system/dark in Settings still gets
    // their choice — only the unset case is affected.
    final modeRaw = prefs.getString(_kMode) ?? 'light';
    final mode = switch (modeRaw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
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

  // ── Concentric radius chain (HIG concentricity) ───────────────────────────
  // One token drives every corner: nested elements shrink their radius by the
  // gap to their container so all curves share a center. At the default
  // radius (18): sheets/dialogs 24 · cards/menus 18 · inputs 14 · chips 10.
  final rOuter = s.radius + 6.0; // sheets, dialogs — outermost floating layer
  final rCard = s.radius; // cards, menus, buttons
  final rField = (s.radius - 4.0).clamp(8.0, 24.0); // inputs, segmented
  final rChip = (s.radius - 8.0).clamp(6.0, 20.0); // chips, small nested

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    // App-wide UI typeface: Cabinet Grotesk (bundled). Arabic/Hebrew have no
    // Cabinet glyphs and fall back to the platform / CanvasKit Noto fonts.
    fontFamily: 'CabinetGrotesk',
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
          borderRadius: BorderRadius.circular(rCard),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rCard),
        ),
        side: BorderSide(color: scheme.outlineVariant),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rField),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    ),
    // ── Floating layer: dialogs, sheets, snackbars ───────────────────────
    // Outermost radius of the concentric chain + zero surface tint so the
    // shape (not a color cast) carries the elevation, like native iOS.
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rOuter),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: scheme.surface,
      // NOT showDragHandle:true — most sheets hand-roll their own handle
      // (audit), a global default would double them. Opt in per sheet.
      dragHandleColor: scheme.onSurfaceVariant.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(rOuter)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: brightness == Brightness.dark
          ? scheme.surfaceContainerHigh
          : scheme.inverseSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rField),
      ),
      insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(rChip),
      ),
      side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rField),
        ),
        side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant.withValues(alpha: 0.5),
      thickness: 0.5,
      space: 0.5,
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
        borderRadius: BorderRadius.circular(rCard),
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
          borderRadius: BorderRadius.circular(rCard),
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
          borderRadius: BorderRadius.circular(rCard),
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
