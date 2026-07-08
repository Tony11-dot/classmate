// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../../../ui/widgets/weight_formats_field.dart';
import '../../../ui/widgets/semester_select_field.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'widgets/audience_section.dart';
import 'widgets/audience_students_summary.dart';
import 'widgets/classroom_library_picker.dart';

class TeacherCreateExamScreen extends ConsumerStatefulWidget {
  const TeacherCreateExamScreen({super.key, this.initialExam});
  final Map<String, dynamic>? initialExam;

  @override
  ConsumerState<TeacherCreateExamScreen> createState() => _TeacherCreateExamScreenState();
}

class _TeacherCreateExamScreenState extends ConsumerState<TeacherCreateExamScreen> {
  List<TeacherCourse> _courses = [];
  List<({String id, String name, int grade})> _cohorts = [];
  List<TeacherStudentWithLevel> _allStudents = [];
  List<String> _schoolSubjects = [];
  bool _loadingData = true;

  final _titleCtrl = TextEditingController();
  final _maxGradeCtrl = TextEditingController();
  List<int> _weights = <int>[];
  int? _semester;
  String? _selectedCourseId;
  String? _selectedSubject;
  DateTime? _selectedDate;
  bool _published = true;
  final List<Map<String, dynamic>> _attachments = [];
  /// TeacherMaterial ids picked from the library that we'll attach to
  /// the exam via /attach-material after the exam itself is saved (or
  /// updated). Each id also gets a placeholder card in [_attachments]
  /// so the teacher sees it staged before save.
  final Set<String> _pendingMaterialIds = {};
  bool _saving = false;

  final Set<String> _selectedCohortIds = {};
  final Set<String> _selectedStudentIds = {};
  final Set<int> _selectedGrades = {};
  AudienceResolution? _audienceResolution;

  List<int> get _availableGrades {
    final s = <int>{...ref.read(authSessionProvider).schoolGrades};
    for (final c in _cohorts) {
      if (c.grade > 0) s.add(c.grade);
    }
    final list = s.toList()..sort();
    return list;
  }

  // Only treat as edit when there's an actual server-side id in the map.
  // Prefill maps (passed from the add-grade flow) have no 'id' key.
  bool get _isEditing {
    final id = widget.initialExam?['id']?.toString().trim() ?? '';
    return id.isNotEmpty;
  }

  String get _editingId => widget.initialExam?['id']?.toString().trim() ?? '';

  @override
  void initState() {
    super.initState();
    final exam = widget.initialExam;
    if (exam != null) {
      // Safe extractions — never use `as String` on untrusted map values.
      _titleCtrl.text = exam['title']?.toString() ?? '';
      _maxGradeCtrl.text = exam['maxGrade']?.toString() ?? '';
      _weights = readWeights(exam);
      _semester = exam['semester'] is int ? exam['semester'] as int : int.tryParse('${exam['semester']}');
      _published = exam['published'] == true;
      final dateRaw = exam['date']?.toString() ?? '';
      if (dateRaw.isNotEmpty) _selectedDate = DateTime.tryParse(dateRaw);
      _selectedCourseId = exam['courseId']?.toString();
      _selectedSubject = exam['subject']?.toString();

      final cIds = exam['targetCohortIds'];
      if (cIds is List) _selectedCohortIds.addAll(cIds.map((e) => e.toString()));

      // Support both server 'targetStudentIds' and add-grade 'prefillStudentIds'
      final sIds = exam['targetStudentIds'] ?? exam['prefillStudentIds'];
      if (sIds is List) {
        _selectedStudentIds.addAll(sIds.map((e) => e.toString()));
      }

      final gs = exam['targetGrades'];
      if (gs is List) {
        for (final g in gs) {
          final n = g is int ? g : int.tryParse('$g');
          if (n != null) _selectedGrades.add(n);
        }
      }

      final rawAttach = exam['attachments'];
      if (rawAttach is List) {
        for (final a in rawAttach) {
          if (a is Map) _attachments.add(Map<String, dynamic>.from(a));
        }
      }
    }
    Future<void>.microtask(_loadData);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _maxGradeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final results = await Future.wait([
        repo.fetchClassrooms(),
        repo.fetchAllStudents(),
        repo.fetchSubjects(),
        repo.fetchCohortsForPicker(),
      ]);
      if (!mounted) return;
      final courses = results[0] as List<TeacherCourse>;
      final cohortMaps = results[3] as List<Map<String, dynamic>>;
      setState(() {
        _courses = courses;
        _allStudents = results[1] as List<TeacherStudentWithLevel>;
        _schoolSubjects = results[2] as List<String>;
        _cohorts = cohortMaps.map((c) => (id: (c['id'] ?? '').toString(), name: (c['name'] ?? '').toString().replaceFirst(RegExp(r'^\d+\s*-\s*'), ''), grade: c['grade'] is int ? c['grade'] as int : int.tryParse('${c['grade'] ?? ''}') ?? 0)).where((c) => c.id.isNotEmpty).toList()..sort((a, b) => a.grade.compareTo(b.grade));
        if (_selectedCourseId == null && courses.isNotEmpty) {
          _selectedCourseId = courses.first.id;
        }
        _loadingData = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingData = false);
    }
  }

