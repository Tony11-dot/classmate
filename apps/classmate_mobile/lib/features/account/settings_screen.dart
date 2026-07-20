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
                  LiquidGlassDropdown<AppTheme>(
                    label: l.settingsTheme,
                    value: t.theme,
                    items: [
                      for (final choice in _kThemes)
                        LiquidGlassDropdownItem(
                          value: choice.value,
                          label: _themeLabel(choice.value, l),
                          icon: choice.icon,
                        ),
                    ],
                    onChanged: tc.setTheme,
                    searchHint: _kThemes
                        .map((c) => _themeLabel(c.value, l))
                        .join(' / '),
                  ),
                  const SizedBox(height: 12),
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
