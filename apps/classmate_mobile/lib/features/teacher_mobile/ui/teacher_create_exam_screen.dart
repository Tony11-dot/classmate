// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'widgets/audience_section.dart';

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
  String? _selectedCourseId;
  String? _selectedSubject;
  DateTime? _selectedDate;
  bool _published = true;
  final List<Map<String, dynamic>> _attachments = [];
  bool _saving = false;

  final Set<String> _selectedCohortIds = {};
  final Set<String> _selectedStudentIds = {};
  final Set<int> _selectedGrades = {};

  List<int> get _availableGrades {
    final s = <int>{};
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

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any, allowMultiple: true);
    if (result == null) return;
    final repo = ref.read(teacherMobileRepositoryProvider);
    setState(() => _saving = true);
    try {
      for (final file in result.files) {
        final path = file.path;
        if (path == null) continue;
        try {
          // Upload the file and get a real CDN URL.
          final uploaded = await repo.uploadAttachmentFile(path, file.name);
          final url = uploaded['url']?.toString() ?? uploaded['mediaUrl']?.toString() ?? '';
          setState(() {
            _attachments.add({'title': file.name, 'url': url.isNotEmpty ? url : path});
          });
        } catch (_) {
          // Upload failed — store local path as fallback (visible to teacher only).
          setState(() {
            // Upload failed — skip this attachment rather than storing a local path the server can't access
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.teacherExamUploadFailedSkipped(file.name))),
              );
            }
          });
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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

      if (_isEditing) {
        await ref.read(teacherMobileRepositoryProvider).updateTeacherExam(
          _editingId,
          {
            'title': title,
            'subject': _selectedSubject,
            'courseId': derivedCourseId,
            'date': dateStr,
            'maxGrade': int.tryParse(_maxGradeCtrl.text.trim()),
            'published': _published,
            'targetType': _selectedCohortIds.isNotEmpty ? 'COHORT' : _selectedStudentIds.isNotEmpty ? 'STUDENTS' : 'EVERYONE',
            'targetCohortIds': _selectedCohortIds.toList(),
            'targetStudentIds': _selectedStudentIds.toList(),
            'targetGrades': _selectedGrades.toList(),
            'attachments': _attachments.where((a) => a['_localOnly'] != true && (a['url'] as String? ?? '').startsWith('http')).toList(),
          },
        );
      } else {
        await ref.read(teacherMobileRepositoryProvider).createTeacherExam(
          title: title,
          subject: _selectedSubject,
          courseId: derivedCourseId,
          date: dateStr,
          maxGrade: int.tryParse(_maxGradeCtrl.text.trim()),
          published: _published,
          targetType: _selectedCohortIds.isNotEmpty ? 'COHORT' : _selectedStudentIds.isNotEmpty ? 'STUDENTS' : 'EVERYONE',
          targetCohortIds: _selectedCohortIds.toList(),
          targetStudentIds: _selectedStudentIds.toList(),
          targetGrades: _selectedGrades.toList(),
          attachments: _attachments.where((a) => a['_localOnly'] != true && (a['url'] as String? ?? '').startsWith('http')).toList(),
        );
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
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Exam' : 'Create Exam',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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
                  title: 'Audience',
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
                const SizedBox(height: 12),

                // ── Exam details ────────────────────────────────────────────
                _Card(
                  title: 'Exam Details',
                  child: Column(
                    children: [
                      // Subject DDL
                      if (_subjects.isNotEmpty) ...[
                        LiquidGlassDropdown<String?>(
                          label: 'Subject *',
                          value: _selectedSubject,
                          items: [
                            const LiquidGlassDropdownItem(value: null, label: 'Select subject', icon: Icons.subject_rounded),
                            ..._subjects.map((s) => LiquidGlassDropdownItem(value: s, label: s, icon: Icons.menu_book_rounded)),
                            const LiquidGlassDropdownItem(value: 'Other', label: 'Other', icon: Icons.category_rounded),
                          ],
                          onChanged: (v) => setState(() => _selectedSubject = v),
                          searchHint: 'Search subjects...',
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
                                ? DateFormat.yMMMd(locale).format(_selectedDate!)
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
                  title: 'Study Materials  (${_attachments.length})',
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
                      OutlinedButton.icon(
                        onPressed: _pickFiles,
                        icon: const Icon(Icons.file_upload_outlined, size: 18),
                        label: Text(AppLocalizations.of(context)!.commonAttachStudyMaterials),
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