  List<String> get _subjects => _schoolSubjects;

  /// Opens the teacher's material library so an existing material can be
  /// stamped into the exam's attachments. The new material flow inside
  /// the picker inherits the exam's subject + audience (cohorts +
  /// individual students) so the just-created material defaults to the
  /// same target set — every field still editable on the add screen.
  Future<void> _pickMaterial() async {
    final picked = await showClassroomLibraryPicker(
      context: context,
      kind: ClassroomLibraryKind.material,
      alreadyAttachedTeacherIds: _pendingMaterialIds,
      prefillSubject: _selectedSubject,
      prefillCohortIds: _selectedCohortIds.toList(),
      prefillStudentIds: _selectedStudentIds.toList(),
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    // Fetch the picked material's metadata so we can show a card.
    try {
      final mats = await ref
          .read(teacherMobileRepositoryProvider)
          .listTeacherMaterials();
      final mat = mats.firstWhere(
        (m) => (m['id'] ?? '').toString() == picked,
        orElse: () => const {},
      );
      if (!mounted) return;
      setState(() {
        _pendingMaterialIds.add(picked);
        // Drop any pre-existing row pointing at the same material so
        // the picker never spawns "two boxes" (one snapshot from the
        // edit-mode initial load, one pending placeholder from this
        // pick) — only the freshest entry sticks.
        _attachments.removeWhere(
            (a) => (a['_sourceMaterialId'] ?? '').toString() == picked);
        _attachments.add({
          'title': (mat['title'] as String?) ?? 'Material',
          'subject': mat['subject'],
          '_sourceMaterialId': picked,
          '_pendingMaterial': true,
        });
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pendingMaterialIds.add(picked);
        _attachments.removeWhere(
            (a) => (a['_sourceMaterialId'] ?? '').toString() == picked);
        _attachments.add({
          'title': 'Material',
          '_sourceMaterialId': picked,
          '_pendingMaterial': true,
        });
      });
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherExamEnterTitle)));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherExamPickDate)));
      return;
    }
    if (_selectedSubject == null || _selectedSubject!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherExamSelectSubject)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final dateStr =
          '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      // Auto-derive courseId from subject (pick first matching course)
      final derivedCourseId = _selectedSubject != null
          ? _courses.where((c) => c.subject == _selectedSubject).firstOrNull?.id
          : _courses.firstOrNull?.id;

      var effectiveTargetType = _selectedCohortIds.isNotEmpty ? 'COHORT' : _selectedStudentIds.isNotEmpty ? 'STUDENTS' : 'EVERYONE';
      var outCohortIds = _selectedCohortIds.toList();
      var outStudentIds = _selectedStudentIds.toList();
      var outGrades = _selectedGrades.toList();
      // Materialize to an explicit student list when students were removed.
      if (_audienceResolution?.hasExclusions == true) {
        effectiveTargetType = 'STUDENTS';
        outStudentIds = _audienceResolution!.effective.map((s) => s.studentId).toList();
        outCohortIds = [];
        outGrades = [];
      }

      // Pending-material rows are written via /attach-material after the
      // exam is saved (server expands material audience + snapshots files).
      // They don't have a `url`, so the existing filter already excludes them.
      final repo = ref.read(teacherMobileRepositoryProvider);
      String savedExamId;
      if (_isEditing) {
        await repo.updateTeacherExam(
          _editingId,
          {
            'title': title,
            'subject': _selectedSubject,
            'courseId': derivedCourseId,
            'date': dateStr,
            'maxGrade': int.tryParse(_maxGradeCtrl.text.trim()),
            'weightPercents': _weights,
            'semester': _semester,
            'published': _published,
            'targetType': effectiveTargetType,
            'targetCohortIds': outCohortIds,
            'targetStudentIds': outStudentIds,
            'targetGrades': outGrades,
            'attachments': _attachments.where((a) => a['_localOnly'] != true && a['_pendingMaterial'] != true && (a['url'] as String? ?? '').startsWith('http')).toList(),
          },
        );
        savedExamId = _editingId;
      } else {
        final created = await repo.createTeacherExam(
          title: title,
          subject: _selectedSubject,
          courseId: derivedCourseId,
          date: dateStr,
          maxGrade: int.tryParse(_maxGradeCtrl.text.trim()),
          weightPercents: _weights,
          semester: _semester,
          published: _published,
          targetType: effectiveTargetType,
          targetCohortIds: outCohortIds,
          targetStudentIds: outStudentIds,
          targetGrades: outGrades,
          attachments: _attachments.where((a) => a['_localOnly'] != true && a['_pendingMaterial'] != true && (a['url'] as String? ?? '').startsWith('http')).toList(),
        );
        // Server returns `{ok, exam: {id, …}}` — the legacy shape was
        // a flat row. Try the nested key first, fall back to the flat
        // id so the attach calls below find a real exam to point at.
        // Without this fix the post-create attach loop ran with an
        // empty examId and silently swallowed every material.
        final nested = created['exam'];
        if (nested is Map && (nested['id'] ?? '').toString().isNotEmpty) {
          savedExamId = nested['id'].toString();
        } else {
          savedExamId = (created['id'] ?? '').toString();
        }
      }

      // Attach every pending material to the saved exam. Each call also
      // expands the material's audience to UNION with the exam's, so
      // the material reaches the new cohort/student/grade set too.
      for (final mid in _pendingMaterialIds) {
        try {
          await repo.attachMaterialToExam(examId: savedExamId, materialId: mid);
        } catch (_) {
          // Soft-fail: one bad material shouldn't roll back the exam save.
        }
      }

      if (!mounted) return;
      context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: l.a11yBack,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? AppLocalizations.of(context)!.teacherExamEditTitle : AppLocalizations.of(context)!.teacherExamNewTitle,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const CmLoading(size: 16)
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(_isEditing ? 'Save' : 'Create'),
            ),
          ),
        ],
      ),
      body: _loadingData
          ? const Center(child: CmLoading())
          : ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                // ── Targeting ──────────────────────────────────────────────
                _Card(
                  title: AppLocalizations.of(context)!.teacherAudienceSectionTitle,
                  child: AudienceSection(
                    cohorts: _cohorts,
                    allStudents: _allStudents,
                    selectedCohortIds: _selectedCohortIds,
                    selectedStudentIds: _selectedStudentIds,
                    selectedGrades: _selectedGrades,
                    availableGrades: _availableGrades,
                    repo: ref.read(teacherMobileRepositoryProvider),
                    onChanged: () => setState(() {}),
                  ),
                ),
                AudienceStudentsSummary(
                  targetType: _selectedCohortIds.isNotEmpty
                      ? 'COHORT'
                      : _selectedStudentIds.isNotEmpty
                          ? 'STUDENTS'
                          : null,
                  cohortIds: _selectedCohortIds.toList(),
                  studentIds: _selectedStudentIds.toList(),
                  grades: _selectedGrades.toList(),
                  onResolutionChanged: (r) => _audienceResolution = r,
                ),
                const SizedBox(height: 12),

                // ── Exam details ────────────────────────────────────────────
                _Card(
                  title: AppLocalizations.of(context)!.teacherExamDetailsSection,
                  child: Column(
                    children: [
                      // Subject DDL
                      if (_subjects.isNotEmpty) ...[
                        LiquidGlassDropdown<String?>(
                          label: AppLocalizations.of(context)!.teacherSubjectRequired,
                          value: _selectedSubject,
                          items: [
                            LiquidGlassDropdownItem(value: null, label: AppLocalizations.of(context)!.teacherSelectSubject, icon: Icons.subject_rounded),
                            ..._subjects.map((s) => LiquidGlassDropdownItem(value: s, label: s, icon: Icons.menu_book_rounded)),
                            LiquidGlassDropdownItem(value: 'Other', label: AppLocalizations.of(context)!.teacherOtherSubjectOption, icon: Icons.category_rounded),
                          ],
                          onChanged: (v) => setState(() => _selectedSubject = v),
                          searchHint: AppLocalizations.of(context)!.teacherMaterialSubjectSearch,
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Title
                      TextField(
                        controller: _titleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.teacherAssignmentTitleField, border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),

                      // Date
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.teacherExamDate,
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today_rounded),
                          ),
                          child: Text(
                            _selectedDate != null
                                ? FriendlyDate.date(_selectedDate!)
                                : 'Pick a date',
                            style: TextStyle(color: _selectedDate != null ? cs.onSurface : cs.onSurfaceVariant),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Max grade
                      TextField(
                        controller: _maxGradeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.teacherAssignmentMaxGrade,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.grade_rounded),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Weight on the subject average (multi-format) + semester
                      WeightFormatsField(
                        value: _weights,
                        onChanged: (w) => _weights = w,
                      ),
                      const SizedBox(height: 12),
                      SemesterSelectField(
                        count: schoolSemesterCount(ref.read(authSessionProvider).schoolSemesters),
                        value: _semester,
                        onChanged: (v) => setState(() => _semester = v),
                      ),
                      const SizedBox(height: 8),

                      SwitchListTile(
                        value: _published,
                        onChanged: (v) => setState(() => _published = v),
                        title: Text(AppLocalizations.of(context)!.teacherExamPublishedHint, style: const TextStyle(fontWeight: FontWeight.w600)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Materials ────────────────────────────────────────────────
                _Card(
                  title: AppLocalizations.of(context)!.teacherExamStudyMaterialsWithCount(_attachments.length),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._attachments.asMap().entries.map((entry) {
                        final i = entry.key;
                        final mat = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: LiquidGlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            borderRadius: BorderRadius.circular(12),
                            color: cs.surfaceContainerLow,
                            border: Border.all(color: cs.outlineVariant),
                            child: Row(
                              children: [
                                Icon(Icons.insert_drive_file_outlined, size: 18, color: cs.primary),
                                const SizedBox(width: 10),
                                Expanded(child: Text(mat['title'] as String? ?? '', overflow: TextOverflow.ellipsis)),
                                IconButton(
                                  tooltip: l.a11yRemove,
                                  icon: Icon(Icons.close_rounded, size: 16, color: cs.error),
                                  onPressed: () => setState(() => _attachments.removeAt(i)),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      // Single attach button — opens the same library picker
                      // that powers period attachments. The picker itself
                      // exposes "Create new material" so file uploads still
                      // happen through the add-material screen rather than a
                      // second button here.
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: _pickMaterial,
                          icon: const Icon(Icons.attach_file_rounded, size: 18),
                          label: Text(AppLocalizations.of(context)!.teacherSlotAttachMaterial),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Shared card ────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

