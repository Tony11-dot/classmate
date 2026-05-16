// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/admin_repository.dart';

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

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminScheduleScreen extends ConsumerStatefulWidget {
  const AdminScheduleScreen({super.key});

  @override
  ConsumerState<AdminScheduleScreen> createState() => _AdminScheduleScreenState();
}

class _AdminScheduleScreenState extends ConsumerState<AdminScheduleScreen> {
  // Filter
  String _filterMode = 'all'; // all | cohort | grade | student
  String? _filterCohortId;
  int?    _filterGrade;
  String? _filterStudentId;

  bool _slotMatchesFilter(Map<String, dynamic> slot) {
    if (_filterMode == 'all') return true;
    final cohortsList = slot['cohorts'] as List? ?? [];
    final studentsList = slot['students'] as List? ?? [];
    if (_filterMode == 'cohort' && _filterCohortId != null) {
      return cohortsList.any((c) => (c is Map ? (c['cohortId'] ?? c['cohort']?['id']) : null)?.toString() == _filterCohortId);
    }
    if (_filterMode == 'grade' && _filterGrade != null) {
      return cohortsList.any((c) => c is Map && (c['cohort'] is Map ? c['cohort']['grade'] : null) == _filterGrade);
    }
    if (_filterMode == 'student' && _filterStudentId != null) {
      return studentsList.any((s) => s is Map && s['studentId']?.toString() == _filterStudentId);
    }
    return false;
  }

