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

// ── Accent colour palette ────────────────────────────────────────────────────

const _kAccents = <Color>[
  Color(0xFF0EA5E9), // Blue
  Color(0xFF4F46E5), // Indigo
  Color(0xFF7C3AED), // Violet
  Color(0xFF0D9488), // Teal
  Color(0xFF16A34A), // Green
  Color(0xFFEA580C), // Orange
  Color(0xFFE11D48), // Rose
];

String _accentLabel(Color color, AppLocalizations l) {
  return switch (color.toARGB32()) {
    0xFF0EA5E9 => l.colorBlue,
    0xFF4F46E5 => l.colorIndigo,
    0xFF7C3AED => l.colorViolet,
    0xFF0D9488 => l.colorTeal,
    0xFF16A34A => l.colorGreen,
    0xFFEA580C => l.colorOrange,
    _ => l.colorRose,
  };
}

bool _accentMatch(Color a, Color b) => a.toARGB32() == b.toARGB32();

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
                  LiquidGlassDropdown<AppThemeMode>(
                    label: l.settingsTheme,
                    value: t.mode,
                    items: [
                      LiquidGlassDropdownItem(
                        value: AppThemeMode.system,
                        label: l.settingsThemeSystem,
                        icon: Icons.settings_suggest_rounded,
                      ),
                      LiquidGlassDropdownItem(
                        value: AppThemeMode.light,
                        label: l.settingsThemeLight,
                        icon: Icons.light_mode_rounded,
                      ),
                      LiquidGlassDropdownItem(
                        value: AppThemeMode.dark,
                        label: l.settingsThemeDark,
                        icon: Icons.dark_mode_rounded,
                      ),
                      LiquidGlassDropdownItem(
                        value: AppThemeMode.coffee,
                        label: l.settingsThemeCoffee,
                        icon: Icons.coffee_rounded,
                      ),
                    ],
                    onChanged: tc.setMode,
                    searchHint: '${l.settingsThemeSystem} / ${l.settingsThemeLight} / ${l.settingsThemeDark} / ${l.settingsThemeCoffee}',
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
                  // ── Accent colour ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 38,
                              height: 38,
                              child: LiquidGlassCard(
                                padding: EdgeInsets.zero,
                                borderRadius: BorderRadius.circular(11),
                                color: t.accent,
                                child: Center(
                                  child: Icon(
                                    Icons.color_lens_outlined,
                                    size: 20,
                                    color: t.accent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.settingsAccentColour,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  l.settingsAccentSubtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: _kAccents.map((accent) {
                            final selected = _accentMatch(t.accent, accent);
                            return Tooltip(
                              message: _accentLabel(accent, l),
                              child: GestureDetector(
                                onTap: () => tc.setAccent(accent),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: selected ? 40 : 34,
                                  height: selected ? 40 : 34,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                    border: selected
                                        ? Border.all(
                                            color: cs.onSurface,
                                            width: 2.5,
                                          )
                                        : null,
                                    boxShadow: selected
                                        ? [
                                            BoxShadow(
                                              color: accent
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: selected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
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
