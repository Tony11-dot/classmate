// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/auth/auth_controller.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final session = ref.watch(authSessionProvider);
    final isAdmin = session.primaryRole == 'ADMIN';

    return Scaffold(
      backgroundColor: cs.surface,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // ── School ────────────────────────────────────────────────────────
          _SectionHeader(label: l.navSchool),
          const SizedBox(height: 10),
          _SettingsNavTile(
            icon: Icons.school_rounded,
            label: l.adminSchoolSettingsTitle,
            subtitle: session.schoolName.isNotEmpty ? session.schoolName : '—',
            onTap: () => context.push('/admin/school'),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 6),
            _SettingsNavTile(
              icon: Icons.manage_history_rounded,
              label: l.adminScheduleTitle,
              subtitle: l.adminScheduleNoSlotsHint,
              onTap: () => context.push('/admin/schedule'),
            ),
          ],
          const SizedBox(height: 6),
          _SettingsNavTile(
            icon: Icons.manage_history_rounded,
            label: l.adminSettingsPeriodDefaults,
            subtitle: l.adminSettingsScheduleSubtitle,
            onTap: () => context.push('/admin/periods'),
          ),
          const SizedBox(height: 24),

          // ── Account ────────────────────────────────────────────────────────
          _SectionHeader(label: l.sectionAccount),
          const SizedBox(height: 10),
          _SettingsNavTile(
            icon: Icons.person_rounded,
            label: l.navProfile,
            subtitle: session.displayName.isNotEmpty ? session.displayName : session.email,
            onTap: () => context.push('/profile'),
          ),
          const SizedBox(height: 6),
          _SettingsNavTile(
            icon: Icons.palette_rounded,
            label: l.navSettings,
            subtitle: 'Theme, colors, language',
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingsNavTile extends StatelessWidget {
  const _SettingsNavTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}
