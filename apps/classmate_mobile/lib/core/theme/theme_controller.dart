import 'dart:convert';

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
  sand,
  sky,
  lavender,
  peach,
  mint,
  // Dark family
  dark,
  midnight,
  nord,
  forest,
  dracula,
  obsidian,
  wine,
  solarized,
  plum,
  ocean,
}

/// The user-selectable app typefaces (Settings → App font). Every family is
/// bundled in pubspec with 400/500/700 statics; [family] must match the
/// pubspec `family:` key exactly. Cabinet Grotesk is the long-standing
/// default. Arabic/Hebrew glyphs are absent from all of them and fall back
/// to the platform Noto fonts — identical behaviour to Cabinet today.
enum AppFont {
  cabinet('CabinetGrotesk', 'Cabinet Grotesk'),
  clashGrotesk('ClashGrotesk', 'Clash Grotesk'),
  clashDisplay('ClashDisplay', 'Clash Display'),
  satoshi('Satoshi', 'Satoshi'),
  generalSans('GeneralSans', 'General Sans'),
  switzer('Switzer', 'Switzer'),
  chillax('Chillax', 'Chillax'),
  ranade('Ranade', 'Ranade'),
  spaceGrotesk('SpaceGrotesk', 'Space Grotesk'),
  sora('Sora', 'Sora'),
  outfit('Outfit', 'Outfit'),
  manrope('Manrope', 'Manrope'),
  urbanist('Urbanist', 'Urbanist'),
  plusJakarta('PlusJakartaSans', 'Plus Jakarta Sans'),
  dmSans('DMSans', 'DM Sans');

  const AppFont(this.family, this.label);

  /// Pubspec font-family key.
  final String family;

  /// Human name — rendered IN this font in the picker.
  final String label;
}

/// A user-created theme (Settings → Theme → Add theme). Unlike the baked
/// presets it is nothing more than a seed colour + brightness — fed through the
/// same `ColorScheme.fromSeed` pipeline as the plain Light/Dark defaults, so a
/// custom theme is a full, cohesive Material 3 palette generated from one pick.
@immutable
class CustomTheme {
  const CustomTheme({
    required this.id,
    required this.name,
    required this.seed,
    required this.dark,
  });

  final String id;
  final String name;
  final int seed; // ARGB
  final bool dark;

  Color get seedColor => Color(seed);

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'seed': seed, 'dark': dark};

  factory CustomTheme.fromJson(Map<String, dynamic> j) => CustomTheme(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? 'Custom',
        seed: (j['seed'] as num).toInt(),
        dark: (j['dark'] as bool?) ?? false,
      );
}

class ThemeState {
  const ThemeState({
    required this.theme,
    required this.radius,
    required this.density,
    required this.textScale,
    required this.reduceMotion,
    required this.font,
    this.customThemes = const <CustomTheme>[],
    this.customId,
  });

  final AppTheme theme;
  final double radius;
  final double density;
  final double textScale;
  final bool reduceMotion;
  final AppFont font;

  /// User-created themes and which one (if any) is currently active. When
  /// [customId] is non-null it overrides [theme].
  final List<CustomTheme> customThemes;
  final String? customId;

  CustomTheme? get activeCustom => customId == null
      ? null
      : customThemes.where((c) => c.id == customId).firstOrNull;

  ThemeState copyWith({
    AppTheme? theme,
    double? radius,
    double? density,
    double? textScale,
    bool? reduceMotion,
    AppFont? font,
    List<CustomTheme>? customThemes,
    String? customId,
    bool clearCustom = false,
  }) {
    return ThemeState(
      theme: theme ?? this.theme,
      radius: radius ?? this.radius,
      density: density ?? this.density,
      textScale: textScale ?? this.textScale,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      font: font ?? this.font,
      customThemes: customThemes ?? this.customThemes,
      customId: clearCustom ? null : (customId ?? this.customId),
    );
  }
}

