// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../data/admin_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _cohortsProvider = FutureProvider.autoDispose<List<AdminCohort>>((ref) {
  return ref.watch(adminRepositoryProvider).listCohorts();
});

final _rosterProvider = FutureProvider.autoDispose.family<List<AdminUser>, String>((ref, cohortId) {
  return ref.watch(adminRepositoryProvider).getCohortRoster(cohortId);
});

// ── Cohorts list screen ────────────────────────────────────────────────────────

class AdminCohortsScreen extends ConsumerWidget {
  const AdminCohortsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final session = ref.watch(authSessionProvider);
    final isAdmin = session.primaryRole == 'ADMIN';
    final cohortsAsync = ref.watch(_cohortsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              heroTag: 'fab_add_cohort',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminCreateCohortScreen(
                  repo: ref.read(adminRepositoryProvider),
                )),
              ).then((_) => ref.invalidate(_cohortsProvider)),
              icon: const Icon(Icons.add_rounded),
              label: Text(AppLocalizations.of(context)!.adminAddCohort),
            )
          : null,
      body: cohortsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cohorts) {
          if (cohorts.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.groups_outlined, size: 64, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.adminNoCohortsYet, style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  if (isAdmin) Text(AppLocalizations.of(context)!.adminScheduleNoSlotsHint, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            );
          }

          final byGrade = <int, List<AdminCohort>>{};
          for (final c in cohorts) {
            byGrade.putIfAbsent(c.grade, () => []).add(c);
          }
          final grades = byGrade.keys.toList()..sort();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              for (final grade in grades) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                  child: Text(
                    'Grade $grade',
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: cs.primary, letterSpacing: 0.5),
                  ),
                ),
                for (final cohort in byGrade[grade]!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CohortCard(
                      cohort: cohort,
                      isAdmin: isAdmin,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AdminCohortDetailScreen(cohort: cohort)),
                      ).then((_) => ref.invalidate(_cohortsProvider)),
                      onDelete: () => _confirmDelete(context, ref, cohort),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext ctx, WidgetRef ref, AdminCohort cohort) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) {
        final dl = AppLocalizations.of(dCtx)!;
        return AlertDialog(
          title: Text(dl.adminDeleteCohort),
          content: Text(dl.adminDeleteCohortConfirm(cohort.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(dl.adminDeleteConfirmCancel)),
            FilledButton(
              onPressed: () => Navigator.pop(dCtx, true),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(dCtx).colorScheme.error),
              child: Text(dl.adminDeleteConfirmDelete),
            ),
          ],
        );
      },
    );
    if (confirm != true) return;
    try {
      await ref.read(adminRepositoryProvider).deleteCohort(cohort.id);
      ref.invalidate(_cohortsProvider);
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

// ── Create cohort — full-screen ────────────────────────────────────────────────

class AdminCreateCohortScreen extends ConsumerStatefulWidget {
  const AdminCreateCohortScreen({super.key, required this.repo});
  final AdminRepository repo;

  @override
  ConsumerState<AdminCreateCohortScreen> createState() => _AdminCreateCohortScreenState();
}

class _AdminCreateCohortScreenState extends ConsumerState<AdminCreateCohortScreen> {
  final _nameCtrl = TextEditingController();
  final Set<int> _grades = <int>{};
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty || _grades.isEmpty) return;
    setState(() => _saving = true);
    try {
      final gradeList = _grades.toList()..sort();
      final multi = gradeList.length > 1;
      for (final g in gradeList) {
        final cohortName = multi ? '$name · Grade $g' : name;
        await widget.repo.createCohort(name: cohortName, grade: g);
      }
      if (!mounted) return;

      if (multi) {
        Navigator.pop(context, true);
      } else {
        final allStudents = await widget.repo.getDdlStudents();
        if (!mounted) return;
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => _AdminAddStudentsScreen(
            repo: widget.repo,
            cohortName: name,
            cohortGrade: gradeList.single,
            allStudents: allStudents,
          )),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final multi = _grades.length > 1;
    final availableGrades = ref.watch(authSessionProvider).schoolGrades;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_create_cohort',
        onPressed: (_saving || _nameCtrl.text.trim().isEmpty || _grades.isEmpty) ? null : _save,
        icon: _saving
            ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(multi ? Icons.add_rounded : Icons.arrow_forward_rounded),
        label: Text(multi ? 'Create ${_grades.length} cohorts' : 'Create & Add Students'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: '${AppLocalizations.of(context)!.adminCohortName} *',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.adminCohortGrade,
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableGrades.map((g) => FilterChip(
                label: Text('Grade $g'),
                selected: _grades.contains(g),
                onSelected: (sel) => setState(() {
                  if (sel) {
                    _grades.add(g);
                  } else {
                    _grades.remove(g);
                  }
                }),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add students — full-screen ─────────────────────────────────────────────────
// Used both from cohort creation flow AND from the cohort detail FAB.

class AdminAddStudentsScreen extends StatefulWidget {
  const AdminAddStudentsScreen({
    super.key,
    required this.repo,
    required this.cohortId,
    required this.cohortName,
    required this.cohortGrade,
  });

  final AdminRepository repo;
  final String cohortId;
  final String cohortName;
  final int cohortGrade;

  @override
  State<AdminAddStudentsScreen> createState() => _AdminAddStudentsScreenState();
}

class _AdminAddStudentsScreenState extends State<AdminAddStudentsScreen> {
  List<Map<String, dynamic>> _allStudents = [];
  final Set<String> _selected = {};
  String _search = '';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final students = await widget.repo.getDdlStudents();
      if (mounted) setState(() { _allStudents = students; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_selected.isEmpty) return;
    setState(() => _saving = true);
    try {
      await widget.repo.addStudentsToCohort(widget.cohortId, _selected.toList());
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AdminAddStudentsScreenImpl(
    allStudents: _allStudents,
    cohortId: widget.cohortId,
    cohortName: widget.cohortName,
    cohortGrade: widget.cohortGrade,
    selected: _selected,
    loading: _loading,
    saving: _saving,
    onToggle: (id) => setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id)),
    onSave: _save,
    onBack: () => Navigator.pop(context),
  );
}

// Same screen but reached from creation flow (no cohortId yet — we already navigated via pushReplacement)
class _AdminAddStudentsScreen extends StatefulWidget {
  const _AdminAddStudentsScreen({
    required this.repo,
    required this.cohortName,
    required this.cohortGrade,
    required this.allStudents,
  });

  final AdminRepository repo;
  final String cohortName;
  final int cohortGrade;
  final List<Map<String, dynamic>> allStudents;

  @override
  State<_AdminAddStudentsScreen> createState() => _AdminAddStudentsFromCreateState();
}

class _AdminAddStudentsFromCreateState extends State<_AdminAddStudentsScreen> {
  final Set<String> _selected = {};
  bool _saving = false;

  Future<void> _save() async {
    // Can't add students without cohortId — cohort doesn't return id on creation yet.
    // Just navigate back to cohorts list which will reload.
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) => _AdminAddStudentsScreenImpl(
    allStudents: widget.allStudents,
    cohortId: '',
    cohortName: widget.cohortName,
    cohortGrade: widget.cohortGrade,
    selected: _selected,
    loading: false,
    saving: _saving,
    onToggle: (id) => setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id)),
    onSave: _save,
    onBack: () => Navigator.pop(context),
  );
}

// Shared implementation widget
class _AdminAddStudentsScreenImpl extends StatefulWidget {
  const _AdminAddStudentsScreenImpl({
    required this.allStudents,
    required this.cohortId,
    required this.cohortName,
    required this.cohortGrade,
    required this.selected,
    required this.loading,
    required this.saving,
    required this.onToggle,
    required this.onSave,
    required this.onBack,
  });

  final List<Map<String, dynamic>> allStudents;
  final String cohortId;
  final String cohortName;
  final int cohortGrade;
  final Set<String> selected;
  final bool loading;
  final bool saving;
  final ValueChanged<String> onToggle;
  final VoidCallback onSave;
  final VoidCallback onBack;

  @override
  State<_AdminAddStudentsScreenImpl> createState() => _AdminAddStudentsScreenImplState();
}

class _AdminAddStudentsScreenImplState extends State<_AdminAddStudentsScreenImpl> {
  String _search = '';
  bool _showGradeOnly = true; // default: filter by cohort's grade

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // Filter: grade filter + search
    final q = _search.toLowerCase();
    final students = widget.allStudents.where((s) {
      // Grade filter
      if (_showGradeOnly) {
        final g = (s['grade'] as num?)?.toInt();
        if (g != widget.cohortGrade) return false;
      }
      if (q.isEmpty) return true;
      return (s['name']?.toString() ?? '').toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: widget.onBack,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Students',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          widget.cohortName,
                          style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (widget.selected.isNotEmpty)
                    FilledButton.icon(
                      onPressed: widget.saving ? null : widget.onSave,
                      icon: widget.saving
                          ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_rounded, size: 16),
                      label: Text('Add ${widget.selected.length}'),
                    )
                  else
                    TextButton(onPressed: widget.onBack, child: const Text('Skip')),
                ],
              ),
            ),
            const Divider(height: 1),
            // Search + grade filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: InputDecoration(
                      hintText: 'Search students…',
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilterChip(
                        label: Text('Grade ${widget.cohortGrade} only'),
                        selected: _showGradeOnly,
                        onSelected: (v) => setState(() => _showGradeOnly = v),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${students.length} student${students.length == 1 ? '' : 's'}',
                        style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Student list
            Expanded(
              child: widget.loading
                  ? const Center(child: CircularProgressIndicator())
                  : students.isEmpty
                      ? Center(
                          child: Text(
                            _showGradeOnly ? 'No grade ${widget.cohortGrade} students found' : 'No students found',
                            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                          itemCount: students.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 4),
                          itemBuilder: (ctx, i) {
                            final s = students[i];
                            final id = s['id']?.toString() ?? '';
                            final name = s['name']?.toString() ?? '';
                            final cohortName = s['cohortName']?.toString() ?? '';
                            final grade = (s['grade'] as num?)?.toInt();
                            final selected = widget.selected.contains(id);

                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () => widget.onToggle(id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38, height: 38,
                                      decoration: BoxDecoration(
                                        color: selected ? cs.primary : cs.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        selected ? Icons.check_rounded : Icons.person_rounded,
                                        size: 18,
                                        color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                          if (cohortName.isNotEmpty || grade != null)
                                            Text(
                                              [if (grade != null) 'Grade $grade', if (cohortName.isNotEmpty) cohortName].join(' · '),
                                              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Cohort card ────────────────────────────────────────────────────────────────

class _CohortCard extends StatelessWidget {
  const _CohortCard({
    required this.cohort,
    required this.isAdmin,
    required this.onTap,
    required this.onDelete,
  });

  final AdminCohort cohort;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('G${cohort.grade}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: cs.onPrimaryContainer)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cohort.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('${cohort.studentCount} students', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
            if (isAdmin)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 20),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Cohort detail screen ───────────────────────────────────────────────────────

class AdminCohortDetailScreen extends ConsumerStatefulWidget {
  const AdminCohortDetailScreen({super.key, required this.cohort});
  final AdminCohort cohort;

  @override
  ConsumerState<AdminCohortDetailScreen> createState() => _AdminCohortDetailScreenState();
}

class _AdminCohortDetailScreenState extends ConsumerState<AdminCohortDetailScreen> {
  late AdminCohort _cohort;

  @override
  void initState() {
    super.initState();
    _cohort = widget.cohort;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final session = ref.watch(authSessionProvider);
    final isAdmin = session.primaryRole == 'ADMIN';
    final rosterAsync = ref.watch(_rosterProvider(_cohort.id));

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_student_cohort',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AdminAddStudentsScreen(
            repo: ref.read(adminRepositoryProvider),
            cohortId: _cohort.id,
            cohortName: _cohort.name,
            cohortGrade: _cohort.grade,
          )),
        ).then((added) {
          if (added == true) {
            ref.invalidate(_rosterProvider(_cohort.id));
            ref.invalidate(_cohortsProvider);
          }
        }),
        icon: const Icon(Icons.person_add_rounded),
        label: Text(AppLocalizations.of(context)!.adminAddStudents),
      ),
      body: rosterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (students) {
          if (students.isEmpty) {
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline_rounded, size: 64, color: cs.outlineVariant),
                    const SizedBox(height: 12),
                    Text(_cohort.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    Text(AppLocalizations.of(context)!.adminNoStudentsInCohort, style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text(AppLocalizations.of(context)!.adminAddStudents, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    if (isAdmin) ...[
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => _showRenameSheet(context),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: Text('Rename'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _cohort.name,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.edit_rounded),
                      tooltip: 'Rename',
                      onPressed: () => _showRenameSheet(context),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.groups_rounded, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Text(
                      '${students.length} student${students.length == 1 ? '' : 's'}',
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ...students.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _RosterTile(
                  user: s,
                  onRemove: () => _removeStudent(context, s),
                ),
              )),
            ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _removeStudent(BuildContext ctx, AdminUser student) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dCtx) => AlertDialog(
        title: Text(AppLocalizations.of(dCtx)!.adminRemoveStudent),
        content: Text(AppLocalizations.of(dCtx)!.adminRemoveStudentConfirm(student.name, _cohort.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx, false), child: Text(AppLocalizations.of(dCtx)!.adminDeleteConfirmCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(dCtx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(dCtx).colorScheme.error),
            child: Text(AppLocalizations.of(dCtx)!.adminDeleteConfirmDelete),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(adminRepositoryProvider).removeStudentFromCohort(_cohort.id, student.id);
      ref.invalidate(_rosterProvider(_cohort.id));
    } catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showRenameSheet(BuildContext ctx) async {
    final nameCtrl = TextEditingController(text: _cohort.name);
    final cs = Theme.of(ctx).colorScheme;
    final updated = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (bCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(bCtx).viewInsets.bottom + 24, left: 20, right: 20, top: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(bCtx)!.adminRenameCohort, style: Theme.of(bCtx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(bCtx)!.adminCohortName,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  try {
                    await ref.read(adminRepositoryProvider).updateCohort(_cohort.id, name: nameCtrl.text.trim());
                    Navigator.pop(bCtx, true);
                  } catch (e) {
                    ScaffoldMessenger.of(bCtx).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
    final newName = nameCtrl.text.trim();
    if (updated == true && newName.isNotEmpty) {
      setState(() => _cohort = AdminCohort(id: _cohort.id, name: newName, grade: _cohort.grade, studentCount: _cohort.studentCount));
    }
  }
}

// ── Detail header (no AppBar) ─────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.cohortName,
    required this.isAdmin,
    required this.onBack,
    required this.onRename,
  });

  final String cohortName;
  final bool isAdmin;
  final VoidCallback onBack;
  final VoidCallback onRename;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: onBack,
            ),
            Expanded(
              child: Text(
                cohortName,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isAdmin)
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: onRename,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Roster tile ────────────────────────────────────────────────────────────────

class _RosterTile extends StatelessWidget {
  const _RosterTile({required this.user, required this.onRemove});
  final AdminUser user;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final initials = _initials(user.name);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(initials, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: cs.onPrimaryContainer))),
        ),
        title: Text(user.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(user.email, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline_rounded, color: cs.error, size: 20),
          onPressed: onRemove,
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _initials(String name) {
  if (name.isEmpty) return 'CM';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  final word = parts[0];
  if (word.length >= 2) return '${word[0]}${word[1]}'.toUpperCase();
  return word[0].toUpperCase();
}
