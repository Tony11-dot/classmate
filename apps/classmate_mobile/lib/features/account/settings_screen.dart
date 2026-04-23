import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/theme/theme_controller.dart';
import '../../l10n/app_localizations.dart';
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
];

// ── Accent colour palette ────────────────────────────────────────────────────

typedef _Accent = ({Color color, String label});

const _kAccents = <_Accent>[
  (color: Color(0xFF4F46E5), label: 'Indigo'),
  (color: Color(0xFF7C3AED), label: 'Violet'),
  (color: Color(0xFF0EA5E9), label: 'Blue'),
  (color: Color(0xFF0D9488), label: 'Teal'),
  (color: Color(0xFF16A34A), label: 'Green'),
  (color: Color(0xFFEA580C), label: 'Orange'),
  (color: Color(0xFFE11D48), label: 'Rose'),
];

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

    final currentLang = locale == null
        ? null
        : _kLanguages.where((l) => l.code == locale.languageCode).firstOrNull;

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
              blurSigma: 18,
              gradient: LinearGradient(
                colors: [cs.tertiaryContainer, cs.surfaceContainerHigh],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: cs.tertiary.withValues(alpha: 0.18),
                    child: Center(
                      child: Icon(Icons.tune_rounded, color: cs.tertiary, size: 26),
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
                  LiquidGlassDropdown<ThemeMode>(
                    label: l.settingsTheme,
                    value: t.mode,
                    items: [
                      LiquidGlassDropdownItem(
                        value: ThemeMode.system,
                        label: l.settingsThemeSystem,
                        icon: Icons.settings_suggest_rounded,
                      ),
                      LiquidGlassDropdownItem(
                        value: ThemeMode.light,
                        label: l.settingsThemeLight,
                        icon: Icons.light_mode_rounded,
                      ),
                      LiquidGlassDropdownItem(
                        value: ThemeMode.dark,
                        label: l.settingsThemeDark,
                        icon: Icons.dark_mode_rounded,
                      ),
                    ],
                    onChanged: tc.setMode,
                    searchHint: '${l.settingsThemeSystem} / ${l.settingsThemeLight} / ${l.settingsThemeDark}',
                  ),
                  const SizedBox(height: 12),
                  LiquidGlassDropdown<String?>(
                    label: currentLang == null
                        ? '${l.settingsLanguage} — ${l.settingsLanguageSystem}'
                        : '${l.settingsLanguage} — ${currentLang.flag} ${currentLang.label}',
                    value: currentLang?.code,
                    items: [
                      LiquidGlassDropdownItem<String?>(
                        value: null,
                        label: l.settingsLanguageSystem,
                        icon: Icons.public_rounded,
                      ),
                      ..._kLanguages.map(
                        (l) => LiquidGlassDropdownItem<String?>(
                          value: l.code,
                          label: '${l.flag}  ${l.label}',
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
                                blurSigma: 8,
                                color: t.accent.withValues(alpha: 0.15),
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
                          children: _kAccents.map((a) {
                            final selected = _accentMatch(t.accent, a.color);
                            return GestureDetector(
                              onTap: () => tc.setAccent(a.color),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: selected ? 40 : 34,
                                height: selected ? 40 : 34,
                                decoration: BoxDecoration(
                                  color: a.color,
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
                                            color: a.color
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
                onTap: () => ref.read(authControllerProvider).logout(context),
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
      blurSigma: 14,
      color: cs.surfaceContainerLow.withValues(alpha: 0.78),
      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
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
                blurSigma: 8,
                color: (iconColor ?? cs.primary).withValues(alpha: 0.1),
                child: Center(
                  child: Icon(icon, size: 20, color: iconColor ?? cs.primary),
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
