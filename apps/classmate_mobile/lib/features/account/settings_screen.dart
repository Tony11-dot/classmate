import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/theme/theme_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/dialogs/confirm_logout.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';

// ── Language catalogue ──────────────────────────────────────────────────────

class _Lang {
  const _Lang(this.code, this.label, this.flag);
  final String code;
  final String label;
  final String flag;
}

const _kLanguages = [
  _Lang('en', 'English', '🇬🇧'),
  _Lang('ar', 'العربية', '🇸🇦'),
  _Lang('he', 'עברית', '🇮🇱'),
  _Lang('fr', 'Français', '🇫🇷'),
  _Lang('ru', 'Русский', '🇷🇺'),
  // Pseudo-locale for translation-leak QA. Every translated string renders
  // wrapped in ‹‹ ... ›› — anything still in English is a hardcoded leak.
  // Gated to debug builds via kDebugMode in the picker below.
  _Lang('ps', '‹‹ Pseudo ››', '🧪'),
];

// ── Theme catalogue ──────────────────────────────────────────────────────────

class _ThemeChoice {
  const _ThemeChoice(this.value, this.icon);
  final AppTheme value;
  final IconData icon;
}

// One cohesive, hand-tuned palette each — no free accent picker. Order groups
// the light family, then the dark family, after System.
const _kThemes = <_ThemeChoice>[
  _ThemeChoice(AppTheme.system, Icons.settings_suggest_rounded),
  // Light family
  _ThemeChoice(AppTheme.light, Icons.light_mode_rounded),
  _ThemeChoice(AppTheme.coffee, Icons.coffee_rounded),
  _ThemeChoice(AppTheme.matcha, Icons.spa_rounded),
  _ThemeChoice(AppTheme.rose, Icons.local_florist_rounded),
  _ThemeChoice(AppTheme.sand, Icons.beach_access_rounded),
  _ThemeChoice(AppTheme.sky, Icons.cloud_rounded),
  _ThemeChoice(AppTheme.lavender, Icons.filter_vintage_rounded),
  _ThemeChoice(AppTheme.peach, Icons.wb_twilight_rounded),
  _ThemeChoice(AppTheme.mint, Icons.eco_rounded),
  // Dark family
  _ThemeChoice(AppTheme.dark, Icons.dark_mode_rounded),
  _ThemeChoice(AppTheme.midnight, Icons.bedtime_rounded),
  _ThemeChoice(AppTheme.nord, Icons.ac_unit_rounded),
  _ThemeChoice(AppTheme.forest, Icons.forest_rounded),
  _ThemeChoice(AppTheme.dracula, Icons.nights_stay_rounded),
  _ThemeChoice(AppTheme.obsidian, Icons.diamond_rounded),
  _ThemeChoice(AppTheme.wine, Icons.wine_bar_rounded),
  _ThemeChoice(AppTheme.solarized, Icons.brightness_5_rounded),
  _ThemeChoice(AppTheme.plum, Icons.nightlight_rounded),
  _ThemeChoice(AppTheme.ocean, Icons.waves_rounded),
];

String _themeLabel(AppTheme t, AppLocalizations l) => switch (t) {
      AppTheme.system => l.settingsThemeSystem,
      AppTheme.light => l.settingsThemeLight,
      AppTheme.coffee => l.settingsThemeCoffee,
      AppTheme.matcha => l.settingsThemeMatcha,
      AppTheme.rose => l.settingsThemeRose,
      AppTheme.sand => l.settingsThemeSand,
      AppTheme.sky => l.settingsThemeSky,
      AppTheme.lavender => l.settingsThemeLavender,
      AppTheme.peach => l.settingsThemePeach,
      AppTheme.mint => l.settingsThemeMint,
      AppTheme.dark => l.settingsThemeDark,
      AppTheme.midnight => l.settingsThemeMidnight,
      AppTheme.nord => l.settingsThemeNord,
      AppTheme.forest => l.settingsThemeForest,
      AppTheme.dracula => l.settingsThemeDracula,
      AppTheme.obsidian => l.settingsThemeObsidian,
      AppTheme.wine => l.settingsThemeWine,
      AppTheme.solarized => l.settingsThemeSolarized,
      AppTheme.plum => l.settingsThemePlum,
      AppTheme.ocean => l.settingsThemeOcean,
    };

