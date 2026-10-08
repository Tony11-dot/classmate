// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_surfaces.dart';
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
          _Group(
            label: l.navSchool,
            icon: Icons.school_outlined,
            children: [
              _SettingsNavTile(
                icon: Icons.school_rounded,
                label: l.adminSchoolSettingsTitle,
                subtitle: session.schoolName.isNotEmpty ? session.schoolName : '—',
                onTap: () => context.push('/admin/school'),
              ),
              if (isAdmin)
                _SettingsNavTile(
                  icon: Icons.calendar_view_week_rounded,
                  label: l.adminScheduleTitle,
                  subtitle: l.adminScheduleNoSlotsHint,
                  onTap: () => context.push('/admin/schedule'),
                ),
              _SettingsNavTile(
                icon: Icons.manage_history_rounded,
                label: l.adminSettingsPeriodDefaults,
                subtitle: l.adminSettingsScheduleSubtitle,
                onTap: () => context.push('/admin/periods'),
              ),
              if (isAdmin)
                _SettingsNavTile(
                  icon: Icons.admin_panel_settings_rounded,
                  label: l.permissionsTitle,
                  subtitle: l.permissionsNavSubtitle,
                  onTap: () => context.push('/admin/permissions'),
                ),
            ],
          ),

          if (isAdmin) ...[
            const SizedBox(height: 14),
            // ── Bulk tools ────────────────────────────────────────────────
            _Group(
              label: l.adminSettingsScreenBulkTools,
              icon: Icons.construction_rounded,
              children: [
                _SettingsNavTile(
                  icon: Icons.upload_file_rounded,
                  label: l.adminSettingsScreenImportUsers,
                  subtitle: l.adminSettingsScreenImportUsersSubtitle,
                  onTap: () => context.push('/admin/import-users'),
                ),
                _SettingsNavTile(
                  icon: Icons.upgrade_rounded,
                  label: l.adminSettingsScreenUpgradeGrades,
                  subtitle: l.adminSettingsScreenUpgradeGradesSubtitle,
                  onTap: () => _confirmAndRun(
                    context, ref,
                    title: l.adminSettingsScreenUpgradeGradesTitle,
                    body: l.adminSettingsScreenUpgradeGradesBody,
                    confirmLabel: l.adminSettingsScreenUpgradeConfirm,
                    destructive: false,
                    action: (repo) => repo.promoteAllGrades(),
                    success: (r) => l.adminSettingsScreenUpgradeSuccess(
                        (r['promoted'] ?? 0) as int, (r['graduating'] ?? 0) as int),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            // ── Danger zone ───────────────────────────────────────────────
            _Group(
              label: l.adminSettingsScreenDangerZone,
              icon: Icons.warning_amber_rounded,
              danger: true,
              children: [
                _SettingsNavTile(
                  icon: Icons.event_busy_rounded,
                  danger: true,
                  label: l.adminSettingsScreenResetSchedule,
                  subtitle: l.adminSettingsScreenResetScheduleSubtitle,
                  onTap: () => _confirmAndRun(
                    context, ref,
                    title: l.adminSettingsScreenResetScheduleTitle,
                    body: l.adminSettingsScreenResetScheduleBody,
                    confirmLabel: l.adminSettingsScreenResetSchedule,
                    destructive: true,
                    action: (repo) => repo.resetSchedule(),
                    success: (r) => l.adminSettingsScreenResetScheduleSuccess(
                        (r['slots'] ?? 0) as int),
                  ),
                ),
                _SettingsNavTile(
                  icon: Icons.groups_rounded,
                  danger: true,
                  label: l.adminSettingsScreenResetCohorts,
                  subtitle: l.adminSettingsScreenResetCohortsSubtitle,
                  onTap: () => _confirmAndRun(
                    context, ref,
                    title: l.adminSettingsScreenResetCohortsTitle,
                    body: l.adminSettingsScreenResetCohortsBody,
                    confirmLabel: l.adminSettingsScreenDeleteCohortsConfirm,
                    destructive: true,
                    action: (repo) => repo.resetCohorts(),
                    success: (r) => l.adminSettingsScreenResetCohortsSuccess(
                        (r['deleted'] ?? 0) as int),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // ── Account ────────────────────────────────────────────────────────
          _Group(
            label: l.sectionAccount,
            icon: Icons.person_outline_rounded,
            children: [
              _SettingsNavTile(
                icon: Icons.person_rounded,
                label: l.navProfile,
                subtitle: session.displayName.isNotEmpty ? session.displayName : session.email,
                onTap: () => context.push('/profile'),
              ),
              _SettingsNavTile(
                icon: Icons.palette_rounded,
                label: l.navSettings,
                subtitle: l.adminSettingsScreenAppearanceSubtitle,
                onTap: () => context.push('/settings'),
              ),
            ],
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
  final l = AppLocalizations.of(context)!;
  final cs = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (d) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(d, false), child: Text(l.adminSettingsScreenCancel)),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError) : null,
          onPressed: () => Navigator.pop(d, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  if (ok != true) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger.showSnackBar(SnackBar(content: Text(l.adminSettingsScreenWorking)));
  try {
    final r = await action(ref.read(adminRepositoryProvider));
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(success(r))));
  } catch (e) {
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(l.adminSettingsScreenFailed(e.toString()))));
  }
}

/// One settings group: a card with a coloured header and hairline-divided
/// rows (same layout as the main Settings screen).
class _Group extends StatelessWidget {
  const _Group({
    required this.label,
    required this.icon,
    required this.children,
    this.danger = false,
  });
  final String label;
  final IconData icon;
  final List<Widget> children;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tone = danger ? cs.error : cs.primary;
    return CmCard(
      radius: CmTokens.radiusXl,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 12, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: tone),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: tone,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 50,
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
            children[i],
          ],
        ],
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CmTokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            CmIconTile(icon: icon, size: 38, color: danger ? cs.error : cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: danger ? cs.error : null,
                      )),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
