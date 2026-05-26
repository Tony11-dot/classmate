// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../../../ui/widgets/cm_loading.dart';

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
  // ── Remote data ───────────────────────────────────────────────────────────
  List<TeacherStudentWithLevel> _allStudents = [];
  List<Map<String, dynamic>> _teacherAssignmentsList = [];
  List<Map<String, dynamic>> _teacherExamsList = [];
  List<String> _schoolSubjects = [];
  bool _loading = true;
  bool _saving = false;

  // ── Step 1 – Students ─────────────────────────────────────────────────────
  final Set<String> _selectedStudentIds = {};
  final Map<String, TextEditingController> _gradeCtrlMap = {};

  // ── Step 2 – Subject ──────────────────────────────────────────────────────
  String? _selectedSubject;

  // ── Step 3 – Grade type ───────────────────────────────────────────────────
  _GradeType _gradeType = _GradeType.assignment;
  final _otherTitleCtrl = TextEditingController();
  final _otherMaxCtrl = TextEditingController();

  // ── Exam picker ───────────────────────────────────────────────────────────
  String? _selectedExamId;

  // ── Assignment fields ─────────────────────────────────────────────────────
  String? _selectedAssignmentId;
  final _newAssignmentTitleCtrl = TextEditingController();

  // ── Published ─────────────────────────────────────────────────────────────
  bool _published = true;

  static const String _kCreate = '__create__';

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    for (final c in _gradeCtrlMap.values) {
      c.dispose();
    }
    _newAssignmentTitleCtrl.dispose();
    _otherTitleCtrl.dispose();
    _otherMaxCtrl.dispose();
    super.dispose();
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final results = await Future.wait<dynamic>([
        repo.fetchAllStudents(),
        repo.listTeacherAssignments(),
        repo.listTeacherExams(),
        repo.fetchSubjects(),
      ]);
      if (!mounted) return;
      final students = results[0] as List<TeacherStudentWithLevel>;
      // Apply prefill: select students passed from the grades list.
      final prefillIds = widget.prefillStudentIds;
      final prefillSubject = widget.prefillSubject;
      for (final s in students) {
        if (prefillIds.contains(s.studentId)) {
          _selectedStudentIds.add(s.studentId);
          _gradeCtrlMap[s.studentId] = TextEditingController();
        }
      }
      // Auto-select subject if prefilled or only one option.
      String? subject = prefillSubject;
      if (subject == null && _selectedStudentIds.isNotEmpty) {
        // Derive common subjects across selected students.
        final commonSubs = students
            .where((s) => _selectedStudentIds.contains(s.studentId))
            .fold<Set<String>?>(null, (acc, s) {
              final set = s.subjects.toSet();
              return acc == null ? set : acc.intersection(set);
            }) ??
            {};
        if (commonSubs.length == 1) subject = commonSubs.first;
      }
      setState(() {
        _allStudents = students;
        _teacherAssignmentsList = results[1] as List<Map<String, dynamic>>;
        _teacherExamsList = results[2] as List<Map<String, dynamic>>;
        _schoolSubjects = (results[3] as List<String>);
        if (subject != null) _selectedSubject = subject;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  // ── Derived data ──────────────────────────────────────────────────────────

  List<String> get _availableSubjects => _schoolSubjects;

  // Groups selected students by their cohortId. Assessments are stored per
  // cohort in the schema, so we create one Assessment + grade-record set per
  // distinct cohort represented in the selection. Students with no cohort
  // are skipped because they have nowhere for the grade to attach.
  Map<String, List<String>> get _cohortStudentGroups {
    if (_selectedSubject == null) return {};
    final groups = <String, List<String>>{};
    for (final id in _selectedStudentIds) {
      final student = _allStudents.where((s) => s.studentId == id).firstOrNull;
      final cohortId = student?.cohortId ?? '';
      if (cohortId.isNotEmpty) {
        groups.putIfAbsent(cohortId, () => []).add(id);
      }
    }
    return groups;
  }

  List<Map<String, dynamic>> get _filteredTeacherAssignments {
    if (_selectedSubject == null) return _teacherAssignmentsList;
    return _teacherAssignmentsList
        .where((a) => (a['subject'] as String? ?? '') == _selectedSubject)
        .toList();
  }

  bool get _showGradeInputs {
    if (_selectedSubject == null || _selectedStudentIds.isEmpty) return false;
    if (_gradeType == _GradeType.other) return true;
    if (_gradeType == _GradeType.exam) {
      return _selectedExamId != null &&
          _selectedExamId!.isNotEmpty &&
          _selectedExamId != _kCreate;
    }
    return _selectedAssignmentId != null &&
        _selectedAssignmentId!.isNotEmpty &&
        _selectedAssignmentId != _kCreate;
  }

  // ── Student selection ─────────────────────────────────────────────────────

  void _toggleStudent(String studentId) {
    setState(() {
      if (_selectedStudentIds.contains(studentId)) {
        _selectedStudentIds.remove(studentId);
        _gradeCtrlMap[studentId]?.dispose();
        _gradeCtrlMap.remove(studentId);
      } else {
        _selectedStudentIds.add(studentId);
        _gradeCtrlMap[studentId] = TextEditingController();
      }
      // Drop subject if it's no longer available for the new student set.
      if (_selectedSubject != null &&
          !_availableSubjects.contains(_selectedSubject)) {
        _selectedSubject = null;
        _selectedAssignmentId = null;
      }
    });
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

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (_selectedStudentIds.isEmpty) {
      _snack('Select at least one student.');
      return;
    }
    if (_selectedSubject == null) {
      _snack('Select a subject.');
      return;
    }
    for (final id in _selectedStudentIds) {
      final val = _gradeCtrlMap[id]?.text.trim() ?? '';
      if (val.isEmpty || int.tryParse(val) == null) {
        _snack('Enter a valid numeric grade for every selected student.');
        return;
      }
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final groups = _cohortStudentGroups;
      if (groups.isEmpty) {
        throw Exception('None of the selected students are assigned to a cohort yet.');
      }

      for (final entry in groups.entries) {
        final cohortId = entry.key;
        final studentIds = entry.value;
        String? assessmentId;

        if (_gradeType == _GradeType.assignment) {
          String assignTitle;
          if (_selectedAssignmentId == _kCreate) {
            assignTitle = _newAssignmentTitleCtrl.text.trim();
            if (assignTitle.isEmpty) throw Exception('Enter an assignment title.');
          } else {
            assignTitle = _teacherAssignmentsList
                    .where((a) => (a['id'] ?? '') == _selectedAssignmentId)
                    .firstOrNull?['title']
                    ?.toString() ??
                'Assignment Grade';
          }
          final created = await repo.createAssessment(
            cohortId: cohortId,
            title: assignTitle,
            subject: _selectedSubject,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            published: _published,
          );
          assessmentId = _extractAssessmentId(created);
        } else if (_gradeType == _GradeType.other) {
          final title = _otherTitleCtrl.text.trim();
          if (title.isEmpty) throw Exception('Enter a title for this grade.');
          final created = await repo.createAssessment(
            cohortId: cohortId,
            title: title,
            subject: _selectedSubject,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            maxGrade: int.tryParse(_otherMaxCtrl.text.trim()),
            published: _published,
          );
          assessmentId = _extractAssessmentId(created);
        } else if (_gradeType == _GradeType.exam && _selectedExamId != null) {
          final exam = _teacherExamsList
              .where((e) => (e['id'] ?? '') == _selectedExamId)
              .firstOrNull;
          final examTitle = exam?['title']?.toString() ?? 'Exam';
          final maxGrade = exam?['maxGrade'] is int ? exam!['maxGrade'] as int : null;
          final created = await repo.createAssessment(
            cohortId: cohortId,
            title: examTitle,
            subject: _selectedSubject,
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            maxGrade: maxGrade,
            published: _published,
          );
          assessmentId = _extractAssessmentId(created);
        } else {
          throw Exception('Unsupported grade type.');
        }

        if (assessmentId == null) {
          throw Exception('Failed to resolve grade record.');
        }

        await repo.saveBulkGrades(
          assessmentId: assessmentId,
          grades: studentIds
              .map((id) => TeacherGradeDraftRecord(
                    studentId: id,
                    grade: int.parse(_gradeCtrlMap[id]!.text.trim()),
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

  /// Pulls the assessment id from createAssessment's response shape. The
  /// server returns `{ ok, assessment: { id, ... } }`; older responses may
  /// flatten the row at the top level. Returns null when neither shape has
  /// a usable id.
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
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final selectedStudents = _allStudents
        .where((s) => _selectedStudentIds.contains(s.studentId))
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Grade',
          style: theme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving || _loading ? null : _save,
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
          : _AddGradeBody(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  // ── 1: Students ─────────────────────────────────────────
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _SectionHeader(
                          icon: Icons.people_outline_rounded,
                          title: 'Students',
                        ),
                        const SizedBox(height: 14),
                        _StudentPickerTrigger(
                          count: selectedStudents.length,
                          onTap: _openStudentPicker,
                        ),
                        if (selectedStudents.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: selectedStudents
                                .map((s) => _StudentChip(
                                      student: s,
                                      onRemove: () =>
                                          _toggleStudent(s.studentId),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── 2: Subject ──────────────────────────────────────────
                  if (_selectedStudentIds.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SectionHeader(
                            icon: Icons.auto_stories_outlined,
                            title: 'Subject',
                          ),
                          const SizedBox(height: 14),
                          LiquidGlassDropdown<String>(
                            label: _selectedSubject ?? 'Select subject',
                            value: _selectedSubject ?? '',
                            items: [
                              const LiquidGlassDropdownItem(
                                value: '',
                                label: 'Select subject',
                                icon: Icons.auto_stories_outlined,
                              ),
                              ..._availableSubjects.map(
                                (s) => LiquidGlassDropdownItem(
                                  value: s,
                                  label: s,
                                  icon: Icons.menu_book_rounded,
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v.isEmpty) return;
                              setState(() {
                                _selectedSubject = v;
                                _selectedAssignmentId = null;
                              });
                            },
                            searchHint: 'Search subjects…',
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── 3: Grade type ───────────────────────────────────────
                  if (_selectedSubject != null) ...[
                    const SizedBox(height: 14),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _SectionHeader(
                            icon: Icons.grade_outlined,
                            title: 'Grade type',
                          ),
                          const SizedBox(height: 14),
                          SegmentedButton<_GradeType>(
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                            segments: [
                              ButtonSegment(
                                value: _GradeType.assignment,
                                label: Text(AppLocalizations.of(context)!.teacherGradeAssignmentType,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              ButtonSegment(
                                value: _GradeType.exam,
                                label: Text(AppLocalizations.of(context)!.teacherGradeExamType,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              ButtonSegment(
                                value: _GradeType.other,
                                label: Text(AppLocalizations.of(context)!.teacherGradeOtherType,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                            selected: {_gradeType},
                            onSelectionChanged: (set) => setState(() {
                              _gradeType = set.first;
                              _selectedAssignmentId = null;
                              _selectedExamId = null;
                            }),
                          ),
                        ],
                      ),
                    ),

                    // ── 4: Source ─────────────────────────────────────────
                    const SizedBox(height: 14),
                    _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_gradeType == _GradeType.assignment) ...[
                            const _SectionHeader(
                              icon: Icons.assignment_outlined,
                              title: 'Assignment',
                            ),
                            const SizedBox(height: 14),
                            LiquidGlassDropdown<String>(
                              label: _selectedAssignmentId == null
                                  ? 'Choose assignment'
                                  : _selectedAssignmentId == _kCreate
                                      ? '+ New assignment'
                                      : _filteredTeacherAssignments
                                              .where((a) => (a['id'] ?? '') == _selectedAssignmentId)
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
                                const LiquidGlassDropdownItem(
                                  value: _kCreate,
                                  label: '+ Create new assignment',
                                  icon: Icons.add_circle_outline_rounded,
                                ),
                                ..._filteredTeacherAssignments.map(
                                  (a) => LiquidGlassDropdownItem(
                                    value: (a['id'] ?? '').toString(),
                                    label: (a['title'] ?? '').toString(),
                                    icon: Icons.assignment_rounded,
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(
                                () => _selectedAssignmentId =
                                    v.isEmpty ? null : v,
                              ),
                              searchHint: 'Search assignments…',
                            ),
                            if (_selectedAssignmentId == _kCreate)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    final courseId = _cohortStudentGroups.keys.firstOrNull;
                                    await context.push(
                                      '/teacher/assignments/add',
                                      extra: <String, dynamic>{
                                        'prefillCourseId': courseId,
                                        'prefillSubject': _selectedSubject,
                                        'prefillStudentIds': _selectedStudentIds.toList(),
                                      },
                                    );
                                    if (mounted) {
                                      // Reload so new assignment appears in list
                                      final repo = ref.read(teacherMobileRepositoryProvider);
                                      final raw = await repo.fetchTeacherAssignments();
                                      if (mounted) {
                                        setState(() {
                                        _teacherAssignmentsList = raw;
                                        _selectedAssignmentId = null;
                                      });
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.open_in_new_rounded),
                                  label: Text(
                                    _selectedSubject != null
                                        ? 'Create assignment for $_selectedSubject →'
                                        : 'Create assignment →',
                                  ),
                                ),
                              ),
                          ] else if (_gradeType == _GradeType.exam) ...[
                            const _SectionHeader(
                              icon: Icons.quiz_outlined,
                              title: 'Exam',
                            ),
                            const SizedBox(height: 14),
                            // Exam DDL — same pattern as Assignment DDL.
                            LiquidGlassDropdown<String>(
                              label: _selectedExamId == null
                                  ? 'Choose exam'
                                  : _selectedExamId == _kCreate
                                      ? '+ Create new exam'
                                      : _teacherExamsList
                                              .where((e) =>
                                                  (e['id'] ?? '') ==
                                                  _selectedExamId)
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
                                const LiquidGlassDropdownItem(
                                  value: _kCreate,
                                  label: '+ Create new exam',
                                  icon: Icons.add_circle_outline_rounded,
                                ),
                                ..._teacherExamsList.map(
                                  (e) => LiquidGlassDropdownItem(
                                    value: (e['id'] ?? '').toString(),
                                    label: (e['title'] ?? '').toString(),
                                    icon: Icons.quiz_rounded,
                                  ),
                                ),
                              ],
                              onChanged: (v) => setState(
                                () => _selectedExamId =
                                    v.isEmpty ? null : v,
                              ),
                              searchHint: 'Search exams…',
                            ),
                            if (_selectedExamId == _kCreate) ...[
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: () async {
                                  final courseId =
                                      _cohortStudentGroups.keys.firstOrNull;
                                  final cohortId = _allStudents
                                      .where((s) => _selectedStudentIds
                                          .contains(s.studentId))
                                      .firstOrNull
                                      ?.cohortId;
                                  await context.push(
                                    '/teacher/exams/create',
                                    extra: <String, dynamic>{
                                      'subject': _selectedSubject ?? '',
                                      'courseId': courseId ?? '',
                                      'cohortId': cohortId ?? '',
                                      'prefillStudentIds':
                                          _selectedStudentIds.toList(),
                                    },
                                  );
                                  if (mounted) {
                                    final repo = ref
                                        .read(teacherMobileRepositoryProvider);
                                    final raw = await repo.listTeacherExams();
                                    if (mounted) {
                                      setState(() {
                                        _teacherExamsList = raw;
                                        _selectedExamId = null;
                                      });
                                    }
                                  }
                                },
                                icon: const Icon(Icons.open_in_new_rounded),
                                label: Text(
                                  _selectedSubject != null
                                      ? 'Create exam for $_selectedSubject →'
                                      : 'Create exam →',
                                ),
                              ),
                            // Exam selected — grade inputs appear in section 5 below.
                            ],
                          ],
                          if (_gradeType == _GradeType.other) ...[
                            const _SectionHeader(
                              icon: Icons.star_outline_rounded,
                              title: 'Other grade',
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _otherTitleCtrl,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.teacherAssignmentTitleField,
                                hintText: 'e.g. Class participation, Quiz 3',
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _otherMaxCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLocalizations.of(context)!.teacherGradeOutOfLabel,
                                hintText: 'e.g. 10',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // ── 5: Per-student grade inputs ───────────────────────
                    if (_showGradeInputs && selectedStudents.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _SectionHeader(
                              icon: Icons.edit_note_rounded,
                              title: 'Enter grades',
                            ),
                            const SizedBox(height: 14),
                            ...selectedStudents.asMap().entries.map(
                              (entry) {
                                final i = entry.key;
                                final s = entry.value;
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: i < selectedStudents.length - 1
                                        ? 10
                                        : 0,
                                  ),
                                  child: _StudentGradeRow(
                                    student: s,
                                    controller: _gradeCtrlMap[s.studentId]!,
                                    maxGrade: _gradeType == _GradeType.other
                                        ? int.tryParse(_otherMaxCtrl.text)
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],

                    // ── 6: Published ──────────────────────────────────────
                    const SizedBox(height: 14),
                    _SectionCard(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Icon(
                          _published
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: _published
                              ? cs.primary
                              : cs.onSurfaceVariant,
                        ),
                        title: Text(AppLocalizations.of(context)!.teacherGradePublishedTitle),
                        subtitle:
                            Text(AppLocalizations.of(context)!.teacherGradePublishedSubtitle),
                        value: _published,
                        onChanged: (v) => setState(() => _published = v),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
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
  // Local copy so toggling updates the UI immediately without waiting for parent rebuild.
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
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
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
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.teacherSearchStudents,
                prefixIcon:
                    const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
              ),
            ),
          ),
          // List
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
          // Done button
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
                child: Text(
                  widget.selected.isEmpty
                      ? 'Done'
                      : 'Done — ${widget.selected.length} student${widget.selected.length == 1 ? '' : 's'}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scroll wrapper that dismisses keyboard on drag
// ─────────────────────────────────────────────────────────────────────────────

class _AddGradeBody extends StatelessWidget {
  const _AddGradeBody({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [child],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-student grade row
// ─────────────────────────────────────────────────────────────────────────────

class _StudentGradeRow extends StatelessWidget {
  const _StudentGradeRow({
    required this.student,
    required this.controller,
    this.maxGrade,
  });

  final TeacherStudentWithLevel student;
  final TextEditingController controller;
  final int? maxGrade;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Row(
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
              if (student.gradeLevel != null)
                Text(
                  'Grade ${student.gradeLevel}',
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
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
            decoration: InputDecoration(
              hintText: maxGrade != null ? '/ $maxGrade' : '—',
              hintStyle:
                  TextStyle(color: cs.onSurfaceVariant, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Student picker trigger
// ─────────────────────────────────────────────────────────────────────────────

class _StudentPickerTrigger extends StatelessWidget {
  const _StudentPickerTrigger({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(Icons.people_outline_rounded,
                size: 20, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                count == 0
                    ? 'Tap to select students…'
                    : '$count student${count == 1 ? '' : 's'} selected',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: count == 0 ? cs.onSurfaceVariant : null,
                  fontWeight:
                      count > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Student chip
// ─────────────────────────────────────────────────────────────────────────────

class _StudentChip extends StatelessWidget {
  const _StudentChip({required this.student, required this.onRemove});

  final TeacherStudentWithLevel student;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            student.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close_rounded,
              size: 15,
              color: cs.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section widgets
// ─────────────────────────────────────────────────────────────────────────────

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
        border:
            Border.all(color: cs.outlineVariant),
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

