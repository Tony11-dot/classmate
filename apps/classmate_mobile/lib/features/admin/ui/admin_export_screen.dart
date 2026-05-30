// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

/// Admin/secretary export screen. Filters are pills — every pill (role,
/// cohort, grade, specific user) adds to the export set (UNION). When no
/// pills are set the screen shows an empty state and the export FAB is
/// hidden. Cohort/grade pills only contribute student rows; specific-user
/// pills always include their user regardless of role.
class AdminExportScreen extends ConsumerStatefulWidget {
  const AdminExportScreen({super.key});

  @override
  ConsumerState<AdminExportScreen> createState() => _AdminExportScreenState();
}

const _kRoles = <String>['STUDENT', 'TEACHER', 'PARENT', 'SECRETARY', 'ADMIN'];

class _AdminExportScreenState extends ConsumerState<AdminExportScreen> {
  // ── Pills ──────────────────────────────────────────────────────────────────
  // Role-wide filtering was removed in favour of per-user picking inside
  // the Users role drill-down. Kept as an empty placeholder so existing
  // call sites that pass `roles: _selectedRoles.toList()` still compile;
  // it's always empty now.
  final Set<String> _selectedRoles = {};
  final Set<String> _selectedCohortIds = {};
  final Set<int> _selectedGrades = {};
  final Set<String> _selectedUserIds = {};

  // ── Data caches for pill labels and the picker sheet ──────────────────────
  List<Map<String, dynamic>> _ddlStudents = [];
  List<Map<String, dynamic>> _ddlTeachers = [];
  List<Map<String, dynamic>> _ddlCohorts = [];
  /// All available grades in the school, derived from cohort metadata.
  List<int> _allGrades = [];
  /// Quick lookup id → user record for rendering specific-user pills.
  final Map<String, Map<String, dynamic>> _userById = {};

  bool _loading = true;
  bool _previewing = false;
  int _previewCount = 0;

  // Debounce repeated preview requests when the user toggles several
  // filters in quick succession.
  Timer? _previewDebounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(adminRepositoryProvider);
      final results = await Future.wait([
        repo.getDdlStudents(),
        repo.getDdlCohorts(),
        repo.getDdlTeachers(),
      ]);
      final students = results[0];
      final cohorts = results[1];
      final teachers = results[2];

      final gradeSet = <int>{};
      for (final c in cohorts) {
        final gs = c['grades'];
        if (gs is List && gs.isNotEmpty) {
          for (final g in gs) {
            if (g is num) gradeSet.add(g.toInt());
          }
        } else {
          final g = c['grade'];
          if (g is num) gradeSet.add(g.toInt());
        }
      }

