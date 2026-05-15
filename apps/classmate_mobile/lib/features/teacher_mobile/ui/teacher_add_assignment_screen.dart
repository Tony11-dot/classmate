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

class TeacherAddAssignmentScreen extends ConsumerStatefulWidget {
  const TeacherAddAssignmentScreen({
    super.key,
    this.prefillCourseId,
    this.prefillSubject,
    this.prefillStudentIds = const [],
    this.initialAssignment,
  });

  final String? prefillCourseId;
  final String? prefillSubject;
  final List<String> prefillStudentIds;
  final Map<String, dynamic>? initialAssignment;

  @override
  ConsumerState<TeacherAddAssignmentScreen> createState() =>
      _TeacherAddAssignmentScreenState();
}

class _TeacherAddAssignmentScreenState
    extends ConsumerState<TeacherAddAssignmentScreen> {
  // ── Data ────────────────────────────────────────────────────────────────────
  List<TeacherCourse> _courses = [];
  List<({String id, String name, int grade})> _cohorts = [];
  List<TeacherStudentWithLevel> _allStudents = [];
  List<String> _schoolSubjects = [];
  bool _loading = true;

  // ── Form fields ──────────────────────────────────────────────────────────────
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _maxGradeCtrl = TextEditingController();
  String? _selectedCourseId;
  String? _selectedSubject;
  DateTime? _dueDate;
  final List<Map<String, dynamic>> _attachments = [];

  // ── Targeting ────────────────────────────────────────────────────────────────
  String _targetType = 'EVERYONE';
  final Set<String> _selectedCohortIds = {};
  final Set<String> _selectedStudentIds = {};
  // member preview: id → list of student names
  final Map<String, List<String>> _memberCache = {};

  bool _saving = false;

  bool get _isEditing => (widget.initialAssignment?['id'] ?? '').toString().isNotEmpty;
  String get _editingId => widget.initialAssignment?['id']?.toString() ?? '';

  @override
  void initState() {
    super.initState();
    // Pre-fill when editing
    final a = widget.initialAssignment;
    if (a != null) {
      _titleCtrl.text = (a['title'] ?? '').toString();
      _descCtrl.text = (a['description'] ?? a['body'] ?? '').toString();
      _maxGradeCtrl.text = a['maxGrade'] != null ? '${a['maxGrade']}' : '';
      _selectedSubject = a['subject']?.toString();
      _selectedCourseId = (a['courseId'] ?? a['_courseId'] ?? '').toString().isEmpty ? null : (a['courseId'] ?? a['_courseId']).toString();
      if (a['dueAt'] != null) _dueDate = DateTime.tryParse(a['dueAt'].toString());
      final cIds = a['targetCohortIds']; if (cIds is List) _selectedCohortIds.addAll(cIds.map((e) => e.toString()));
      final sIds = a['targetStudentIds']; if (sIds is List) _selectedStudentIds.addAll(sIds.map((e) => e.toString()));
      final att = a['attachments']; if (att is List) { for (final x in att) { if (x is Map) _attachments.add(Map<String, dynamic>.from(x)); } }
    }
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _maxGradeCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final futures = <Future>[
        repo.fetchClassrooms(),
        repo.fetchAllStudents(),
        repo.fetchSubjects(),
        repo.fetchCohortsForPicker(),
        if (widget.prefillCourseId != null)
          repo.fetchClassroomPeople(widget.prefillCourseId!),
      ];
      final results = await Future.wait(futures);
      if (!mounted) return;

      final courses = results[0] as List<TeacherCourse>;
      final students = results[1] as List<TeacherStudentWithLevel>;
      final subjects = results[2] as List<String>;

      // Pre-fill subject and course from classroom context
      if (_selectedSubject == null && widget.prefillSubject?.isNotEmpty == true) {
        _selectedSubject = widget.prefillSubject;
      }
      if (_selectedCourseId == null && widget.prefillCourseId?.isNotEmpty == true) {
        _selectedCourseId = widget.prefillCourseId;
      }

      // Auto-select students from grade screen (prefillStudentIds)
      if (widget.prefillStudentIds.isNotEmpty) {
        _targetType = 'STUDENTS';
        _selectedStudentIds.addAll(widget.prefillStudentIds);
      }
      // Pre-select classroom students when launched from classroom tab
      else if (widget.prefillCourseId != null && results.length > 4 && _targetType == 'EVERYONE') {
        final peopleData = results[4] as Map<String, dynamic>;
        final items = peopleData['items'] as Map<String, dynamic>?;
        final studentIds = items?['studentUserIds'];
        if (studentIds is List && studentIds.isNotEmpty) {
          _targetType = 'STUDENTS';
          _selectedStudentIds.addAll(studentIds.map((e) => e.toString()));
        }
      }

      final cohortMaps = results[3] as List<Map<String, dynamic>>;
      setState(() {
        _courses = courses;
        _allStudents = students;
        _schoolSubjects = subjects;
        _cohorts = cohortMaps.map((c) => (
          id: (c['id'] ?? '').toString(),
          name: (c['name'] ?? '').toString().replaceFirst(RegExp(r'^\d+\s*-\s*'), ''),
          grade: c['grade'] is int ? c['grade'] as int : int.tryParse('${c['grade'] ?? ''}') ?? 0,
        )).where((c) => c.id.isNotEmpty).toList()..sort((a, b) => a.grade.compareTo(b.grade));
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<String> get _subjects => _schoolSubjects;

  List<String> get _previewMembers {
    final seen = <String>{};
    final result = <String>[];
    void add(List<String> names) {
      for (final n in names) {
        if (seen.add(n)) result.add(n);
      }
    }
    if (_selectedCourseId != null) add(_memberCache[_selectedCourseId!] ?? []);
    for (final id in _selectedCohortIds) {
      add(_memberCache[id] ?? []);
    }
    result.sort();
    return result;
  }

  Future<void> _fetchMembersFor(String id, {bool isClassroom = false}) async {
    if (_memberCache.containsKey(id)) return;
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      if (isClassroom) {
        final data = await repo.fetchClassroomPeople(id);
        final items = (data['items'] as Map?)?['students'] as List? ?? [];
        if (mounted) setState(() => _memberCache[id] = items.map((s) => (s as Map)['name']?.toString() ?? '').where((n) => n.isNotEmpty).toList());
      } else {
        final students = await repo.fetchCohortStudents(id);
        if (mounted) setState(() => _memberCache[id] = students.map((s) => s.name).toList());
      }
    } catch (_) {}
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    // Show uploading state
    setState(() {});
    final repo = ref.read(teacherMobileRepositoryProvider);
    for (final file in result.files) {
      final path = file.path ?? '';
      if (path.isEmpty) continue;
      try {
        final uploaded = await repo.uploadAttachmentFile(path, file.name);
        final url = (uploaded['url'] ?? uploaded['fileUrl'] ?? '').toString().trim();
        if (url.isNotEmpty) {
          setState(() => _attachments.add({'name': file.name, 'url': url, 'type': 'file'}));
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not upload ${file.name}')),
          );
        }
      }
    }
  }

  Future<void> _save({required bool published}) async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title.')),
      );
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
      final dueAtStr = _dueDate != null
          ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
          : null;

      // Derive targetType from additive selections
      final effectiveTargetType = _selectedCohortIds.isNotEmpty
          ? 'COHORT'
          : _selectedStudentIds.isNotEmpty
              ? 'STUDENTS'
              : 'EVERYONE';

      if (_isEditing) {
        await ref.read(teacherMobileRepositoryProvider).updateTeacherAssignment(_editingId, {
          'title': title,
          'description': _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          'subject': _selectedSubject,
          'dueAt': dueAtStr,
          'maxGrade': int.tryParse(_maxGradeCtrl.text.trim()),
          'targetType': effectiveTargetType,
          'targetCohortIds': _selectedCohortIds.toList(),
          'targetStudentIds': _selectedStudentIds.toList(),
          'attachments': _attachments,
          'published': published,
        });
      } else {
        await ref.read(teacherMobileRepositoryProvider).createTeacherAssignmentV2(
          title: title,
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          courseId: _selectedCourseId,
          subject: _selectedSubject,
          dueAt: dueAtStr,
          maxGrade: int.tryParse(_maxGradeCtrl.text.trim()),
          targetType: effectiveTargetType,
          targetCohortIds: _selectedCohortIds.toList(),
          targetStudentIds: _selectedStudentIds.toList(),
          attachments: _attachments,
          published: published,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(published ? 'Assignment published.' : 'Draft saved.')),
      );
      if (context.canPop()) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
        items: _cohorts
            .map((c) => _PickerItem(
                  id: c.id,
                  label: c.name,
                  subtitle: c.grade > 0 ? 'Grade ${c.grade}' : '',
                ))
            .toList(),
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
                  subtitle: s.gradeLevel != null ? 'Grade ${s.gradeLevel}' : '',
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
          _isEditing ? 'Edit Assignment' : 'New Assignment',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => _save(published: false),
            child: const Text('Save Draft'),
          ),
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : () => _save(published: true),
              icon: _saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send_rounded, size: 18),
              label: const Text('Publish'),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CmLoading())
          : ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                // ── Targeting card ──────────────────────────────────────────
                _SectionCard(
                  title: 'Audience',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Classrooms ─────────────────────────────────────────
                      _AudiencePicker(
                        icon: Icons.class_rounded,
                        label: 'Classrooms',
                        summary: _selectedCourseId == null
                            ? null
                            : _courses.where((c) => c.id == _selectedCourseId).map((c) => c.name).firstOrNull ?? _selectedCourseId!,
                        onTap: () async {
                          await showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            backgroundColor: cs.surfaceContainerLow,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
                            builder: (_) => _SinglePickerSheet(
                              title: 'Select classroom',
                              items: [
                                _PickerItem(id: '', label: 'None', subtitle: ''),
                                ..._courses.map((c) => _PickerItem(id: c.id, label: c.name, subtitle: c.subject)),
                              ],
                              selected: _selectedCourseId ?? '',
                              onSelect: (id) {
                                setState(() => _selectedCourseId = id.isEmpty ? null : id);
                                if (id.isNotEmpty) _fetchMembersFor(id, isClassroom: true);
                              },
                            ),
                          );
                        },
                        cs: cs,
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _AudiencePicker(
                        icon: Icons.groups_rounded,
                        label: 'Cohorts',
                        summary: _selectedCohortIds.isEmpty ? null : _cohorts.where((c) => _selectedCohortIds.contains(c.id)).map((c) => c.name).join(', '),
                        onTap: () async {
                          await _openCohortPicker();
                          for (final id in _selectedCohortIds) {
                            _fetchMembersFor(id);
                          }
                        },
                        cs: cs,
                        theme: theme,
                      ),
                      const SizedBox(height: 8),
                      _AudiencePicker(
                        icon: Icons.person_rounded,
                        label: 'Students',
                        summary: _selectedStudentIds.isEmpty ? null : '${_selectedStudentIds.length} student${_selectedStudentIds.length == 1 ? '' : 's'}',
                        onTap: _openStudentPicker,
                        cs: cs,
                        theme: theme,
                      ),
                      // ── Members preview ────────────────────────────────────
                      if (_previewMembers.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${_previewMembers.length} member${_previewMembers.length == 1 ? '' : 's'} will receive this',
                                  style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Wrap(spacing: 6, runSpacing: 4,
                                children: _previewMembers.map((name) => Chip(
                                  label: Text(name, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_selectedCourseId == null && _selectedCohortIds.isEmpty && _selectedStudentIds.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Visible to everyone', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Details card ────────────────────────────────────────────
                _SectionCard(
                  title: 'Details',
                  child: Column(
                    children: [
                      // Subject DDL
                      if (_subjects.isNotEmpty) ...[
                        LiquidGlassDropdown<String?>(
                          label: 'Subject *',
                          value: _selectedSubject,
                          items: [
                            const LiquidGlassDropdownItem(
                              value: null,
                              label: 'No subject',
                              icon: Icons.subject_rounded,
                            ),
                            ..._subjects.map((s) => LiquidGlassDropdownItem(
                                  value: s,
                                  label: s,
                                  icon: Icons.menu_book_rounded,
                                )),
                            const LiquidGlassDropdownItem(
                              value: 'Other',
                              label: 'Other',
                              icon: Icons.category_rounded,
                            ),
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
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextField(
                        controller: _descCtrl,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Instructions / Description',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Due date
                      InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _dueDate = picked);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Due date (optional)',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.calendar_today_rounded),
                            suffixIcon: _dueDate != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () => setState(() => _dueDate = null),
                                  )
                                : null,
                          ),
                          child: Text(
                            _dueDate != null
                                ? DateFormat.yMMMd(locale).format(_dueDate!)
                                : 'No due date',
                            style: TextStyle(
                              color: _dueDate != null ? cs.onSurface : cs.onSurfaceVariant,
                            ),
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
                      const SizedBox(height: 12),

                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Attachments card ────────────────────────────────────────
                _SectionCard(
                  title: 'Attachments  (${_attachments.length})',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._attachments.asMap().entries.map((entry) {
                        final i = entry.key;
                        final file = entry.value;
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
                                Expanded(
                                  child: Text(
                                    file['name'] as String? ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
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
                        icon: const Icon(Icons.attach_file_rounded, size: 18),
                        label: const Text('Attach files'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Shared section card ────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
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

// ── Person picker bottom sheet ────────────────────────────────────────────────

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
    widget.onToggle(id);
  }

  List<_PickerItem> get _filtered {
    if (_query.trim().isEmpty) return widget.items;
    final q = _query.trim().toLowerCase();
    return widget.items.where((i) => i.label.toLowerCase().contains(q) || i.subtitle.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) {
        return Container(
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
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: Row(children: [
                  Expanded(child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
                  if (_localSelected.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)),
                      child: Text('${_localSelected.length} selected', style: TextStyle(color: cs.onPrimaryContainer, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                ]),
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
                    final sel = _localSelected.contains(item.id);
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
                            ? Icon(Icons.check_circle_rounded, key: const ValueKey('c'), color: cs.primary)
                            : Icon(Icons.radio_button_unchecked, key: const ValueKey('u'), color: cs.outlineVariant),
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
        );
      },
    );
  }
}

// ── Shared audience picker row ───────────────────────────────────────────────

class _AudiencePicker extends StatelessWidget {
  const _AudiencePicker({
    required this.icon,
    required this.label,
    required this.summary,
    required this.onTap,
    required this.cs,
    required this.theme,
  });
  final IconData icon;
  final String label;
  final String? summary;
  final VoidCallback onTap;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final hasValue = summary != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: hasValue ? cs.primaryContainer.withValues(alpha: 0.3) : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasValue ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: hasValue ? cs.primary : cs.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Expanded(
            child: hasValue ? Text(
              summary!,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ) : const SizedBox.shrink(),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
        ]),
      ),
    );
  }
}

// ── Single-select picker sheet ────────────────────────────────────────────────

class _SinglePickerSheet extends StatefulWidget {
  const _SinglePickerSheet({required this.title, required this.items, required this.selected, required this.onSelect});
  final String title;
  final List<_PickerItem> items;
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  State<_SinglePickerSheet> createState() => _SinglePickerSheetState();
}

class _SinglePickerSheetState extends State<_SinglePickerSheet> {
  String _query = '';
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final q = _query.toLowerCase();
    final filtered = widget.items.where((i) => q.isEmpty || i.label.toLowerCase().contains(q) || i.subtitle.toLowerCase().contains(q)).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      minChildSize: 0.35,
      builder: (ctx, scrollCtrl) => Column(children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(widget.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search…',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final item = filtered[i];
              final isSelected = _selected == item.id;
              return RadioListTile<String>(
                value: item.id,
                groupValue: _selected,
                onChanged: (v) {
                  setState(() => _selected = v ?? '');
                  widget.onSelect(v ?? '');
                  Navigator.of(context).pop();
                },
                title: Text(item.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400)),
                subtitle: item.subtitle.isNotEmpty ? Text(item.subtitle, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)) : null,
                selected: isSelected,
                activeColor: cs.primary,
              );
            },
          ),
        ),
      ]),
    );
  }
}