class ThemeController extends Notifier<ThemeState> {
  static const _kMode = 'ui_mode';
  static const _kRadius = 'ui_radius';
  static const _kDensity = 'ui_density';
  static const _kTextScale = 'ui_text_scale';
  static const _kReduceMotion = 'ui_reduce_motion';
  static const _kFont = 'ui_font';
  static const _kCustomThemes = 'ui_custom_themes';
  static const _kCustomId = 'ui_custom_id';

  @override
  ThemeState build() {
    _load();
    return const ThemeState(
      theme: AppTheme.light,
      radius: 18.0,
      density: 0.0,
      textScale: 1.0,
      reduceMotion: false,
      font: AppFont.cabinet,
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

    final fontRaw = prefs.getString(_kFont) ?? AppFont.cabinet.name;
    final font = AppFont.values.where((f) => f.name == fontRaw).firstOrNull ??
        AppFont.cabinet;

    // Custom themes (user-created seed themes) + which one is active.
    List<CustomTheme> customThemes = const [];
    final rawCustom = prefs.getString(_kCustomThemes);
    if (rawCustom != null && rawCustom.isNotEmpty) {
      try {
        final decoded = json.decode(rawCustom);
        if (decoded is List) {
          customThemes = decoded
              .whereType<Map<String, dynamic>>()
              .map(CustomTheme.fromJson)
              .toList();
        }
      } catch (_) {
        customThemes = const [];
      }
    }
    final storedCustomId = prefs.getString(_kCustomId);
    final customId = customThemes.any((c) => c.id == storedCustomId)
        ? storedCustomId
        : null;

    state = state.copyWith(
      theme: theme,
      radius: radius,
      density: density,
      textScale: textScale,
      reduceMotion: reduceMotion,
      font: font,
      customThemes: customThemes,
      customId: customId,
      clearCustom: customId == null,
    );
  }

  Future<void> _persistCustom() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kCustomThemes,
      json.encode(state.customThemes.map((c) => c.toJson()).toList()),
    );
    final id = state.customId;
    if (id == null) {
      await prefs.remove(_kCustomId);
    } else {
      await prefs.setString(_kCustomId, id);
    }
  }

  /// Create a custom theme from a seed colour + brightness and activate it.
  /// Returns the new theme's id.
  Future<String> addCustomTheme({
    required String name,
    required Color seed,
    required bool dark,
  }) async {
    final id = 'custom-${DateTime.now().microsecondsSinceEpoch}';
    final theme = CustomTheme(
      id: id,
      name: name.trim().isEmpty ? 'Custom' : name.trim(),
      seed: seed.toARGB32(),
      dark: dark,
    );
    state = state.copyWith(
      customThemes: [...state.customThemes, theme],
      customId: id,
    );
    await _persistCustom();
    return id;
  }

  /// Activate an existing custom theme.
  Future<void> selectCustom(String id) async {
    if (!state.customThemes.any((c) => c.id == id)) return;
    state = state.copyWith(customId: id);
    await _persistCustom();
  }

  Future<void> deleteCustom(String id) async {
    final wasActive = state.customId == id;
    state = state.copyWith(
      customThemes: state.customThemes.where((c) => c.id != id).toList(),
      clearCustom: wasActive,
    );
    await _persistCustom();
  }

  Future<void> setFont(AppFont font) async {
    state = state.copyWith(font: font);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFont, font.name);
  }

  Future<void> setTheme(AppTheme theme) async {
    // Picking a preset deactivates any active custom theme.
    state = state.copyWith(theme: theme, clearCustom: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, theme.name);
    await prefs.remove(_kCustomId);
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

/// Sand — sun-bleached desert paper, warm terracotta accent.
final _sandPalette = _Palette(
  brightness: Brightness.light,
  seed: const Color(0xFFB0632F),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFFF5EDE0),
    onSurface: const Color(0xFF3E342A),
    onSurfaceVariant: const Color(0xFF6E6152),
    surfaceContainerLowest: const Color(0xFFFCF6EC),
    surfaceContainerLow: const Color(0xFFF1E7D8),
    surfaceContainer: const Color(0xFFEBE0CF),
    surfaceContainerHigh: const Color(0xFFE4D7C2),
    surfaceContainerHighest: const Color(0xFFDCCDB4),
    outline: const Color(0xFFA6917A),
    outlineVariant: const Color(0xFFD2C2AB),
    primaryContainer: const Color(0xFFF3DCC4),
    onPrimaryContainer: const Color(0xFF48260F),
    secondaryContainer: const Color(0xFFEADBC6),
    onSecondaryContainer: const Color(0xFF3B2C1B),
  ),
);

