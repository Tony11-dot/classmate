// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/contracts/school_subject.dart';
import '../../../core/util/subject_color.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/admin_repository.dart';
import 'admin_subject_detail_screen.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _periodsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getPeriods();
});

final _defaultsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getPeriodDefaults();
});

final _teachersDdlProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getDdlTeachers();
});

final _cohortsDdlProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getDdlCohorts();
});

final _studentsDdlProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminRepositoryProvider).getDdlStudents();
});

// Decides whether a slot should render as "Grade N" rather than naming its
// cohorts.  Priority: trust the slot's explicit `audienceGrade` column
// (recorded when the admin originally picked By Grade) → otherwise fall
// back to the heuristic of comparing the slot's cohorts against the school's
// cohorts at each grade.  Returns null for cohort/student-mode periods.
int? slotAudienceGrade(
  Map<String, dynamic> slot,
  List<Map<String, dynamic>> allCohorts,
) {
  final raw = slot['audienceGrade'];
  final explicit = raw is int ? raw : (raw is num ? raw.toInt() : null);
  if (explicit != null) return explicit;
  final cohortRows = (slot['cohorts'] as List? ?? const [])
      .whereType<Map>()
      .map((c) => Map<String, dynamic>.from(c))
      .toList();
  return _detectSlotGradeHeuristic(cohortRows, allCohorts);
}

