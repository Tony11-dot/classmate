import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ThemePreset {
  clean, // Apple-clean, calm
  iosCards, // iOS cards, softer radius, subtle shadows
  sharpContrast, // high contrast, thicker borders, strong separation
  neoBrutal, // bold borders, flatter surfaces, punchy look
  monoMinimal, // very minimal, low elevation, strict monochrome feel
  cozy, // warmer, rounder, comfy spacing/typography
}

class ThemeState {
  const ThemeState({
    this.mode = ThemeMode.system,
    this.preset = ThemePreset.clean,
    this.accent = const Color(0xFF3B82F6),
    this.radius = 16,
    this.density = 10,
    this.textScale = 1.0,
    this.motion = 1.0,
  });

  final ThemeMode mode;
  final ThemePreset preset;
  final Color accent;
  final double radius;
  final double density;
  final double textScale; // 0.9..1.2
  final double motion; // 0.7..1.4

  ThemeState copyWith({
    ThemeMode? mode,
    ThemePreset? preset,
    Color? accent,
    double? radius,
    double? density,
    double? textScale,
    double? motion,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      preset: preset ?? this.preset,
      accent: accent ?? this.accent,
      radius: radius ?? this.radius,
      density: density ?? this.density,
      textScale: textScale ?? this.textScale,
      motion: motion ?? this.motion,
    );
  }
}

final themeControllerProvider = NotifierProvider<ThemeController, ThemeState>(
  () => ThemeController(),
);

class ThemeController extends Notifier<ThemeState> {
  @override
  ThemeState build() => const ThemeState();

  void setMode(ThemeMode m) => state = state.copyWith(mode: m);
  void setPreset(ThemePreset p) => state = state.copyWith(preset: p);
  void setAccent(Color c) => state = state.copyWith(accent: c);
  void setRadius(double r) => state = state.copyWith(radius: r);
  void setDensity(double d) => state = state.copyWith(density: d);
  void setTextScale(double s) => state = state.copyWith(textScale: s);
  void setMotion(double m) => state = state.copyWith(motion: m);

  ThemeData theme(Brightness b) {
    final bool dark = b == Brightness.dark;

    final cs = ColorScheme.fromSeed(seedColor: state.accent, brightness: b);

    final base = ThemeData(useMaterial3: true, brightness: b, colorScheme: cs);

    // Ensure DARK MODE TEXT IS WHITE (fix #1)
    final whiteText = base.textTheme.apply(
      bodyColor: dark ? Colors.white : null,
      displayColor: dark ? Colors.white : null,
    );

    // Base knobs
    final r = BorderRadius.circular(state.radius);
    final pad = state.density.clamp(6.0, 18.0);

    // Preset differences (make them REALLY different)
    double elevationBase = 1;
    double borderW = 1;
    double cardOpacity = dark ? 0.22 : 0.60;
    FontWeight titleWeight = FontWeight.w700;
    double titleSize = 18;

    switch (state.preset) {
      case ThemePreset.clean:
        elevationBase = 1;
        borderW = 1;
        cardOpacity = dark ? 0.20 : 0.58;
        titleWeight = FontWeight.w700;
        titleSize = 18;
        break;
      case ThemePreset.iosCards:
        elevationBase = 2.2;
        borderW = 0.6;
        cardOpacity = dark ? 0.26 : 0.66;
        titleWeight = FontWeight.w700;
        titleSize = 18;
        break;
      case ThemePreset.sharpContrast:
        elevationBase = 1.2;
        borderW = 1.8;
        cardOpacity = dark ? 0.18 : 0.52;
        titleWeight = FontWeight.w800;
        titleSize = 19;
        break;
      case ThemePreset.neoBrutal:
        elevationBase = 0.0; // flatter
        borderW = 2.4; // bold borders
        cardOpacity = dark ? 0.14 : 0.42;
        titleWeight = FontWeight.w900;
        titleSize = 20;
        break;
      case ThemePreset.monoMinimal:
        elevationBase = 0.2;
        borderW = 0.8;
        cardOpacity = dark ? 0.12 : 0.36;
        titleWeight = FontWeight.w700;
        titleSize = 18;
        break;
      case ThemePreset.cozy:
        elevationBase = 1.4;
        borderW = 0.9;
        cardOpacity = dark ? 0.24 : 0.64;
        titleWeight = FontWeight.w800;
        titleSize = 19;
        break;
    }

    // Typography scaling
    final scaledText = whiteText.copyWith(
      titleLarge: whiteText.titleLarge?.copyWith(
        fontSize: (whiteText.titleLarge?.fontSize ?? 22) * state.textScale,
        fontWeight: titleWeight,
      ),
      titleMedium: whiteText.titleMedium?.copyWith(
        fontSize: (whiteText.titleMedium?.fontSize ?? 18) * state.textScale,
        fontWeight: titleWeight,
      ),
      bodyMedium: whiteText.bodyMedium?.copyWith(
        fontSize: (whiteText.bodyMedium?.fontSize ?? 14) * state.textScale,
      ),
      bodySmall: whiteText.bodySmall?.copyWith(
        fontSize: (whiteText.bodySmall?.fontSize ?? 12) * state.textScale,
      ),
    );

    final outline = cs.outline.withValues(
      alpha:
          state.preset == ThemePreset.sharpContrast ||
              state.preset == ThemePreset.neoBrutal
          ? 0.55
          : 0.18,
    );

    return base.copyWith(
      textTheme: scaledText,
      visualDensity: VisualDensity.compact,
      scaffoldBackgroundColor: cs.surface,
      dividerColor: outline,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: scaledText.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: titleSize.toDouble(),
          color: dark ? Colors.white : cs.onSurface,
        ),
        iconTheme: IconThemeData(color: dark ? Colors.white : cs.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: elevationBase,
        color: cs.surface.withValues(alpha: cardOpacity),
        shape: RoundedRectangleBorder(
          borderRadius: r,
          side: BorderSide(color: outline, width: borderW),
        ),
        margin: EdgeInsets.zero,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(state.radius * 0.9),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: pad,
          vertical: pad * 0.2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(state.radius * 0.9),
        ),
        filled: true,
        fillColor: cs.surface.withValues(alpha: dark ? 0.18 : 0.45),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: r),
        backgroundColor: cs.surface.withValues(alpha: dark ? 0.80 : 0.92),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final p in TargetPlatform.values)
            p: _ScaledCupertinoTransitionsBuilder(scale: state.motion),
        },
      ),
    );
  }
}

class _ScaledCupertinoTransitionsBuilder extends PageTransitionsBuilder {
  const _ScaledCupertinoTransitionsBuilder({required this.scale});
  final double scale;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    // NOTE: We don't change route.duration here (Flutter controls it),
    // but we can adjust the *feel* via curve/opacity/slide.
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.03, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
        child: child,
      ),
    );
  }
}