  Future<void> _openAddPeriod({int? preDay, int? prePeriod, String? preCohortId, String? preStudentId, int? preGrade}) async {
    final teachers = await ref.read(_teachersDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final cohorts  = await ref.read(_cohortsDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final students = await ref.read(_studentsDdlProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    final defaults = await ref.read(_defaultsProvider.future).catchError((_) => <Map<String, dynamic>>[]);
    if (!mounted) return;

    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminAddPeriodScreen(
        repo: ref.read(adminRepositoryProvider),
        teachers: teachers, cohorts: cohorts, students: students, defaults: defaults,
        initialDay: preDay, initialPeriod: prePeriod,
        initialCohortId: preCohortId, initialStudentId: preStudentId,
        initialGrade: preGrade,
      )),
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
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_admin_schedule',
        onPressed: () => _openAddPeriod(),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.adminScheduleAddPeriod),
      ),
      body: Column(
        children: [
          // ── Filter bar ────────────────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _FilterChipItem(label: 'All', selected: _filterMode == 'all',
                    onTap: () => setState(() { _filterMode = 'all'; })),
                const SizedBox(width: 6),
                // Grade filter
                _FilterChipItem(
                  label: _filterMode == 'grade' ? 'Grade $_filterGrade ▾' : 'By Grade ▾',
                  selected: _filterMode == 'grade',
                  onTap: () async {
                    final picked = await showLiquidGlassPicker<int>(
                      context: context,
                      title: 'By Grade',
                      currentValue: _filterGrade ?? -1,
                      items: allGrades.map((g) => LiquidGlassDropdownItem(value: g, label: 'Grade $g')).toList(),
                    );
                    if (picked != null) setState(() { _filterMode = 'grade'; _filterGrade = picked; });
                  },
                ),
                const SizedBox(width: 6),
                // Cohort filter
                _FilterChipItem(
                  label: _filterMode == 'cohort'
                      ? '${allCohorts.firstWhere((c) => c['id']?.toString() == _filterCohortId, orElse: () => const {})['name']?.toString() ?? 'Cohort'} ▾'
                      : 'By Cohort ▾',
                  selected: _filterMode == 'cohort',
                  onTap: () async {
                    final picked = await showLiquidGlassPicker<String>(
                      context: context,
                      title: 'By Cohort',
                      currentValue: _filterCohortId ?? '',
                      items: allCohorts.map((c) => LiquidGlassDropdownItem(
                        value: c['id']?.toString() ?? '',
                        label: c['name']?.toString() ?? '',
                      )).toList(),
                    );
                    if (picked != null && picked.isNotEmpty) setState(() { _filterMode = 'cohort'; _filterCohortId = picked; });
                  },
                ),
                const SizedBox(width: 6),
                // Student filter
                _FilterChipItem(
                  label: _filterMode == 'student'
                      ? '${allStudents.firstWhere((s) => s['id']?.toString() == _filterStudentId, orElse: () => const {})['name']?.toString() ?? 'Student'} ▾'
                      : 'By Student ▾',
                  selected: _filterMode == 'student',
                  onTap: () async {
                    final picked = await showLiquidGlassPicker<String>(
                      context: context,
                      title: 'By Student',
                      currentValue: _filterStudentId ?? '',
                      items: allStudents.map((s) => LiquidGlassDropdownItem(
                        value: s['id']?.toString() ?? '',
                        label: s['name']?.toString() ?? '',
                      )).toList(),
                    );
                    if (picked != null && picked.isNotEmpty) setState(() { _filterMode = 'student'; _filterStudentId = picked; });
                  },
                ),
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
                final filtered = allPeriods.where(_slotMatchesFilter).toList();
                final grid = <(int, int), List<Map<String, dynamic>>>{};
                for (final s in filtered) {
                  final k = ((s['dayOfWeek'] as num?)?.toInt() ?? 0, (s['period'] as num?)?.toInt() ?? 1);
                  grid.putIfAbsent(k, () => []).add(s);
                }

                return _ScheduleGrid(
                  grid: grid,
                  onCellTap: (day, period) => _openAddPeriod(
                    preDay: day,
                    prePeriod: period,
                    preCohortId: _filterMode == 'cohort' ? _filterCohortId : null,
                    preStudentId: _filterMode == 'student' ? _filterStudentId : null,
                    preGrade: _filterMode == 'grade' ? _filterGrade : null,
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
  const _ScheduleGrid({required this.grid, required this.onCellTap});

  final Map<(int, int), List<Map<String, dynamic>>> grid;
  final void Function(int day, int period) onCellTap;

  static const _dayShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const double _headerH = 36;
  static const double _headerW = 48;
  static const double _cellW   = 110;
  static const double _cellH   = 90;
  static const int _periods    = 9;
  static const int _days       = 7;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final totalW = _headerW + _days * _cellW;
    final totalH = _headerH + _periods * _cellH;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(40),
      minScale: 0.45,
      maxScale: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: totalW,
          height: totalH,
          child: Column(
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
              // Period rows
              ...List.generate(_periods, (pi) {
                final period = pi + 1;
                return Row(
                  children: [
                    // Period label
                    Container(
                      width: _headerW,
                      height: _cellH,
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
        height: height,
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
          color: hasSlots ? cs.primaryContainer.withValues(alpha: 0.08) : cs.surface,
        ),
        padding: const EdgeInsets.all(4),
        child: hasSlots
            ? SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: slots.take(3).map((s) => _SlotCard(slot: s)).toList(),
                ),
              )
            : null,
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot});
  final Map<String, dynamic> slot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final subject     = slot['subject']?.toString() ?? '';
    final teacherName = slot['teacher'] is Map ? (slot['teacher']['name']?.toString() ?? '') : '';
    final cohorts     = slot['cohorts'] as List? ?? [];
    final cohortNames = cohorts
        .whereType<Map>()
        .map((c) => (c['cohort'] is Map ? c['cohort']['name'] : null)?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    final cohortLabel = cohortNames.isEmpty
        ? ''
        : cohortNames.length == 1
            ? cohortNames.first
            : '${cohortNames.first} +${cohortNames.length - 1}';
    final freq = (slot['frequencyWeeks'] as num?)?.toInt() ?? 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject.isNotEmpty ? subject : teacherName.isNotEmpty ? teacherName : 'Period',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (cohortLabel.isNotEmpty)
            Text(cohortLabel, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: cs.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
          if (freq > 1)
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: cs.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('×$freq wks', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: cs.onSecondaryContainer)),
            ),
        ],
      ),
    );
  }
}

// ── Filter chip ────────────────────────────────────────────────────────────────

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
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

  int  _frequencyWeeks = 1;
  bool _customFreq = false;
  final _customFreqCtrl = TextEditingController();
  DateTime? _startDate; // first occurrence for bi-weekly etc.

  bool _saving = false;

