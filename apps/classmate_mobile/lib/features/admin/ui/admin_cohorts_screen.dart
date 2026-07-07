// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/nav/glass_back_button.dart';
import '../../../ui/widgets/glass_search_field.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
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
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.commonErrorWith(e))),
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

          // Group by primary grade (grades.first). Multi-grade cohorts appear
          // once, under their lowest grade — keeps the list to one row per
          // cohort while still being roughly sorted by grade.
          final byGrade = <int, List<AdminCohort>>{};
          for (final c in cohorts) {
            final primary = c.grades.isEmpty ? c.grade : c.grades.first;
            byGrade.putIfAbsent(primary, () => []).add(c);
          }
          final grades = byGrade.keys.toList()..sort();

          return ListView(
            padding: EdgeInsets.fromLTRB(
                16, 8 + MediaQuery.paddingOf(context).top, 16, 120),
            children: [
              for (final grade in grades) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                  child: Text(
                    AppLocalizations.of(context)!.adminCohortGradeFormat(grade.toString()),
                    style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: cs.primary, letterSpacing: 0.5),
                  ),
                ),
                for (final cohort in byGrade[grade]!)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _CohortCard(
                      cohort: cohort,
                      isAdmin: isAdmin,
                      // Root navigator so the detail screen covers the shell
                      // (its own AppBar takes over). MaterialPageRoute (no
                      // fullscreenDialog) preserves iOS edge-swipe-back.
                      onTap: () => Navigator.of(context, rootNavigator: true).push(
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
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(AppLocalizations.of(ctx)!.commonErrorWith(e))));
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
  bool _homeroom = false;
  String? _homeroomTeacherId;
  List<Map<String, dynamic>> _teachers = const [];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() async {
      try {
        final t = await widget.repo.getDdlTeachers();
        if (mounted) setState(() => _teachers = t);
      } catch (_) {}
    });
  }

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
      await widget.repo.createCohort(
        name: name,
        grades: gradeList,
        homeroomTeacherId: _homeroom ? _homeroomTeacherId : null,
      );
      if (!mounted) return;

      final allStudents = await widget.repo.getDdlStudents();
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => _AdminAddStudentsScreen(
          repo: widget.repo,
          cohortName: name,
          cohortGrades: gradeList,
          allStudents: allStudents,
        )),
      );
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
    final availableGrades = ref.watch(authSessionProvider).schoolGrades;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_create_cohort',
        onPressed: (_saving || _nameCtrl.text.trim().isEmpty || _grades.isEmpty) ? null : _save,
        icon: _saving
            ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.arrow_forward_rounded),
        label: Text(AppLocalizations.of(context)!.adminCreateAndAddStudents),
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
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.adminCohortGrade,
              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableGrades.map((g) => FilterChip(
                label: Text(AppLocalizations.of(context)!.adminCohortGradeFormat(g.toString())),
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
            const SizedBox(height: 20),
            // Homeroom class → pick the homeroom teacher (مربّي/ة الصف).
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _homeroom,
              title: Text(AppLocalizations.of(context)!.cohortHomeroomLabel),
              subtitle: Text(
                AppLocalizations.of(context)!.cohortHomeroomHint,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              onChanged: (v) => setState(() => _homeroom = v),
            ),
            if (_homeroom) ...[
              const SizedBox(height: 8),
              LiquidGlassSelectField<String>(
                label: AppLocalizations.of(context)!.cohortHomeroomTeacher,
                hint: AppLocalizations.of(context)!.cohortHomeroomTeacher,
                value: _homeroomTeacherId,
                items: _teachers
                    .map((t) => LiquidGlassDropdownItem(value: '${t['id']}', label: '${t['name'] ?? ''}'))
                    .toList(),
                onChanged: (id) => setState(() => _homeroomTeacherId = id),
              ),
            ],
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
    required this.cohortGrades,
  });

  final AdminRepository repo;
  final String cohortId;
  final String cohortName;
  final List<int> cohortGrades;

  @override
  State<AdminAddStudentsScreen> createState() => _AdminAddStudentsScreenState();
}

class _AdminAddStudentsScreenState extends State<AdminAddStudentsScreen> {
  List<Map<String, dynamic>> _allStudents = [];
  final Set<String> _selected = {};
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.commonErrorWith(e))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _AdminAddStudentsScreenImpl(
    allStudents: _allStudents,
    cohortId: widget.cohortId,
    cohortName: widget.cohortName,
    cohortGrades: widget.cohortGrades,
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
    required this.cohortGrades,
    required this.allStudents,
  });

  final AdminRepository repo;
  final String cohortName;
  final List<int> cohortGrades;
  final List<Map<String, dynamic>> allStudents;

  @override
  State<_AdminAddStudentsScreen> createState() => _AdminAddStudentsFromCreateState();
}

