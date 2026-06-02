// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../../../ui/widgets/cm_loading.dart';

enum _AudienceMode { students, cohorts, grades }

enum _GradeType { assignment, exam, other }

class TeacherAddGradeScreen extends ConsumerStatefulWidget {
  const TeacherAddGradeScreen({
    super.key,
    this.prefillStudentIds = const {},
    this.prefillSubject,
  });

  final Set<String> prefillStudentIds;
  final String? prefillSubject;

  @override
  ConsumerState<TeacherAddGradeScreen> createState() =>
      _TeacherAddGradeScreenState();
}

class _TeacherAddGradeScreenState
    extends ConsumerState<TeacherAddGradeScreen> {
  // ── Remote data ─────────────────────────────────────────────────────────
  List<TeacherStudentWithLevel> _allStudents = [];
  List<Map<String, dynamic>> _allCohorts = [];
  List<Map<String, dynamic>> _teacherAssignmentsList = [];
  List<Map<String, dynamic>> _teacherExamsList = [];
  List<String> _schoolSubjects = [];
  bool _loading = true;
  bool _saving = false;

  // ── Audience ────────────────────────────────────────────────────────────
  _AudienceMode _audienceMode = _AudienceMode.students;
  final Set<String> _selectedStudentIds = {};
  final Set<String> _selectedCohortIds = {};
  final Set<int> _selectedGrades = {};

  // ── Type ────────────────────────────────────────────────────────────────
  _GradeType _gradeType = _GradeType.exam;

  // ── Source (exam/assignment) ────────────────────────────────────────────
  String? _selectedExamId;
  String? _selectedAssignmentId;

  // ── "Other" fields (only used when type = other) ────────────────────────
  final _otherTitleCtrl = TextEditingController();
  // "Out of" / max score for an Other (free-form) grade — e.g. score out of 20.
  final _otherMaxCtrl = TextEditingController();
  String? _otherSubject;

  // ── Per-student grade + notes inputs ────────────────────────────────────
  final Map<String, TextEditingController> _gradeCtrlMap = {};
  final Map<String, TextEditingController> _noteCtrlMap = {};

  bool _published = true;

  @override
  void initState() {
    super.initState();
    _selectedStudentIds.addAll(widget.prefillStudentIds);
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    for (final c in _gradeCtrlMap.values) {
      c.dispose();
    }
    for (final c in _noteCtrlMap.values) {
      c.dispose();
    }
    _otherTitleCtrl.dispose();
    _otherMaxCtrl.dispose();
    super.dispose();
  }

  // ── Loading ─────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final results = await Future.wait<dynamic>([
        repo.fetchAllStudents(),
        repo.fetchCohortsForPicker(),
        repo.listTeacherAssignments(),
        repo.listTeacherExams(),
        repo.fetchSubjects(),
      ]);
      if (!mounted) return;
      setState(() {
        _allStudents = results[0] as List<TeacherStudentWithLevel>;
        _allCohorts = results[1] as List<Map<String, dynamic>>;
        _teacherAssignmentsList = results[2] as List<Map<String, dynamic>>;
        _teacherExamsList = results[3] as List<Map<String, dynamic>>;
        _schoolSubjects = results[4] as List<String>;
        if (widget.prefillSubject != null) {
          _otherSubject = widget.prefillSubject;
        }
        // Ensure controllers exist for any prefilled students.
        for (final id in _selectedStudentIds) {
          _gradeCtrlMap.putIfAbsent(id, () => TextEditingController());
          _noteCtrlMap.putIfAbsent(id, () => TextEditingController());
        }
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ── Derived helpers ─────────────────────────────────────────────────────

  /// All student IDs implied by the current audience selection. When the
  /// teacher selects cohorts, expand each cohort into its student list so
  /// grading writes individual GradeRecord rows.
  List<TeacherStudentWithLevel> get _effectiveStudents {
    switch (_audienceMode) {
      case _AudienceMode.students:
        return _allStudents
            .where((s) => _selectedStudentIds.contains(s.studentId))
            .toList();
      case _AudienceMode.cohorts:
        if (_selectedCohortIds.isEmpty) return const [];
        return _allStudents
            .where((s) => _selectedCohortIds.contains(s.cohortId))
            .toList();
      case _AudienceMode.grades:
        if (_selectedGrades.isEmpty) return const [];
        return _allStudents
            .where((s) =>
                s.gradeLevel != null && _selectedGrades.contains(s.gradeLevel))
            .toList();
    }
  }

  /// All grade levels across the school. Same three-step source as
  /// the announcement audience picker so the chips never come up
  /// empty for teachers whose student endpoint returns null
  /// gradeLevels (the messages-people fallback path).
  List<int> get _availableGrades {
    final s = <int>{};
    for (final st in _allStudents) {
      final g = st.gradeLevel;
      if (g != null && g > 0) s.add(g);
    }
    for (final c in _allCohorts) {
      final g = c['grade'];
      final n = g is int ? g : int.tryParse('${g ?? ''}');
      if (n != null && n > 0) s.add(n);
    }
    if (s.isEmpty) {
      for (var i = 1; i <= 12; i++) {
        s.add(i);
      }
    }
    return s.toList()..sort();
  }

  bool _itemVisibleToAudience(Map<String, dynamic> item) {
    final targetType = (item['targetType'] as String? ?? 'EVERYONE').toUpperCase();
    if (targetType == 'EVERYONE') return true;
    final cohortIds = (item['targetCohortIds'] as List?)
            ?.map((e) => e.toString())
            .toSet() ??
        const <String>{};
    final studentIds = (item['targetStudentIds'] as List?)
            ?.map((e) => e.toString())
            .toSet() ??
        const <String>{};

    final grades = (item['targetGrades'] as List?)
            ?.map((e) => (e is num) ? e.toInt() : int.tryParse(e.toString()))
            .whereType<int>()
            .toSet() ??
        const <int>{};

    switch (_audienceMode) {
      case _AudienceMode.students:
        if (_selectedStudentIds.isEmpty) return false;
        for (final sid in _selectedStudentIds) {
          final student =
              _allStudents.where((s) => s.studentId == sid).firstOrNull;
          if (student == null) return false;
          final ok = (targetType == 'STUDENTS' && studentIds.contains(sid)) ||
              (targetType == 'COHORT' && cohortIds.contains(student.cohortId)) ||
              (targetType == 'GRADE' &&
                  student.gradeLevel != null &&
                  grades.contains(student.gradeLevel));
          if (!ok) return false;
        }
        return true;
      case _AudienceMode.cohorts:
        if (_selectedCohortIds.isEmpty) return false;
        for (final cid in _selectedCohortIds) {
          final ok = targetType == 'COHORT' && cohortIds.contains(cid);
          if (!ok) return false;
        }
        return true;
      case _AudienceMode.grades:
        if (_selectedGrades.isEmpty) return false;
        for (final g in _selectedGrades) {
          final ok = targetType == 'GRADE' && grades.contains(g);
          if (!ok) return false;
        }
        return true;
    }
  }

  List<Map<String, dynamic>> get _filteredExams =>
      _teacherExamsList.where(_itemVisibleToAudience).toList();

  List<Map<String, dynamic>> get _filteredAssignments =>
      _teacherAssignmentsList.where(_itemVisibleToAudience).toList();

  /// Title + subject inherited from the chosen source, or from "Other" fields.
  ({String? title, String? subject, int? maxGrade}) get _inheritedSource {
    if (_gradeType == _GradeType.other) {
      return (
        title: _otherTitleCtrl.text.trim().isEmpty
            ? null
            : _otherTitleCtrl.text.trim(),
        subject: _otherSubject,
        maxGrade: int.tryParse(_otherMaxCtrl.text.trim()),
      );
    }
    final list =
        _gradeType == _GradeType.exam ? _teacherExamsList : _teacherAssignmentsList;
    final selectedId =
        _gradeType == _GradeType.exam ? _selectedExamId : _selectedAssignmentId;
    if (selectedId == null) return (title: null, subject: null, maxGrade: null);
    final item =
        list.where((e) => (e['id'] ?? '') == selectedId).firstOrNull;
    if (item == null) return (title: null, subject: null, maxGrade: null);
    return (
      title: item['title']?.toString(),
      subject: item['subject']?.toString(),
      maxGrade: item['maxGrade'] is int ? item['maxGrade'] as int : null,
    );
  }

  bool get _hasSource {
    switch (_gradeType) {
      case _GradeType.exam:
        return _selectedExamId != null && _selectedExamId!.isNotEmpty;
      case _GradeType.assignment:
        return _selectedAssignmentId != null && _selectedAssignmentId!.isNotEmpty;
      case _GradeType.other:
        return _otherTitleCtrl.text.trim().isNotEmpty;
    }
  }

  // ── Selection mutations ─────────────────────────────────────────────────

  void _toggleStudent(String id) {
    setState(() {
      if (_selectedStudentIds.contains(id)) {
        _selectedStudentIds.remove(id);
        _gradeCtrlMap.remove(id)?.dispose();
        _noteCtrlMap.remove(id)?.dispose();
      } else {
        _selectedStudentIds.add(id);
        _gradeCtrlMap[id] = TextEditingController();
        _noteCtrlMap[id] = TextEditingController();
      }
    });
  }

  void _toggleCohort(String id) {
    setState(() {
      if (_selectedCohortIds.contains(id)) {
        _selectedCohortIds.remove(id);
      } else {
        _selectedCohortIds.add(id);
      }
      for (final s in _effectiveStudents) {
        _gradeCtrlMap.putIfAbsent(s.studentId, () => TextEditingController());
        _noteCtrlMap.putIfAbsent(s.studentId, () => TextEditingController());
      }
    });
  }

  void _toggleGrade(int g) {
    setState(() {
      if (_selectedGrades.contains(g)) {
        _selectedGrades.remove(g);
      } else {
        _selectedGrades.add(g);
      }
      for (final s in _effectiveStudents) {
        _gradeCtrlMap.putIfAbsent(s.studentId, () => TextEditingController());
        _noteCtrlMap.putIfAbsent(s.studentId, () => TextEditingController());
      }
    });
  }

  // ── Save ────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    final effective = _effectiveStudents;
    if (effective.isEmpty) {
      _snack('Pick at least one student, cohort, or grade.');
      return;
    }
    if (!_hasSource) {
      _snack(_gradeType == _GradeType.other
          ? 'Enter a title for this grade.'
          : _gradeType == _GradeType.exam
              ? 'Pick an exam.'
              : 'Pick an assignment.');
      return;
    }

    final inherited = _inheritedSource;
    final title = inherited.title;
    if (title == null || title.isEmpty) {
      _snack('Could not resolve grade title.');
      return;
    }

    // Validate every student has a numeric grade.
    final entries = <_PendingEntry>[];
    for (final s in effective) {
      final raw = _gradeCtrlMap[s.studentId]?.text.trim() ?? '';
      final grade = int.tryParse(raw);
      if (grade == null) {
        _snack('Enter a numeric grade for ${s.name}.');
        return;
      }
      entries.add(_PendingEntry(
        student: s,
        grade: grade,
        comment: _noteCtrlMap[s.studentId]?.text.trim(),
      ));
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);

      // Group by cohort: students without a cohort fall into the synthetic
      // empty-string bucket, which we handle by assigning to the first
      // available cohort (the assessment row still needs a cohortId per
      // schema, but the grade itself is per-student).
      final fallbackCohort = _allCohorts.isNotEmpty
          ? (_allCohorts.first['id'] ?? '').toString()
          : '';

      final byCohort = <String, List<_PendingEntry>>{};
      for (final e in entries) {
        final cohortId = e.student.cohortId.isNotEmpty
            ? e.student.cohortId
            : fallbackCohort;
        if (cohortId.isEmpty) {
          throw Exception(
            'No cohort available to anchor this grade. Create a cohort first.',
          );
        }
        byCohort.putIfAbsent(cohortId, () => []).add(e);
      }

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      for (final entry in byCohort.entries) {
        final created = await repo.createAssessment(
          cohortId: entry.key,
          title: title,
          subject: inherited.subject,
          date: today,
          maxGrade: inherited.maxGrade,
          published: _published,
        );
        final assessmentId = _extractAssessmentId(created);
        if (assessmentId == null) {
          throw Exception('Failed to create grade record.');
        }
        await repo.saveBulkGrades(
          assessmentId: assessmentId,
          grades: entry.value
              .map((p) => TeacherGradeDraftRecord(
                    studentId: p.student.studentId,
                    grade: p.grade,
                    comment: p.comment,
                  ))
              .toList(),
        );
      }

      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _snack('Error: $e', isError: true);
    }
  }

  String? _extractAssessmentId(Map<String, dynamic> raw) {
    final nested = raw['assessment'];
    if (nested is Map) {
      final id = nested['id']?.toString().trim();
      if (id != null && id.isNotEmpty) return id;
    }
    final flat = raw['id']?.toString().trim();
    if (flat != null && flat.isNotEmpty) return flat;
    return null;
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  /// Push the Create Exam screen with the currently-selected audience
  /// pre-filled, then refresh the exam list so the new exam is pickable
  /// without leaving the Add Grade screen.
  Future<void> _createExamOnSpot() async {
    final cohortIds = _audienceMode == _AudienceMode.cohorts
        ? _selectedCohortIds.toList()
        : _allStudents
            .where((s) => _selectedStudentIds.contains(s.studentId))
            .map((s) => s.cohortId)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();
    await context.push(
      '/teacher/exams/create',
      extra: <String, dynamic>{
        'cohortId': cohortIds.isNotEmpty ? cohortIds.first : '',
        'prefillCohortIds': cohortIds,
        'prefillStudentIds': _audienceMode == _AudienceMode.students
            ? _selectedStudentIds.toList()
            : <String>[],
      },
    );
    if (!mounted) return;
    final repo = ref.read(teacherMobileRepositoryProvider);
    final raw = await repo.listTeacherExams();
    if (!mounted) return;
    setState(() => _teacherExamsList = raw);
  }

  /// Push the Add Assignment screen, then refresh.
  Future<void> _createAssignmentOnSpot() async {
    final cohortIds = _audienceMode == _AudienceMode.cohorts
        ? _selectedCohortIds.toList()
        : _allStudents
            .where((s) => _selectedStudentIds.contains(s.studentId))
            .map((s) => s.cohortId)
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList();
    await context.push(
      '/teacher/assignments/add',
      extra: <String, dynamic>{
        'prefillCohortIds': cohortIds,
        'prefillStudentIds': _audienceMode == _AudienceMode.students
            ? _selectedStudentIds.toList()
            : <String>[],
      },
    );
    if (!mounted) return;
    final repo = ref.read(teacherMobileRepositoryProvider);
    final raw = await repo.listTeacherAssignments();
    if (!mounted) return;
    setState(() => _teacherAssignmentsList = raw);
  }

  Future<void> _openStudentPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _StudentPickerSheet(
        students: _allStudents,
        selected: Set.from(_selectedStudentIds),
        onToggle: _toggleStudent,
      ),
    );
  }

  Future<void> _openCohortPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _CohortPickerSheet(
        cohorts: _allCohorts,
        selected: Set.from(_selectedCohortIds),
        onToggle: _toggleCohort,
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final effective = _effectiveStudents;
    final inherited = _inheritedSource;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(AppLocalizations.of(context)!.teacherAddGradeTitle,
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: (_saving || _loading) ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.commonSave),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CmLoading())
          : ListView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                // ── Audience ────────────────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SectionHeader(
                        icon: Icons.people_outline_rounded,
                        title: 'Audience',
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<_AudienceMode>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        segments: [
                          ButtonSegment(
                            value: _AudienceMode.students,
                            label: Text(AppLocalizations.of(context)!.teacherMaterialAudienceStudents,
                                maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
                          ),
                          ButtonSegment(
                            value: _AudienceMode.cohorts,
                            label: Text(AppLocalizations.of(context)!.teacherMaterialAudienceCohorts,
                                maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
                          ),
                          ButtonSegment(
                            value: _AudienceMode.grades,
                            label: Text(AppLocalizations.of(context)!.teacherMaterialAudienceGrades,
                                maxLines: 1, overflow: TextOverflow.fade, softWrap: false),
                          ),
                        ],
                        selected: {_audienceMode},
                        onSelectionChanged: (set) => setState(() {
                          _audienceMode = set.first;
                          // Clear source selection — visibility may change.
                          _selectedExamId = null;
                          _selectedAssignmentId = null;
                        }),
                      ),
                      const SizedBox(height: 14),
                      if (_audienceMode == _AudienceMode.students) ...[
                        _PickerTrigger(
                          label: _selectedStudentIds.isEmpty
                              ? 'Tap to select students…'
                              : '${_selectedStudentIds.length} student${_selectedStudentIds.length == 1 ? '' : 's'} selected',
                          onTap: _openStudentPicker,
                          icon: Icons.person_outline_rounded,
                        ),
                        if (_selectedStudentIds.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _allStudents
                                .where((s) =>
                                    _selectedStudentIds.contains(s.studentId))
                                .map((s) => _Chip(
                                      label: s.name,
                                      onRemove: () =>
                                          _toggleStudent(s.studentId),
                                    ))
                                .toList(),
                          ),
                        ],
                      ] else if (_audienceMode == _AudienceMode.cohorts) ...[
                        _PickerTrigger(
                          label: _selectedCohortIds.isEmpty
                              ? 'Tap to select cohorts…'
                              : '${_selectedCohortIds.length} cohort${_selectedCohortIds.length == 1 ? '' : 's'} selected',
                          onTap: _openCohortPicker,
                          icon: Icons.group_work_outlined,
                        ),
                        if (_selectedCohortIds.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _allCohorts
                                .where((c) => _selectedCohortIds
                                    .contains((c['id'] ?? '').toString()))
                                .map((c) => _Chip(
                                      label:
                                          (c['name'] ?? '').toString(),
                                      onRemove: () => _toggleCohort(
                                          (c['id'] ?? '').toString()),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${effective.length} student${effective.length == 1 ? '' : 's'} will be graded',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ] else ...[
                        // ── Grades: small inline chip row of all school grades ──
                        if (_availableGrades.isEmpty)
                          Text(
                            'No grade levels found on your students yet.',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _availableGrades.map((g) {
                              final selected = _selectedGrades.contains(g);
                              return ChoiceChip(
                                visualDensity: VisualDensity.compact,
                                label: Text(AppLocalizations.of(context)!.teacherAddGradeLabel(g)),
                                selected: selected,
                                onSelected: (_) => _toggleGrade(g),
                              );
                            }).toList(),
                          ),
                        if (_selectedGrades.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(
                            '${effective.length} student${effective.length == 1 ? '' : 's'} will be graded',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Type ────────────────────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        icon: Icons.category_outlined,
                        title: AppLocalizations.of(context)!
                            .teacherGradeTypeSection,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<_GradeType>(
                        showSelectedIcon: false,
                        style: SegmentedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          textStyle: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        segments: [
                          ButtonSegment(
                            value: _GradeType.exam,
                            label: Text(
                              AppLocalizations.of(context)!.teacherGradeExamType,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                          ButtonSegment(
                            value: _GradeType.assignment,
                            label: Text(
                              AppLocalizations.of(context)!.teacherGradeAssignmentType,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                          ButtonSegment(
                            value: _GradeType.other,
                            label: Text(
                              AppLocalizations.of(context)!.teacherGradeOtherType,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                            ),
                          ),
                        ],
                        selected: {_gradeType},
                        onSelectionChanged: (set) => setState(() {
                          _gradeType = set.first;
                          _selectedExamId = null;
                          _selectedAssignmentId = null;
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Source ──────────────────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        icon: _gradeType == _GradeType.exam
                            ? Icons.quiz_outlined
                            : _gradeType == _GradeType.assignment
                                ? Icons.assignment_outlined
                                : Icons.edit_outlined,
                        title: _gradeType == _GradeType.exam
                            ? 'Exam'
                            : _gradeType == _GradeType.assignment
                                ? 'Assignment'
                                : 'Details',
                      ),
                      const SizedBox(height: 14),
                      if (_gradeType == _GradeType.exam) ...[
                        LiquidGlassDropdown<String>(
                          label: _selectedExamId == null
                              ? 'Choose exam'
                              : _filteredExams
                                      .where((e) =>
                                          (e['id'] ?? '') == _selectedExamId)
                                      .firstOrNull?['title']
                                      ?.toString() ??
                                  'Choose exam',
                          value: _selectedExamId ?? '',
                          items: [
                            const LiquidGlassDropdownItem(
                              value: '',
                              label: 'Choose exam',
                              icon: Icons.quiz_outlined,
                            ),
                            ..._filteredExams.map(
                              (e) => LiquidGlassDropdownItem(
                                value: (e['id'] ?? '').toString(),
                                label: (e['title'] ?? '').toString(),
                                icon: Icons.quiz_rounded,
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(
                              () => _selectedExamId = v.isEmpty ? null : v),
                          searchHint: 'Search exams…',
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => _createExamOnSpot(),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: Text(AppLocalizations.of(context)!.teacherCreateNewExam),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        if (_filteredExams.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              effective.isEmpty
                                  ? 'Select an audience first to filter exams.'
                                  : 'No exams reach all selected ${_audienceMode == _AudienceMode.cohorts ? "cohorts" : _audienceMode == _AudienceMode.grades ? "grades" : "students"}.',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                        if (inherited.subject != null &&
                            inherited.subject!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: _InheritedRow(
                              icon: Icons.menu_book_rounded,
                              label: 'Subject',
                              value: inherited.subject!,
                            ),
                          ),
                      ] else if (_gradeType == _GradeType.assignment) ...[
                        LiquidGlassDropdown<String>(
                          label: _selectedAssignmentId == null
                              ? 'Choose assignment'
                              : _filteredAssignments
                                      .where((a) =>
                                          (a['id'] ?? '') ==
                                          _selectedAssignmentId)
                                      .firstOrNull?['title']
                                      ?.toString() ??
                                  'Choose assignment',
                          value: _selectedAssignmentId ?? '',
                          items: [
                            const LiquidGlassDropdownItem(
                              value: '',
                              label: 'Choose assignment',
                              icon: Icons.assignment_outlined,
                            ),
                            ..._filteredAssignments.map(
                              (a) => LiquidGlassDropdownItem(
                                value: (a['id'] ?? '').toString(),
                                label: (a['title'] ?? '').toString(),
                                icon: Icons.assignment_rounded,
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(() =>
                              _selectedAssignmentId = v.isEmpty ? null : v),
                          searchHint: 'Search assignments…',
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () => _createAssignmentOnSpot(),
                          icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                          label: Text(AppLocalizations.of(context)!.teacherCreateNewAssignment),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        if (_filteredAssignments.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              effective.isEmpty
                                  ? 'Select an audience first to filter assignments.'
                                  : 'No assignments reach all selected ${_audienceMode == _AudienceMode.cohorts ? "cohorts" : _audienceMode == _AudienceMode.grades ? "grades" : "students"}.',
                              style: theme.textTheme.labelSmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                        if (inherited.subject != null &&
                            inherited.subject!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: _InheritedRow(
                              icon: Icons.menu_book_rounded,
                              label: 'Subject',
                              value: inherited.subject!,
                            ),
                          ),
                      ] else ...[
                        TextField(
                          controller: _otherTitleCtrl,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            hintText: 'e.g. Class participation, Quiz 3',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        LiquidGlassDropdown<String>(
                          label: _otherSubject ?? 'Select subject',
                          value: _otherSubject ?? '',
                          items: [
                            const LiquidGlassDropdownItem(
                              value: '',
                              label: 'Select subject',
                              icon: Icons.auto_stories_outlined,
                            ),
                            ..._schoolSubjects.map(
                              (s) => LiquidGlassDropdownItem(
                                value: s,
                                label: s,
                                icon: Icons.menu_book_rounded,
                              ),
                            ),
                          ],
                          onChanged: (v) => setState(
                              () => _otherSubject = v.isEmpty ? null : v),
                          searchHint: 'Search subjects…',
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _otherMaxCtrl,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.teacherGradeOutOfLabel,
                            hintText: AppLocalizations.of(context)!.teacherGradeOutOfHint,
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.percent_rounded),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Grades ──────────────────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        icon: Icons.edit_note_rounded,
                        title: AppLocalizations.of(context)!
                            .teacherEnterGradesSection,
                      ),
                      const SizedBox(height: 12),
                      if (effective.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            'Select an audience above to enter grades.',
                            style: theme.textTheme.labelMedium
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        )
                      else
                        ...effective.asMap().entries.map((entry) {
                          final i = entry.key;
                          final s = entry.value;
                          final ctrl = _gradeCtrlMap.putIfAbsent(
                              s.studentId, () => TextEditingController());
                          final note = _noteCtrlMap.putIfAbsent(
                              s.studentId, () => TextEditingController());
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: i < effective.length - 1 ? 14 : 0,
                            ),
                            child: _StudentGradeRow(
                              student: s,
                              gradeCtrl: ctrl,
                              noteCtrl: note,
                              maxGrade: inherited.maxGrade,
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Published ───────────────────────────────────────────
                _SectionCard(
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    secondary: Icon(
                      _published
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: _published ? cs.primary : cs.onSurfaceVariant,
                    ),
                    title: Text(AppLocalizations.of(context)!
                        .teacherGradePublishedTitle),
                    subtitle: Text(AppLocalizations.of(context)!
                        .teacherGradePublishedSubtitle),
                    value: _published,
                    onChanged: (v) => setState(() => _published = v),
                  ),
                ),
              ],
            ),
    );
  }
}

class _PendingEntry {
  _PendingEntry({required this.student, required this.grade, this.comment});
  final TeacherStudentWithLevel student;
  final int grade;
  final String? comment;
}

// ─────────────────────────────────────────────────────────────────────────────
// Student picker bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _StudentPickerSheet extends StatefulWidget {
  const _StudentPickerSheet({
    required this.students,
    required this.selected,
    required this.onToggle,
  });

  final List<TeacherStudentWithLevel> students;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  State<_StudentPickerSheet> createState() => _StudentPickerSheetState();
}

class _StudentPickerSheetState extends State<_StudentPickerSheet> {
  String _query = '';
  late Set<String> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = Set.from(widget.selected);
  }

  void _toggle(String id) {
    setState(() {
      if (_localSelected.contains(id)) {
        _localSelected.remove(id);
      } else {
        _localSelected.add(id);
      }
    });
    widget.onToggle(id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final filtered = _query.isEmpty
        ? widget.students
        : widget.students
            .where((s) =>
                s.name.toLowerCase().contains(_query.toLowerCase()) ||
                s.email.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.45,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Text(
                  'Select students',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (_localSelected.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_localSelected.length} selected',
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.teacherSearchStudents,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final s = filtered[i];
                final isSelected = _localSelected.contains(s.studentId);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _toggle(s.studentId),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? cs.primaryContainer
                                  : cs.surfaceContainerHighest
                                      .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Center(
                              child: Text(
                                s.name.isNotEmpty
                                    ? s.name[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: isSelected
                                      ? cs.onPrimaryContainer
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  s.name,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected ? cs.primary : null,
                                  ),
                                ),
                                if (s.gradeLevel != null ||
                                    s.cohortName.isNotEmpty)
                                  Text(
                                    [
                                      if (s.gradeLevel != null)
                                        'Grade ${s.gradeLevel}',
                                      if (s.cohortName.isNotEmpty)
                                        s.cohortName,
                                    ].join(' · '),
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                            color: cs.onSurfaceVariant),
                                  ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggle(s.studentId),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.commonDone),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cohort picker bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CohortPickerSheet extends StatefulWidget {
  const _CohortPickerSheet({
    required this.cohorts,
    required this.selected,
    required this.onToggle,
  });

  final List<Map<String, dynamic>> cohorts;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  State<_CohortPickerSheet> createState() => _CohortPickerSheetState();
}

class _CohortPickerSheetState extends State<_CohortPickerSheet> {
  String _query = '';
  late Set<String> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = Set.from(widget.selected);
  }

  void _toggle(String id) {
    setState(() {
      if (_localSelected.contains(id)) {
        _localSelected.remove(id);
      } else {
        _localSelected.add(id);
      }
    });
    widget.onToggle(id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final filtered = _query.isEmpty
        ? widget.cohorts
        : widget.cohorts
            .where((c) =>
                (c['name'] ?? '').toString().toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Select cohorts',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search cohorts…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final c = filtered[i];
                final id = (c['id'] ?? '').toString();
                final name = (c['name'] ?? '').toString();
                final grade = c['grade'];
                final isSelected = _localSelected.contains(id);
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _toggle(id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 10),
                      child: Row(
                        children: [
                          Icon(Icons.group_work_outlined,
                              color: isSelected
                                  ? cs.primary
                                  : cs.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (grade != null)
                                  Text(AppLocalizations.of(context)!.teacherAddGradeLabel(grade),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                              color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => _toggle(id),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.commonDone),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-student grade + notes row
// ─────────────────────────────────────────────────────────────────────────────

class _StudentGradeRow extends StatelessWidget {
  const _StudentGradeRow({
    required this.student,
    required this.gradeCtrl,
    required this.noteCtrl,
    this.maxGrade,
  });

  final TeacherStudentWithLevel student;
  final TextEditingController gradeCtrl;
  final TextEditingController noteCtrl;
  final int? maxGrade;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Center(
                child: Text(
                  student.name.isNotEmpty
                      ? student.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    student.name,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (student.cohortName.isNotEmpty)
                    Text(
                      student.cohortName,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: maxGrade != null ? 96 : 80,
              child: TextField(
                controller: gradeCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  hintText: maxGrade != null ? '/ $maxGrade' : '—',
                  hintStyle: TextStyle(
                      color: cs.onSurfaceVariant, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: noteCtrl,
          textCapitalization: TextCapitalization.sentences,
          minLines: 1,
          maxLines: 2,
          style: theme.textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: 'Notes (optional)',
            hintStyle: TextStyle(color: cs.onSurfaceVariant),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: cs.outlineVariant)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared little widgets
// ─────────────────────────────────────────────────────────────────────────────

class _PickerTrigger extends StatelessWidget {
  const _PickerTrigger({
    required this.label,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded,
                size: 15, color: cs.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

class _InheritedRow extends StatelessWidget {
  const _InheritedRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.labelMedium
              ?.copyWith(color: cs.onSurfaceVariant),
        ),
        Text(
          value,
          style: theme.textTheme.labelMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