// ── Screen ──────────────────────────────────────────────────────────────────

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(themeControllerProvider);
    final tc = ref.read(themeControllerProvider.notifier);
    final locale = ref.watch(localeControllerProvider);
    final lc = ref.read(localeControllerProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    // Always resolve to the language the app is ACTUALLY showing — the user's
    // explicit choice if set, otherwise the active (system-resolved) locale.
    // Never leave this null, or the selector would render "null" instead of the
    // current language.
    final activeCode = locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final currentLang = _kLanguages.firstWhere(
      (l) => l.code == activeCode,
      orElse: () => _kLanguages.first, // English
    );

    final l = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        // ── Header ────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: LiquidGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              borderRadius: BorderRadius.circular(24),
              color: cs.surfaceContainerLow,
              border: Border.all(color: cs.outlineVariant),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: cs.primaryContainer,
                    child: Center(
                      child: Icon(Icons.tune_rounded, color: cs.onPrimaryContainer, size: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.settingsTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        l.settingsSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Appearance ────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _Section(
              title: l.settingsAppearance,
              icon: Icons.palette_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Theme is now a gallery, ClassNotes-style: a single entry row
                  // that opens a screen of live theme swatches + "Add theme".
                  _SettingRow(
                    icon: Icons.palette_rounded,
                    title: l.settingsTheme,
                    subtitle: t.activeCustom?.name ?? _themeLabel(t.theme, l),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ThemeGalleryScreen(),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _ThemeDot(),
                        const SizedBox(width: 8),
                        Icon(Icons.chevron_right_rounded,
                            color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                  const _Divider(),
                  LiquidGlassDropdown<String?>(
                    label: '${l.settingsLanguage} — ${currentLang.flag} ${currentLang.label}',
                    value: currentLang.code,
                    items: [
                      // Pseudo-locale (code 'ps') is dev-only — strip it in
                      // release builds so end users never see it as a real
                      // language option. The "System default" option was
                      // intentionally removed: every user picks a real
                      // language so we never have to debug "why is my UI
                      // English when my OS is Arabic".
                      ..._kLanguages
                          .where((lang) => kDebugMode || lang.code != 'ps')
                          .map(
                            (lang) => LiquidGlassDropdownItem<String?>(
                              value: lang.code,
                              label: '${lang.flag}  ${lang.label}',
                              icon: Icons.translate_rounded,
                            ),
                          ),
                    ],
                    onChanged: lc.setLocale,
                    searchHint: l.settingsLanguageSearchHint,
                  ),
                  const _Divider(),
                  _SettingRow(
                    icon: Icons.text_fields_rounded,
                    title: l.settingsAppFont,
                    subtitle: t.font.label,
                    onTap: () => _showFontPicker(context, t.font, tc.setFont),
                    trailing: Icon(Icons.chevron_right_rounded,
                        color: cs.onSurfaceVariant),
                  ),
                  const _Divider(),
                  _SettingRow(
                    icon: Icons.animation_rounded,
                    title: l.settingsReduceMotion,
                    subtitle: l.settingsReduceMotionSubtitle,
                    trailing: Switch(
                      value: t.reduceMotion,
                      onChanged: tc.setReduceMotion,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Menu ──────────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: _Section(
              title: l.reorderToolsSettingsSection,
              icon: Icons.menu_rounded,
              child: _SettingRow(
                icon: Icons.reorder_rounded,
                title: l.reorderToolsTitle,
                subtitle: l.reorderToolsSettingsSubtitle,
                onTap: () => context.push('/settings/reorder-tools'),
                trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ),

        // ── Account ───────────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
            child: _Section(
              title: l.settingsAccount,
              icon: Icons.manage_accounts_outlined,
              child: _SettingRow(
                icon: Icons.logout_rounded,
                title: l.settingsLogout,
                subtitle: l.settingsLogoutSubtitle,
                iconColor: cs.error,
                titleColor: cs.error,
                onTap: () async {
                  if (!await confirmLogout(context)) return;
                  if (!context.mounted) return;
                  ref.read(authControllerProvider).logout();
                },
                trailing: Icon(Icons.chevron_right_rounded, color: cs.error),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Font picker ─────────────────────────────────────────────────────────────

/// Bottom sheet listing every bundled typeface — each name rendered IN that
/// font, so choosing is seeing. Selection applies live and persists.
Future<void> _showFontPicker(
  BuildContext context,
  AppFont current,
  ValueChanged<AppFont> onSelect,
) async {
  final l = AppLocalizations.of(context)!;
  final cs = Theme.of(context).colorScheme;
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: cs.surfaceContainerLow,
    builder: (sheetCtx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.62,
      maxChildSize: 0.92,
      builder: (ctx, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 4),
            child: Row(
              children: [
                Icon(Icons.text_fields_rounded, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  l.settingsAppFont,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              l.settingsAppFontSubtitle,
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              itemCount: AppFont.values.length,
              itemBuilder: (ctx, i) {
                final font = AppFont.values[i];
                final selected = font == current;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      onSelect(font);
                      Navigator.of(sheetCtx).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? cs.primaryContainer.withValues(alpha: 0.55)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? cs.primary.withValues(alpha: 0.55)
                              : cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // The name IS the specimen — rendered in the
                                // family it names.
                                Text(
                                  font.label,
                                  style: TextStyle(
                                    fontFamily: font.family,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l.settingsAppFontSpecimen,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: font.family,
                                    fontSize: 12.5,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (font == AppFont.cabinet) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: cs.secondaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                l.settingsAppFontDefault,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSecondaryContainer,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (selected)
                            Icon(Icons.check_circle_rounded,
                                size: 20, color: cs.primary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      glass: true,
      borderRadius: BorderRadius.circular(20),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Divider(
          height: 1,
          color: Theme.of(context)
              .colorScheme
              .outlineVariant
              .withValues(alpha: 0.4),
        ),
      );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              height: 38,
              child: LiquidGlassCard(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(11),
                color: iconColor != null ? cs.errorContainer : cs.primaryContainer,
                child: Center(
                  child: Icon(icon, size: 20, color: iconColor ?? cs.onPrimaryContainer),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  Theme gallery — ClassNotes-style: live swatches + "Add theme"
// ══════════════════════════════════════════════════════════════════════════

/// A small accent dot for the theme row trailing — the current theme's accent.
class _ThemeDot extends StatelessWidget {
  const _ThemeDot();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: cs.primary,
        shape: BoxShape.circle,
        border: Border.all(color: cs.outlineVariant, width: 0.5),
      ),
    );
  }
}

/// The full-screen theme gallery. Live preview swatches for every preset
/// grouped Light / Dark, a Custom section, and an "Add theme" action that
/// creates a seed-based custom theme — mirroring the native ClassNotes flow.
class ThemeGalleryScreen extends ConsumerWidget {
  const ThemeGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final t = ref.watch(themeControllerProvider);
    final tc = ref.read(themeControllerProvider.notifier);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    final light = _kThemes.where((c) => !appThemeIsDark(c.value)).toList();
    final dark = _kThemes.where((c) => appThemeIsDark(c.value)).toList();

    Widget presetTile(_ThemeChoice choice) {
      final scheme = appThemeColorScheme(choice.value, platformBrightness);
      final selected = t.customId == null && t.theme == choice.value;
      return _ThemeTile(
        scheme: scheme,
        label: _themeLabel(choice.value, l),
        selected: selected,
        onTap: () => tc.setTheme(choice.value),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l.settingsTheme),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          FilledButton.icon(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: cs.surface,
              showDragHandle: true,
              builder: (_) => const _AddThemeSheet(),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add theme'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          if (t.customThemes.isNotEmpty) ...[
            const _GalleryHeader('Custom'),
            Wrap(
              spacing: 14,
              runSpacing: 16,
              children: [
                for (final ct in t.customThemes)
                  _ThemeTile(
                    scheme: ColorScheme.fromSeed(
                      seedColor: ct.seedColor,
                      brightness:
                          ct.dark ? Brightness.dark : Brightness.light,
                    ),
                    label: ct.name,
                    selected: t.customId == ct.id,
                    onTap: () => tc.selectCustom(ct.id),
                    onDelete: () => tc.deleteCustom(ct.id),
                  ),
              ],
            ),
          ],
          const _GalleryHeader('Light'),
          Wrap(
            spacing: 14,
            runSpacing: 16,
            children: [for (final c in light) presetTile(c)],
          ),
          const _GalleryHeader('Dark'),
          Wrap(
            spacing: 14,
            runSpacing: 16,
            children: [for (final c in dark) presetTile(c)],
          ),
        ],
      ),
    );
  }
}

class _GalleryHeader extends StatelessWidget {
  const _GalleryHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 22, 0, 12),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}

/// A tappable theme tile — the live swatch preview + label, with a selected
/// ring/check and an optional long-press delete (custom themes).
class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.scheme,
    required this.label,
    required this.selected,
    required this.onTap,
    this.onDelete,
  });

  final ColorScheme scheme;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            onLongPress: onDelete,
            child: Stack(
              children: [
                _ThemeSwatch(scheme: scheme, ringColor: selected ? cs.primary : null),
                if (selected)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(1),
                      child: Icon(Icons.check_rounded,
                          size: 13, color: cs.onPrimary),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? cs.primary : cs.onSurface,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The miniature "what this theme looks like" tile: surface card, accent dot,
/// two ink text-bars, and a little paper page. Mirrors ClassNotes'
/// `ThemeSwatchView`.
class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.scheme, this.ringColor});

  final ColorScheme scheme;
  final Color? ringColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 108,
      height: 44,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ringColor ?? scheme.outlineVariant,
          width: ringColor != null ? 2 : 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bar(34, scheme.onSurface),
              const SizedBox(height: 4),
              _bar(24, scheme.onSurfaceVariant),
            ],
          ),
          const Spacer(),
          Container(
            width: 18,
            height: 24,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: scheme.outlineVariant, width: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(double w, Color c) => Container(
        width: w,
        height: 3,
        decoration:
            BoxDecoration(color: c, borderRadius: BorderRadius.circular(1.5)),
      );
}

/// "Add theme" — pick a seed colour + name + light/dark; a full Material 3
/// palette is generated from the seed (like the native ClassNotes editor,
/// simplified to a one-tap seed).
class _AddThemeSheet extends ConsumerStatefulWidget {
  const _AddThemeSheet();

  @override
  ConsumerState<_AddThemeSheet> createState() => _AddThemeSheetState();
}

class _AddThemeSheetState extends ConsumerState<_AddThemeSheet> {
  static const _seeds = <Color>[
    Color(0xFF256489), Color(0xFF0EA5E9), Color(0xFF6366F1), Color(0xFF8B5CF6),
    Color(0xFFB4637A), Color(0xFFEC4899), Color(0xFFEF4444), Color(0xFFF97316),
    Color(0xFF9B6B43), Color(0xFFCA8A04), Color(0xFF4F7942), Color(0xFF16A34A),
    Color(0xFF0D9488), Color(0xFF06B6D4), Color(0xFF334155), Color(0xFF7C3AED),
    Color(0xFFBD93F9), Color(0xFFA7C080),
  ];

  final _name = TextEditingController();
  Color _seed = _seeds.first;
  bool _dark = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final preview = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: _dark ? Brightness.dark : Brightness.light,
    );
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New theme',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          Row(
            children: [
              _ThemeSwatch(scheme: preview),
              const SizedBox(width: 14),
              Expanded(
                child: TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'My theme',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Accent',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in _seeds)
                GestureDetector(
                  onTap: () => setState(() => _seed = c),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _seed == c ? cs.onSurface : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: _seed == c
                        ? Icon(Icons.check_rounded,
                            size: 18, color: cnPickInk(c))
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Light'), icon: Icon(Icons.light_mode_rounded)),
              ButtonSegment(value: true, label: Text('Dark'), icon: Icon(Icons.dark_mode_rounded)),
            ],
            selected: {_dark},
            onSelectionChanged: (s) => setState(() => _dark = s.first),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () async {
              await ref.read(themeControllerProvider.notifier).addCustomTheme(
                    name: _name.text,
                    seed: _seed,
                    dark: _dark,
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Create theme'),
          ),
        ],
      ),
    );
  }
}

/// White vs near-black ink for a checkmark on a coloured swatch.
Color cnPickInk(Color bg) {
  final l = 0.2126 * bg.r + 0.7152 * bg.g + 0.0722 * bg.b;
  return l > 0.55 ? const Color(0xFF14171A) : Colors.white;
}
