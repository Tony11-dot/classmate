// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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

  // Targeting
  String _targetType = 'EVERYONE';
  final Set<String> _selectedCohortIds = {};
  final Set<String> _selectedStudentIds = {};

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
      _targetType = exam['targetType']?.toString() ?? 'EVERYONE';

      final cIds = exam['targetCohortIds'];
      if (cIds is List) _selectedCohortIds.addAll(cIds.map((e) => e.toString()));

      // Support both server 'targetStudentIds' and add-grade 'prefillStudentIds'
      final sIds = exam['targetStudentIds'] ?? exam['prefillStudentIds'];
      if (sIds is List) {
        _selectedStudentIds.addAll(sIds.map((e) => e.toString()));
        if (_selectedStudentIds.isNotEmpty) _targetType = 'STUDENTS';
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

  String _targetSummary() {
    if (_targetType == 'EVERYONE') return 'All students';
    if (_targetType == 'COHORT') {
      if (_selectedCohortIds.isEmpty) return 'No cohorts selected';
      return _cohorts.where((c) => _selectedCohortIds.contains(c.id)).map((c) => c.name).join(', ');
    }
    if (_selectedStudentIds.isEmpty) return 'No students selected';
    return '${_selectedStudentIds.length} student${_selectedStudentIds.length == 1 ? '' : 's'}';
  }

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
                SnackBar(content: Text('Upload failed for ${file.name}. File skipped.')),
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
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title.')));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please pick an exam date.')));
      return;
    }
    if (_selectedSubject == null || _selectedSubject!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject.')),
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

  Future<void> _openCohortPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PersonPickerSheet(
        title: 'Select classes',
        items: _cohorts.map((c) => _PickerItem(
          id: c.id,
          label: c.name,
          subtitle: c.grade > 0 ? 'Grade ${c.grade}' : '',
        )).toList(),
        selected: Set.from(_selectedCohortIds),
        onToggle: (id) => setState(() {
          if (_selectedCohortIds.contains(id)) {
            _selectedCohortIds.remove(id);
          } else {
            _selectedCohortIds.add(id);
          }
        }),
      ),
    );
  }

  Future<void> _openStudentPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PersonPickerSheet(
        title: 'Select students',
        items: _allStudents
            .map((s) => _PickerItem(
                  id: s.studentId,
                  label: s.name,
                  subtitle: s.gradeLevel != null ? 'Grade ${s.gradeLevel}' : s.cohortName,
                ))
            .toList(),
        selected: Set.from(_selectedStudentIds),
        onToggle: (id) => setState(() {
          if (_selectedStudentIds.contains(id)) {
            _selectedStudentIds.remove(id);
          } else {
            _selectedStudentIds.add(id);
          }
        }),
      ),
    );
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
          ? const Center(child: const CmLoading())
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
                        decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
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
                          decoration: const InputDecoration(
                            labelText: 'Exam date *',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today_rounded),
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
                        decoration: const InputDecoration(
                          labelText: 'Max grade (optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.grade_rounded),
                        ),
                      ),
                      const SizedBox(height: 8),

                      SwitchListTile(
                        value: _published,
                        onChanged: (v) => setState(() => _published = v),
                        title: const Text('Published — students can see this exam', style: TextStyle(fontWeight: FontWeight.w600)),
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
                        label: const Text('Attach study materials'),
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

// ── Person picker sheet (shared) ───────────────────────────────────────────────

class _PickerItem {
  const _PickerItem({required this.id, required this.label, this.subtitle = ''});
  final String id;
  final String label;
  final String subtitle;
}

class _PersonPickerSheet extends StatefulWidget {
  const _PersonPickerSheet({
    required this.title,
    required this.items,
    required this.selected,
    required this.onToggle,
  });
  final String title;
  final List<_PickerItem> items;
  final Set<String> selected;
  final void Function(String id) onToggle;

  @override
  State<_PersonPickerSheet> createState() => _PersonPickerSheetState();
}

class _PersonPickerSheetState extends State<_PersonPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  // Local mirror of selected — updates immediately on tap so checkmarks are live.
  late Set<String> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = Set.from(widget.selected);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggle(String id) {
    setState(() {
      if (_localSelected.contains(id)) {
        _localSelected.remove(id);
      } else {
        _localSelected.add(id);
      }
    });
    // Also update parent so the underlying set stays in sync.
    widget.onToggle(id);
  }

  List<_PickerItem> get _filtered {
    if (_query.trim().isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((i) => i.label.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) => Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                  if (_localSelected.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)),
                      child: Text('${_localSelected.length} selected',
                          style: TextStyle(color: cs.onPrimaryContainer, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scroll,
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) {
                  final item = _filtered[i];
                  final sel = _localSelected.contains(item.id); // ← local, updates live
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: sel ? cs.primaryContainer : cs.surfaceContainerHigh,
                      child: Text(
                        item.label.isNotEmpty ? item.label[0].toUpperCase() : '?',
                        style: TextStyle(fontWeight: FontWeight.w700, color: sel ? cs.onPrimaryContainer : cs.onSurface),
                      ),
                    ),
                    title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: item.subtitle.isNotEmpty ? Text(item.subtitle) : null,
                    trailing: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: sel
                          ? Icon(Icons.check_circle_rounded, key: const ValueKey('checked'), color: cs.primary)
                          : Icon(Icons.radio_button_unchecked, key: const ValueKey('unchecked'), color: cs.outlineVariant),
                    ),
                    onTap: () => _toggle(item.id),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Done (${_localSelected.length} selected)'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