      if (!mounted) return;
      setState(() {
        _ddlStudents = students;
        _ddlTeachers = teachers;
        _ddlCohorts = cohorts;
        _allGrades = gradeSet.toList()..sort();
        _userById.clear();
        for (final u in [...students, ...teachers]) {
          final id = u['id']?.toString() ?? '';
          if (id.isNotEmpty) _userById[id] = u;
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _hasFilters =>
      _selectedRoles.isNotEmpty ||
      _selectedCohortIds.isNotEmpty ||
      _selectedGrades.isNotEmpty ||
      _selectedUserIds.isNotEmpty;

  void _schedulePreview() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(const Duration(milliseconds: 280), _refreshPreview);
  }

  Future<void> _refreshPreview() async {
    if (!_hasFilters) {
      setState(() {
        _previewCount = 0;
        _previewing = false;
      });
      return;
    }
    setState(() => _previewing = true);
    try {
      final rows = await ref.read(adminRepositoryProvider).exportUsers(
            roles: _selectedRoles.toList(),
            cohortIds: _selectedCohortIds.toList(),
            gradeIds: _selectedGrades.toList(),
            userIds: _selectedUserIds.toList(),
          );
      if (!mounted) return;
      setState(() {
        _previewCount = rows.length;
        _previewing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _previewing = false);
    }
  }

  // ── Pill mutators ──────────────────────────────────────────────────────────
  void _toggleRole(String role) {
    setState(() {
      if (_selectedRoles.contains(role)) {
        _selectedRoles.remove(role);
      } else {
        _selectedRoles.add(role);
      }
    });
    _schedulePreview();
  }

  void _toggleCohort(String id) {
    setState(() {
      if (_selectedCohortIds.contains(id)) {
        _selectedCohortIds.remove(id);
      } else {
        _selectedCohortIds.add(id);
      }
    });
    _schedulePreview();
  }

  void _toggleGrade(int g) {
    setState(() {
      if (_selectedGrades.contains(g)) {
        _selectedGrades.remove(g);
      } else {
        _selectedGrades.add(g);
      }
    });
    _schedulePreview();
  }

  void _toggleUser(String id) {
    setState(() {
      if (_selectedUserIds.contains(id)) {
        _selectedUserIds.remove(id);
      } else {
        _selectedUserIds.add(id);
      }
    });
    _schedulePreview();
  }

  /// Bulk toggle used by the role drill-down's "Select all" affordance.
  /// `selected: true` adds every id in [ids] to _selectedUserIds; false
  /// removes them. One setState + one debounced preview no matter how
  /// many users.
  void _setUsersSelected(Iterable<String> ids, bool selected) {
    setState(() {
      if (selected) {
        _selectedUserIds.addAll(ids);
      } else {
        _selectedUserIds.removeAll(ids);
      }
    });
    _schedulePreview();
  }

  /// Add fetched user records to the id→record cache so pills can render
  /// names for users that came in via the lazy per-role drill-down
  /// (parents/secretaries/admins aren't in the eager DDL load).
  void _cacheUsers(List<Map<String, dynamic>> users) {
    if (users.isEmpty) return;
    setState(() {
      for (final u in users) {
        final id = u['id']?.toString() ?? '';
        if (id.isNotEmpty) _userById[id] = u;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _selectedRoles.clear();
      _selectedCohortIds.clear();
      _selectedGrades.clear();
      _selectedUserIds.clear();
      _previewCount = 0;
    });
  }

  // ── Add filter sheet ───────────────────────────────────────────────────────
  Future<void> _openAddFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) => _AddFilterSheet(
        cohorts: _ddlCohorts,
        grades: _allGrades,
        students: _ddlStudents,
        teachers: _ddlTeachers,
        selectedCohortIds: _selectedCohortIds,
        selectedGrades: _selectedGrades,
        selectedUserIds: _selectedUserIds,
        onToggleCohort: _toggleCohort,
        onToggleGrade: _toggleGrade,
        onToggleUser: _toggleUser,
        onSetUsersSelected: _setUsersSelected,
        onCacheUsers: _cacheUsers,
        loadUsersByRole: (role) =>
            ref.read(adminRepositoryProvider).getDdlUsersByRole(role),
      ),
    );
  }

  // ── Export bottom sheet ────────────────────────────────────────────────────
  void _showExportSheet() {
    if (!_hasFilters || _previewCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.adminExportNeedStudents)),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _ExportOptionsSheet(
        userCount: _previewCount,
        filter: _UserExportFilter(
          roles: _selectedRoles.toList(),
          cohortIds: _selectedCohortIds.toList(),
          gradeIds: _selectedGrades.toList(),
          userIds: _selectedUserIds.toList(),
        ),
        repo: ref.read(adminRepositoryProvider),
        session: ref.read(authSessionProvider),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: _hasFilters && _previewCount > 0
          ? FloatingActionButton.extended(
              heroTag: 'fab_export',
              onPressed: _showExportSheet,
              icon: const Icon(Icons.download_rounded),
              label: Text(l.adminExportButton(_previewCount)),
            )
          : null,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  // Header
                  Text(
                    l.adminExportHeaderTitle,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.adminExportHeaderSubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),

                  // Add filter button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openAddFilterSheet,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(l.adminExportAddFilter),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Pills bar
                  if (!_hasFilters)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.filter_list_rounded, size: 36, color: cs.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text(
                            l.adminExportEmptyState,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  else
                    _PillsBar(
                      selectedRoles: _selectedRoles,
                      selectedCohortIds: _selectedCohortIds,
                      selectedGrades: _selectedGrades,
                      selectedUserIds: _selectedUserIds,
                      cohorts: _ddlCohorts,
                      userById: _userById,
                      onRemoveRole: _toggleRole,
                      onRemoveCohort: _toggleCohort,
                      onRemoveGrade: _toggleGrade,
                      onRemoveUser: _toggleUser,
                      onClearAll: _clearAll,
                    ),

                  // Preview card
                  if (_hasFilters) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cs.primaryContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          if (_previewing)
                            const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(Icons.people_alt_rounded, color: cs.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _previewing
                                  ? l.adminExportCounting
                                  : l.adminExportMatchCount(_previewCount),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

// ── Pills bar ────────────────────────────────────────────────────────────────

class _PillsBar extends StatelessWidget {
  const _PillsBar({
    required this.selectedRoles,
    required this.selectedCohortIds,
    required this.selectedGrades,
    required this.selectedUserIds,
    required this.cohorts,
    required this.userById,
    required this.onRemoveRole,
    required this.onRemoveCohort,
    required this.onRemoveGrade,
    required this.onRemoveUser,
    required this.onClearAll,
  });

  final Set<String> selectedRoles;
  final Set<String> selectedCohortIds;
  final Set<int> selectedGrades;
  final Set<String> selectedUserIds;
  final List<Map<String, dynamic>> cohorts;
  final Map<String, Map<String, dynamic>> userById;
  final ValueChanged<String> onRemoveRole;
  final ValueChanged<String> onRemoveCohort;
  final ValueChanged<int> onRemoveGrade;
  final ValueChanged<String> onRemoveUser;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    final pills = <Widget>[];

    for (final role in selectedRoles) {
      pills.add(_Pill(
        icon: Icons.badge_rounded,
        label: '${l.adminExportPillRolePrefix} ${_localizedRoleName(l, role)}',
        onRemove: () => onRemoveRole(role),
      ));
    }
    for (final cid in selectedCohortIds) {
      final c = cohorts.firstWhere(
        (x) => x['id']?.toString() == cid,
        orElse: () => const {},
      );
      final name = (c['name'] ?? '').toString();
      pills.add(_Pill(
        icon: Icons.groups_rounded,
        label: '${l.adminExportPillCohortPrefix} ${name.isEmpty ? cid : name}',
        onRemove: () => onRemoveCohort(cid),
      ));
    }
    for (final g in selectedGrades) {
      pills.add(_Pill(
        icon: Icons.school_rounded,
        label: l.adminCohortGradeFormat(g.toString()),
        onRemove: () => onRemoveGrade(g),
      ));
    }
    for (final uid in selectedUserIds) {
      final u = userById[uid] ?? const {};
      final name = (u['name'] ?? '').toString();
      pills.add(_Pill(
        icon: Icons.person_rounded,
        label: name.isEmpty ? uid : name,
        onRemove: () => onRemoveUser(uid),
      ));
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.adminExportActiveFilters(pills.length),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(l.adminExportClearAll),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: pills),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.onRemove});
  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primaryContainer,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: cs.onPrimaryContainer),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.close_rounded, size: 16, color: cs.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add-filter modal sheet ───────────────────────────────────────────────────

class _AddFilterSheet extends StatefulWidget {
  const _AddFilterSheet({
    required this.cohorts,
    required this.grades,
    required this.students,
    required this.teachers,
    required this.selectedCohortIds,
    required this.selectedGrades,
    required this.selectedUserIds,
    required this.onToggleCohort,
    required this.onToggleGrade,
    required this.onToggleUser,
    required this.onSetUsersSelected,
    required this.onCacheUsers,
    required this.loadUsersByRole,
  });

  final List<Map<String, dynamic>> cohorts;
  final List<int> grades;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> teachers;
  final Set<String> selectedCohortIds;
  final Set<int> selectedGrades;
  final Set<String> selectedUserIds;
  final ValueChanged<String> onToggleCohort;
  final ValueChanged<int> onToggleGrade;
  final ValueChanged<String> onToggleUser;
  final void Function(Iterable<String> ids, bool selected) onSetUsersSelected;
  final ValueChanged<List<Map<String, dynamic>>> onCacheUsers;
  final Future<List<Map<String, dynamic>>> Function(String role) loadUsersByRole;

  @override
  State<_AddFilterSheet> createState() => _AddFilterSheetState();
}

class _AddFilterSheetState extends State<_AddFilterSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String _userQuery = '';
  // Per-role drill-down: null = show role picker; non-null = show that
  // role's user list. Lazily-loaded role lists are cached here so we
  // don't refetch every time the user switches roles.
  String? _drillRole;
  final Map<String, List<Map<String, dynamic>>> _roleUsers = {};
  final Set<String> _loadingRoles = {};

  static const _kRoleOrder = <String>['STUDENT', 'TEACHER', 'PARENT', 'SECRETARY', 'ADMIN'];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    // Seed cache with eagerly-loaded students + teachers so opening
    // those drill-downs is instant.
    _roleUsers['STUDENT'] = widget.students;
    _roleUsers['TEACHER'] = widget.teachers;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _ensureRoleLoaded(String role) async {
    if (_roleUsers.containsKey(role)) return;
    if (_loadingRoles.contains(role)) return;
    setState(() => _loadingRoles.add(role));
    try {
      final users = await widget.loadUsersByRole(role);
      if (!mounted) return;
      widget.onCacheUsers(users);
      setState(() {
        _roleUsers[role] = users;
        _loadingRoles.remove(role);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _roleUsers[role] = const [];
        _loadingRoles.remove(role);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                if (_drillRole != null)
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => setState(() {
                      _drillRole = null;
                      _userQuery = '';
                    }),
                  ),
                Expanded(
                  child: Text(
                    _drillRole != null
                        ? _localizedRoleName(l, _drillRole!)
                        : l.adminExportAddFilter,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.commonDone),
                ),
              ],
            ),
          ),
          if (_drillRole == null)
            TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: cs.primary,
              unselectedLabelColor: cs.onSurfaceVariant,
              indicatorColor: cs.primary,
              tabs: [
                Tab(text: l.adminExportFilterUsersTab),
                Tab(text: l.adminExportFilterCohortsTab),
                Tab(text: l.adminExportFilterGradesTab),
              ],
            ),
          const SizedBox(height: 4),
          Expanded(
            child: _drillRole != null
                ? _buildRoleDrillDown(scrollCtrl, l, _drillRole!)
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _buildUsersTab(scrollCtrl, l),
                      _buildCohortsTab(scrollCtrl, l),
                      _buildGradesTab(scrollCtrl, l),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCohortsTab(ScrollController c, AppLocalizations l) {
    if (widget.cohorts.isEmpty) {
      return Center(child: Text(l.adminNoCohortsYet));
    }
    return ListView.separated(
      controller: c,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: widget.cohorts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (ctx, i) {
        final cohort = widget.cohorts[i];
        final id = cohort['id']?.toString() ?? '';
        final name = (cohort['name'] ?? '').toString();
        final grade = (cohort['grade'] as num?)?.toInt();
        final selected = widget.selectedCohortIds.contains(id);
        return _PickerRow(
          icon: Icons.groups_rounded,
          label: name.isEmpty ? id : name,
          subtitle: grade != null ? l.adminCohortGradeFormat(grade.toString()) : null,
          selected: selected,
          onTap: () {
            widget.onToggleCohort(id);
            setState(() {});
          },
        );
      },
    );
  }

  Widget _buildGradesTab(ScrollController c, AppLocalizations l) {
    if (widget.grades.isEmpty) {
      return Center(child: Text(l.adminExportNoGradesConfigured));
    }
    return ListView.separated(
      controller: c,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: widget.grades.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (ctx, i) {
        final g = widget.grades[i];
        final selected = widget.selectedGrades.contains(g);
        return _PickerRow(
          icon: Icons.school_rounded,
          label: l.adminCohortGradeFormat(g.toString()),
          selected: selected,
          onTap: () {
            widget.onToggleGrade(g);
            setState(() {});
          },
        );
      },
    );
  }

  // Root view of the Users tab — five role rows. Tapping a row swaps
  // the sheet body into the per-role drill-down (handled in build()
  // via _drillRole).
  Widget _buildUsersTab(ScrollController c, AppLocalizations l) {
    return ListView.separated(
      controller: c,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      itemCount: _kRoleOrder.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (ctx, i) {
        final role = _kRoleOrder[i];
        final cached = _roleUsers[role];
        final pickedHere = cached == null
            ? 0
            : cached.where((u) =>
                widget.selectedUserIds.contains(u['id']?.toString() ?? '')).length;
        final subtitle = pickedHere > 0
            ? l.adminExportRolePickedCount(pickedHere)
            : null;
        return _PickerRow(
          icon: _roleIcon(role),
          label: _localizedRoleName(l, role),
          subtitle: subtitle,
          selected: false,
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            setState(() {
              _drillRole = role;
              _userQuery = '';
            });
            _ensureRoleLoaded(role);
          },
        );
      },
    );
  }

  // Drill-down view for one role. Shows a search box + Select-all
  // checkbox in the header + a checkbox per user. Selections feed
  // _selectedUserIds via the parent.
  Widget _buildRoleDrillDown(ScrollController c, AppLocalizations l, String role) {
    final users = _roleUsers[role];
    final loading = _loadingRoles.contains(role) || users == null;
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (users.isEmpty) {
      return Center(child: Text(l.adminExportNoStudents));
    }
    final q = _userQuery.trim().toLowerCase();
    final filtered = q.isEmpty
        ? users
        : users.where((u) {
            final name = (u['name'] ?? '').toString().toLowerCase();
            final email = (u['email'] ?? '').toString().toLowerCase();
            final username = (u['username'] ?? '').toString().toLowerCase();
            return name.contains(q) || email.contains(q) || username.contains(q);
          }).toList();

    final visibleIds = filtered
        .map((u) => u['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toList();
    final allVisibleSelected = visibleIds.isNotEmpty &&
        visibleIds.every((id) => widget.selectedUserIds.contains(id));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _userQuery = v),
            decoration: InputDecoration(
              hintText: l.adminScheduleSearchStudents,
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
          child: _PickerRow(
            icon: Icons.checklist_rtl_rounded,
            label: l.adminExportSelectAll,
            subtitle: l.adminExportSelectedCount(
              filtered.where((u) => widget.selectedUserIds
                  .contains(u['id']?.toString() ?? '')).length,
              filtered.length,
            ),
            selected: allVisibleSelected,
            onTap: () {
              widget.onSetUsersSelected(visibleIds, !allVisibleSelected);
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: c,
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 4),
            itemBuilder: (ctx, i) {
              final u = filtered[i];
              final id = u['id']?.toString() ?? '';
              final name = (u['name'] ?? '').toString();
              final email = (u['email'] ?? '').toString();
              final username = (u['username'] ?? '').toString();
              final selected = widget.selectedUserIds.contains(id);
              return _PickerRow(
                icon: _roleIcon(role),
                label: name.isEmpty ? (username.isEmpty ? id : username) : name,
                subtitle: email.isNotEmpty ? email : null,
                selected: selected,
                onTap: () {
                  widget.onToggleUser(id);
                  setState(() {});
                },
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _roleIcon(String role) => switch (role) {
        'STUDENT' => Icons.school_rounded,
        'TEACHER' => Icons.cast_for_education_rounded,
        'PARENT' => Icons.family_restroom_rounded,
        'SECRETARY' => Icons.support_agent_rounded,
        'ADMIN' => Icons.shield_rounded,
        _ => Icons.person_rounded,
      };
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.4)
                : cs.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: selected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if ((subtitle ?? '').isNotEmpty)
                    Text(
                      subtitle!,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? cs.primary : cs.onSurfaceVariant,
                ),
          ],
        ),
      ),
    );
  }
}

// ── Export options sheet ─────────────────────────────────────────────────────

class _UserExportFilter {
  const _UserExportFilter({
    required this.roles,
    required this.cohortIds,
    required this.gradeIds,
    required this.userIds,
  });
  final List<String> roles;
  final List<String> cohortIds;
  final List<int> gradeIds;
  final List<String> userIds;
}

class _ExportOptionsSheet extends StatefulWidget {
  const _ExportOptionsSheet({
    required this.userCount,
    required this.filter,
    required this.repo,
    required this.session,
  });