/// Sky — airy pale-blue paper, deep ocean accent.
final _skyPalette = _Palette(
  brightness: Brightness.light,
  seed: const Color(0xFF2F6FB0),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFFEDF3F9),
    onSurface: const Color(0xFF27333E),
    onSurfaceVariant: const Color(0xFF556472),
    surfaceContainerLowest: const Color(0xFFF6FAFD),
    surfaceContainerLow: const Color(0xFFE7EFF6),
    surfaceContainer: const Color(0xFFDFE9F2),
    surfaceContainerHigh: const Color(0xFFD6E2ED),
    surfaceContainerHighest: const Color(0xFFCBD9E7),
    outline: const Color(0xFF7C8B9A),
    outlineVariant: const Color(0xFFC0CEDC),
    primaryContainer: const Color(0xFFCFE1F3),
    onPrimaryContainer: const Color(0xFF0E2A42),
    secondaryContainer: const Color(0xFFDAE6F0),
    onSecondaryContainer: const Color(0xFF223341),
  ),
);

/// Lavender — pale lilac paper, muted violet accent.
final _lavenderPalette = _Palette(
  brightness: Brightness.light,
  seed: const Color(0xFF7A5AC2),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFFF3EFFA),
    onSurface: const Color(0xFF332C43),
    onSurfaceVariant: const Color(0xFF635A73),
    surfaceContainerLowest: const Color(0xFFFAF7FE),
    surfaceContainerLow: const Color(0xFFEEE9F7),
    surfaceContainer: const Color(0xFFE7E1F2),
    surfaceContainerHigh: const Color(0xFFDFD8ED),
    surfaceContainerHighest: const Color(0xFFD6CDE6),
    outline: const Color(0xFF8E85A0),
    outlineVariant: const Color(0xFFCEC4DE),
    primaryContainer: const Color(0xFFE4DAF6),
    onPrimaryContainer: const Color(0xFF2C1D4F),
    secondaryContainer: const Color(0xFFE1DBEF),
    onSecondaryContainer: const Color(0xFF302941),
  ),
);

/// Peach — warm apricot cream, soft coral accent.
final _peachPalette = _Palette(
  brightness: Brightness.light,
  seed: const Color(0xFFCB5F4E),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFFFBEEE7),
    onSurface: const Color(0xFF43322C),
    onSurfaceVariant: const Color(0xFF77605A),
    surfaceContainerLowest: const Color(0xFFFFF7F2),
    surfaceContainerLow: const Color(0xFFF7E9E1),
    surfaceContainer: const Color(0xFFF2E1D8),
    surfaceContainerHigh: const Color(0xFFEBD8CD),
    surfaceContainerHighest: const Color(0xFFE3CCC0),
    outline: const Color(0xFFAB9188),
    outlineVariant: const Color(0xFFDCC7BD),
    primaryContainer: const Color(0xFFF8D9CE),
    onPrimaryContainer: const Color(0xFF521F13),
    secondaryContainer: const Color(0xFFEFDBD0),
    onSecondaryContainer: const Color(0xFF43291F),
  ),
);

/// Mint — cool pale mint paper, deep teal accent.
final _mintPalette = _Palette(
  brightness: Brightness.light,
  seed: const Color(0xFF2E9C86),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFFEAF4EF),
    onSurface: const Color(0xFF26332E),
    onSurfaceVariant: const Color(0xFF54655E),
    surfaceContainerLowest: const Color(0xFFF4FAF7),
    surfaceContainerLow: const Color(0xFFE3EFEA),
    surfaceContainer: const Color(0xFFDBE9E3),
    surfaceContainerHigh: const Color(0xFFD1E1DA),
    surfaceContainerHighest: const Color(0xFFC6D8D0),
    outline: const Color(0xFF7B8D86),
    outlineVariant: const Color(0xFFBFD3CB),
    primaryContainer: const Color(0xFFCDE8DE),
    onPrimaryContainer: const Color(0xFF0C3229),
    secondaryContainer: const Color(0xFFD7E7E0),
    onSecondaryContainer: const Color(0xFF23332D),
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