  static const _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
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
  ({List<String>? cohortIds, List<String>? studentIds}) _resolveAudience() {
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
            .map((c) => c['id']?.toString() ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
        return (cohortIds: matching.isNotEmpty ? matching : null, studentIds: null);
    }
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
    final freq = _customFreq
        ? (int.tryParse(_customFreqCtrl.text.trim()) ?? 1).clamp(1, 52)
        : _frequencyWeeks;

    final audience = _resolveAudience();
    setState(() => _saving = true);
    int created = 0;
    String? firstError;

    for (final slot in _slots) {
      try {
        final sd = _startDate != null
            ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
            : null;
        await widget.repo.createPeriod(
          dayOfWeek: slot.dayOfWeek,
          period: slot.period,
          teacherId: _teacherId,
          cohortIds: audience.cohortIds,
          studentIds: audience.studentIds,
          startTime: _defaultTime(slot.period, true).isNotEmpty ? _defaultTime(slot.period, true) : null,
          endTime: _defaultTime(slot.period, false).isNotEmpty ? _defaultTime(slot.period, false) : null,
          frequencyWeeks: freq,
          startDate: sd,
        );
        created++;
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [

            // ── Day + Period slots ────────────────────────────────────────
            _SectionLabel(label: l.adminScheduleDayLabel, cs: cs, theme: theme),
            const SizedBox(height: 10),
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
            TextButton.icon(
              onPressed: () => setState(() => _slots.add(_DayPeriodSlot())),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(l.adminScheduleAddAnother),
            ),
            const SizedBox(height: 16),

            // ── Teacher DDL ───────────────────────────────────────────────
            _SectionLabel(label: l.adminScheduleTeacherLabel, cs: cs, theme: theme),
            const SizedBox(height: 8),
            LiquidGlassDropdown<String>(
              label: l.adminScheduleSelectTeacher,
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
            const SizedBox(height: 16),

            // ── Audience: cohort, student, or by-grade ────────────────────
            _SectionLabel(label: l.adminScheduleCohortLabel, cs: cs, theme: theme),
            const SizedBox(height: 8),
            SegmentedButton<_AudienceMode>(
              segments: [
                ButtonSegment(value: _AudienceMode.cohort, label: Text(l.adminScheduleSelectCohort)),
                ButtonSegment(value: _AudienceMode.student, label: Text(l.adminStudents)),
                const ButtonSegment(value: _AudienceMode.grade, label: Text('By Grade')),
              ],
              selected: {_audience},
              onSelectionChanged: (s) => setState(() {
                _audience = s.first;
                _cohortIds.clear();
                _studentIds.clear();
                _audienceGrade = null;
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
                onToggle: (id) => setState(() =>
                  _cohortIds.contains(id) ? _cohortIds.remove(id) : _cohortIds.add(id)),
              ),
              if (_cohortIds.isNotEmpty) ...[
                const SizedBox(height: 10),
                _CohortStudentPreview(
                  allStudents: widget.students,
                  selectedCohortIds: _cohortIds,
                  cohorts: widget.cohorts,
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
                    final matching = widget.cohorts
                        .where((c) => _cohortGradesOf(c).contains(g))
                        .length;
                    return ChoiceChip(
                      label: Text('Grade $g · $matching cohorts'),
                      selected: _audienceGrade == g,
                      onSelected: (_) => setState(() => _audienceGrade = g),
                    );
                  }).toList(),
                );
              }),
            ],
            const SizedBox(height: 16),

            // ── Frequency ─────────────────────────────────────────────────
            _SectionLabel(label: l.adminScheduleFrequencyLabel, cs: cs, theme: theme),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
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

            // ── Start date (shown when frequency > 1) ─────────────────────
            if (_frequencyWeeks > 1 || _customFreq) ...[
              const SizedBox(height: 20),
              _SectionLabel(label: 'Starting Date', cs: cs, theme: theme),
              const SizedBox(height: 4),
              Text(
                'Pick which ${_slots.isNotEmpty ? _dayLabels[_slots.first.dayOfWeek] : 'day'} to start from.',
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
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

// ── Cohort student preview ────────────────────────────────────────────────────

class _CohortStudentPreview extends StatelessWidget {
  const _CohortStudentPreview({
    required this.allStudents,
    required this.selectedCohortIds,
    required this.cohorts,
  });

  final List<Map<String, dynamic>> allStudents;
  final Set<String> selectedCohortIds;
  final List<Map<String, dynamic>> cohorts;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    // Find cohort names for header
    final names = cohorts
        .where((c) => selectedCohortIds.contains(c['id']?.toString()))
        .map((c) => c['name']?.toString() ?? '')
        .where((n) => n.isNotEmpty)
        .toList();

    // Filter students who belong to selected cohorts
    final students = allStudents.where((s) {
      final cid = s['cohortId']?.toString() ?? '';
      // Fallback: match by cohortName if cohortId isn't present
      if (cid.isNotEmpty) return selectedCohortIds.contains(cid);
      final cn = s['cohortName']?.toString() ?? '';
      return names.any((n) => n == cn);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_rounded, size: 14, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                '${students.length} student${students.length == 1 ? '' : 's'} in selected cohort${selectedCohortIds.length == 1 ? '' : 's'}',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          if (students.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: students.take(20).map((s) {
                final name = s['name']?.toString() ?? '';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Text(name, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                );
              }).toList(),
            ),
            if (students.length > 20)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('+${students.length - 20} more',
                    style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Section label ──────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.cs, required this.theme});
  final String label;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: cs.primary,
      ),
    );
  }
}
