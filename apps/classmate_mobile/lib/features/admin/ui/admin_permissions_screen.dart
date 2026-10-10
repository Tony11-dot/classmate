// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_press.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';
import '../../../ui/widgets/cm_search_field.dart';
import '../data/admin_repository.dart';

/// Admin-managed permissions. A searchable checklist of capabilities, each with
/// a switch per configurable role (Secretaries / Teachers). Admins always have
/// full access, so they are never shown here. Secretary abilities default OFF;
/// teacher abilities default ON — an admin flips either.
///
/// Body-only: the app shell supplies the top bar. Saving happens from a pinned
/// bottom bar that only appears when there are unsaved changes.
class AdminPermissionsScreen extends ConsumerStatefulWidget {
  const AdminPermissionsScreen({super.key});

  @override
  ConsumerState<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends ConsumerState<AdminPermissionsScreen> {
  List<PermissionCapability> _caps = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String _query = '';
  final _searchCtrl = TextEditingController();

  /// Current (possibly edited) values: capKey -> role -> enabled.
  final Map<String, Map<String, bool>> _state = {};
  /// The values as last loaded/saved, to detect "dirty".
  final Map<String, Map<String, bool>> _baseline = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // First load shows the spinner. A pull-to-refresh keeps the list on
    // screen and re-applies any unsaved toggles on top of the fresh truth, so
    // a refresh can never silently flip a switch back (QA round 2, #2).
    final initial = _caps.isEmpty;
    final pending = _dirty ? _pendingEdits() : null;
    setState(() { _loading = initial; _error = null; });
    try {
      final caps = await ref.read(adminRepositoryProvider).fetchPermissions();
      if (!mounted) return;
      setState(() {
        _caps = caps;
        _hydrate(caps);
        if (pending != null) _applyEdits(pending);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (initial) {
        setState(() { _error = '$e'; _loading = false; });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.permissionsLoadFailed('$e'))),
        );
      }
    }
  }

  /// Toggles that differ from the loaded baseline: capKey -> role -> value.
  Map<String, Map<String, bool>> _pendingEdits() {
    final out = <String, Map<String, bool>>{};
    for (final entry in _state.entries) {
      final base = _baseline[entry.key] ?? const {};
      for (final r in entry.value.entries) {
        if (base[r.key] != r.value) (out[entry.key] ??= {})[r.key] = r.value;
      }
    }
    return out;
  }

  void _applyEdits(Map<String, Map<String, bool>> edits) {
    for (final e in edits.entries) {
      final cur = _state[e.key];
      if (cur == null) continue; // capability no longer in the catalog
      for (final r in e.value.entries) {
        if (cur.containsKey(r.key)) cur[r.key] = r.value;
      }
    }
  }

  /// True when any switch differs from its catalog default.
  bool get _anyDeviation => _caps.any((c) => c.configurableRoles
      .any((r) => (_state[c.key]?[r] ?? c.enabledFor(r)) != c.defaultFor(r)));

  /// Every switch back to its catalog default; the Save bar then confirms.
  void _restoreDefaults() => setState(() {
        for (final c in _caps) {
          final cur = _state[c.key] ??= {};
          for (final r in c.configurableRoles) {
            cur[r] = c.defaultFor(r);
          }
        }
      });

  void _hydrate(List<PermissionCapability> caps) {
    _state.clear();
    _baseline.clear();
    for (final c in caps) {
      final cur = <String, bool>{};
      final base = <String, bool>{};
      for (final role in c.configurableRoles) {
        final v = c.enabledFor(role);
        cur[role] = v;
        base[role] = v;
      }
      _state[c.key] = cur;
      _baseline[c.key] = base;
    }
  }

  bool get _dirty {
    for (final entry in _state.entries) {
      final base = _baseline[entry.key] ?? const {};
      for (final r in entry.value.entries) {
        if (base[r.key] != r.value) return true;
      }
    }
    return false;
  }

  /// Build the overrides payload: ROLE -> { capKey: bool }.
  Map<String, Map<String, bool>> _buildOverrides() {
    final out = <String, Map<String, bool>>{};
    for (final c in _caps) {
      final cur = _state[c.key];
      if (cur == null) continue;
      for (final role in c.configurableRoles) {
        final v = cur[role];
        if (v == null) continue;
        (out[role] ??= <String, bool>{})[c.key] = v;
      }
    }
    return out;
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final caps = await ref.read(adminRepositoryProvider).savePermissions(_buildOverrides());
      if (!mounted) return;
      setState(() {
        _caps = caps;
        _hydrate(caps);
        _saving = false;
      });
      messenger.showSnackBar(SnackBar(content: Text(l.permissionsSaved)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(l.permissionsSaveFailed(e.toString()))));
    }
  }

  void _discard() => setState(() => _hydrate(_caps));

  List<PermissionCapability> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _caps;
    final l = AppLocalizations.of(context)!;
    return _caps.where((c) {
      final t = capabilityText(l, c);
      return t.label.toLowerCase().contains(q) ||
          t.description.toLowerCase().contains(q) ||
          moduleText(l, c.module).toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    if (_loading) return const Center(child: CmLoading());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock_outline_rounded, size: 40, color: cs.onSurfaceVariant),
              const SizedBox(height: 12),
              Text(l.permissionsLoadFailed(_error!), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: _load, child: Text(l.permissionsResetChanges)),
            ],
          ),
        ),
      );
    }

    // Group filtered caps by module, preserving catalog order.
    final filtered = _filtered;
    final modules = <String>[];
    final byModule = <String, List<PermissionCapability>>{};
    for (final c in filtered) {
      byModule.putIfAbsent(c.module, () {
        modules.add(c.module);
        return [];
      }).add(c);
    }

    return Scaffold(
      backgroundColor: cs.surface,
      // Single scrolling list: the search bar is the first item so it scrolls
      // away with the page (was pinned above the list before).
      body: CmRefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            CmSearchField(
              controller: _searchCtrl,
              hint: l.permissionsSearchHint,
              onChanged: (v) => setState(() => _query = v),
            ),
            if (filtered.isEmpty) ...[
              const SizedBox(height: 80),
              Icon(Icons.search_off_rounded, size: 40, color: cs.onSurfaceVariant),
              const SizedBox(height: 12),
              Center(child: Text(l.permissionsNoResults(_query))),
            ] else ...[
              if (_query.isEmpty) ...[
                const SizedBox(height: 12),
                _HeaderBlurb(text: l.permissionsHeaderBlurb),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: _anyDeviation ? _restoreDefaults : null,
                    icon: const Icon(Icons.restart_alt_rounded, size: 18),
                    label: Text(l.permissionsRestoreDefaults),
                  ),
                ),
              ],
              for (final m in modules) ...[
                const SizedBox(height: 18),
                _ModuleHeader(label: m),
                const SizedBox(height: 8),
                for (final c in byModule[m]!)
                  _CapabilityCard(
                    cap: c,
                    state: _state[c.key] ?? const {},
                    onToggle: (role, val) => setState(() {
                      (_state[c.key] ??= {})[role] = val;
                    }),
                  ),
              ],
            ],
          ],
        ),
      ),
      bottomNavigationBar: _dirty ? _SaveBar(
        saving: _saving,
        onSave: _save,
        onDiscard: _discard,
      ) : null,
    );
  }
}

