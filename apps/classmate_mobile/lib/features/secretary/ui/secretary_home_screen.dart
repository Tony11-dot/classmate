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
        padding: EdgeInsets.fromLTRB(
            16, 12 + MediaQuery.paddingOf(context).top, 16, 24),
        children: [
          const SizedBox(height: 4),
          Text(
            l.secretaryWelcomeGreeting(greetingName),
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            session.schoolName.isNotEmpty
                ? '${l.roleSecretary} · ${session.schoolName}'
                : l.roleSecretary,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 22),
          Text(
            l.secretaryYourTools,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
            ),
            itemCount: tiles.length,
            itemBuilder: (ctx, i) {
              final t = tiles[i];
              return _ToolTile(
                icon: t.icon,
                label: t.label,
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
  const _ToolTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 26, color: cs.onPrimaryContainer),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: cs.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