class _AdminAddStudentsFromCreateState extends State<_AdminAddStudentsScreen> {
  final Set<String> _selected = {};
  final bool _saving = false;

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
    cohortGrades: widget.cohortGrades,
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
    required this.cohortGrades,
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
  final List<int> cohortGrades;
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
  bool _showGradeOnly = true; // default: filter by cohort's grade(s)

  String _gradeChipLabelOf(AppLocalizations l) {
    final gs = widget.cohortGrades;
    if (gs.length <= 1) return l.adminCohortsGradeOnly(gs.isEmpty ? '?' : gs.first.toString());
    final sorted = [...gs]..sort();
    final isRange = sorted.last - sorted.first == sorted.length - 1;
    return isRange
        ? l.adminCohortsGradeRangeOnly(sorted.first, sorted.last)
        : l.adminCohortsGradeOnly(sorted.join(', '));
  }

  String get _emptyMsg {
    final gs = widget.cohortGrades;
    if (gs.length <= 1) return 'No grade ${gs.isEmpty ? '?' : gs.first} students found';
    return 'No students found in this cohort\'s grades';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    final gradeSet = widget.cohortGrades.toSet();

    // Filter: grade filter + search
    final q = _search.toLowerCase();
    final students = widget.allStudents.where((s) {
      // Grade filter
      if (_showGradeOnly) {
        final g = (s['grade'] as num?)?.toInt();
        if (g == null || !gradeSet.contains(g)) return false;
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
                  GlassBackButton(onPressed: widget.onBack),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.adminAddStudentsTitle,
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
                      label: Text(l.commonAddCount(widget.selected.length)),
                    )
                  else
                    TextButton(onPressed: widget.onBack, child: Text(AppLocalizations.of(context)!.adminSkipAdding)),
                ],
              ),
            ),
            const Divider(height: 1),
            // Search + grade filter
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Column(
                children: [
                  GlassSearchField(
                    hintText: AppLocalizations.of(context)!.adminScheduleSearchStudents,
                    onChanged: (v) => setState(() => _search = v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilterChip(
                        label: Text(_gradeChipLabelOf(l)),
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
                            _showGradeOnly ? _emptyMsg : 'No students found',
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
                            // Already-in-cohort check: the DDL returns
                            // multi-cohort membership via `cohortIds`; legacy
                            // single `cohortId` covers older rows. Treat the
                            // current cohort id as present in either.
                            final cidList = (s['cohortIds'] as List?)
                                    ?.map((e) => e.toString())
                                    .toList() ??
                                const <String>[];
                            final legacyCid = s['cohortId']?.toString() ?? '';
                            final alreadyInCohort = widget.cohortId.isNotEmpty &&
                                (cidList.contains(widget.cohortId) ||
                                    legacyCid == widget.cohortId);
                            final selected = widget.selected.contains(id);

                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              // Tapping a member who's already in is a no-op;
                              // the badge tells the admin why.
                              onTap: alreadyInCohort ? null : () => widget.onToggle(id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: alreadyInCohort
                                      ? cs.surfaceContainerLow.withValues(alpha: 0.6)
                                      : selected
                                          ? cs.primaryContainer
                                          : cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: alreadyInCohort
                                        ? cs.outlineVariant.withValues(alpha: 0.4)
                                        : selected
                                            ? cs.primary.withValues(alpha: 0.4)
                                            : cs.outlineVariant.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38, height: 38,
                                      decoration: BoxDecoration(
                                        color: alreadyInCohort
                                            ? cs.tertiaryContainer
                                            : selected
                                                ? cs.primary
                                                : cs.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        alreadyInCohort
                                            ? Icons.check_rounded
                                            : selected
                                                ? Icons.check_rounded
                                                : Icons.person_rounded,
                                        size: 18,
                                        color: alreadyInCohort
                                            ? cs.onTertiaryContainer
                                            : selected
                                                ? cs.onPrimary
                                                : cs.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: alreadyInCohort
                                                  ? cs.onSurfaceVariant
                                                  : null,
                                            ),
                                          ),
                                          if (cohortName.isNotEmpty || grade != null)
                                            Text(
                                              [if (grade != null) 'Grade $grade', if (cohortName.isNotEmpty) cohortName].join(' · '),
                                              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (alreadyInCohort)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: cs.tertiaryContainer,
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Text(
                                          AppLocalizations.of(context)!.adminInCohortBadge,
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: cs.onTertiaryContainer,
                                            fontWeight: FontWeight.w700,
                                          ),
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
    final l = AppLocalizations.of(context)!;
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
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    cohort.gradeChip,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: cs.onPrimaryContainer),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cohort.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(l.cohortStudentsCount(cohort.studentCount), style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
            if (isAdmin)
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: cs.error, size: 20),
                tooltip: l.a11yDelete,
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
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start: 8),
          child: Center(
            child: GlassBackButton(
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        title: Text(
          _cohort.name,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              tooltip: AppLocalizations.of(context)!.adminRenameCohort,
              onPressed: () => _showRenameSheet(context),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_student_cohort',
        // Root navigator so AddStudents covers the shell's AppBar + bottom
        // nav entirely — matches the Add User / Edit User full-screen
        // pattern the rest of the admin flows use.
        onPressed: () => Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(builder: (_) => AdminAddStudentsScreen(
            repo: ref.read(adminRepositoryProvider),
            cohortId: _cohort.id,
            cohortName: _cohort.name,
            cohortGrades: _cohort.grades,
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
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.commonErrorWith(e))),
        data: (students) {
          if (students.isEmpty) {
            // AppBar already shows the cohort name + rename action; keep the
            // empty-state body focused on the "no students" affordance.
            return SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline_rounded, size: 64, color: cs.outlineVariant),
                    const SizedBox(height: 12),
                    Text(AppLocalizations.of(context)!.adminNoStudentsInCohort, style: theme.textTheme.titleSmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text(AppLocalizations.of(context)!.adminAddStudents, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            );
          }

          // AppBar already carries the cohort name + rename — body skips
          // the duplicate title row and jumps straight into the roster.
          return SafeArea(
            child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
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
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(AppLocalizations.of(ctx)!.commonErrorWith(e))));
    }
  }

  Future<void> _showRenameSheet(BuildContext ctx) async {
    final l = AppLocalizations.of(ctx)!;
    final cs = Theme.of(ctx).colorScheme;
    final nameCtrl = TextEditingController(text: _cohort.name);
    final grades = <int>{..._cohort.grades};
    final availableGrades = ref.read(authSessionProvider).schoolGrades;
    String? homeroomTeacherId; // null = leave unchanged
    // Load teachers for the homeroom picker (best-effort).
    List<Map<String, dynamic>> teachers = const [];
    try {
      teachers = await ref.read(adminRepositoryProvider).getDdlTeachers();
    } catch (_) {}
    if (!ctx.mounted) return;

    final updated = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (bCtx) => StatefulBuilder(
        builder: (bCtx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(bCtx).viewInsets.bottom + 24, left: 20, right: 20, top: 0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.adminRenameCohort, style: Theme.of(bCtx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: l.adminCohortName,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(l.navGrades, style: Theme.of(bCtx).textTheme.labelLarge),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableGrades
                      .map((g) => FilterChip(
                            label: Text(l.adminCohortGradeFormat(g.toString())),
                            selected: grades.contains(g),
                            onSelected: (sel) => setSheet(() => sel ? grades.add(g) : grades.remove(g)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Homeroom teacher (مربّي/ة الصف) — drives the certificates access.
                LiquidGlassSelectField<String>(
                  label: l.cohortHomeroomTeacher,
                  hint: l.cohortHomeroomTeacher,
                  value: homeroomTeacherId,
                  items: teachers
                      .map((t) => LiquidGlassDropdownItem(value: '${t['id']}', label: '${t['name'] ?? ''}'))
                      .toList(),
                  onChanged: (id) => setSheet(() => homeroomTeacherId = id),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      try {
                        await ref.read(adminRepositoryProvider).updateCohort(
                              _cohort.id,
                              name: nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim(),
                              grades: grades.isEmpty ? null : (grades.toList()..sort()),
                              homeroomTeacherId: homeroomTeacherId,
                            );
                        Navigator.pop(bCtx, true);
                      } catch (e) {
                        ScaffoldMessenger.of(bCtx).showSnackBar(SnackBar(content: Text(l.commonErrorWith(e))));
                      }
                    },
                    child: Text(l.commonSave),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (updated == true) {
      final newName = nameCtrl.text.trim().isEmpty ? _cohort.name : nameCtrl.text.trim();
      final gl = grades.toList()..sort();
      setState(() => _cohort = AdminCohort(
            id: _cohort.id,
            name: newName,
            grade: gl.isNotEmpty ? gl.first : _cohort.grade,
            grades: gl.isNotEmpty ? gl : _cohort.grades,
            studentCount: _cohort.studentCount,
          ));
    }
    nameCtrl.dispose();
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
          tooltip: AppLocalizations.of(context)!.a11yRemove,
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