class _HeaderBlurb extends StatelessWidget {
  const _HeaderBlurb({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 2, bottom: 2),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_moduleIcon(label), size: 17, color: cs.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              moduleText(AppLocalizations.of(context)!, label),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard({
    required this.cap,
    required this.state,
    required this.onToggle,
  });
  final PermissionCapability cap;
  final Map<String, bool> state;
  final void Function(String role, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final tokens = CmTokens.of(context);

    String roleLabel(String r) => switch (r) {
      'SECRETARY' => l.permissionsColSecretary,
      'TEACHER' => l.permissionsColTeacher,
      _ => r,
    };

    bool roleVal(String r) => state[r] ?? cap.enabledFor(r);
    bool roleChanged(String r) => roleVal(r) != cap.defaultFor(r);
    final anyChanged = cap.configurableRoles.any(roleChanged);
    final roles = cap.configurableRoles.toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(CmTokens.radiusMd),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: tokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(capabilityText(l, cap).label,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(capabilityText(l, cap).description,
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              if (anyChanged) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: tokens.warnContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l.permissionsChangedBadge,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tokens.onWarnContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < roles.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _RoleChip(
                    label: roleLabel(roles[i]),
                    value: roleVal(roles[i]),
                    changed: roleChanged(roles[i]),
                    onChanged: (v) => onToggle(roles[i], v),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Compact per-role toggle — the two (Secretary / Teacher) sit side by side so
/// an admin compares both roles for a capability at a glance. A changed-from-
/// default chip gets an amber outline (mirrors the card's "Changed" badge).
class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.value,
    required this.changed,
    required this.onChanged,
  });
  final String label;
  final bool value;
  final bool changed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = CmTokens.of(context);
    // The whole chip toggles, not just the small switch — tapping the role
    // name used to do nothing, which read as "not clickable" (QA round 2, #2).
    return CmPress(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 4),
        decoration: BoxDecoration(
          color: value ? cs.surfaceContainerHigh : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(CmTokens.radiusSm),
          border: Border.all(
            color: changed
                ? tokens.warn.withValues(alpha: 0.7)
                : cs.outlineVariant.withValues(alpha: 0.5),
            width: changed ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: value ? cs.onSurface : cs.onSurfaceVariant,
                    ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }
}

/// The server's catalog is English. Known capabilities and sections read in
/// the app's language; anything added to the catalog later falls back to the
/// server's text until it gets a translation.
({String label, String description}) capabilityText(AppLocalizations l, PermissionCapability c) =>
    switch (c.key) {
      'cohorts.manageMembers' => (label: l.permCohortsManageMembers, description: l.permCohortsManageMembersDesc),
      'cohorts.manage' => (label: l.permCohortsManage, description: l.permCohortsManageDesc),
      'students.create' => (label: l.permStudentsCreate, description: l.permStudentsCreateDesc),
      'students.delete' => (label: l.permStudentsDelete, description: l.permStudentsDeleteDesc),
      'cmail.send' => (label: l.permCmailSend, description: l.permCmailSendDesc),
      'certificates.manage' => (label: l.permCertificatesManage, description: l.permCertificatesManageDesc),
      'grades.edit' => (label: l.permGradesEdit, description: l.permGradesEditDesc),
      'materials.manage' => (label: l.permMaterialsManage, description: l.permMaterialsManageDesc),
      'assignments.manage' => (label: l.permAssignmentsManage, description: l.permAssignmentsManageDesc),
      'exams.manage' => (label: l.permExamsManage, description: l.permExamsManageDesc),
      'meetings.manage' => (label: l.permMeetingsManage, description: l.permMeetingsManageDesc),
      'forms.manage' => (label: l.permFormsManage, description: l.permFormsManageDesc),
      'schedule.edit' => (label: l.permScheduleEdit, description: l.permScheduleEditDesc),
      'announcements.post' => (label: l.permAnnouncementsPost, description: l.permAnnouncementsPostDesc),
      _ => (label: c.label, description: c.description),
    };

String moduleText(AppLocalizations l, String module) => switch (module) {
      'Classes & Students' => l.permModuleClassesStudents,
      'Communication' => l.permModuleCommunication,
      'Certificates' => l.permModuleCertificates,
      'Teaching' => l.permModuleTeaching,
      'Schedule & Announcements' => l.permModuleScheduleAnnouncements,
      _ => module,
    };

/// Maps a permission module name to a representative icon for its section
/// header. Matched loosely on the module string so new backend modules still
/// get a sensible icon (falls back to a generic "tune" glyph).
IconData _moduleIcon(String module) {
  final k = module.toLowerCase();
  // Real catalog modules: "Classes & Students", "Communication",
  // "Certificates", "Teaching". The rest are forward-compatible guesses.
  if (k.contains('class') || k.contains('cohort')) return Icons.groups_rounded;
  if (k.contains('communic')) return Icons.forum_rounded;
  if (k.contains('schedul') || k.contains('announce')) return Icons.event_note_rounded;
  if (k.contains('teach')) return Icons.co_present_rounded;
  if (k.contains('student')) return Icons.school_rounded;
  if (k.contains('grade')) return Icons.grade_rounded;
  if (k.contains('material')) return Icons.folder_rounded;
  if (k.contains('assign')) return Icons.assignment_rounded;
  if (k.contains('exam')) return Icons.quiz_rounded;
  if (k.contains('meet')) return Icons.event_rounded;
  if (k.contains('form')) return Icons.description_rounded;
  if (k.contains('cert')) return Icons.workspace_premium_rounded;
  if (k.contains('mail')) return Icons.alternate_email_rounded;
  if (k.contains('message') || k.contains('chat')) return Icons.chat_bubble_rounded;
  return Icons.tune_rounded;
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.saving, required this.onSave, required this.onDiscard});
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
        ),
        child: Row(
          children: [
            TextButton(
              onPressed: saving ? null : onDiscard,
              child: Text(l.permissionsResetChanges),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const CmLoading(size: 16)
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(l.permissionsSave),
            ),
          ],
        ),
      ),
    );
  }
}