/// Dracula — the cult purple-slate dark with a soft violet accent.
final _draculaPalette = _Palette(
  brightness: Brightness.dark,
  seed: const Color(0xFFBD93F9),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFF282A36),
    onSurface: const Color(0xFFF8F8F2),
    onSurfaceVariant: const Color(0xFFB8BAC8),
    surfaceContainerLowest: const Color(0xFF21222C),
    surfaceContainerLow: const Color(0xFF2D2F3B),
    surfaceContainer: const Color(0xFF343746),
    surfaceContainerHigh: const Color(0xFF3C3F51),
    surfaceContainerHighest: const Color(0xFF44475A),
    outline: const Color(0xFF6272A4),
    outlineVariant: const Color(0xFF44475A),
    primary: const Color(0xFFBD93F9),
    onPrimary: const Color(0xFF241A38),
    primaryContainer: const Color(0xFF44415E),
    onPrimaryContainer: const Color(0xFFE9DDFF),
    secondaryContainer: const Color(0xFF3B3A52),
    onSecondaryContainer: const Color(0xFFE3E0F5),
  ),
);

/// Obsidian — near-black neutral glass with an electric cyan accent.
final _obsidianPalette = _Palette(
  brightness: Brightness.dark,
  seed: const Color(0xFF4CC9D6),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFF111315),
    onSurface: const Color(0xFFE4E6E8),
    onSurfaceVariant: const Color(0xFF9BA1A6),
    surfaceContainerLowest: const Color(0xFF0B0C0E),
    surfaceContainerLow: const Color(0xFF16181B),
    surfaceContainer: const Color(0xFF1B1E21),
    surfaceContainerHigh: const Color(0xFF23272B),
    surfaceContainerHighest: const Color(0xFF2D3237),
    outline: const Color(0xFF4A5157),
    outlineVariant: const Color(0xFF2A2F34),
    primary: const Color(0xFF57D6E0),
    onPrimary: const Color(0xFF05282E),
    primaryContainer: const Color(0xFF14424A),
    onPrimaryContainer: const Color(0xFFB4EEF4),
    secondaryContainer: const Color(0xFF25292D),
    onSecondaryContainer: const Color(0xFFD3D8DC),
  ),
);

/// Wine — deep burgundy cellar, warm rosé accent.
final _winePalette = _Palette(
  brightness: Brightness.dark,
  seed: const Color(0xFFE07491),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFF241016),
    onSurface: const Color(0xFFF3DDE3),
    onSurfaceVariant: const Color(0xFFC79AA4),
    surfaceContainerLowest: const Color(0xFF1C0B10),
    surfaceContainerLow: const Color(0xFF2B141B),
    surfaceContainer: const Color(0xFF321820),
    surfaceContainerHigh: const Color(0xFF3D1F28),
    surfaceContainerHighest: const Color(0xFF492833),
    outline: const Color(0xFF7C5560),
    outlineVariant: const Color(0xFF4A2C33),
    primary: const Color(0xFFEC9AAE),
    onPrimary: const Color(0xFF3E0E1D),
    primaryContainer: const Color(0xFF5C2434),
    onPrimaryContainer: const Color(0xFFFFD9E1),
    secondaryContainer: const Color(0xFF3A1F27),
    onSecondaryContainer: const Color(0xFFF4D3DB),
  ),
);

