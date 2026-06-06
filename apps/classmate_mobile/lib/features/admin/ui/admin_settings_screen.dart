// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/auth/auth_controller.dart';
import '../data/admin_repository.dart';

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

          if (isAdmin) ...[
            const SizedBox(height: 24),
            // ── Bulk tools ────────────────────────────────────────────────
            _SectionHeader(label: 'Bulk tools'),
            const SizedBox(height: 10),
            _SettingsNavTile(
              icon: Icons.upload_file_rounded,
              label: 'Import users',
              subtitle: 'Add many at once — grid or CSV',
              onTap: () => context.push('/admin/import-users'),
            ),
            const SizedBox(height: 6),
            _SettingsNavTile(
              icon: Icons.upgrade_rounded,
              label: 'Upgrade grades',
              subtitle: 'Promote every student one grade',
              onTap: () => _confirmAndRun(
                context, ref,
                title: 'Upgrade all grades?',
                body: 'Every student moves up one grade. Students already at the top '
                    'grade are kept as graduating (never deleted) for you to handle. '
                    'This is safe to run once at the start of the school year.',
                confirmLabel: 'Upgrade',
                destructive: false,
                action: (repo) => repo.promoteAllGrades(),
                success: (r) => 'Promoted ${r['promoted'] ?? 0} students · ${r['graduating'] ?? 0} graduating',
              ),
            ),

            const SizedBox(height: 24),
            // ── Danger zone ───────────────────────────────────────────────
            _SectionHeader(label: 'Danger zone'),
            const SizedBox(height: 10),
            _SettingsNavTile(
              icon: Icons.event_busy_rounded,
              danger: true,
              label: 'Reset schedule',
              subtitle: 'Delete all periods & overrides',
              onTap: () => _confirmAndRun(
                context, ref,
                title: 'Reset the whole schedule?',
                body: 'This permanently deletes every period and one-off override for '
                    'your school. Bell-schedule times are kept. This cannot be undone.',
                confirmLabel: 'Reset schedule',
                destructive: true,
                action: (repo) => repo.resetSchedule(),
                success: (r) => 'Schedule cleared — ${r['slots'] ?? 0} periods removed',
              ),
            ),
            const SizedBox(height: 6),
            _SettingsNavTile(
              icon: Icons.groups_rounded,
              danger: true,
              label: 'Reset cohorts',
              subtitle: 'Delete all of your cohorts',
              onTap: () => _confirmAndRun(
                context, ref,
                title: 'Delete all cohorts?',
                body: 'This permanently deletes every cohort in your school and removes '
                    'students from them. Student accounts are NOT deleted. This cannot be undone.',
                confirmLabel: 'Delete cohorts',
                destructive: true,
                action: (repo) => repo.resetCohorts(),
                success: (r) => 'Deleted ${r['deleted'] ?? 0} cohorts',
              ),
            ),
          ],
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

/// Shared confirm → run → toast flow for the bulk/danger actions.
Future<void> _confirmAndRun(
  BuildContext context,
  WidgetRef ref, {
  required String title,
  required String body,
  required String confirmLabel,
  required bool destructive,
  required Future<Map<String, dynamic>> Function(AdminRepository repo) action,
  required String Function(Map<String, dynamic> r) success,
}) async {
  final cs = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Cancel')),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: cs.error) : null,
          onPressed: () => Navigator.pop(d, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  if (ok != true) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(const SnackBar(content: Text('Working…')));
  try {
    final r = await action(ref.read(adminRepositoryProvider));
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(success(r))));
  } catch (e) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
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
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final accent = danger ? cs.error : cs.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: danger ? cs.errorContainer.withValues(alpha: 0.18) : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (danger ? cs.error : cs.outlineVariant).withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: danger ? cs.error.withValues(alpha: 0.12) : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: danger ? cs.error : null,
                      )),
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