// Heuristic for legacy slots without an explicit `audienceGrade` — returns
// the grade only when the slot's cohorts exactly equal the full set of
// cohorts at some grade in [allCohorts] AND the grade has more than one
// cohort (single-cohort grades are ambiguous).
int? _detectSlotGradeHeuristic(
  List<Map<String, dynamic>> slotCohortRows,
  List<Map<String, dynamic>> allCohorts,
) {
  if (slotCohortRows.isEmpty) return null;
  final slotCohortIds = slotCohortRows
      .map((c) =>
          (c['cohortId'] ?? (c['cohort'] is Map ? c['cohort']['id'] : null))
              ?.toString() ??
          '')
      .where((id) => id.isNotEmpty)
      .toSet();
  if (slotCohortIds.isEmpty) return null;

  List<int> cohortGrades(Map<String, dynamic> c) {
    final raw = c['grades'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => e is num ? e.toInt() : int.tryParse('$e') ?? -1)
          .where((g) => g >= 0)
          .toList();
    }
    final g = c['grade'];
    if (g is num) return [g.toInt()];
    return const [];
  }

  final candidateGrades = <int>{};
  for (final c in allCohorts) {
    for (final g in cohortGrades(c)) {
      candidateGrades.add(g);
    }
  }
  for (final g in candidateGrades) {
    final atGrade = allCohorts
        .where((c) => cohortGrades(c).contains(g))
        .map((c) => c['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    if (atGrade.length <= 1) continue; // ambiguous — skip
    if (atGrade.length != slotCohortIds.length) continue;
    if (!atGrade.containsAll(slotCohortIds)) continue;
    return g;
  }
  return null;
}

// Subject-name → hex color lookup, used to tint schedule cells when the slot
// itself doesn't carry an explicit color override.  Empty map until fetched.
final _subjectColorsProvider = FutureProvider.autoDispose<Map<String, String>>((ref) async {
  try {
    final subjects = await ref.watch(adminRepositoryProvider).listAllSchoolSubjects();
    final m = <String, String>{};
    for (final s in subjects) {
      final c = s.color;
      if (c != null && c.isNotEmpty) m[s.nameEn.toLowerCase()] = c;
    }
    return m;
  } catch (_) {
    return const <String, String>{};
  }
});

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminScheduleScreen extends ConsumerStatefulWidget {
  /// When true, hides the Add Period FAB and disables tap-to-edit on
  /// existing slots. Used by the secretary role's read-only schedule
  /// view — same grid + filters as admin, no mutation entry points.
  const AdminScheduleScreen({super.key, this.readOnly = false});
  final bool readOnly;

  @override
  ConsumerState<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends ConsumerState<AdminScheduleScreen> {
  // Filter — three independent sets, OR'd across types.  Empty everywhere
  // means "show all".  Grade filter is transitive (covers cohorts + students
  // at that grade); cohort filter is strict (explicit cohort membership
  // only, even if a grade-level slot would otherwise also cover it).
  final Set<int>    _filterGrades     = {};
  final Set<String> _filterCohortIds  = {};
  final Set<String> _filterStudentIds = {};

  bool get _hasAnyFilter =>
      _filterGrades.isNotEmpty ||
      _filterCohortIds.isNotEmpty ||
      _filterStudentIds.isNotEmpty;

  /// True when [slot] should appear under the current filter selection.
  /// Selections OR together across types: a slot matches if it satisfies
  /// ANY selected grade, cohort, or student.  Per-type semantics:
  ///  - **Grade**: transitive — slot.audienceGrade matches, OR any cohort
  ///    on the slot includes that grade, OR an individually-enrolled
  ///    student is at that grade.
  ///  - **Cohort**: strict — the cohort id must be in slot.cohorts.  A
  ///    grade-level slot covering this cohort transitively does NOT match.
  ///  - **Student**: transitive — direct enrollment, cohort membership, or
  ///    cohort-at-student's-grade all count.
  bool _slotMatchesFilter(
    Map<String, dynamic> slot, {
    required List<Map<String, dynamic>> allCohorts,
    required List<Map<String, dynamic>> allStudents,
  }) {
    if (!_hasAnyFilter) return true;

    for (final g in _filterGrades) {
      if (_slotCoversGrade(slot, g, allStudents)) return true;
    }
    for (final cid in _filterCohortIds) {
      if (_slotHasCohortStrict(slot, cid, allCohorts)) return true;
    }
    for (final sid in _filterStudentIds) {
      if (_slotMatchesStudent(slot, sid,
              allCohorts: allCohorts, allStudents: allStudents)) {
        return true;
      }
    }
    return false;
  }

  /// Grade filter — slot matches grade [g] if explicitly audienced to it,
  /// has any cohort covering [g], or has an individually-enrolled student
  /// whose own grade is [g].
  bool _slotCoversGrade(
    Map<String, dynamic> slot,
    int g,
    List<Map<String, dynamic>> allStudents,
  ) {
    final ag = slot['audienceGrade'];
    if (ag is num && ag.toInt() == g) return true;

    final cohortsList = slot['cohorts'] as List? ?? const [];
    for (final c in cohortsList) {
      if (c is! Map) continue;
      final cohort = c['cohort'] is Map ? c['cohort'] as Map : null;
      final gs = cohort?['grades'];
      if (gs is List && gs.any((e) => e == g)) return true;
      if (cohort?['grade'] == g) return true;
    }

    final studentsList = slot['students'] as List? ?? const [];
    for (final s in studentsList) {
      if (s is! Map) continue;
      final sid = s['studentId']?.toString();
      if (sid == null || sid.isEmpty) continue;
      final student = allStudents.firstWhere(
        (st) => st['id']?.toString() == sid,
        orElse: () => const {},
      );
      if (student.isEmpty) continue;
      final sg = student['grade'];
      final gradeN = sg is int ? sg : (sg is num ? sg.toInt() : null);
      if (gradeN == g) return true;
    }
    return false;
  }

  /// Cohort filter — strict.  The slot must have been *saved as a cohort
  /// audience*, not as a grade (which gets persisted as the union of every
  /// cohort at that grade and would otherwise leak into the cohort filter).
  /// Grade-mode is identified via [slotAudienceGrade] (explicit
  /// `audienceGrade` column when present, legacy heuristic otherwise).
  bool _slotHasCohortStrict(
    Map<String, dynamic> slot,
    String cohortId,
    List<Map<String, dynamic>> allCohorts,
  ) {
    if (slotAudienceGrade(slot, allCohorts) != null) return false;
    final cohortsList = slot['cohorts'] as List? ?? const [];
    for (final c in cohortsList) {
      if (c is! Map) continue;
      final id =
          (c['cohortId'] ?? (c['cohort'] is Map ? c['cohort']['id'] : null))
              ?.toString();
      if (id == cohortId) return true;
    }
    return false;
  }

  /// Student filter — matches when [sid] is actually in the slot's audience.
  /// Three buckets:
  ///   1. Direct individual enrollment (slot.students contains sid).
  ///   2. Cohort-mode slot whose cohorts include one [sid] is a member of.
  ///   3. Grade-mode slot whose audienceGrade equals [sid]'s own grade.
  ///
  /// Bucket 2 is gated on the slot being cohort-mode because grade-mode
  /// slots persist as the union of every cohort at that grade — taking the
  /// raw intersection would match cohorts the student isn't actually in.
  /// Bucket 3 handles the grade case explicitly and intentionally.
  bool _slotMatchesStudent(
    Map<String, dynamic> slot,
    String sid, {
    required List<Map<String, dynamic>> allCohorts,
    required List<Map<String, dynamic>> allStudents,
  }) {
    final studentsList = slot['students'] as List? ?? const [];
    if (studentsList.any((s) => s is Map && s['studentId']?.toString() == sid)) {
      return true;
    }

    final student = allStudents.firstWhere(
      (s) => s['id']?.toString() == sid,
      orElse: () => const {},
    );
    if (student.isEmpty) return false;

    final slotGrade = slotAudienceGrade(slot, allCohorts);

    // Cohort bucket — only meaningful when the slot is cohort-mode.
    if (slotGrade == null) {
      final studentCohortIds = <String>{
        ...((student['cohortIds'] as List?)?.map((e) => e.toString()) ?? const []),
        if ((student['cohortId'] ?? '').toString().isNotEmpty)
          student['cohortId'].toString(),
      };
      for (final c in allCohorts) {
        final ids = c['studentIds'];
        if (ids is List && ids.any((e) => e.toString() == sid)) {
          final cid = c['id']?.toString() ?? '';
          if (cid.isNotEmpty) studentCohortIds.add(cid);
        }
      }
      if (studentCohortIds.isNotEmpty) {
        final cohortsList = slot['cohorts'] as List? ?? const [];
        final slotCohortIds = cohortsList
            .whereType<Map>()
            .map((c) =>
                (c['cohortId'] ?? (c['cohort'] is Map ? c['cohort']['id'] : null))
                    ?.toString() ??
                '')
            .where((id) => id.isNotEmpty)
            .toSet();
        if (slotCohortIds.any(studentCohortIds.contains)) return true;
      }
      return false;
    }

    // Grade bucket — slot is grade-mode; match iff it's the student's grade.
    final grade = student['grade'];
    final gradeN = grade is int ? grade : (grade is num ? grade.toInt() : null);
    return gradeN != null && gradeN == slotGrade;
  }

  /// Sheet listing every period that already lives at (day, period), with
  /// per-row delete + an Add Period button.  Empty squares still open the
  /// sheet so the Add button is one tap away and we can later surface
  /// shortcut hints.
  Future<void> _openSquareSheet({
    required int day,
    required int period,
    required List<Map<String, dynamic>> slots,
  }) async {
    // Secretary mode: tapping a cell does nothing. The grid is purely a
    // view — no add, no edit, no delete entry points.
    if (widget.readOnly) return;
    final repo = ref.read(adminRepositoryProvider);
    final action = await showModalBottomSheet<_SquareSheetAction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SquarePeriodsSheet(
        day: day,
        period: period,
        slots: slots,
        onDelete: (id) async {
          try {
            await repo.deletePeriod(id);
            return true;
          } catch (_) {
            return false;
          }
        },
      ),
    );
    // Any sheet exit re-pulls periods — cheap, and covers swipe-dismiss
    // after a delete (which the bottom sheet result can't communicate).
    ref.invalidate(_periodsProvider);
    if (action == null) return;
    switch (action.kind) {
      case _SquareSheetActionKind.add:
        // Prefill the audience picker only when exactly one filter of a single
        // type is active — otherwise the prefill is ambiguous and the admin
        // probably wants a blank picker.
        final onlyOneType =
            (_filterGrades.length + _filterCohortIds.length + _filterStudentIds.length) == 1;
        await _openAddPeriod(
          preDay: day,
          prePeriod: period,
          preCohortId: onlyOneType && _filterCohortIds.length == 1
              ? _filterCohortIds.first
              : null,
          preStudentId: onlyOneType && _filterStudentIds.length == 1
              ? _filterStudentIds.first
              : null,
          preGrade: onlyOneType && _filterGrades.length == 1
              ? _filterGrades.first
              : null,
        );
        break;
      case _SquareSheetActionKind.edit:
        await _openEditPeriod(action.slot!);
        break;
    }
  }

  Future<void> _openEditPeriod(Map<String, dynamic> slot) async {
    final teachers = await ref.read(_teachersDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final cohorts  = await ref.read(_cohortsDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final students = await ref.read(_studentsDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final defaults = await ref.read(_defaultsProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    if (!mounted) return;

    final saved = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminAddPeriodScreen(
          repo: ref.read(adminRepositoryProvider),
          teachers: teachers, cohorts: cohorts, students: students, defaults: defaults,
          editingSlot: slot,
        ),
      ),
    );
    if (saved == true) ref.invalidate(_periodsProvider);
  }

  Future<void> _openAddPeriod({int? preDay, int? prePeriod, String? preCohortId, String? preStudentId, int? preGrade}) async {
    final teachers = await ref.read(_teachersDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final cohorts  = await ref.read(_cohortsDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final students = await ref.read(_studentsDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final defaults = await ref.read(_defaultsProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    if (!mounted) return;

    // rootNavigator covers the shell (tab bar hides). fullscreenDialog is
    // intentionally OFF — the dialog flag suppresses the iOS swipe-back
    // gesture, and the screen already presents full-screen via the root
    // navigator push.
    final created = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(
        builder: (_) => AdminAddPeriodScreen(
          repo: ref.read(adminRepositoryProvider),
          teachers: teachers, cohorts: cohorts, students: students, defaults: defaults,
          initialDay: preDay, initialPeriod: prePeriod,
          initialCohortId: preCohortId, initialStudentId: preStudentId,
          initialGrade: preGrade,
        ),
      ),
    );
    if (created == true) ref.invalidate(_periodsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l  = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final periodsAsync   = ref.watch(_periodsProvider);
    final cohortsAsync   = ref.watch(_cohortsDdlProvider);
    final studentsAsync  = ref.watch(_studentsDdlProvider);

    final allCohorts  = cohortsAsync.maybeWhen(data: (d) => d, orElse: () => <Map<String, dynamic>>[]);
    final allStudents = studentsAsync.maybeWhen(data: (d) => d, orElse: () => <Map<String, dynamic>>[]);
    // Show every grade configured for this school, not just grades that already
    // have cohorts — admins planning a brand-new grade need to see it here too.
    final allGrades = ref.watch(authSessionProvider).schoolGrades;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: widget.readOnly
          ? null
          : FloatingActionButton.extended(
              heroTag: 'fab_admin_schedule',
              onPressed: () => _openAddPeriod(),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.adminScheduleAddPeriod),
            ),
      body: Column(
        children: [
          // ── Filter bar ────────────────────────────────────────────────────
          // Layout: [selected pills (× to remove)] [Add: Grade / Cohort / Student]
          // [Clear] (shown only when at least one filter is active).  Picking
          // any item adds it to its set; tapping an already-selected pill
          // removes it.  When every item of a type is selected, the matching
          // Add chip greys out.
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                // Selected grade pills
                for (final g in _filterGrades) ...[
                  _FilterChipItem(
                    label: 'Grade $g',
                    selected: true,
                    showRemove: true,
                    onTap: () => setState(() => _filterGrades.remove(g)),
                  ),
                  const SizedBox(width: 6),
                ],
                // Selected cohort pills
                for (final cid in _filterCohortIds) ...[
                  _FilterChipItem(
                    label: allCohorts
                            .firstWhere((c) => c['id']?.toString() == cid,
                                orElse: () => const {})['name']
                            ?.toString() ??
                        'Cohort',
                    selected: true,
                    showRemove: true,
                    onTap: () => setState(() => _filterCohortIds.remove(cid)),
                  ),
                  const SizedBox(width: 6),
                ],
                // Selected student pills
                for (final sid in _filterStudentIds) ...[
                  _FilterChipItem(
                    label: allStudents
                            .firstWhere((s) => s['id']?.toString() == sid,
                                orElse: () => const {})['name']
                            ?.toString() ??
                        'Student',
                    selected: true,
                    showRemove: true,
                    onTap: () => setState(() => _filterStudentIds.remove(sid)),
                  ),
                  const SizedBox(width: 6),
                ],
                // Add Grade
                _FilterChipItem(
                  label: 'By Grade ▾',
                  selected: false,
                  enabled: allGrades.any((g) => !_filterGrades.contains(g)),
                  onTap: () async {
                    final remaining = allGrades
                        .where((g) => !_filterGrades.contains(g))
                        .toList();
                    if (remaining.isEmpty) return;
                    final picked = await showLiquidGlassPicker<int>(
                      context: context,
                      title: l.adminScheduleAddGrade,
                      currentValue: -1,
                      items: remaining
                          .map((g) => LiquidGlassDropdownItem(
                              value: g, label: l.adminCohortGradeFormat(g.toString())))
                          .toList(),
                    );
                    if (picked != null) {
                      setState(() => _filterGrades.add(picked));
                    }
                  },
                ),
                const SizedBox(width: 6),
                // Add Cohort
                _FilterChipItem(
                  label: l.adminScheduleByCohort,
                  selected: false,
                  enabled: allCohorts.any((c) =>
                      !_filterCohortIds.contains(c['id']?.toString() ?? '')),
                  onTap: () async {
                    final remaining = allCohorts
                        .where((c) => !_filterCohortIds
                            .contains(c['id']?.toString() ?? ''))
                        .toList();
                    if (remaining.isEmpty) return;
                    final picked = await showLiquidGlassPicker<String>(
                      context: context,
                      title: l.adminScheduleAddCohort,
                      currentValue: '',
                      items: remaining
                          .map((c) => LiquidGlassDropdownItem(
                                value: c['id']?.toString() ?? '',
                                label: c['name']?.toString() ?? '',
                              ))
                          .toList(),
                    );
                    if (picked != null && picked.isNotEmpty) {
                      setState(() => _filterCohortIds.add(picked));
                    }
                  },
                ),
                const SizedBox(width: 6),
                // Add Student
                _FilterChipItem(
                  label: l.adminScheduleByStudent,
                  selected: false,
                  enabled: allStudents.any((s) =>
                      !_filterStudentIds.contains(s['id']?.toString() ?? '')),
                  onTap: () async {
                    final remaining = allStudents
                        .where((s) => !_filterStudentIds
                            .contains(s['id']?.toString() ?? ''))
                        .toList();
                    if (remaining.isEmpty) return;
                    final picked = await showLiquidGlassPicker<String>(
                      context: context,
                      title: l.adminScheduleAddStudent,
                      currentValue: '',
                      items: remaining
                          .map((s) => LiquidGlassDropdownItem(
                                value: s['id']?.toString() ?? '',
                                label: s['name']?.toString() ?? '',
                              ))
                          .toList(),
                    );
                    if (picked != null && picked.isNotEmpty) {
                      setState(() => _filterStudentIds.add(picked));
                    }
                  },
                ),
                if (_hasAnyFilter) ...[
                  const SizedBox(width: 6),
                  _FilterChipItem(
                    label: l.adminScheduleClearFilters,
                    selected: false,
                    onTap: () => setState(() {
                      _filterGrades.clear();
                      _filterCohortIds.clear();
                      _filterStudentIds.clear();
                    }),
                  ),
                ],
              ],
            ),
          ),
          // ── Grid ──────────────────────────────────────────────────────────
          Expanded(
            child: periodsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (allPeriods) {
                // Build (day, period) → [slots] map filtered by current selection
                final filtered = allPeriods
                    .where((s) => _slotMatchesFilter(
                          s,
                          allCohorts: allCohorts,
                          allStudents: allStudents,
                        ))
                    .toList();
                final grid = <(int, int), List<Map<String, dynamic>>>{};
                for (final s in filtered) {
                  final k = ((s['dayOfWeek'] as num?)?.toInt() ?? 0, (s['period'] as num?)?.toInt() ?? 1);
                  grid.putIfAbsent(k, () => []).add(s);
                }

                // Grid row count = max of:
                //  - highest period in the school's configured defaults
                //  - highest period that has an actual slot
                //  - a sensible floor (8) so new schools don't render a stub.
                int maxFromDefaults = 0;
                final defaults = ref.watch(_defaultsProvider).maybeWhen(
                      data: (d) => d,
                      orElse: () => const <Map<String, dynamic>>[],
                    );
                for (final d in defaults) {
                  final p = (d['period'] as num?)?.toInt() ?? 0;
                  if (p > maxFromDefaults) maxFromDefaults = p;
                }
                int maxFromSlots = 0;
                for (final s in allPeriods) {
                  final p = (s['period'] as num?)?.toInt() ?? 0;
                  if (p > maxFromSlots) maxFromSlots = p;
                }
                final periodCount = [maxFromDefaults, maxFromSlots, 8]
                    .reduce((a, b) => a > b ? a : b);

                return _ScheduleGrid(
                  grid: grid,
                  periodCount: periodCount,
                  onCellTap: (day, period) => _openSquareSheet(
                    day: day,
                    period: period,
                    slots: grid[(day, period)] ?? const [],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Interactive 7×9 schedule grid ─────────────────────────────────────────────

class _ScheduleGrid extends StatelessWidget {
  const _ScheduleGrid({
    required this.grid,
    required this.onCellTap,
    this.periodCount = 9,
  });

  final Map<(int, int), List<Map<String, dynamic>>> grid;
  final void Function(int day, int period) onCellTap;
  /// Number of period rows the grid renders. Driven by the school's
  /// period defaults + the highest scheduled slot — see the call site
  /// in [AdminScheduleScreen.build].
  final int periodCount;

  static const _dayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const double _headerH = 36;
  static const double _headerW = 48;
  static const double _cellW   = 110;
  static const double _cellH   = 90;
  static const int _days       = 7;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final totalW = _headerW + _days * _cellW;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(40),
      minScale: 0.45,
      maxScale: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        // Width is fixed; height grows to fit content so cells with many
        // stacked slots can expand their row instead of clipping.
        child: SizedBox(
          width: totalW,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row
              Row(
                children: [
                  // Corner
                  SizedBox(width: _headerW, height: _headerH),
                  ...List.generate(_days, (d) => Container(
                    width: _cellW,
                    height: _headerH,
                    alignment: Alignment.center,
                    child: Text(
                      _dayShort[d],
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )),
                ],
              ),
              // Period rows. IntrinsicHeight makes the period-label cell
              // stretch to match whichever day cell in the row has the most
              // stacked slots — otherwise the label is glued to _cellH and
              // a tall cell pulls only itself out of alignment.
              ...List.generate(periodCount, (pi) {
                final period = pi + 1;
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Period label
                      Container(
                        width: _headerW,
                        alignment: Alignment.center,
                        child: Text(
                          'P$period',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                      ...List.generate(_days, (day) {
                        final slots = grid[(day, period)] ?? [];
                        return _GridCell(
                          width: _cellW,
                          height: _cellH,
                          slots: slots,
                          onTap: () => onCellTap(day, period),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  const _GridCell({required this.width, required this.height, required this.slots, required this.onTap});
  final double width;
  /// Minimum cell height (the row's "default" rhythm). Cells with several
  /// stacked slots grow beyond this so every period is visible — see the
  /// IntrinsicHeight row in [_ScheduleGrid.build].
  final double height;
  final List<Map<String, dynamic>> slots;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasSlots = slots.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        constraints: BoxConstraints(minHeight: height),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          color: hasSlots ? cs.primaryContainer.withValues(alpha: 0.08) : cs.surface,
        ),
        padding: const EdgeInsets.all(4),
        // No more .take(3) cap and no inner scroll view — every stacked
        // period renders, and the row grows vertically to fit. Panning the
        // InteractiveViewer (parent) is the way to scroll.
        child: hasSlots
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: slots.map((s) => _SlotCard(slot: s)).toList(),
              )
            : null,
      ),
    );
  }
}

class _SlotCard extends ConsumerWidget {
  const _SlotCard({required this.slot});
  final Map<String, dynamic> slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final subject     = slot['subject']?.toString() ?? '';
    final teacherName = slot['teacher'] is Map ? (slot['teacher']['name']?.toString() ?? '') : '';
    final cohorts     = slot['cohorts'] as List? ?? [];
    final cohortRows = cohorts.whereType<Map>().map((c) => Map<String, dynamic>.from(c)).toList();
    final cohortNames = cohortRows
        .map((c) => (c['cohort'] is Map ? c['cohort']['name'] : null)?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    // If this slot covers every cohort at some grade, prefer "Grade N" over
    // listing cohort names — that's what the admin originally chose.
    final allCohorts = ref.watch(_cohortsDdlProvider).maybeWhen(
          data: (d) => d,
          orElse: () => const <Map<String, dynamic>>[],
        );
    final gradeForSlot = slotAudienceGrade(slot, allCohorts);
    final cohortLabel = gradeForSlot != null
        ? 'Grade $gradeForSlot'
        : (cohortNames.isEmpty
            ? ''
            : cohortNames.length == 1
                ? cohortNames.first
                : '${cohortNames.first} +${cohortNames.length - 1}');
    final freq = (slot['frequencyWeeks'] as num?)?.toInt() ?? 1;

    // Color resolution: slot.color (per-period override) → subject's color
    // (set in the subject editor) → deterministic palette hue keyed by name.
    final slotColorHex = slot['color']?.toString();
    final subjectColors = ref.watch(_subjectColorsProvider).maybeWhen(
          data: (m) => m,
          orElse: () => const <String, String>{},
        );
    final subjectColorHex = subject.isNotEmpty
        ? subjectColors[subject.toLowerCase()]
        : null;
    final fallbackSeed = subject.isNotEmpty ? subject : teacherName;
    final base = parseSubjectColor(slotColorHex)
        ?? parseSubjectColor(subjectColorHex)
        ?? subjectColorOrFallback(null, fallbackSeed);

    // Tint the background; pick a contrasting foreground based on luminance.
    final bg = Color.alphaBlend(base.withValues(alpha: 0.22), cs.surface);
    final fg = base.computeLuminance() < 0.55
        ? base
        : HSLColor.fromColor(base).withLightness(0.32).toColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: base, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject.isNotEmpty ? subject : teacherName.isNotEmpty ? teacherName : 'Period',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: fg),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (cohortLabel.isNotEmpty)
            Text(
              cohortLabel,
              style: TextStyle(fontSize: 9, color: fg.withValues(alpha: 0.78)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (freq > 1)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: base.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '×$freq wks',
                style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: fg),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Filter chip ────────────────────────────────────────────────────────────────

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.showRemove = false,
    this.enabled = true,
  });
  final String label;
  final bool selected;
  final bool showRemove;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final disabled = !enabled;
    final bg = selected
        ? cs.primaryContainer
        : (disabled
            ? cs.surfaceContainerLow.withValues(alpha: 0.5)
            : cs.surfaceContainerLow);
    final borderColor = selected
        ? cs.primary.withValues(alpha: 0.4)
        : cs.outlineVariant.withValues(alpha: disabled ? 0.3 : 0.5);
    final fg = selected
        ? cs.primary
        : (disabled ? cs.onSurfaceVariant.withValues(alpha: 0.5) : cs.onSurfaceVariant);
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: EdgeInsets.only(
          left: 14,
          right: showRemove ? 8 : 14,
          top: 8,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: fg,
              ),
            ),
            if (showRemove) ...[
              const SizedBox(width: 4),
              Icon(Icons.close_rounded, size: 16, color: fg),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Add Period — full-screen ───────────────────────────────────────────────────
// Multi-slot: admin can add N day+period pairs, shared teacher/cohort/frequency

class AdminAddPeriodScreen extends ConsumerStatefulWidget {
  const AdminAddPeriodScreen({
    super.key,
    required this.repo,
    required this.teachers,
    required this.cohorts,
    required this.students,
    required this.defaults,
    this.initialDay,
    this.initialPeriod,
    this.initialCohortId,
    this.initialStudentId,
    this.initialGrade,
    this.editingSlot,
  });

  final AdminRepository repo;
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> cohorts;
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> defaults;
  final int? initialDay;
  final int? initialPeriod;
  final String? initialCohortId;
  final String? initialStudentId;
  final int? initialGrade;

  /// When non-null, the screen is in edit mode: fields are seeded from this
  /// slot map (id + teacher + subject + color + cohorts + students + freq)
  /// and saving issues PATCH /admin/periods/:id instead of POST.
  final Map<String, dynamic>? editingSlot;

  @override
  ConsumerState<AdminAddPeriodScreen> createState() => _AdminAddPeriodScreenState();
}

class _DayPeriodSlot {
  int dayOfWeek;
  int period;
  _DayPeriodSlot({this.dayOfWeek = 0, this.period = 1});
}

enum _AudienceMode { cohort, student, grade }

class _AdminAddPeriodScreenState extends ConsumerState<AdminAddPeriodScreen> {
  late final List<_DayPeriodSlot> _slots;

  String? _teacherId;
  final Set<String> _cohortIds  = {};
  final Set<String> _studentIds = {};
  int? _audienceGrade;
  _AudienceMode _audience = _AudienceMode.cohort;

  // Audience customization — when the admin tweaks the auto-populated student
  // list in cohort/grade mode (adds or removes individuals), we treat the
  // period as targeting individuals rather than the whole cohort/grade.  The
  // cohort isn't modified; only this period's saved audience changes shape.
  bool _audienceCustomized = false;
  final Set<String> _customStudentIds = {};

  int  _frequencyWeeks = 1;
  bool _customFreq = false;
  final _customFreqCtrl = TextEditingController();
  DateTime? _startDate; // first occurrence for bi-weekly etc.

  /// Slot subject — must match the nameEn of a school subject. Freeform
  /// text entry was removed; the picker only allows select-or-add.
  String? _subject;

  /// Optional caption shown above "subject · teacher" on the schedule
  /// tile. Lets admins annotate a slot ("Quiz day", "Lab session", etc.)
  /// without renaming the subject.
  final _captionCtrl = TextEditingController();

  /// Optional per-period color override (#RRGGBB).  Null = inherit from the
  /// subject's color (or palette fallback) at render time.
  String? _colorOverride;

  bool _saving = false;


  bool get _isEditing => widget.editingSlot != null;
  String? get _editingId => widget.editingSlot?['id']?.toString();

  @override
  void initState() {
    super.initState();

    final edit = widget.editingSlot;
    if (edit != null) {
      // Seed every field from the slot we're editing.  The audience picker
      // starts in whichever mode the saved period was using — cohorts/
      // students chosen, grade left blank since the server doesn't track
      // "saved as grade" separately from "saved as the set of cohorts at
      // that grade."  Admins re-pick grade explicitly if they want it.
      final day = (edit['dayOfWeek'] as num?)?.toInt() ?? widget.initialDay ?? 1;
      final period = (edit['period'] as num?)?.toInt() ?? widget.initialPeriod ?? 1;
      _slots = [_DayPeriodSlot(dayOfWeek: day, period: period)];

      _teacherId = edit['teacherId']?.toString().trim().isNotEmpty == true
          ? edit['teacherId']?.toString()
          : (edit['teacher'] is Map ? edit['teacher']['id']?.toString() : null);

      _subject = edit['subject']?.toString();
      _captionCtrl.text = edit['caption']?.toString().trim() ?? '';
      final rawColor = edit['color']?.toString().trim() ?? '';
      _colorOverride = rawColor.isEmpty ? null : rawColor;

      final freq = (edit['frequencyWeeks'] as num?)?.toInt() ?? 1;
      if (freq == 0 || freq == 1 || freq == 2 || freq == 4) {
        _frequencyWeeks = freq;
        _customFreq = false;
      } else if (freq > 0) {
        _customFreq = true;
        _customFreqCtrl.text = '$freq';
      }
      // Restore the anchor date so editing a Once slot shows its date
      // pre-selected and editing a recurring slot keeps its first occurrence.
      final rawStartDate = edit['startDate']?.toString().trim() ?? '';
      if (rawStartDate.isNotEmpty) {
        _startDate = DateTime.tryParse(rawStartDate);
      }

      final cohortRows = (edit['cohorts'] as List?) ?? const [];
      final existingCohortIds = cohortRows
          .whereType<Map>()
          .map((c) =>
              (c['cohortId'] ?? (c['cohort'] is Map ? c['cohort']['id'] : null))
                  ?.toString() ??
              '')
          .where((id) => id.isNotEmpty)
          .toList();
      final studentRows = (edit['students'] as List?) ?? const [];
      final existingStudentIds = studentRows
          .whereType<Map>()
          .map((s) =>
              (s['studentId'] ??
                      (s['student'] is Map ? s['student']['userId'] : null))
                  ?.toString() ??
              '')
          .where((id) => id.isNotEmpty)
          .toList();

      // Audience mode restore:
      //   1) Trust the slot's explicit `audienceGrade` when present — this
      //      is the admin's original intent recorded at save time.
      //   2) Fall back to the heuristic for legacy slots created before the
      //      `audienceGrade` column existed.
      //   3) Otherwise default to cohort or student mode based on payload.
      final rawAudienceGrade = edit['audienceGrade'];
      final explicitGrade = rawAudienceGrade is int
          ? rawAudienceGrade
          : (rawAudienceGrade is num ? rawAudienceGrade.toInt() : null);
      final detectedGrade = explicitGrade ??
          _detectGradeFromAudience(
            existingCohortIds: existingCohortIds.toSet(),
            existingStudentIds: existingStudentIds,
          );
      if (detectedGrade != null) {
        _audience = _AudienceMode.grade;
        _audienceGrade = detectedGrade;
      } else if (existingStudentIds.isNotEmpty && existingCohortIds.isEmpty) {
        _audience = _AudienceMode.student;
        _studentIds.addAll(existingStudentIds);
      } else {
        _audience = _AudienceMode.cohort;
        _cohortIds.addAll(existingCohortIds);
      }
      return;
    }

    _slots = [_DayPeriodSlot(
      dayOfWeek: widget.initialDay ?? 1,
      period: widget.initialPeriod ?? 1,
    )];
    if (widget.initialCohortId != null && widget.initialCohortId!.isNotEmpty) {
      _audience = _AudienceMode.cohort;
      _cohortIds.add(widget.initialCohortId!);
    } else if (widget.initialStudentId != null && widget.initialStudentId!.isNotEmpty) {
      _audience = _AudienceMode.student;
      _studentIds.add(widget.initialStudentId!);
    } else if (widget.initialGrade != null) {
      _audience = _AudienceMode.grade;
      _audienceGrade = widget.initialGrade;
    }
  }

  @override
  void dispose() {
    _customFreqCtrl.dispose();
    _captionCtrl.dispose();
    super.dispose();
  }

  String _defaultTime(int period, bool isStart) {
    final def = widget.defaults.firstWhere(
      (d) => (d['period'] as num?)?.toInt() == period,
      orElse: () => const {},
    );
    if (isStart) return def['startTime']?.toString() ?? '';
    return def['endTime']?.toString() ?? '';
  }

  /// Resolves the current audience selection into either cohortIds or studentIds
  /// for the period-create API. Returns (cohortIds, studentIds) — at most one
  /// is non-null. Grade mode expands to every cohort matching that grade.
  /// If the admin customized the auto-populated student list, the period
  /// targets those individuals regardless of mode.
  ({List<String>? cohortIds, List<String>? studentIds}) _resolveAudience() {
    if (_audienceCustomized && _customStudentIds.isNotEmpty) {
      return (cohortIds: null, studentIds: _customStudentIds.toList());
    }
    switch (_audience) {
      case _AudienceMode.cohort:
        return (cohortIds: _cohortIds.isNotEmpty ? _cohortIds.toList() : null, studentIds: null);
      case _AudienceMode.student:
        return (cohortIds: null, studentIds: _studentIds.isNotEmpty ? _studentIds.toList() : null);
      case _AudienceMode.grade:
        final g = _audienceGrade;
        if (g == null) return (cohortIds: null, studentIds: null);
        final matching = widget.cohorts
            .where((c) => _cohortGradesOf(c).contains(g))
            .toList();
        final matchingIds = matching
            .map((c) => c['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
        // Union of students already enrolled in matched cohorts — anyone in
        // _customStudentIds outside this set is a standalone grade-N
        // student.  Save the cohorts AND the standalone individuals so the
        // grade grouping is preserved in the schedule record while
        // standalone students still receive the period.
        final cohortStudents = <String>{};
        for (final c in matching) {
          final ids = c['studentIds'];
          if (ids is List) cohortStudents.addAll(ids.map((e) => e.toString()));
        }
        for (final cid in matchingIds) {
          for (final r in (_cohortRosterCache[cid] ?? const [])) {
            final id = r['id'] ?? '';
            if (id.isNotEmpty) cohortStudents.add(id);
          }
        }
        final standalone = _customStudentIds
            .where((s) => !cohortStudents.contains(s))
            .toList();
        return (
          cohortIds: matchingIds.isNotEmpty ? matchingIds : null,
          studentIds: standalone.isNotEmpty ? standalone : null,
        );
    }
  }

  void _onAudienceEdited(Set<String> effective, {required bool customized}) {
    setState(() {
      _audienceCustomized = customized;
      _customStudentIds
        ..clear()
        ..addAll(effective);
    });
  }

  /// Returns the grades a cohort spans. Falls back to [grade] when the API
  /// hasn't sent the multi-grade `grades` field yet (e.g. cached older data).
  static List<int> _cohortGradesOf(Map<String, dynamic> c) {
    final raw = c['grades'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => (e as num).toInt()).toList();
    }
    final g = (c['grade'] as num?)?.toInt();
    return g == null ? const [] : [g];
  }

  /// Inverse of the grade-mode save: decides whether the existing audience
  /// (cohorts + individual students) on a slot can be expressed as "By
  /// Grade N".  Returns the grade if it fits — exact match on the school's
  /// cohorts at N + any individuals all share grade N — otherwise null.
  int? _detectGradeFromAudience({
    required Set<String> existingCohortIds,
    required List<String> existingStudentIds,
  }) {
    if (existingCohortIds.isEmpty && existingStudentIds.isEmpty) return null;
    final candidates = <int>{};
    for (final c in widget.cohorts) {
      for (final g in _cohortGradesOf(c)) {
        candidates.add(g);
      }
    }
    for (final g in candidates) {
      final atGrade = widget.cohorts
          .where((c) => _cohortGradesOf(c).contains(g))
          .map((c) => c['id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      if (atGrade.isEmpty) continue;
      // Single-cohort grades are ambiguous (cohort mode and grade mode
      // produce identical saves when nothing else is attached) — only
      // restore as grade mode when there's a real signal that the admin
      // picked a grade: either multiple matched cohorts or standalone
      // grade-N students saved alongside.
      if (atGrade.length == 1 && existingStudentIds.isEmpty) continue;
      // Period must cover every cohort at this grade — no more, no less.
      if (atGrade.length != existingCohortIds.length) continue;
      if (!atGrade.containsAll(existingCohortIds)) continue;
      // Any individually-listed students must also be at this grade
      // (standalone grade-N students saved alongside the cohorts).
      bool allMatch = true;
      for (final sid in existingStudentIds) {
        final s = widget.students.firstWhere(
          (e) => e['id']?.toString() == sid,
          orElse: () => const {},
        );
        final raw = s['grade'];
        final sg = raw is int ? raw : (raw is num ? raw.toInt() : null);
        if (sg != g) {
          allMatch = false;
          break;
        }
      }
      if (allMatch) return g;
    }
    return null;
  }

  static String? _cohortGradeLabel(Map<String, dynamic> c) {
    final gs = _cohortGradesOf(c);
    if (gs.isEmpty) return null;
    if (gs.length == 1) return 'Grade ${gs.first}';
    final sorted = [...gs]..sort();
    final isRange = sorted.last - sorted.first == sorted.length - 1;
    return isRange
        ? 'Grade ${sorted.first}-${sorted.last}'
        : 'Grades ${sorted.join(', ')}';
  }

  Future<void> _save() async {
    // Subject is required — without one the slot renders as just a teacher
    // name and the grid loses its primary affordance (what is being taught).
    final subject = (_subject ?? '').trim();
    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pick a subject before saving the period.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final freq = _customFreq
        ? (int.tryParse(_customFreqCtrl.text.trim()) ?? 1).clamp(1, 52)
        : _frequencyWeeks;

    // Any non-weekly recurring slot needs an anchor date so the
    // bi-weekly / monthly rendering can compute "every N weeks from
    // when".  Once obviously needs a date too — it's the only date
    // the slot renders on.  Only freq=1 (plain weekly) doesn't need
    // one, because it renders on every matching weekday.
    if (freq != 1 && _startDate == null) {
      final msg = freq == 0
          ? 'Pick a date for a one-off period.'
          : 'Pick a start date for the every-$freq-weeks schedule.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final audience = _resolveAudience();

    // Conflict check — warn before overwriting/duplicating any existing
    // period at the same (day, slot) for an overlapping audience. The user
    // can confirm to proceed (one-off lectures replacing a regular class is
    // the expected case) or cancel to back out.
    final conflicts = _findConflicts(
      audience: audience,
      freq: freq,
      startDate: _startDate,
    );
    // Captured here for the post-create patch — see _ConflictChoice.keepCurrent.
    _ConflictChoice? conflictChoice;
    final draftYmd = _startDate != null
        ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
        : null;
    final newStudentDateSkipsForDraft = <String>{};
    // Whole-day skips applied to the new slot — used for teacher
    // conflicts under Keep-current (we can't per-student-skip a
    // teacher; the slot just can't run on those dates).
    final newSkipDatesForDraft = <String>{};
    if (conflicts.isNotEmpty) {
      conflictChoice = await _confirmConflictDialog(conflicts);
      if (conflictChoice == null || conflictChoice == _ConflictChoice.cancel) {
        return;
      }
      if (conflictChoice == _ConflictChoice.override) {
        try {
          // Compute every date the draft would render on so we can
          // suppress the existing slot on each of them.  For Once, that's
          // a single date.  For recurring (with or without anchor), it's
          // the next ~year of matching dates.
          final draftSkipDates = <String>{};
          for (final dr in _slots) {
            draftSkipDates.addAll(_renderDatesForSlot(
              dayOfWeek: dr.dayOfWeek,
              frequencyWeeks: freq,
              startDate: draftYmd,
            ));
          }
          for (final hit in conflicts) {
            if (hit.id.isEmpty) continue;
            final updated = <String>{
              ...hit.skipDates,
              ...draftSkipDates,
            }.toList()
              ..sort();
            await widget.repo.updatePeriod(
              id: hit.id,
              skipDates: updated,
            );
          }
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Override failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
          return;
        }
      } else if (conflictChoice == _ConflictChoice.keepCurrent) {
        // Keep current: existing slot stays for everyone; the new slot
        // hides for the conflicted students on every date it would
        // render. Per-student precision — the new slot still renders
        // for the rest of its audience on those dates.
        //
        // Teacher-clash hits are an exception: a teacher can't be in
        // two places, so the new slot can't run AT ALL on those dates
        // (regardless of audience). We stamp whole-day skipDates on
        // the new slot for those.
        final draftDates = <String>{};
        for (final dr in _slots) {
          draftDates.addAll(_renderDatesForSlot(
            dayOfWeek: dr.dayOfWeek,
            frequencyWeeks: freq,
            startDate: draftYmd,
          ));
        }
        for (final hit in conflicts) {
          if (hit.teacherClash) {
            newSkipDatesForDraft.addAll(draftDates);
            continue;
          }
          for (final sid in hit.affectedStudentIds) {
            for (final d in draftDates) {
              newStudentDateSkipsForDraft.add('$sid:$d');
            }
          }
        }
      }
      // _ConflictChoice.stack — no-op, both periods render side-by-side.
    }

    setState(() => _saving = true);

    // Edit path — single PATCH against the slot we opened.
    if (_isEditing) {
      final id = _editingId ?? '';
      if (id.isEmpty) {
        setState(() => _saving = false);
        return;
      }
      try {
        final slot = _slots.first;
        final sd = _startDate != null
            ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
            : null;
        await widget.repo.updatePeriod(
          id: id,
          dayOfWeek: slot.dayOfWeek,
          period: slot.period,
          teacherId: _teacherId,
          setTeacherId: true,
          subject: _subject,
          setSubject: true,
          caption: _captionCtrl.text.trim().isEmpty ? null : _captionCtrl.text.trim(),
          setCaption: true,
          color: _colorOverride,
          setColor: true,
          audienceGrade: _audience == _AudienceMode.grade ? _audienceGrade : null,
          setAudienceGrade: true,
          cohortIds: audience.cohortIds ?? const <String>[],
          studentIds: audience.studentIds ?? const <String>[],
          frequencyWeeks: freq,
          // Stamp the date even when null so toggling between Once/Weekly
          // clears the anchor properly.
          startDate: sd,
          setStartDate: true,
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
        return;
      }
      if (!mounted) return;
      setState(() => _saving = false);
      Navigator.pop(context, true);
      return;
    }

    int created = 0;
    String? firstError;

    for (final slot in _slots) {
      try {
        final sd = _startDate != null
            ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
            : null;
        final newId = await widget.repo.createPeriod(
          dayOfWeek: slot.dayOfWeek,
          period: slot.period,
          teacherId: _teacherId,
          cohortIds: audience.cohortIds,
          studentIds: audience.studentIds,
          subject: _subject,
          caption: _captionCtrl.text.trim().isEmpty ? null : _captionCtrl.text.trim(),
          color: _colorOverride,
          audienceGrade: _audience == _AudienceMode.grade ? _audienceGrade : null,
          startTime: _defaultTime(slot.period, true).isNotEmpty ? _defaultTime(slot.period, true) : null,
          endTime: _defaultTime(slot.period, false).isNotEmpty ? _defaultTime(slot.period, false) : null,
          frequencyWeeks: freq,
          startDate: sd,
        );
        created++;
        // Keep-current: stamp the new slot's studentDateSkips so it
        // doesn't render for the conflicted students on its anchor
        // date. Date-scoped, so when that date passes the new slot
        // also disappears naturally (it's a Once); no-op when the
        // choice wasn't Keep current.  Teacher-clash dates pile onto
        // skipDates (whole-day) since a teacher can't be in two
        // places — per-student precision doesn't apply.
        if (conflictChoice == _ConflictChoice.keepCurrent && newId.isNotEmpty) {
          if (newStudentDateSkipsForDraft.isNotEmpty) {
            await widget.repo.updatePeriod(
              id: newId,
              studentDateSkips: newStudentDateSkipsForDraft.toList()..sort(),
            );
          }
          if (newSkipDatesForDraft.isNotEmpty) {
            await widget.repo.updatePeriod(
              id: newId,
              skipDates: newSkipDatesForDraft.toList()..sort(),
            );
          }
        }
      } catch (e) {
        firstError ??= e.toString();
      }
    }

    if (!mounted) { setState(() => _saving = false); return; }
    setState(() => _saving = false);

    if (created == 0) {
      // All failed
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(firstError ?? 'Failed to create slots'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } else {
      if (created < _slots.length && firstError != null) {
        // Partial success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Created $created/${_slots.length} slots. $firstError'),
          duration: const Duration(seconds: 5),
        ));
      }
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_add_period',
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.check_rounded),
        label: Text(l.adminScheduleSave),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          children: [
            // ── Back chevron — no AppBar, so this is the only way back ─────
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () => Navigator.maybePop(context),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                ),
                const SizedBox(width: 4),
                Text(
                  _isEditing ? 'Edit period' : l.adminScheduleAddPeriod,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Day + Period slots ────────────────────────────────────────
            ..._slots.asMap().entries.map((entry) {
              final i = entry.key;
              final slot = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DayPeriodRow(
                  slot: slot,
                  index: i,
                  total: _slots.length,
                  defaults: widget.defaults,
                  onChanged: () => setState(() {}),
                  onRemove: _slots.length > 1 ? () => setState(() => _slots.removeAt(i)) : null,
                ),
              );
            }),
            // Multi-slot creation doesn't apply in edit mode — a single
            // PATCH targets exactly one slot.  Hide the affordance so admins
            // don't expect to spawn new rows from the editor.
            if (!_isEditing)
              TextButton.icon(
                onPressed: () => setState(() => _slots.add(_DayPeriodSlot())),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Add slot'),
              ),
            const SizedBox(height: 12),

            // ── Teacher DDL ───────────────────────────────────────────────
            LiquidGlassDropdown<String>(
              label: 'Teacher',
              value: _teacherId ?? '',
              searchHint: l.adminScheduleSearchTeacher,
              items: [
                LiquidGlassDropdownItem(value: '', label: '— None —'),
                ...widget.teachers.map((t) => LiquidGlassDropdownItem(
                  value: t['id']?.toString() ?? '',
                  label: t['name']?.toString() ?? '',
                )),
              ],
              onChanged: (v) => setState(() {
                _teacherId = v.isEmpty ? null : v;
              }),
            ),
            const SizedBox(height: 12),

            // ── Subject (required) ───────────────────────────────────────
            _SubjectPickerField(
              repo: widget.repo,
              value: _subject,
              cohorts: widget.cohorts,
              selectedCohortIds: _cohortIds,
              audienceGrade: _audienceGrade,
              audience: _audience,
              onChanged: (v) => setState(() {
                _subject = v;
                // Don't touch _colorOverride here.  If the admin already
                // picked a palette swatch, they meant it — wiping it on a
                // later subject change would silently undo their choice.
                // When _colorOverride is null, the picker still re-resolves
                // the "auto" tile to the new subject's color automatically.
              }),
            ),
            const SizedBox(height: 10),
            _PeriodColorRow(
              subjectName: _subject,
              repo: widget.repo,
              colorOverride: _colorOverride,
              onChanged: (hex) => setState(() => _colorOverride = hex),
            ),
            const SizedBox(height: 12),

            // ── Caption (optional) ───────────────────────────────────────
            // Shows above the subject on the schedule tile when set. Lets
            // admins clarify a one-off ("Exam review") without changing
            // the underlying subject.
            TextField(
              controller: _captionCtrl,
              textInputAction: TextInputAction.done,
              maxLength: 60,
              decoration: InputDecoration(
                labelText: 'Caption (optional)',
                hintText: 'e.g. Exam review',
                counterText: '',
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // ── Audience: cohort, student, or by-grade ────────────────────
            SegmentedButton<_AudienceMode>(
              // showSelectedIcon=false drops the leading checkmark — with it
              // on, the icon + "Students" overflows the segment width and the
              // trailing "s" wraps to a new line.
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: _AudienceMode.cohort, label: Text('Cohorts')),
                ButtonSegment(value: _AudienceMode.student, label: Text('Students')),
                ButtonSegment(value: _AudienceMode.grade, label: Text('Grade')),
              ],
              selected: {_audience},
              onSelectionChanged: (s) => setState(() {
                _audience = s.first;
                _cohortIds.clear();
                _studentIds.clear();
                _audienceGrade = null;
                _audienceCustomized = false;
                _customStudentIds.clear();
              }),
            ),
            const SizedBox(height: 10),
            if (_audience == _AudienceMode.cohort) ...[
              _MultiPickerList(
                items: widget.cohorts,
                selected: _cohortIds,
                nameKey: 'name',
                subtitleBuilder: (item) => _cohortGradeLabel(item),
                searchHint: l.adminScheduleSearchCohort,
                onToggle: (id) => setState(() {
                  if (_cohortIds.contains(id)) {
                    _cohortIds.remove(id);
                  } else {
                    _cohortIds.add(id);
                  }
                  // Changing which cohorts are selected blows away any
                  // per-student customization since the auto-derived set is
                  // about to differ — restart from the new roster.
                  _audienceCustomized = false;
                  _customStudentIds.clear();
                }),
              ),
              if (_cohortIds.isNotEmpty) ...[
                const SizedBox(height: 10),
                _CohortStudentPreview(
                  allStudents: widget.students,
                  selectedCohortIds: _cohortIds,
                  cohorts: widget.cohorts,
                  onEdited: _onAudienceEdited,
                ),
              ],
            ] else if (_audience == _AudienceMode.student)
              _MultiPickerList(
                items: widget.students,
                selected: _studentIds,
                nameKey: 'name',
                subtitleBuilder: (item) {
                  final g = item['grade'];
                  final cn = item['cohortName']?.toString() ?? '';
                  if (g != null) return 'Grade $g${cn.isNotEmpty ? ' · $cn' : ''}';
                  return cn.isNotEmpty ? cn : null;
                },
                searchHint: l.adminSearchStudents,
                onToggle: (id) => setState(() =>
                  _studentIds.contains(id) ? _studentIds.remove(id) : _studentIds.add(id)),
              )
            else ...[
              // Grade mode — pick a single grade; expanded to all matching cohorts on save
              Builder(builder: (ctx) {
                // Use the school's full grade range, not just grades that
                // already have cohorts — admins planning a new grade need to
                // see it in the picker too.
                final grades = ref.watch(authSessionProvider).schoolGrades;
                if (grades.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No cohorts yet — create one first.',
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: grades.map((g) {
                    return ChoiceChip(
                      label: Text('Grade $g'),
                      selected: _audienceGrade == g,
                      onSelected: (_) => setState(() {
                        _audienceGrade = g;
                        _audienceCustomized = false;
                        _customStudentIds.clear();
                      }),
                    );
                  }).toList(),
                );
              }),
              if (_audienceGrade != null) ...[
                const SizedBox(height: 10),
                _GradeStudentPreview(
                  allStudents: widget.students,
                  cohorts: widget.cohorts,
                  grade: _audienceGrade!,
                  onEdited: _onAudienceEdited,
                ),
              ],
            ],
            const SizedBox(height: 12),

            // ── Frequency ─────────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Once = one-off override; replaces the regular slot just for
                // the chosen date. Persisted as frequencyWeeks=0 + startDate.
                _FreqChip(label: 'Once', selected: !_customFreq && _frequencyWeeks == 0,
                    onTap: () => setState(() { _frequencyWeeks = 0; _customFreq = false; })),
                _FreqChip(label: l.adminScheduleFreqWeekly, selected: !_customFreq && _frequencyWeeks == 1,
                    onTap: () => setState(() { _frequencyWeeks = 1; _customFreq = false; })),
                _FreqChip(label: l.adminScheduleFreqBiweekly, selected: !_customFreq && _frequencyWeeks == 2,
                    onTap: () => setState(() { _frequencyWeeks = 2; _customFreq = false; })),
                _FreqChip(label: l.adminScheduleFreqMonthly, selected: !_customFreq && _frequencyWeeks == 4,
                    onTap: () => setState(() { _frequencyWeeks = 4; _customFreq = false; })),
                _FreqChip(label: l.adminScheduleFreqCustom, selected: _customFreq,
                    onTap: () => setState(() => _customFreq = true)),
              ],
            ),
            if (_customFreq) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Every ', style: theme.textTheme.bodyMedium),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _customFreqCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      ),
                    ),
                  ),
                  Text(' weeks', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],

            // ── Date picker — required for "Once", optional first-occurrence
            // for repeating frequencies. Label shifts to match the meaning.
            if (_frequencyWeeks == 0 || _frequencyWeeks > 1 || _customFreq) ...[
              const SizedBox(height: 16),
              Text(
                _frequencyWeeks == 0 ? 'On' : 'Starts on',
                style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _nextMatchingDates(_slots.isNotEmpty ? _slots.first.dayOfWeek : 1, 6).map((d) {
                  final label = '${_monthName(d.month)} ${d.day}';
                  final selected = _startDate != null && _startDate!.year == d.year && _startDate!.month == d.month && _startDate!.day == d.day;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) => setState(() => _startDate = d),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Compute next N dates that fall on the given dayOfWeek (0=Sun)
  List<DateTime> _nextMatchingDates(int targetDow, int count) {
    final today = DateTime.now();
    final results = <DateTime>[];
    var day = today;
    while (results.length < count) {
      if (day.weekday % 7 == targetDow) results.add(day);
      day = day.add(const Duration(days: 1));
    }
    return results;
  }

  static const _months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String _monthName(int m) => m >= 1 && m <= 12 ? _months[m] : '$m';

  /// Finds existing periods that overlap this draft at the same (day, slot)
  /// for an overlapping audience. Returns up to a handful of human-readable
  /// labels for the warning dialog.
  ///
  /// Overlap rules (anything in common is a conflict):
  ///   - Any cohort id in the draft's cohort audience also appears on the
  ///     existing slot's cohorts.
  ///   - Any student id in the draft's student audience also appears on the
  ///     existing slot's students.
  ///   - The draft's audienceGrade matches the existing slot's audienceGrade.
  ///   - The draft's audienceGrade equals any existing slot cohort's grade
  ///     (covers grade-mode draft conflicting with cohort-mode existing).
  ///   - The existing slot's audienceGrade equals any of the draft's
  ///     cohort grades (covers the reverse).
  /// Resolves an audience description into the concrete set of student
  /// user-ids who would attend the period.  Used both for the new draft
  /// and for every existing slot so the conflict resolver can intersect
  /// them and discover the per-student overlap.
  Set<String> _studentsForAudience({
    Set<String>? cohortIds,
    Set<String>? directStudentIds,
    int? audienceGrade,
  }) {
    final out = <String>{};
    if (directStudentIds != null) out.addAll(directStudentIds);

    // Cohort membership comes from the cohorts DDL, which already unions
    // the StudentCohort join + legacy studentProfile.cohortId (see
    // listCohortsForDDL on the server). Falls back to per-student
    // cohortIds when the cohort row's studentIds field is empty.
    if (cohortIds != null && cohortIds.isNotEmpty) {
      for (final cid in cohortIds) {
        final c = widget.cohorts.firstWhere(
          (e) => e['id']?.toString() == cid,
          orElse: () => const {},
        );
        final ids = (c['studentIds'] as List?)
                ?.map((e) => e.toString())
                .where((s) => s.isNotEmpty)
                .toList() ??
            const <String>[];
        out.addAll(ids);
        if (ids.isEmpty) {
          // Legacy fallback — read cohortIds off each student row.
          for (final s in widget.students) {
            final scs = (s['cohortIds'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const <String>[];
            final sc = s['cohortId']?.toString() ?? '';
            if (scs.contains(cid) || sc == cid) {
              final id = s['id']?.toString();
              if (id != null && id.isNotEmpty) out.add(id);
            }
          }
        }
      }
    }

    // Grade audience — every student whose own grade matches.
    if (audienceGrade != null) {
      for (final s in widget.students) {
        final g = (s['grade'] as num?)?.toInt();
        if (g == audienceGrade) {
          final id = s['id']?.toString();
          if (id != null && id.isNotEmpty) out.add(id);
        }
      }
    }
    return out;
  }

  /// Same resolver, applied to an existing slot row from the periods
  /// provider. Honors both modes the slot can persist in (cohort-mode +
  /// audienceGrade), and reuses the audience helper for the actual lookup.
  Set<String> _studentsForExistingSlot(Map<String, dynamic> slot) {
    final cohortRows = (slot['cohorts'] as List? ?? const []).whereType<Map>().toList();
    final cohortIds = cohortRows
        .map((c) => (c['cohortId'] ?? (c['cohort'] is Map ? c['cohort']['id'] : null))?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    final studentIds = (slot['students'] as List? ?? const [])
        .whereType<Map>()
        .map((s) => s['studentId']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    final ag = (slot['audienceGrade'] as num?)?.toInt();

    return _studentsForAudience(
      cohortIds: cohortIds,
      directStudentIds: studentIds,
      audienceGrade: ag,
    );
    // Note: we deliberately DON'T subtract the slot's skipForStudentIds
    // anymore. That legacy field's filter logic was removed from the
    // server resolver (it stayed sticky after the overriding period was
    // gone), so a student in skipForStudentIds is back to seeing the
    // slot and absolutely needs the conflict warning if we're about to
    // add another period at the same time.
  }

  /// Calendar-date enumeration for a slot's render schedule over the
  /// next year.  Mirrors the server's rendering rules so the conflict
  /// scanner sees the same dates the user would.
  ///   - Once (freq=0): exactly the startDate.
  ///   - Weekly (freq=1): every matching weekday from startDate (or
  ///     today's matching weekday when none) for 52 weeks.
  ///   - Bi-weekly / monthly (freq=2/4/N): startDate + multiples of
  ///     N weeks, on the slot's weekday.
  Set<String> _renderDatesForSlot({
    required int dayOfWeek, // 0=Sun..6=Sat
    required int frequencyWeeks,
    required String? startDate,
  }) {
    final out = <String>{};
    if (frequencyWeeks == 0) {
      if (startDate != null && startDate.length == 10) out.add(startDate);
      return out;
    }
    final step = frequencyWeeks >= 1 ? frequencyWeeks : 1;
    DateTime anchor;
    if (startDate != null && startDate.length == 10) {
      final parsed = DateTime.tryParse(startDate);
      if (parsed == null) return out;
      anchor = DateTime(parsed.year, parsed.month, parsed.day);
    } else {
      // No anchor — start at "today's matching weekday" for weekly slots.
      final today = DateTime.now();
      final base = DateTime(today.year, today.month, today.day);
      final delta = (dayOfWeek - (base.weekday % 7) + 7) % 7;
      anchor = base.add(Duration(days: delta));
    }
    final horizon = anchor.add(const Duration(days: 365));
    var d = anchor;
    while (!d.isAfter(horizon)) {
      out.add(
        '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}',
      );
      d = d.add(Duration(days: step * 7));
    }
    return out;
  }

  /// Per-student conflict scan. For each existing period at the same
  /// (day, slot), intersects its student audience with the draft's,
  /// returning a hit for every existing slot that shares at least one
  /// student with the draft. The Once-anchor date filter still applies
  /// so two never-overlapping one-offs don't trip the warning.
  List<_ConflictHit> _findConflicts({
    required ({List<String>? cohortIds, List<String>? studentIds}) audience,
    required int freq,
    required DateTime? startDate,
  }) {
    final periodsAsync = ref.read(_periodsProvider);
    final all = periodsAsync.maybeWhen(data: (d) => d, orElse: () => const <Map<String, dynamic>>[]);

    final draftCohortIds = (audience.cohortIds ?? const <String>[]).toSet();
    final draftStudentIds = (audience.studentIds ?? const <String>[]).toSet();
    final draftGrade = _audience == _AudienceMode.grade ? _audienceGrade : null;
    final draftStudents = _studentsForAudience(
      cohortIds: draftCohortIds,
      directStudentIds: draftStudentIds,
      audienceGrade: draftGrade,
    );

    final hits = <_ConflictHit>[];
    final editingId = _editingId;
    final draftYmd = startDate != null
        ? '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}'
        : null;
    // Enumerate the dates the draft itself would render on so we can do
    // a real calendar-date intersection against each existing slot.
    // Without this we'd flag bi-weekly slots that share (day, period)
    // but never actually land on the same Monday (different anchor weeks).
    final draftDates = <String>{};
    for (final dr in _slots) {
      draftDates.addAll(_renderDatesForSlot(
        dayOfWeek: dr.dayOfWeek,
        frequencyWeeks: freq,
        startDate: draftYmd,
      ));
    }

    for (final slot in all) {
      if (editingId != null && slot['id']?.toString() == editingId) continue;
      // Same (day, slot) — different periods can coexist; same time can't.
      final drafts = _slots;
      final sameSpot = drafts.any((d) =>
          d.dayOfWeek == (slot['dayOfWeek'] as num?)?.toInt() &&
          d.period == (slot['period'] as num?)?.toInt());
      if (!sameSpot) continue;

      // Real calendar-date intersection. Two recurring slots at the same
      // (day, period) but different bi-weekly anchors never collide on
      // any actual date — don't flag them as conflicting.
      final exFreq = (slot['frequencyWeeks'] as num?)?.toInt() ?? 1;
      final exYmd = slot['startDate']?.toString();
      final exDates = _renderDatesForSlot(
        dayOfWeek: (slot['dayOfWeek'] as num?)?.toInt() ?? 0,
        frequencyWeeks: exFreq,
        startDate: exYmd,
      );
      // Subtract skipDates from the existing slot — if it's already
      // marked as suppressed on the draft's date, no conflict for that
      // date.  (skipForStudentIds intentionally not consulted here; the
      // server resolver ignores it now too.)
      final exSkips = ((slot['skipDates'] as List?) ?? const [])
          .map((e) => e.toString())
          .toSet();
      final exEffective = exDates.where((d) => !exSkips.contains(d)).toSet();
      if (draftDates.intersection(exEffective).isEmpty) continue;

      final exStudents = _studentsForExistingSlot(slot);
      final affected = exStudents.intersection(draftStudents);

      // Teacher clash: the draft's teacher is already teaching at this
      // (day, period) on overlapping dates. Independent of student
      // overlap — even if rosters don't intersect, the teacher can't be
      // in two places at once.
      final exTeacherId = (slot['teacherId']?.toString().trim().isNotEmpty == true
              ? slot['teacherId']?.toString()
              : (slot['teacher'] is Map ? slot['teacher']['id']?.toString() : null))
          ?.trim();
      final draftTeacherId = (_teacherId ?? '').trim();
      final teacherClash = draftTeacherId.isNotEmpty &&
          exTeacherId != null &&
          exTeacherId == draftTeacherId;

      if (affected.isEmpty && !teacherClash) continue;

      // Resolve names from the students DDL so the dialog reads as
      // "Tony, Sara, ...".
      final names = <String>[];
      for (final sid in affected) {
        final s = widget.students.firstWhere(
          (st) => st['id']?.toString() == sid,
          orElse: () => const {},
        );
        final n = s['name']?.toString().trim() ?? '';
        if (n.isNotEmpty) names.add(n);
      }
      names.sort();

      hits.add(_ConflictHit(
        id: slot['id']?.toString() ?? '',
        subject: (slot['subject'] ?? '').toString(),
        teacherName: (slot['teacher'] is Map ? slot['teacher']['name'] : null)?.toString() ?? '',
        audienceLabel: _audienceLabelForSlot(slot),
        frequencyWeeks: exFreq,
        skipDates: ((slot['skipDates'] as List?) ?? const [])
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList(),
        studentDateSkips: ((slot['studentDateSkips'] as List?) ?? const [])
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .toList(),
        affectedStudentIds: affected.toList(),
        affectedStudentNames: names,
        teacherClash: teacherClash,
      ));
      if (hits.length >= 5) break;
    }
    return hits;
  }

  String _audienceLabelForSlot(Map<String, dynamic> slot) {
    final ag = (slot['audienceGrade'] as num?)?.toInt();
    if (ag != null) return 'Grade $ag';
    final names = (slot['cohorts'] as List? ?? const [])
        .whereType<Map>()
        .map((c) => (c['cohort'] is Map ? c['cohort']['name'] : null)?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    if (names.isNotEmpty) {
      return names.length == 1 ? names.first : '${names.first} +${names.length - 1}';
    }
    final n = (slot['students'] as List? ?? const []).length;
    return n > 0 ? '$n student${n == 1 ? '' : 's'}' : '—';
  }

  /// Builds the per-student conflict dialog. Always lists the affected
  /// student names (the whole point of the per-student detection is that
  /// only this subset is double-booked), and offers three resolutions:
  /// override (new wins), keep-current (new hides for those students), or
  /// stack (both render side-by-side). The choice ONLY affects the listed
  /// students — anyone else in either audience keeps seeing what they did.
  Future<_ConflictChoice?> _confirmConflictDialog(
    List<_ConflictHit> hits,
  ) async {
    final affectedAll = <String>{};
    for (final h in hits) {
      affectedAll.addAll(h.affectedStudentNames);
    }
    final names = affectedAll.toList()..sort();
    final preview = names.length <= 6
        ? names.join(', ')
        : '${names.take(6).join(', ')} +${names.length - 6} more';
    final teacherClashHits = hits.where((h) => h.teacherClash).toList();
    final draftTeacherName = (() {
      final id = _teacherId ?? '';
      if (id.isEmpty) return '';
      final t = widget.teachers.firstWhere(
        (e) => e['id']?.toString() == id,
        orElse: () => const {},
      );
      return t['name']?.toString().trim() ?? '';
    })();

    return showDialog<_ConflictChoice>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Conflicting period'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (teacherClashHits.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      draftTeacherName.isNotEmpty
                          ? '$draftTeacherName would have two classes at the same time.'
                          : 'This teacher would have two classes at the same time.',
                    ),
                  ),
                if (affectedAll.isNotEmpty)
                  Text(
                    affectedAll.length == 1
                        ? '${names.isNotEmpty ? names.first : 'A student'} would have two periods at the same time:'
                        : '${affectedAll.length} students would have two periods at the same time:',
                  ),
                const SizedBox(height: 8),
                for (final h in hits)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      '• ${[h.subject, h.audienceLabel, if (h.teacherName.isNotEmpty) h.teacherName].where((s) => s.isNotEmpty).join(' · ')}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                if (names.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Affected: $preview',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  affectedAll.isEmpty
                      ? 'How should this be resolved?'
                      : 'How should this be resolved for those students?',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          actionsOverflowDirection: VerticalDirection.down,
          actionsAlignment: MainAxisAlignment.end,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, _ConflictChoice.cancel),
              child: const Text('Cancel'),
            ),
            // Override + Keep current are always offered.  Both use
            // explicit date enumeration over the draft's render dates
            // (Once = anchor date; recurring = the next year of matching
            // dates), so the suppression's lifetime tracks the draft's
            // schedule, not "forever."
            TextButton(
              onPressed: () => Navigator.pop(ctx, _ConflictChoice.keepCurrent),
              child: const Text('Keep current'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _ConflictChoice.override),
              child: const Text('Override'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, _ConflictChoice.stack),
              child: const Text('Show both'),
            ),
          ],
        );
      },
    );
  }
}

/// Outcomes from the per-student conflict dialog.
/// - `cancel`: bail out, don't save the new period.
/// - `override`: new period wins for the affected students. We patch each
///   existing slot's `skipForStudentIds` to add those ids, so they stop
///   seeing the old period.
/// - `keepCurrent`: existing period wins; the new period gets stamped with
///   the union of affected student ids in `skipForStudentIds` after create
///   so it never renders for them.
/// - `stack`: both periods render side-by-side for the affected students.
enum _ConflictChoice { cancel, override, keepCurrent, stack }

class _ConflictHit {
  final String id;
  final String subject;
  final String teacherName;
  final String audienceLabel;
  final int frequencyWeeks;
  final List<String> skipDates;
  /// Existing studentDateSkips entries on the conflicting slot. We merge
  /// the new entries on top when admin picks Override so we don't blow
  /// away any prior date-scoped suppressions on this slot.
  final List<String> studentDateSkips;
  /// Students who would be double-booked by adding the draft — the
  /// intersection of the existing slot's audience and the draft's. Drives
  /// the dialog copy and the override patch.
  final List<String> affectedStudentIds;
  final List<String> affectedStudentNames;
  /// True when the draft's teacher is the same as this slot's teacher
  /// (the teacher would have two simultaneous classes). Independent of
  /// student overlap — a teacher clash alone is enough to flag a hit.
  final bool teacherClash;
  const _ConflictHit({
    required this.id,
    required this.subject,
    required this.teacherName,
    required this.audienceLabel,
    required this.frequencyWeeks,
    required this.skipDates,
    required this.studentDateSkips,
    required this.affectedStudentIds,
    required this.affectedStudentNames,
    required this.teacherClash,
  });
}

// ── Day + Period row ───────────────────────────────────────────────────────────

class _DayPeriodRow extends StatefulWidget {
  const _DayPeriodRow({
    required this.slot,
    required this.index,
    required this.total,
    required this.defaults,
    required this.onChanged,
    required this.onRemove,
  });

  final _DayPeriodSlot slot;
  final int index;
  final int total;
  final List<Map<String, dynamic>> defaults;
  final VoidCallback onChanged;
  final VoidCallback? onRemove;

  @override
  State<_DayPeriodRow> createState() => _DayPeriodRowState();
}

class _DayPeriodRowState extends State<_DayPeriodRow> {
  static const _dayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const _allDays = [0, 1, 2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Slot ${widget.index + 1}',
                  style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700, color: cs.primary)),
              const Spacer(),
              if (widget.onRemove != null)
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Icon(Icons.close_rounded, size: 18, color: cs.onSurfaceVariant),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Days row — all 7 days
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _allDays.map((d) => ChoiceChip(
              label: Text(_dayShort[d], style: const TextStyle(fontSize: 12)),
              selected: widget.slot.dayOfWeek == d,
              visualDensity: VisualDensity.compact,
              onSelected: (_) {
                setState(() => widget.slot.dayOfWeek = d);
                widget.onChanged();
              },
            )).toList(),
          ),
          const SizedBox(height: 10),
          // Period picker (LiquidGlass style)
          LiquidGlassDropdown<int>(
            label: 'Period',
            value: widget.slot.period,
            items: List.generate(9, (i) => i + 1).map((p) {
              final def = widget.defaults.firstWhere(
                (d) => (d['period'] as num?)?.toInt() == p, orElse: () => const {});
              final hint = def.isNotEmpty && (def['startTime'] ?? '').toString().isNotEmpty
                  ? ' · ${def['startTime']}'
                  : '';
              return LiquidGlassDropdownItem(value: p, label: 'Period $p$hint');
            }).toList(),
            onChanged: (v) {
              setState(() => widget.slot.period = v);
              widget.onChanged();
            },
          ),
        ],
      ),
    );
  }
}

// ── Multi-select picker list ───────────────────────────────────────────────────

class _MultiPickerList extends StatefulWidget {
  const _MultiPickerList({
    required this.items,
    required this.selected,
    required this.nameKey,
    required this.subtitleBuilder,
    required this.searchHint,
    required this.onToggle,
  });

  final List<Map<String, dynamic>> items;
  final Set<String> selected;
  final String nameKey;
  final String? Function(Map<String, dynamic>) subtitleBuilder;
  final String searchHint;
  final void Function(String id) onToggle;

  @override
  State<_MultiPickerList> createState() => _MultiPickerListState();
}

class _MultiPickerListState extends State<_MultiPickerList> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final q = _q.toLowerCase();
    final filtered = widget.items.where((item) {
      final name = (item[widget.nameKey] ?? '').toString().toLowerCase();
      return q.isEmpty || name.contains(q);
    }).toList();

    return Column(
      children: [
        TextField(
          onChanged: (v) => setState(() => _q = v),
          decoration: InputDecoration(
            hintText: widget.searchHint,
            prefixIcon: const Icon(Icons.search_rounded, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          ),
        ),
        const SizedBox(height: 4),
        if (widget.selected.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, size: 14, color: cs.primary),
                const SizedBox(width: 6),
                Text('${widget.selected.length} selected',
                    style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700, color: cs.primary)),
              ],
            ),
          ),
        const SizedBox(height: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final item = filtered[i];
              final id = item['id']?.toString() ?? '';
              final name = item[widget.nameKey]?.toString() ?? '';
              final sub = widget.subtitleBuilder(item);
              final sel = widget.selected.contains(id);
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                value: sel,
                onChanged: (_) => widget.onToggle(id),
                title: Text(name,
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                subtitle: sub != null
                    ? Text(sub,
                        style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant))
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Frequency chip ─────────────────────────────────────────────────────────────

class _FreqChip extends StatelessWidget {
  const _FreqChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? cs.primary : cs.outlineVariant),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

// ── Audience preview/editor ──────────────────────────────────────────────────
//
// The cohort + grade audience pickers both render an editable student list.
// Removing or adding a student auto-flips the period to "individual students"
// (the cohort itself is untouched — only this period's saved audience shape
// changes).  Both previews compute the auto-derived set + universe and hand
// off to [_AudienceEditor] for the actual UI.

typedef AudienceEditCallback = void Function(Set<String> effective, {required bool customized});

// Per-cohort roster cache shared between cohort + grade previews.  Lets us
// stop refetching the same cohort during a single Add Period session and lets
// both widgets benefit from any roster the other has already pulled.
final Map<String, List<Map<String, String>>> _cohortRosterCache = {};

bool _setEq(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);

class _CohortStudentPreview extends ConsumerStatefulWidget {
  const _CohortStudentPreview({
    required this.allStudents,
    required this.selectedCohortIds,
    required this.cohorts,
    required this.onEdited,
  });

  final List<Map<String, dynamic>> allStudents;
  final Set<String> selectedCohortIds;
  final List<Map<String, dynamic>> cohorts;
  final AudienceEditCallback onEdited;

  @override
  ConsumerState<_CohortStudentPreview> createState() =>
      _CohortStudentPreviewState();
}

class _CohortStudentPreviewState extends ConsumerState<_CohortStudentPreview> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchMissingRosters();
  }

  @override
  void didUpdateWidget(covariant _CohortStudentPreview old) {
    super.didUpdateWidget(old);
    if (!_setEq(widget.selectedCohortIds, old.selectedCohortIds)) {
      _fetchMissingRosters();
    }
  }

  Future<void> _fetchMissingRosters() async {
    final missing = widget.selectedCohortIds
        .where((id) => id.isNotEmpty && !_cohortRosterCache.containsKey(id))
        .toList();
    if (missing.isEmpty) return;
    if (mounted) setState(() => _loading = true);
    final repo = ref.read(adminRepositoryProvider);
    for (final cid in missing) {
      try {
        final roster = await repo.getCohortRoster(cid);
        _cohortRosterCache[cid] = roster
            .map((u) => {'id': u.id, 'name': u.name})
            .toList();
      } catch (_) {
        _cohortRosterCache[cid] = const [];
      }
    }
    if (mounted) setState(() {} );
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cohorts = widget.cohorts;
    final selectedCohortIds = widget.selectedCohortIds;
    final allStudents = widget.allStudents;

    final names = cohorts
        .where((c) => selectedCohortIds.contains(c['id']?.toString()))
        .map((c) => c['name']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    // Auto-derived student set: cohort.studentIds → roster cache → student
    // DDL fields, deduped by id.
    final auto = <String, String>{}; // id → name
    final selectedStudentIdsFromCohorts = cohorts
        .where((c) => selectedCohortIds.contains(c['id']?.toString()))
        .expand((c) {
          final ids = c['studentIds'];
          return ids is List ? ids.map((e) => e.toString()) : const <String>[];
        })
        .where((s) => s.isNotEmpty)
        .toSet();
    for (final cid in selectedCohortIds) {
      for (final r in (_cohortRosterCache[cid] ?? const [])) {
        final id = r['id'] ?? '';
        if (id.isNotEmpty) auto[id] = r['name'] ?? '';
      }
    }
    for (final s in allStudents) {
      final sid = s['id']?.toString() ?? '';
      if (sid.isEmpty) continue;
      bool belongs = selectedStudentIdsFromCohorts.contains(sid);
      if (!belongs) {
        final ids = (s['cohortIds'] as List?)
                ?.map((e) => e.toString())
                .where((e) => e.isNotEmpty)
                .toList() ??
            const <String>[];
        if (ids.any(selectedCohortIds.contains)) belongs = true;
      }
      if (!belongs) {
        final cid = s['cohortId']?.toString() ?? '';
        if (cid.isNotEmpty && selectedCohortIds.contains(cid)) belongs = true;
      }
      if (!belongs) {
        final cn = s['cohortName']?.toString() ?? '';
        if (cn.isNotEmpty && names.any((n) => n == cn)) belongs = true;
      }
      if (!belongs) {
        final cnList = (s['cohortNames'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
        if (cnList.any(names.contains)) belongs = true;
      }
      if (belongs) {
        auto[sid] = (s['name']?.toString() ?? auto[sid] ?? '');
      }
    }

    final selectionKey = (selectedCohortIds.toList()..sort()).join(',');

    return _AudienceEditor(
      key: ValueKey('cohort:$selectionKey'),
      accent: cs.primary,
      autoStudents: auto,
      allCandidates: allStudents,
      countLabelBuilder: (n) =>
          '$n student${n == 1 ? '' : 's'} in selected cohort${selectedCohortIds.length == 1 ? '' : 's'}',
      loading: _loading,
      onChanged: widget.onEdited,
    );
  }
}

// ── Grade student preview ────────────────────────────────────────────────────
// Mirrors _CohortStudentPreview but resolves membership through the cohorts
// that target the picked grade — so admins picking "By Grade" see exactly who
// the period will land on before they commit.
class _GradeStudentPreview extends ConsumerStatefulWidget {
  const _GradeStudentPreview({
    required this.allStudents,
    required this.cohorts,
    required this.grade,
    required this.onEdited,
  });

  final List<Map<String, dynamic>> allStudents;
  final List<Map<String, dynamic>> cohorts;
  final int grade;
  final AudienceEditCallback onEdited;

  @override
  ConsumerState<_GradeStudentPreview> createState() =>
      _GradeStudentPreviewState();
}

class _GradeStudentPreviewState extends ConsumerState<_GradeStudentPreview> {
  bool _loading = false;

  List<int> _cohortGradesOf(Map<String, dynamic> c) {
    final raw = c['grades'];
    if (raw is List) {
      return raw
          .map((e) => e is int ? e : int.tryParse(e?.toString() ?? ''))
          .whereType<int>()
          .toList();
    }
    final single = c['grade'];
    if (single is int) return [single];
    if (single is String) {
      final n = int.tryParse(single);
      if (n != null) return [n];
    }
    return const [];
  }

  @override
  void initState() {
    super.initState();
    _fetchMissingRosters();
  }

  @override
  void didUpdateWidget(covariant _GradeStudentPreview old) {
    super.didUpdateWidget(old);
    if (old.grade != widget.grade || old.cohorts.length != widget.cohorts.length) {
      _fetchMissingRosters();
    }
  }

  Future<void> _fetchMissingRosters() async {
    final cohortIds = widget.cohorts
        .where((c) => _cohortGradesOf(c).contains(widget.grade))
        .map((c) => c['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .where((id) => !_cohortRosterCache.containsKey(id))
        .toList();
    if (cohortIds.isEmpty) return;
    if (mounted) setState(() => _loading = true);
    final repo = ref.read(adminRepositoryProvider);
    for (final cid in cohortIds) {
      try {
        final roster = await repo.getCohortRoster(cid);
        _cohortRosterCache[cid] = roster
            .map((u) => {'id': u.id, 'name': u.name})
            .toList();
      } catch (_) {
        _cohortRosterCache[cid] = const [];
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final allStudents = widget.allStudents;
    final cohorts = widget.cohorts;
    final grade = widget.grade;

    final cohortsForGrade =
        cohorts.where((c) => _cohortGradesOf(c).contains(grade)).toList();
    final cohortIdsForGrade = cohortsForGrade
        .map((c) => c['id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    final cohortNamesForGrade = cohortsForGrade
        .map((c) => c['name']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toSet();
    final studentIdsForGrade = cohortsForGrade
        .expand((c) {
          final ids = c['studentIds'];
          return ids is List ? ids.map((e) => e.toString()) : const <String>[];
        })
        .where((s) => s.isNotEmpty)
        .toSet();

    final auto = <String, String>{};
    for (final cid in cohortIdsForGrade) {
      for (final r in (_cohortRosterCache[cid] ?? const [])) {
        final id = r['id'] ?? '';
        if (id.isNotEmpty) auto[id] = r['name'] ?? '';
      }
    }
    for (final s in allStudents) {
      final sid = s['id']?.toString() ?? '';
      if (sid.isEmpty) continue;
      bool belongs = studentIdsForGrade.contains(sid);
      if (!belongs) {
        final ids = (s['cohortIds'] as List?)
                ?.map((e) => e.toString())
                .where((e) => e.isNotEmpty)
                .toList() ??
            const <String>[];
        if (ids.any(cohortIdsForGrade.contains)) belongs = true;
      }
      if (!belongs) {
        final cid = s['cohortId']?.toString() ?? '';
        if (cid.isNotEmpty && cohortIdsForGrade.contains(cid)) belongs = true;
      }
      if (!belongs) {
        final cn = s['cohortName']?.toString() ?? '';
        if (cn.isNotEmpty && cohortNamesForGrade.contains(cn)) belongs = true;
      }
      if (!belongs) {
        final cnList = (s['cohortNames'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
        if (cnList.any(cohortNamesForGrade.contains)) belongs = true;
      }
      // Standalone grade-N students — admin set their grade level on the
      // profile but they aren't in any cohort yet.  Include them so "By
      // Grade" actually means everyone at that grade level.
      if (!belongs) {
        final g = s['grade'];
        final gn = g is int ? g : (g is num ? g.toInt() : int.tryParse('$g'));
        if (gn == grade) belongs = true;
      }
      if (belongs) {
        auto[sid] = (s['name']?.toString() ?? auto[sid] ?? '');
      }
    }

    return _AudienceEditor(
      key: ValueKey('grade:$grade'),
      accent: cs.primary,
      autoStudents: auto,
      allCandidates: allStudents,
      countLabelBuilder: (n) =>
          '$n ${n == 1 ? 'student' : 'students'} in Grade $grade',
      loading: _loading,
      onChanged: widget.onEdited,
    );
  }
}

// ── Shared audience editor ───────────────────────────────────────────────────

class _AudienceEditor extends StatefulWidget {
  const _AudienceEditor({
    super.key,
    required this.accent,
    required this.autoStudents,
    required this.allCandidates,
    required this.countLabelBuilder,
    required this.loading,
    required this.onChanged,
  });

  /// Container/accent color (primary).
  final Color accent;

  /// id → name auto-derived from the current cohort/grade selection. The
  /// editor seeds [effective] from this; if more students arrive later (e.g.
  /// roster fetch resolves), they get unioned in unless the admin has already
  /// customized the list.
  final Map<String, String> autoStudents;

  /// Universe used to populate the Add Student picker.
  final List<Map<String, dynamic>> allCandidates;

  final String Function(int count) countLabelBuilder;
  final bool loading;
  final AudienceEditCallback onChanged;

  @override
  State<_AudienceEditor> createState() => _AudienceEditorState();
}

class _AudienceEditorState extends State<_AudienceEditor> {
  /// Live set the admin is editing.
  final Map<String, String> _effective = {};

  /// Snapshot of the auto-derived set the admin last accepted as the baseline.
  /// Used to determine whether the current [_effective] is "customized" (admin
  /// has diverged) — when they revert to exactly this, the period saves as a
  /// clean cohort/grade period again.
  Set<String> _baseline = const {};

  bool _customized = false;

  @override
  void initState() {
    super.initState();
    _effective.addAll(widget.autoStudents);
    _baseline = widget.autoStudents.keys.toSet();
    // Notify parent of initial set so save logic resolves correctly even
    // without any user edits.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onChanged(_effective.keys.toSet(), customized: _customized);
    });
  }

  @override
  void didUpdateWidget(covariant _AudienceEditor old) {
    super.didUpdateWidget(old);
    // If the auto set grew (e.g. roster fetch landed) and admin hasn't
    // customized yet, union the new entries in so they see the full list.
    if (!_customized) {
      final newKeys = widget.autoStudents.keys.toSet();
      if (!_setEq(newKeys, _baseline)) {
        _effective
          ..clear()
          ..addAll(widget.autoStudents);
        _baseline = newKeys;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          widget.onChanged(_effective.keys.toSet(), customized: false);
        });
      }
    }
  }

  void _recomputeCustomized() {
    final current = _effective.keys.toSet();
    final isCustom = !_setEq(current, _baseline);
    if (isCustom != _customized) _customized = isCustom;
    widget.onChanged(current, customized: _customized);
  }

  void _remove(String id) {
    setState(() {
      _effective.remove(id);
      _recomputeCustomized();
    });
  }

  Future<void> _openAddSheet() async {
    final pool = widget.allCandidates
        .where((s) {
          final id = s['id']?.toString() ?? '';
          return id.isNotEmpty && !_effective.containsKey(id);
        })
        .toList();
    final picked = await showModalBottomSheet<List<Map<String, String>>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddStudentsSheet(pool: pool),
    );
    if (picked == null || picked.isEmpty) return;
    setState(() {
      for (final s in picked) {
        final id = s['id'] ?? '';
        if (id.isNotEmpty) _effective[id] = s['name'] ?? '';
      }
      _recomputeCustomized();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final count = _effective.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_rounded, size: 14, color: widget.accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.countLabelBuilder(count),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: widget.accent,
                  ),
                ),
              ),
              if (widget.loading)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: widget.accent),
                ),
            ],
          ),
          if (_customized) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_pin_circle_rounded, size: 12, color: cs.onTertiaryContainer),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Customized — saved as individual students',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (_effective.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ..._effective.entries.take(40).map((e) {
                  final name = e.value;
                  return InputChip(
                    label: Text(
                      name,
                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    onDeleted: () => _remove(e.key),
                    deleteIcon: const Icon(Icons.close_rounded, size: 14),
                    backgroundColor: cs.surface,
                    side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }),
                if (_effective.length > 40)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '+${_effective.length - 40} more',
                      style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _openAddSheet,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              label: const Text('Add student'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                visualDensity: VisualDensity.compact,
                minimumSize: const Size(0, 32),
                foregroundColor: widget.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddStudentsSheet extends StatefulWidget {
  const _AddStudentsSheet({required this.pool});
  final List<Map<String, dynamic>> pool;

  @override
  State<_AddStudentsSheet> createState() => _AddStudentsSheetState();
}

class _AddStudentsSheetState extends State<_AddStudentsSheet> {
  String _q = '';
  final Set<String> _picked = {};

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final q = _q.trim().toLowerCase();
    final filtered = widget.pool.where((s) {
      if (q.isEmpty) return true;
      final name = (s['name'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add students',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextButton(
                    onPressed: _picked.isEmpty
                        ? null
                        : () {
                            final result = widget.pool
                                .where((s) => _picked.contains(s['id']?.toString()))
                                .map((s) => {
                                      'id': (s['id'] ?? '').toString(),
                                      'name': (s['name'] ?? '').toString(),
                                    })
                                .toList();
                            Navigator.of(context).pop(result);
                          },
                    child: Text('Add (${_picked.length})'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => setState(() => _q = v),
                decoration: InputDecoration(
                  hintText: 'Search students…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No students match.',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final item = filtered[i];
                        final id = item['id']?.toString() ?? '';
                        final name = item['name']?.toString() ?? '';
                        final grade = item['grade'];
                        final cn = item['cohortName']?.toString() ?? '';
                        final sub = grade != null
                            ? 'Grade $grade${cn.isNotEmpty ? ' · $cn' : ''}'
                            : (cn.isNotEmpty ? cn : null);
                        final sel = _picked.contains(id);
                        return CheckboxListTile(
                          dense: true,
                          value: sel,
                          onChanged: (_) => setState(() {
                            if (sel) {
                              _picked.remove(id);
                            } else {
                              _picked.add(id);
                            }
                          }),
                          title: Text(name,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          subtitle: sub == null ? null : Text(sub,
                              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
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

// ── Grid square periods sheet ────────────────────────────────────────────────
//
// Tapping a square in the schedule grid opens this sheet — it lists every
// period sitting at (day, period), each with its color + subject + teacher +
// cohort/student summary and a delete button, plus an Add Period CTA.

enum _SquareSheetActionKind { add, edit }

class _SquareSheetAction {
  const _SquareSheetAction.add() : kind = _SquareSheetActionKind.add, slot = null;
  const _SquareSheetAction.edit(this.slot) : kind = _SquareSheetActionKind.edit;
  final _SquareSheetActionKind kind;
  final Map<String, dynamic>? slot;
}

class _SquarePeriodsSheet extends ConsumerStatefulWidget {
  const _SquarePeriodsSheet({
    required this.day,
    required this.period,
    required this.slots,
    required this.onDelete,
  });

  final int day;
  final int period;
  final List<Map<String, dynamic>> slots;
  final Future<bool> Function(String slotId) onDelete;

  @override
  ConsumerState<_SquarePeriodsSheet> createState() =>
      _SquarePeriodsSheetState();
}

class _SquarePeriodsSheetState extends ConsumerState<_SquarePeriodsSheet> {
  static const _dayLong = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  /// Working copy — lets us strip rows out optimistically on delete without
  /// having to round-trip through the parent rebuild.
  late List<Map<String, dynamic>> _slots;

  @override
  void initState() {
    super.initState();
    _slots = List<Map<String, dynamic>>.from(widget.slots);
  }

  Future<void> _delete(Map<String, dynamic> slot) async {
    final id = slot['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete period?'),
        content: const Text('This removes the slot from the schedule. Past attendance stays.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    final ok = await widget.onDelete(id);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _slots.removeWhere((s) => (s['id']?.toString() ?? '') == id);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete period.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final subjectColors = ref.watch(_subjectColorsProvider).maybeWhen(
          data: (m) => m,
          orElse: () => const <String, String>{},
        );

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${_dayLong[widget.day]} · Period ${widget.period}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context, const _SquareSheetAction.add()),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add period'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: _slots.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      child: Text(
                        'No periods here yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                      itemCount: _slots.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) => _SquareSlotTile(
                        slot: _slots[i],
                        subjectColors: subjectColors,
                        onDelete: () => _delete(_slots[i]),
                        onTap: () => Navigator.pop(
                          context,
                          _SquareSheetAction.edit(_slots[i]),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

}

class _SquareSlotTile extends ConsumerStatefulWidget {
  const _SquareSlotTile({
    required this.slot,
    required this.subjectColors,
    required this.onDelete,
    required this.onTap,
  });

  final Map<String, dynamic> slot;
  final Map<String, String> subjectColors;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  ConsumerState<_SquareSlotTile> createState() => _SquareSlotTileState();
}

class _SquareSlotTileState extends ConsumerState<_SquareSlotTile> {
  bool _expanded = false;
  bool _loadingRoster = false;

  /// Cohort name + optional grade label, formatted for the audience header.
  String _cohortDisplayLabel(Map cohortRow) {
    final cohort = cohortRow['cohort'];
    if (cohort is! Map) return '';
    final name = cohort['name']?.toString() ?? '';
    final grades = cohort['grades'];
    String? gradeLabel;
    if (grades is List && grades.isNotEmpty) {
      final ints = grades
          .map((e) => e is int ? e : int.tryParse('$e'))
          .whereType<int>()
          .toList()
        ..sort();
      if (ints.length == 1) {
        gradeLabel = 'Grade ${ints.first}';
      } else {
        final contiguous = ints.last - ints.first == ints.length - 1;
        gradeLabel = contiguous
            ? 'Grade ${ints.first}-${ints.last}'
            : 'Grades ${ints.join(', ')}';
      }
    } else {
      final g = cohort['grade'];
      if (g is int) gradeLabel = 'Grade $g';
      if (g is num) gradeLabel = 'Grade ${g.toInt()}';
    }
    if (name.isEmpty && gradeLabel == null) return '';
    if (name.isEmpty) return gradeLabel!;
    if (gradeLabel == null) return name;
    return '$name · $gradeLabel';
  }

  Future<void> _toggleExpand(List<Map<String, dynamic>> cohortRows) async {
    if (_expanded) {
      setState(() => _expanded = false);
      return;
    }
    // Pull rosters for any cohort we haven't cached yet — the shared
    // _cohortRosterCache lets us reuse work the Add Period previews did.
    final missing = cohortRows
        .map((c) =>
            (c['cohortId'] ?? (c['cohort'] is Map ? c['cohort']['id'] : null))
                ?.toString() ??
            '')
        .where((id) => id.isNotEmpty && !_cohortRosterCache.containsKey(id))
        .toList();
    if (missing.isNotEmpty) {
      setState(() => _loadingRoster = true);
      final repo = ref.read(adminRepositoryProvider);
      for (final cid in missing) {
        try {
          final roster = await repo.getCohortRoster(cid);
          _cohortRosterCache[cid] = roster
              .map((u) => {'id': u.id, 'name': u.name})
              .toList();
        } catch (_) {
          _cohortRosterCache[cid] = const [];
        }
      }
      if (!mounted) return;
    }
    setState(() {
      _loadingRoster = false;
      _expanded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final slot = widget.slot;
    final subject = slot['subject']?.toString() ?? '';
    final teacherName = slot['teacher'] is Map ? (slot['teacher']['name']?.toString() ?? '') : '';

    final cohortRows = (slot['cohorts'] as List? ?? [])
        .whereType<Map>()
        .map((c) => Map<String, dynamic>.from(c))
        .where((c) => c['cohort'] is Map)
        .toList();
    final students = (slot['students'] as List? ?? [])
        .whereType<Map>()
        .map((s) => (s['student'] is Map && s['student']['user'] is Map
                ? s['student']['user']['name']
                : null)
            ?.toString() ??
            '')
        .where((n) => n.isNotEmpty)
        .toList();
    final freq = (slot['frequencyWeeks'] as num?)?.toInt() ?? 1;

    final slotHex = slot['color']?.toString();
    final subjectHex = subject.isNotEmpty ? widget.subjectColors[subject.toLowerCase()] : null;
    final color = parseSubjectColor(slotHex)
        ?? parseSubjectColor(subjectHex)
        ?? subjectColorOrFallback(null, subject.isNotEmpty ? subject : teacherName);

    final isCohortPeriod = cohortRows.isNotEmpty;
    // Prefer a single "Grade N" label when the slot's cohorts cover every
    // cohort at that grade — that's how the admin originally picked it.
    final allCohorts = ref.watch(_cohortsDdlProvider).maybeWhen(
          data: (d) => d,
          orElse: () => const <Map<String, dynamic>>[],
        );
    final gradeForSlot = slotAudienceGrade(slot, allCohorts);
    final cohortLabels = gradeForSlot != null
        ? <String>['Grade $gradeForSlot']
        : cohortRows.map(_cohortDisplayLabel).where((s) => s.isNotEmpty).toList();

    // For cohort/grade periods we lazily fetch the union of cohort rosters
    // on first expand.  Individual-student periods skip the chevron entirely
    // and just list the names directly.
    List<String> expandedNames = const [];
    if (isCohortPeriod && _expanded) {
      final seen = <String>{};
      final names = <String>[];
      for (final c in cohortRows) {
        final cid =
            (c['cohortId'] ?? (c['cohort'] is Map ? c['cohort']['id'] : null))
                ?.toString() ??
                '';
        if (cid.isEmpty) continue;
        for (final r in (_cohortRosterCache[cid] ?? const [])) {
          final id = r['id'] ?? '';
          final name = r['name'] ?? '';
          if (id.isEmpty || !seen.add(id)) continue;
          if (name.isNotEmpty) names.add(name);
        }
      }
      expandedNames = names;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          decoration: BoxDecoration(
            color: Color.alphaBlend(color.withValues(alpha: 0.12), cs.surface),
            borderRadius: BorderRadius.circular(14),
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.isNotEmpty ? subject : (teacherName.isNotEmpty ? teacherName : 'Period'),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (teacherName.isNotEmpty && subject.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          teacherName,
                          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),

                    // ── Audience block ────────────────────────────────────
                    if (isCohortPeriod) ...[
                      const SizedBox(height: 6),
                      // The whole row is the expand toggle; isolate it from
                      // the parent InkWell with a separate GestureDetector
                      // so tapping it doesn't fall through to "edit period."
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _toggleExpand(cohortRows),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.groups_rounded, size: 14, color: color),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  cohortLabels.join(' · '),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              if (_loadingRoster)
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(strokeWidth: 1.5, color: color),
                                )
                              else
                                AnimatedRotation(
                                  duration: const Duration(milliseconds: 180),
                                  turns: _expanded ? 0.5 : 0.0,
                                  child: Icon(Icons.expand_more_rounded,
                                      size: 18, color: cs.onSurfaceVariant),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (_expanded) ...[
                        const SizedBox(height: 4),
                        if (expandedNames.isEmpty)
                          Text(
                            'No students in these cohorts yet.',
                            style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          )
                        else
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: expandedNames
                                .map((n) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: cs.surface,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: cs.outlineVariant.withValues(alpha: 0.5)),
                                      ),
                                      child: Text(n, style: theme.textTheme.labelSmall),
                                    ))
                                .toList(),
                          ),
                      ],
                    ] else if (students.isNotEmpty) ...[
                      // Individual-student period — no expand affordance,
                      // just list the names directly.
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: students
                            .map((n) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: cs.surface,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: cs.outlineVariant.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(n, style: theme.textTheme.labelSmall),
                                ))
                            .toList(),
                      ),
                    ],

                    if (freq > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Every $freq weeks',
                          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                tooltip: 'Delete period',
                onPressed: widget.onDelete,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Period color row ─────────────────────────────────────────────────────────
//
// Compact swatch strip in Add Period.  Defaults to the subject's color (set in
// the subject editor); admin can tap a swatch to override just for this slot,
// or hit the auto/reset tile to fall back.

class _PeriodColorRow extends StatefulWidget {
  const _PeriodColorRow({
    required this.subjectName,
    required this.repo,
    required this.colorOverride,
    required this.onChanged,
  });

  final String? subjectName;
  final AdminRepository repo;
  final String? colorOverride;
  final ValueChanged<String?> onChanged;

  @override
  State<_PeriodColorRow> createState() => _PeriodColorRowState();
}

class _PeriodColorRowState extends State<_PeriodColorRow> {
  /// Session-level cache so we don't hit /admin/subjects/all every rebuild.
  static List<SchoolSubject>? _cachedSubjects;
  static Future<List<SchoolSubject>>? _inFlight;

  late Future<List<SchoolSubject>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadSubjects();
  }

  Future<List<SchoolSubject>> _loadSubjects() async {
    if (_cachedSubjects != null) return _cachedSubjects!;
    final pending = _inFlight ??= widget.repo.listAllSchoolSubjects().then((v) {
      _cachedSubjects = v;
      _inFlight = null;
      return v;
    }).catchError((_) {
      _inFlight = null;
      return <SchoolSubject>[];
    });
    return pending;
  }

  String? _subjectHex(List<SchoolSubject> subjects) {
    final n = (widget.subjectName ?? '').trim();
    if (n.isEmpty) return null;
    for (final s in subjects) {
      if (s.nameEn.trim().toLowerCase() == n.toLowerCase()) return s.color;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return FutureBuilder<List<SchoolSubject>>(
      future: _future,
      builder: (ctx, snap) {
        final subjects = snap.data ?? const <SchoolSubject>[];
        final subjectHex = _subjectHex(subjects);
        final seed = (widget.subjectName ?? '').trim();
        // What the period would render as today, given override > subject > fallback.
        final effective = parseSubjectColor(widget.colorOverride)
            ?? parseSubjectColor(subjectHex)
            ?? subjectColorOrFallback(null, seed);
        final hasOverride = widget.colorOverride != null;

        return Row(
          children: [
            Text(
              'Color',
              style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: effective,
                shape: BoxShape.circle,
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Auto/reset — match subject color (or fallback)
                    _MiniSwatch(
                      color: parseSubjectColor(subjectHex)
                          ?? subjectColorOrFallback(null, seed),
                      selected: !hasOverride,
                      icon: Icons.auto_awesome_rounded,
                      onTap: () => widget.onChanged(null),
                    ),
                    const SizedBox(width: 6),
                    ...kSubjectPalette.map((c) {
                      final hex = colorToHex(c);
                      final isSelected = hasOverride && sameRgb(parseSubjectColor(widget.colorOverride)!, c);
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _MiniSwatch(
                          color: c,
                          selected: isSelected,
                          onTap: () => widget.onChanged(hex),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MiniSwatch extends StatelessWidget {
  const _MiniSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
            width: selected ? 2 : 1,
          ),
        ),
        child: icon != null
            ? Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.9))
            : (selected ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null),
      ),
    );
  }
}

// ── Subject picker ────────────────────────────────────────────────────────────
// Three modes packed behind one chip:
//   1. Pick from the school's defined subjects (fetched on first tap)
//   2. Type freeform on the spot
//   3. Create a new full 5-language subject and persist it to the school

class _SubjectPickerField extends StatelessWidget {
  const _SubjectPickerField({
    required this.repo,
    required this.value,
    required this.cohorts,
    required this.selectedCohortIds,
    required this.audienceGrade,
    required this.audience,
    required this.onChanged,
  });

  final AdminRepository repo;
  final String? value;
  final List<Map<String, dynamic>> cohorts;
  final Set<String> selectedCohortIds;
  final int? audienceGrade;
  final _AudienceMode audience;
  final ValueChanged<String?> onChanged;

  /// Grades that this slot's audience currently targets — used to decide
  /// which SchoolGradeSubjectDefault rows a brand-new subject should land in.
  List<int> _targetedGrades() {
    switch (audience) {
      case _AudienceMode.grade:
        return audienceGrade != null ? [audienceGrade!] : const [];
      case _AudienceMode.cohort:
        final grades = <int>{};
        for (final c in cohorts) {
          if (!selectedCohortIds.contains(c['id']?.toString())) continue;
          final raw = c['grades'];
          if (raw is List && raw.isNotEmpty) {
            for (final g in raw) {
              grades.add((g as num).toInt());
            }
          } else {
            final g = (c['grade'] as num?)?.toInt();
            if (g != null) grades.add(g);
          }
        }
        return grades.toList()..sort();
      case _AudienceMode.student:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final hasValue = (value ?? '').trim().isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.menu_book_rounded, size: 18, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasValue ? value! : 'Subject *',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: hasValue ? FontWeight.w700 : FontWeight.w500,
                  color: hasValue ? cs.onSurface : cs.onSurfaceVariant,
                ),
              ),
            ),
            if (hasValue)
              IconButton(
                icon: Icon(Icons.clear_rounded, size: 18, color: cs.onSurfaceVariant),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                onPressed: () => onChanged(null),
              )
            else
              Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SubjectPickerSheet(
        repo: repo,
        currentValue: value,
        targetGrades: _targetedGrades(),
      ),
    );
    if (picked != null) onChanged(picked.isEmpty ? null : picked);
  }
}

class _SubjectPickerSheet extends StatefulWidget {
  const _SubjectPickerSheet({
    required this.repo,
    required this.currentValue,
    required this.targetGrades,
  });

  final AdminRepository repo;
  final String? currentValue;
  final List<int> targetGrades;

  @override
  State<_SubjectPickerSheet> createState() => _SubjectPickerSheetState();
}

class _SubjectPickerSheetState extends State<_SubjectPickerSheet> {
  late Future<List<SchoolSubject>> _subjectsFuture;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _subjectsFuture = widget.repo.listAllSchoolSubjects();
  }

  Future<void> _createNew() async {
    final created = await Navigator.of(context, rootNavigator: true)
        .push<SchoolSubject>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const AdminSubjectDetailScreen(initial: SchoolSubject(nameEn: '')),
      ),
    );
    if (created == null || created.nameEn.trim().isEmpty) return;

    // Persist to the school's subjects library — but only if we know which
    // grades to add to. Otherwise it's used once as the slot label and
    // skipped from the library (admin can add it via School Settings later).
    if (widget.targetGrades.isNotEmpty) {
      try {
        await widget.repo.addSubjectToGrades(grades: widget.targetGrades, subject: created);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Saved as slot label only — couldn\'t add to library: $e')),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved as slot label. Pick an audience first to also add to the school library.')),
      );
    }

    if (!mounted) return;
    Navigator.pop(context, created.nameEn.trim());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Subject',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _createNew,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add new'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Search across existing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search school subjects…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<SchoolSubject>>(
                future: _subjectsFuture,
                builder: (ctx, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data ?? const <SchoolSubject>[];
                  final q = _search.trim().toLowerCase();
                  final filtered = q.isEmpty
                      ? all
                      : all.where((s) => s.nameEn.toLowerCase().contains(q)).toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          all.isEmpty
                              ? 'No school subjects yet. Tap "Add new" to define one.'
                              : 'No subjects match your search.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (lctx, i) {
                      final s = filtered[i];
                      final selected = widget.currentValue == s.nameEn;
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.pop(context, s.nameEn),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: subjectColorOrFallback(s.color, s.nameEn),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: cs.outlineVariant.withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.nameEn,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                        color: selected ? cs.primary : cs.onSurface,
                                      ),
                                    ),
                                    if (_otherLangs(s).isNotEmpty)
                                      Text(
                                        _otherLangs(s),
                                        style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              if (selected) Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _otherLangs(SchoolSubject s) => [
        if ((s.nameAr ?? '').isNotEmpty) s.nameAr!,
        if ((s.nameHe ?? '').isNotEmpty) s.nameHe!,
        if ((s.nameFr ?? '').isNotEmpty) s.nameFr!,
        if ((s.nameRu ?? '').isNotEmpty) s.nameRu!,
      ].join(' · ');
}