/// Solarized — Ethan Schoonover's teal-slate dark with an amber accent.
final _solarizedPalette = _Palette(
  brightness: Brightness.dark,
  seed: const Color(0xFFB58900),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFF002B36),
    onSurface: const Color(0xFF93A1A1),
    onSurfaceVariant: const Color(0xFF839496),
    surfaceContainerLowest: const Color(0xFF00232C),
    surfaceContainerLow: const Color(0xFF073642),
    surfaceContainer: const Color(0xFF0A3D4A),
    surfaceContainerHigh: const Color(0xFF0E4653),
    surfaceContainerHighest: const Color(0xFF14505E),
    outline: const Color(0xFF586E75),
    outlineVariant: const Color(0xFF0E4653),
    primary: const Color(0xFFC99A2E),
    onPrimary: const Color(0xFF2C2100),
    primaryContainer: const Color(0xFF554614),
    onPrimaryContainer: const Color(0xFFF5E4B0),
    secondaryContainer: const Color(0xFF0E4653),
    onSecondaryContainer: const Color(0xFFCFE0DF),
  ),
);

/// Plum — deep grape twilight, bright lilac accent.
final _plumPalette = _Palette(
  brightness: Brightness.dark,
  seed: const Color(0xFFB98CE0),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFF1E1526),
    onSurface: const Color(0xFFE9DFF3),
    onSurfaceVariant: const Color(0xFFB1A3C0),
    surfaceContainerLowest: const Color(0xFF17101E),
    surfaceContainerLow: const Color(0xFF251A2F),
    surfaceContainer: const Color(0xFF2B1F37),
    surfaceContainerHigh: const Color(0xFF342740),
    surfaceContainerHighest: const Color(0xFF3E2F4C),
    outline: const Color(0xFF6E5E7E),
    outlineVariant: const Color(0xFF362A43),
    primary: const Color(0xFFC9A2ED),
    onPrimary: const Color(0xFF33204A),
    primaryContainer: const Color(0xFF48335E),
    onPrimaryContainer: const Color(0xFFEBDCFB),
    secondaryContainer: const Color(0xFF33273F),
    onSecondaryContainer: const Color(0xFFE4DAF0),
  ),
);

/// Ocean — deep sea-trench teal, luminous aqua accent.
final _oceanPalette = _Palette(
  brightness: Brightness.dark,
  seed: const Color(0xFF3FB5C4),
  overrides: (base) => base.copyWith(
    surface: const Color(0xFF0C1E24),
    onSurface: const Color(0xFFDBEBEE),
    onSurfaceVariant: const Color(0xFF98B0B6),
    surfaceContainerLowest: const Color(0xFF07171C),
    surfaceContainerLow: const Color(0xFF11262D),
    surfaceContainer: const Color(0xFF152E36),
    surfaceContainerHigh: const Color(0xFF1D3A43),
    surfaceContainerHighest: const Color(0xFF264851),
    outline: const Color(0xFF456068),
    outlineVariant: const Color(0xFF23424B),
    primary: const Color(0xFF56C7D4),
    onPrimary: const Color(0xFF04272E),
    primaryContainer: const Color(0xFF1A4B54),
    onPrimaryContainer: const Color(0xFFB6ECF2),
    secondaryContainer: const Color(0xFF1B333B),
    onSecondaryContainer: const Color(0xFFCFE6EA),
  ),
);

_Palette _concretePalette(AppTheme theme) => switch (theme) {
      AppTheme.system || AppTheme.light => _lightPalette,
      AppTheme.coffee => _coffeePalette,
      AppTheme.matcha => _matchaPalette,
      AppTheme.rose => _rosePalette,
      AppTheme.sand => _sandPalette,
      AppTheme.sky => _skyPalette,
      AppTheme.lavender => _lavenderPalette,
      AppTheme.peach => _peachPalette,
      AppTheme.mint => _mintPalette,
      AppTheme.dark => _darkPalette,
      AppTheme.midnight => _midnightPalette,
      AppTheme.nord => _nordPalette,
      AppTheme.forest => _forestPalette,
      AppTheme.dracula => _draculaPalette,
      AppTheme.obsidian => _obsidianPalette,
      AppTheme.wine => _winePalette,
      AppTheme.solarized => _solarizedPalette,
      AppTheme.plum => _plumPalette,
      AppTheme.ocean => _oceanPalette,
    };

/// Whether a concrete theme is a dark palette (used for the status bar / logo
/// variant). [AppTheme.system] is resolved by the OS, not here.
bool appThemeIsDark(AppTheme theme) =>
    _concretePalette(theme).brightness == Brightness.dark;