  final int userCount;
  final _UserExportFilter filter;
  final AdminRepository repo;
  final dynamic session;

  @override
  State<_ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<_ExportOptionsSheet> {
  bool _includePasswords = false;
  bool _exporting = false;
  /// When ON, the PDF export devotes a full page to each user with a
  /// data-forward layout (no shared table). Off = legacy compact table.
  bool _eachUserAlone = false;
  /// Only meaningful when [_eachUserAlone] is true. ON = generate one
  /// PDF file per user (shared as N attachments); OFF = a single PDF
  /// where each user gets its own page.
  bool _separateFiles = false;
  // Language picker for the export. Drives which name field
  // (nameEn / nameAr / nameHe / nameFr / nameRu) becomes the primary
  // "Name" column in the PDF and the first column in the CSV. Defaults
  // to the app's current locale so the most-likely intent is preselected.
  late String _lang = _initialLang();

  String _initialLang() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return const ['en', 'ar', 'he', 'fr', 'ru'].contains(code) ? code : 'en';
  }

  String _nameForLang(Map<String, dynamic> u, String lang) {
    final key = 'name${lang[0].toUpperCase()}${lang.substring(1)}';
    final v = (u[key] ?? '').toString();
    if (v.isNotEmpty) return v;
    // Fall back to nameEn, then the raw `name` legacy field.
    return (u['nameEn'] ?? u['name'] ?? '').toString();
  }

