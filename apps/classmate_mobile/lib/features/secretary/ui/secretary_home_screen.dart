import 'package:classmate_mobile/core/theme/cm_tokens.dart';
import 'package:classmate_mobile/ui/widgets/cm_press.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session.dart';
import '../../../l10n/app_localizations.dart';

/// Secretary's main landing — a 2-column grid of the seven tools the
/// secretary can reach. Modeled on the parent home screen but without
/// the child picker (secretary's work is school-wide, not per-student).
class SecretaryHomeScreen extends ConsumerWidget {
  const SecretaryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(authSessionProvider);

    final tiles = <_ToolDef>[
      _ToolDef(
        icon: Icons.manage_history_rounded,
        label: l.adminScheduleTitle,
        route: '/secretary/schedule',
      ),
      _ToolDef(
        icon: Icons.people_rounded,
        label: l.navPeople,
        route: '/secretary/people',
      ),
      _ToolDef(
        icon: Icons.groups_rounded,
        label: l.navCohorts,
        route: '/secretary/cohorts',
      ),
      _ToolDef(
        icon: Icons.campaign_rounded,
        label: l.navAnnouncements,
        route: '/announcements',
      ),
      _ToolDef(
        icon: Icons.chat_bubble_rounded,
        label: l.navMessages,
        route: '/messages',
      ),
      _ToolDef(
        icon: Icons.flag_outlined,
        label: l.secretaryReports,
        route: '/secretary/reports',
      ),
      _ToolDef(
        icon: Icons.download_rounded,
        label: l.secretaryExportData,
        route: '/secretary/export',
      ),
    ];

    final greetingName = session.displayName.isNotEmpty ? session.displayName : 'there';

    return Scaffold(
      backgroundColor: cs.surface,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // Greeting hero.
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primaryContainer,
                  Color.alphaBlend(cs.primary.withValues(alpha: 0.14), cs.primaryContainer),
                ],
              ),
              borderRadius: BorderRadius.circular(CmTokens.radiusXl),
              boxShadow: CmTokens.of(context).shadowMd,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: cs.surface,
                  child: Text(
                    greetingName.trim().isEmpty ? '?' : greetingName.trim().characters.first.toUpperCase(),
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: cs.primary),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.secretaryWelcomeGreeting(greetingName),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        session.schoolName.isNotEmpty
                            ? '${l.roleSecretary} · ${session.schoolName}'
                            : l.roleSecretary,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l.secretaryYourTools,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemCount: tiles.length,
            itemBuilder: (ctx, i) {
              final t = tiles[i];
              return _ToolTile(
                icon: t.icon,
                label: t.label,
                tone: i % 3,
                onTap: () => context.push(t.route),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ToolDef {
  const _ToolDef({required this.icon, required this.label, required this.route});
  final IconData icon;
  final String label;
  final String route;
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tone = 0,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Rotate through the scheme's three container hues so the grid isn't a
    // wall of one colour.
    final bg = [cs.primaryContainer, cs.secondaryContainer, cs.tertiaryContainer][tone];
    final fg = [cs.onPrimaryContainer, cs.onSecondaryContainer, cs.onTertiaryContainer][tone];
    return CmPress(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(CmTokens.radiusLg),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3), width: 0.8),
          boxShadow: CmTokens.of(context).shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 23, color: fg),
            ),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