/// Whether [theme] repaints the neutral surfaces (coffee, matcha, nord, …).
/// The plain System / Light / Dark defaults are NOT tinted — they keep the
/// original navy/white brand assets.
bool appThemeIsTinted(AppTheme theme) => _concretePalette(theme).isTinted;

/// Resolves the stored pref value ('ui_mode') back to an [AppTheme].
AppTheme appThemeFromName(String? raw) =>
    AppTheme.values.where((t) => t.name == (raw ?? '')).firstOrNull ??
    AppTheme.light;

/// The concrete [ColorScheme] a theme resolves to — [AppTheme.system] picks
/// the plain Light/Dark default by [platformBrightness]. Used by surfaces
/// that render BEFORE the MaterialApp exists (the launch splash).
ColorScheme appThemeColorScheme(AppTheme theme, Brightness platformBrightness) {
  final concrete = theme == AppTheme.system
      ? (platformBrightness == Brightness.dark ? AppTheme.dark : AppTheme.light)
      : theme;
  return _concretePalette(concrete).scheme();
}

/// Theme-carried brand tint — ALWAYS the theme's primary colour. There is a
/// single source mark (the original blue light asset) used everywhere; the
/// logo, the CM icon and the loading animation flatten to this colour (srcIn
/// keeps every detail of the mark + wordmark, just recoloured) so the brand
/// matches each theme's primary on every theme, including System/Light/Dark.
class BrandTint extends ThemeExtension<BrandTint> {
  const BrandTint({this.tint});

  final Color? tint;

  static Color? of(BuildContext context) =>
      Theme.of(context).extension<BrandTint>()?.tint;

  @override
  BrandTint copyWith({Color? tint}) => BrandTint(tint: tint ?? this.tint);

  @override
  BrandTint lerp(ThemeExtension<BrandTint>? other, double t) {
    if (other is! BrandTint) return this;
    return BrandTint(tint: Color.lerp(tint, other.tint, t));
  }
}

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
  // An active custom theme wins: build its palette straight from the seed +
  // brightness (no overrides) — the same pipeline as the plain Light/Dark
  // defaults, so it's a full cohesive Material 3 scheme from one colour.
  final custom = s.activeCustom;
  if (custom != null) {
    final p = _Palette(
      brightness: custom.dark ? Brightness.dark : Brightness.light,
      seed: custom.seedColor,
    );
    final td = _buildTheme(p, s);
    return (
      light: td,
      dark: td,
      mode: custom.dark ? ThemeMode.dark : ThemeMode.light,
    );
  }
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

/// Zero-motion route transitions for reduce-motion mode: the incoming page
/// just appears. (Swipe-back is unavailable in this mode — it is itself an
/// animation; the back button still works everywhere.)
class _InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const _InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      child;
}

ThemeData _buildTheme(_Palette p, ThemeState s) {
  final scheme = p.scheme();
  final brightness = p.brightness;

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    // App-wide UI typeface — the user's pick from Settings → App font
    // (Cabinet Grotesk by default). Arabic/Hebrew have no glyphs in any of
    // the bundled families and fall back to platform / CanvasKit Noto fonts.
    fontFamily: s.font.family,
    visualDensity: VisualDensity(horizontal: s.density, vertical: s.density),
    extensions: <ThemeExtension<dynamic>>[
      // One mark, recoloured to the theme's primary on EVERY theme — the
      // dark/white asset variants are gone; the single blue source is tinted.
      BrandTint(tint: scheme.primary),
    ],
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
    //
    // Reduce-motion (Settings → Appearance) swaps these for INSTANT
    // transitions — screens appear/disappear with no slide at all. This is
    // the single most feelable effect of the switch; before, it only set a
    // MediaQuery flag that almost nothing consumed.
    pageTransitionsTheme: s.reduceMotion
        ? const PageTransitionsTheme(
            builders: {
              TargetPlatform.iOS: _InstantPageTransitionsBuilder(),
              TargetPlatform.macOS: _InstantPageTransitionsBuilder(),
              TargetPlatform.android: _InstantPageTransitionsBuilder(),
            },
          )
        : const PageTransitionsTheme(
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