  /// Source rect for the iOS share popover. iPad + newer iPhone share sheets
  /// require a non-zero anchor or they throw
  /// `PlatformException(sharePositionOrigin: argument must be set...)`.
  Rect _shareOrigin(BuildContext ctx) {
    final box = ctx.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      return box.localToGlobal(Offset.zero) & box.size;
    }
    final size = MediaQuery.sizeOf(ctx);
    return Rect.fromLTWH(size.width / 2, 0, 1, 1);
  }

  Future<bool> _confirmPasswords() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (d) {
        final cs = Theme.of(d).colorScheme;
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: cs.error),
              const SizedBox(width: 10),
              Expanded(child: Text(AppLocalizations.of(context)!.adminExportIncludesPasswords)),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)!.adminExportPasswordsWarning(widget.userCount),
            style: const TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(d, false),
              child: Text(AppLocalizations.of(context)!.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(d, true),
              child: Text(AppLocalizations.of(context)!.adminExportButton(widget.userCount)),
            ),
          ],
        );
      },
    );
    return confirm == true;
  }

  Future<List<Map<String, dynamic>>> _fetch() => widget.repo.exportUsers(
        roles: widget.filter.roles,
        cohortIds: widget.filter.cohortIds,
        gradeIds: widget.filter.gradeIds,
        userIds: widget.filter.userIds,
        generatePasswords: _includePasswords,
      );

  // ── CSV ────────────────────────────────────────────────────────────────────
  Future<void> _exportCsv() async {
    if (_includePasswords && !await _confirmPasswords()) return;
    setState(() => _exporting = true);
    try {
      final users = await _fetch();
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      final headers = [
        l.adminExportColumnNameEn,
        l.adminExportColumnNameAr,
        l.adminExportColumnNameHe,
        l.adminExportColumnNameFr,
        l.adminExportColumnNameRu,
        l.adminExportColumnRole,
        l.adminExportColumnEmail,
        l.adminExportColumnUsername,
        l.adminExportColumnPhone,
        l.adminExportColumnGrade,
        l.adminExportColumnCohorts,
        l.adminExportColumnSchool,
      ];
      if (_includePasswords) headers.add(l.adminExportColumnPassword);
      final buf = StringBuffer()..writeln(headers.join(','));
      for (final u in users) {
        final cohortNamesRaw = u['cohortNames'];
        final cohortsJoined = cohortNamesRaw is List
            ? cohortNamesRaw.whereType<String>().where((n) => n.isNotEmpty).join(' / ')
            : (u['cohortName']?.toString() ?? '');
        final role = (u['role'] ?? '').toString();
        final isStudent = role == 'STUDENT';
        final row = [
          _esc(u['nameEn']?.toString() ?? ''),
          _esc(u['nameAr']?.toString() ?? ''),
          _esc(u['nameHe']?.toString() ?? ''),
          _esc(u['nameFr']?.toString() ?? ''),
          _esc(u['nameRu']?.toString() ?? ''),
          _esc(_localizedRoleName(l, role)),
          _esc(u['email']?.toString() ?? ''),
          _esc(u['username']?.toString() ?? ''),
          _esc(u['phone']?.toString() ?? ''),
          isStudent ? (u['grade']?.toString() ?? '') : '—',
          _esc(isStudent ? cohortsJoined : '—'),
          _esc(u['schoolName']?.toString() ?? ''),
          if (_includePasswords) _esc(u['tempPassword']?.toString() ?? ''),
        ];
        buf.writeln(row.join(','));
      }
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/users_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buf.toString());
      if (!mounted) return;
      final origin = _shareOrigin(context);
      Navigator.pop(context);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'text/csv')],
        subject: 'ClassMate Users',
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── PDF ────────────────────────────────────────────────────────────────────
  Future<void> _exportPdf() async {
    if (_includePasswords && !await _confirmPasswords()) return;
    setState(() => _exporting = true);
    try {
      final users = await _fetch();
      if (!mounted) return;
      final schoolName = widget.session?.schoolName ?? '';
      final exportedBy = (widget.session?.displayName ?? widget.session?.email ?? 'Admin') as String;
      final l = AppLocalizations.of(context)!;

      // Three branches:
      //   1. Compact table (legacy) — one PDF, all users in a single
      //      landscape table.
      //   2. Each user alone, bundled — one PDF, one full page per user.
      //   3. Each user alone, separate — N PDFs, one per user; shared
      //      together via the OS share sheet.
      if (!_eachUserAlone) {
        final bytes = await _buildPdf(
          users,
          withPasswords: _includePasswords,
          schoolName: schoolName,
          exportedBy: exportedBy,
          l: l,
        );
        if (!mounted) return;
        final origin = _shareOrigin(context);
        Navigator.pop(context);
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'classmate_users.pdf',
          bounds: origin,
        );
      } else if (!_separateFiles) {
        final bytes = await _buildPerUserPdf(
          users,
          withPasswords: _includePasswords,
          schoolName: schoolName,
          exportedBy: exportedBy,
          l: l,
        );
        if (!mounted) return;
        final origin = _shareOrigin(context);
        Navigator.pop(context);
        await Printing.sharePdf(
          bytes: bytes,
          filename: 'classmate_users.pdf',
          bounds: origin,
        );
      } else {
        // One PDF per user. Write each to a temp file then share them
        // as a single XFile batch.
        final dir = await getTemporaryDirectory();
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final files = <XFile>[];
        for (var i = 0; i < users.length; i++) {
          final bytes = await _buildPerUserPdf(
            [users[i]],
            withPasswords: _includePasswords,
            schoolName: schoolName,
            exportedBy: exportedBy,
            l: l,
          );
          final safeName = (_nameForLang(users[i], _lang).isEmpty
                  ? (users[i]['username']?.toString() ?? 'user')
                  : _nameForLang(users[i], _lang))
              .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_');
          final f = File('${dir.path}/classmate_${safeName}_$stamp.pdf');
          await f.writeAsBytes(bytes);
          files.add(XFile(f.path, mimeType: 'application/pdf'));
        }
        if (!mounted) return;
        final origin = _shareOrigin(context);
        Navigator.pop(context);
        await Share.shareXFiles(
          files,
          subject: 'ClassMate Users',
          sharePositionOrigin: origin,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  /// Builds a PDF where each user occupies a full A4 portrait page. The
  /// layout is data-forward (large name, badge row, info cards) rather
  /// than the compact landscape table the legacy export uses.
  Future<Uint8List> _buildPerUserPdf(
    List<Map<String, dynamic>> users, {
    required bool withPasswords,
    required String schoolName,
    required String exportedBy,
    required AppLocalizations l,
  }) async {
    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final baseBold = await PdfGoogleFonts.notoSansBold();
    final arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
    final hebrewFont = await PdfGoogleFonts.notoSansHebrewRegular();
    // logo_light.png is the wide wordmark — used here as the page-top
    // brand mark. icon_light.png is kept for the corner chip so the
    // header still has a recognisable square icon next to metadata.
    final cmWordmark = pw.MemoryImage(
      (await rootBundle.load('assets/images/logo_light.png')).buffer.asUint8List(),
    );
    final cmIcon = pw.MemoryImage(
      (await rootBundle.load('assets/images/icon_light.png')).buffer.asUint8List(),
    );

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: baseBold,
        fontFallback: [arabicFont, hebrewFont],
      ),
    );

    const brandBlue = PdfColor.fromInt(0xFF2563EB);
    const brandDeep = PdfColor.fromInt(0xFF1E3A5F);
    const fieldBg = PdfColor.fromInt(0xFFF1F5F9);
    const pwBg = PdfColor.fromInt(0xFFFAF5FF);
    const pwBorder = PdfColor.fromInt(0xFF7C3AED);
    const fieldLabel = PdfColor.fromInt(0xFF64748B);
    const noteBg = PdfColor.fromInt(0xFFFFF7ED);
    const noteBorder = PdfColor.fromInt(0xFFEA580C);

    final now = DateTime.now();
    final dateStr = '${_months[now.month]} ${now.day}, ${now.year}';

    for (final u in users) {
      final role = (u['role'] ?? '').toString();
      final isStudent = role == 'STUDENT';
      final cohortNamesRaw = u['cohortNames'];
      final cohortsJoined = cohortNamesRaw is List
          ? cohortNamesRaw
              .whereType<String>()
              .where((n) => n.isNotEmpty)
              .join(' / ')
          : (u['cohortName']?.toString() ?? '');

      final fields = <_PerUserField>[
        _PerUserField(label: l.adminExportColumnRole, value: _localizedRoleName(l, role)),
        if ((u['email'] ?? '').toString().isNotEmpty)
          _PerUserField(label: l.adminExportColumnEmail, value: u['email'].toString()),
        if ((u['username'] ?? '').toString().isNotEmpty)
          _PerUserField(label: l.adminExportColumnUsername, value: u['username'].toString(), mono: true),
        if ((u['phone'] ?? '').toString().isNotEmpty)
          _PerUserField(label: l.adminExportColumnPhone, value: u['phone'].toString(), mono: true),
        if (isStudent && (u['grade'] ?? '').toString().isNotEmpty)
          _PerUserField(label: l.adminExportColumnGrade, value: u['grade'].toString()),
        if (isStudent && cohortsJoined.isNotEmpty)
          _PerUserField(label: l.adminExportColumnCohorts, value: cohortsJoined),
        if ((u['schoolName'] ?? '').toString().isNotEmpty)
          _PerUserField(label: l.adminExportColumnSchool, value: u['schoolName'].toString()),
      ];

      final displayName = _nameForLang(u, _lang);
      final isRtlName = _isRtlText(displayName);

      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(40, 36, 40, 32),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // ── Top metadata strip — icon chip + school + date/by ──
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Container(
                  width: 32,
                  height: 32,
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    color: brandBlue,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Image(cmIcon, fit: pw.BoxFit.contain),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (schoolName.isNotEmpty)
                        pw.Text(
                          schoolName,
                          style: pw.TextStyle(
                            fontSize: 11,
                            color: brandDeep,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      pw.Text(
                        l.adminExportPdfUserDirectory,
                        style: const pw.TextStyle(
                          fontSize: 9,
                          color: fieldLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      dateStr,
                      style: const pw.TextStyle(fontSize: 9, color: fieldLabel),
                    ),
                    pw.Text(
                      l.adminExportPdfBy(exportedBy),
                      style: const pw.TextStyle(fontSize: 9, color: fieldLabel),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            // ── Big centred wordmark ─────────────────────────────────────
            // SizedBox needs BOTH width and height — Container(height: …)
            // alone collapses to zero width in the pdf layout engine, so
            // the image renders as a 0-px invisible blip. logo_light.png
            // is 1530×344 (≈4.45:1), so we lock the height at 52 and let
            // BoxFit.contain pick a width within the available 220.
            pw.Center(
              child: pw.SizedBox(
                width: 230,
                height: 52,
                child: pw.Image(cmWordmark, fit: pw.BoxFit.contain),
              ),
            ),
            pw.SizedBox(height: 22),
            // ── Welcome intro text ───────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(18, 14, 18, 14),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFEFF6FF),
                borderRadius: pw.BorderRadius.circular(12),
                border: pw.Border.all(color: brandBlue, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Welcome to ClassMate',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: brandDeep,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    withPasswords
                        ? 'This sheet contains your ClassMate account details. Use the username and password below to sign in to the ClassMate app on iOS or Android. You can change your password from the app once you\'re in.'
                        : 'This sheet contains your ClassMate account details. Use your username to sign in to the ClassMate app on iOS or Android.',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: brandDeep,
                      lineSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 18),
            // ── BIG name + role chip ─────────────────────────────────────
            pw.Directionality(
              textDirection: isRtlName
                  ? pw.TextDirection.rtl
                  : pw.TextDirection.ltr,
              child: pw.Text(
                displayName.isEmpty ? (u['username']?.toString() ?? '—') : displayName,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 30,
                  fontWeight: pw.FontWeight.bold,
                  color: brandDeep,
                  height: 1.1,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Center(
              child: pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: pw.BoxDecoration(
                  color: brandBlue,
                  borderRadius: pw.BorderRadius.circular(999),
                ),
                child: pw.Text(
                  _localizedRoleName(l, role).toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 18),
            // ── Field cards ──────────────────────────────────────────────
            ...fields.map((f) {
              final isRtl = _isRtlText(f.value);
              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 8),
                padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 10),
                decoration: pw.BoxDecoration(
                  color: fieldBg,
                  borderRadius: pw.BorderRadius.circular(9),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      f.label.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: fieldLabel,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Directionality(
                      textDirection: isRtl
                          ? pw.TextDirection.rtl
                          : pw.TextDirection.ltr,
                      child: pw.Text(
                        f.value,
                        style: pw.TextStyle(
                          fontSize: 13,
                          color: brandDeep,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: f.mono ? 0.5 : 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (withPasswords && (u['tempPassword'] ?? '').toString().isNotEmpty) ...[
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: pw.BoxDecoration(
                  color: pwBg,
                  borderRadius: pw.BorderRadius.circular(9),
                  border: pw.Border.all(color: pwBorder, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      l.adminExportColumnPassword.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: pwBorder,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      u['tempPassword'].toString(),
                      style: pw.TextStyle(
                        fontSize: 20,
                        color: pwBorder,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            pw.SizedBox(height: 10),
            // ── Important / privacy notice ──────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: pw.BoxDecoration(
                color: noteBg,
                borderRadius: pw.BorderRadius.circular(9),
                border: pw.Border.all(color: noteBorder, width: 0.6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'IMPORTANT',
                    style: pw.TextStyle(
                      fontSize: 8,
                      color: noteBorder,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Bullet(
                    text: 'Keep these credentials private. Do not share your password.',
                    style: const pw.TextStyle(fontSize: 9, color: brandDeep, lineSpacing: 2),
                  ),
                  if (withPasswords)
                    pw.Bullet(
                      text: 'Change your password after first sign-in (Settings → Account).',
                      style: const pw.TextStyle(fontSize: 9, color: brandDeep, lineSpacing: 2),
                    ),
                  pw.Bullet(
                    text: 'By using ClassMate you agree to our Terms of Service and Privacy Policy at classmate.app/legal.',
                    style: const pw.TextStyle(fontSize: 9, color: brandDeep, lineSpacing: 2),
                  ),
                  pw.Bullet(
                    text: 'For help, contact your school administrator or support@classmate.app.',
                    style: const pw.TextStyle(fontSize: 9, color: brandDeep, lineSpacing: 2),
                  ),
                ],
              ),
            ),
            pw.Spacer(),
            // ── Footer ──────────────────────────────────────────────────
            pw.Container(
              padding: const pw.EdgeInsets.all(9),
              decoration: pw.BoxDecoration(
                color: const PdfColor.fromInt(0xFFEFF6FF),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: brandBlue, width: 0.5),
              ),
              child: pw.Text(
                l.adminExportPdfFooter,
                style: pw.TextStyle(
                  fontSize: 7.5,
                  color: brandBlue,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ));
    }
    return doc.save();
  }

  Future<Uint8List> _buildPdf(
    List<Map<String, dynamic>> users, {
    required bool withPasswords,
    required String schoolName,
    required String exportedBy,
    required AppLocalizations l,
  }) async {
    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final baseBold = await PdfGoogleFonts.notoSansBold();
    final arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
    final hebrewFont = await PdfGoogleFonts.notoSansHebrewRegular();
    final cmLogo = pw.MemoryImage(
      (await rootBundle.load('assets/images/icon_light.png')).buffer.asUint8List(),
    );

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: baseFont,
        bold: baseBold,
        fontFallback: [arabicFont, hebrewFont],
      ),
    );
    final now = DateTime.now();
    final dateStr = '${_months[now.month]} ${now.day}, ${now.year}';

    const brandBlue = PdfColor.fromInt(0xFF2563EB);
    const brandLight = PdfColor.fromInt(0xFFEFF6FF);
    const headerBg = PdfColor.fromInt(0xFF1E3A5F);
    const rowAlt = PdfColor.fromInt(0xFFF8FAFD);
    const pwColor = PdfColor.fromInt(0xFF7C3AED);

    final cols = withPasswords
        ? [
            _Col(l.adminExportColumnIndex, 0.03),
            _Col(l.adminExportColumnName, 0.13),
            _Col(l.adminExportColumnRole, 0.07),
            _Col(l.adminExportColumnEmail, 0.13),
            _Col(l.adminExportColumnUsername, 0.10),
            _Col(l.adminExportColumnPhone, 0.10),
            _Col(l.adminExportColumnGrade, 0.05),
            _Col(l.adminExportColumnCohorts, 0.12),
            _Col(l.adminExportColumnSchool, 0.12),
            _Col(l.adminExportColumnPassword, 0.15),
          ]
        : [
            _Col(l.adminExportColumnIndex, 0.04),
            _Col(l.adminExportColumnName, 0.16),
            _Col(l.adminExportColumnRole, 0.08),
            _Col(l.adminExportColumnEmail, 0.16),
            _Col(l.adminExportColumnUsername, 0.11),
            _Col(l.adminExportColumnPhone, 0.11),
            _Col(l.adminExportColumnGrade, 0.05),
            _Col(l.adminExportColumnCohorts, 0.15),
            _Col(l.adminExportColumnSchool, 0.14),
          ];

    final fmt = PdfPageFormat.a4.landscape;
    final pageW = fmt.availableWidth;

    doc.addPage(pw.MultiPage(
      pageFormat: fmt,
      margin: const pw.EdgeInsets.all(24),
      build: (ctx) => [
        pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: pw.BoxDecoration(color: brandBlue, borderRadius: pw.BorderRadius.circular(12)),
          child: pw.Row(
            children: [
              pw.Container(
                width: 44,
                height: 44,
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(10)),
                alignment: pw.Alignment.center,
                child: pw.Image(cmLogo, fit: pw.BoxFit.contain),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('ClassMate', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                    if (schoolName.isNotEmpty)
                      pw.Text(schoolName, style: const pw.TextStyle(fontSize: 11, color: PdfColor(1, 1, 1, 0.7))),
                  ],
                ),
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(l.adminExportPdfUserDirectory, style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                  pw.Text(dateStr, style: const pw.TextStyle(fontSize: 10, color: PdfColor(1, 1, 1, 0.7))),
                  pw.Text(l.adminExportPdfBy(exportedBy), style: const pw.TextStyle(fontSize: 10, color: PdfColor(1, 1, 1, 0.7))),
                  pw.Text(l.adminExportPdfUsersCount(users.length), style: const pw.TextStyle(fontSize: 10, color: PdfColor(1, 1, 1, 0.7))),
                ],
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 14),
        pw.Table(
          columnWidths: {for (var i = 0; i < cols.length; i++) i: pw.FixedColumnWidth(cols[i].fraction * pageW)},
          children: [
            pw.TableRow(
              decoration: pw.BoxDecoration(color: headerBg, borderRadius: const pw.BorderRadius.only(topLeft: pw.Radius.circular(8), topRight: pw.Radius.circular(8))),
              children: cols.map((c) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                child: pw.Text(c.label, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              )).toList(),
            ),
            ...users.asMap().entries.map((entry) {
              final i = entry.key;
              final u = entry.value;
              final cohortNamesRaw = u['cohortNames'];
              final cohortsJoined = cohortNamesRaw is List
                  ? cohortNamesRaw.whereType<String>().where((n) => n.isNotEmpty).join(' / ')
                  : (u['cohortName']?.toString() ?? '');
              final role = (u['role'] ?? '').toString();
              final isStudent = role == 'STUDENT';
              final cells = withPasswords
                  ? [
                      '${i + 1}',
                      _nameForLang(u, _lang),
                      _localizedRoleName(l, role),
                      u['email'] ?? '',
                      u['username'] ?? '',
                      u['phone'] ?? '',
                      isStudent ? '${u['grade'] ?? ''}' : '—',
                      isStudent ? cohortsJoined : '—',
                      u['schoolName'] ?? '',
                      u['tempPassword'] ?? '',
                    ]
                  : [
                      '${i + 1}',
                      _nameForLang(u, _lang),
                      _localizedRoleName(l, role),
                      u['email'] ?? '',
                      u['username'] ?? '',
                      u['phone'] ?? '',
                      isStudent ? '${u['grade'] ?? ''}' : '—',
                      isStudent ? cohortsJoined : '—',
                      u['schoolName'] ?? '',
                    ];
              return pw.TableRow(
                decoration: pw.BoxDecoration(color: i.isOdd ? rowAlt : PdfColors.white),
                children: cells.asMap().entries.map((ce) {
                  final isPw = withPasswords && ce.key == cells.length - 1;
                  final text = ce.value.toString();
                  // Arabic + Hebrew need explicit RTL direction or the PDF
                  // renderer treats them as LTR and the glyph shaper omits
                  // proper letter-joining ("separate letters that don't
                  // spell words" per the bug report). Detection here
                  // catches any cell whose content is dominated by RTL
                  // code points (Arabic U+0600-06FF, Hebrew U+0590-05FF).
                  final isRtl = _isRtlText(text);
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    child: pw.Directionality(
                      textDirection: isRtl
                          ? pw.TextDirection.rtl
                          : pw.TextDirection.ltr,
                      child: pw.Text(
                        text,
                        textDirection: isRtl
                            ? pw.TextDirection.rtl
                            : pw.TextDirection.ltr,
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: isPw ? pwColor : PdfColors.black,
                          fontWeight: isPw ? pw.FontWeight.bold : pw.FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Container(
          padding: const pw.EdgeInsets.all(10),
          decoration: pw.BoxDecoration(color: brandLight, borderRadius: pw.BorderRadius.circular(8), border: pw.Border.all(color: brandBlue, width: 0.5)),
          child: pw.Text(
            l.adminExportPdfFooter,
            style: pw.TextStyle(fontSize: 8, color: brandBlue, fontStyle: pw.FontStyle.italic),
          ),
        ),
      ],
    ));
    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.adminExportOptionsTitle, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    Text(l.adminExportUsersSelected(widget.userCount), style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: _includePasswords ? cs.errorContainer.withValues(alpha: 0.2) : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _includePasswords ? cs.error.withValues(alpha: 0.4) : cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: SwitchListTile.adaptive(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              title: Text(
                l.adminExportIncludePasswords,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _includePasswords ? cs.error : cs.onSurface,
                ),
              ),
              subtitle: Text(
                _includePasswords ? l.adminExportPasswordsOn : l.adminExportPasswordsOff,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: _includePasswords ? cs.error : cs.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              value: _includePasswords,
              activeColor: cs.error,
              onChanged: (v) => setState(() => _includePasswords = v),
            ),
          ),
          const SizedBox(height: 10),
          // ── Each-user-alone toggle ────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: SwitchListTile.adaptive(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              title: Text(
                'Each user alone',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                _eachUserAlone
                    ? 'One full page per user, big readable card layout.'
                    : 'Compact table — every user is a row.',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant, height: 1.3),
              ),
              value: _eachUserAlone,
              onChanged: (v) => setState(() {
                _eachUserAlone = v;
                if (!v) _separateFiles = false;
              }),
            ),
          ),
          if (_eachUserAlone) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.4)),
              ),
              child: SwitchListTile.adaptive(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                title: Text(
                  _separateFiles
                      ? 'Separate PDF per user'
                      : 'Single PDF, one page per user',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  _separateFiles
                      ? 'You\'ll share ${widget.userCount} PDF file${widget.userCount == 1 ? "" : "s"} at once — each user gets their own.'
                      : 'Everyone in one PDF, each on their own page.',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant, height: 1.3),
                ),
                value: _separateFiles,
                onChanged: (v) => setState(() => _separateFiles = v),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            l.adminExportLanguageLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          // SingleChildScrollView lets the 5 chips fit on narrow phones
          // without overflowing — the segment row would otherwise hard-
          // wrap or shrink labels into illegible glyphs.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in const [
                  ('en', '🇬🇧', 'EN'),
                  ('ar', '🇸🇦', 'AR'),
                  ('he', '🇮🇱', 'HE'),
                  ('fr', '🇫🇷', 'FR'),
                  ('ru', '🇷🇺', 'RU'),
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text('${entry.$2}  ${entry.$3}'),
                      selected: _lang == entry.$1,
                      onSelected: (_) => setState(() => _lang = entry.$1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _exporting ? null : _exportCsv,
                  icon: _exporting
                      ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.table_chart_rounded, size: 16),
                  label: Text(l.adminExportCsvButton),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _exporting ? null : _exportPdf,
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF7C3AED), foregroundColor: Colors.white),
                  icon: _exporting
                      ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: Text(l.adminExportPdfButton),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _Col {
  const _Col(this.label, this.fraction);
  final String label;
  final double fraction;
}

class _PerUserField {
  const _PerUserField({required this.label, required this.value, this.mono = false});
  final String label;
  final String value;
  final bool mono;
}

const _months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

String _esc(String v) {
  if (v.contains(',') || v.contains('"') || v.contains('\n')) {
    return '"${v.replaceAll('"', '""')}"';
  }
  return v;
}

// Returns true if the string's strong characters are predominantly
// right-to-left (Arabic U+0600-06FF, Hebrew U+0590-05FF). Used by the
// PDF row renderer to set TextDirection per cell so glyph shaping
// joins letters correctly. Numbers + Latin punctuation alone aren't
// strong characters and don't tip the balance either way.
bool _isRtlText(String s) {
  if (s.isEmpty) return false;
  var rtl = 0;
  var ltr = 0;
  for (final codeUnit in s.codeUnits) {
    if ((codeUnit >= 0x0590 && codeUnit <= 0x05FF) ||
        (codeUnit >= 0x0600 && codeUnit <= 0x06FF) ||
        (codeUnit >= 0x0750 && codeUnit <= 0x077F) ||
        (codeUnit >= 0xFB50 && codeUnit <= 0xFDFF) ||
        (codeUnit >= 0xFE70 && codeUnit <= 0xFEFF)) {
      rtl++;
    } else if ((codeUnit >= 0x0041 && codeUnit <= 0x005A) ||
        (codeUnit >= 0x0061 && codeUnit <= 0x007A) ||
        (codeUnit >= 0x00C0 && codeUnit <= 0x024F) ||
        (codeUnit >= 0x0400 && codeUnit <= 0x04FF)) {
      ltr++;
    }
  }
  return rtl > ltr;
}

String _localizedRoleName(AppLocalizations l, String role) {
  switch (role.toUpperCase()) {
    case 'STUDENT':
      return l.adminExportRoleStudent;
    case 'TEACHER':
      return l.adminExportRoleTeacher;
    case 'PARENT':
      return l.adminExportRoleParent;
    case 'SECRETARY':
      return l.adminExportRoleSecretary;
    case 'ADMIN':
      return l.adminExportRoleAdmin;
    default:
      return role;
  }
}
