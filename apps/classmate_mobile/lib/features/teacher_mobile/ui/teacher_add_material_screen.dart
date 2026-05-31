// ignore_for_file: use_build_context_synchronously
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';

class TeacherAddMaterialScreen extends ConsumerStatefulWidget {
  const TeacherAddMaterialScreen({
    super.key,
    this.prefillCourseId,
    this.prefillSubject,
    this.prefillCohortIds,
    this.prefillStudentIds,
    this.initialMaterial,
  });

  final String? prefillCourseId;
  final String? prefillSubject;
  /// Pre-selected cohort ids — wires the audience to "By Cohort" with
  /// these checked when the screen mounts. Used by the period →
  /// attachments → create-new flow so the new material defaults to
  /// the period's audience.
  final List<String>? prefillCohortIds;
  /// Pre-selected individual student ids — same intent as prefillCohortIds.
  final List<String>? prefillStudentIds;
  final Map<String, dynamic>? initialMaterial;

  @override
  ConsumerState<TeacherAddMaterialScreen> createState() =>
      _TeacherAddMaterialScreenState();
}

class _TeacherAddMaterialScreenState
    extends ConsumerState<TeacherAddMaterialScreen> {
  List<TeacherCourse> _courses = [];
  List<({String id, String name, int grade})> _cohorts = [];
  List<TeacherStudentWithLevel> _allStudents = [];
  List<String> _schoolSubjects = [];
  bool _loading = true;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _selectedCourseId;
  String? _selectedSubject;

  // Multiple attachments — links and files can coexist freely
  final List<String> _links = [];           // user-entered URLs
  final List<PlatformFile> _files = [];     // picked local files
  final _linkCtrl = TextEditingController();
  bool _showLinkInput = false;

  String _targetType = 'EVERYONE';
  final Set<String> _selectedCohortIds = {};
  final Set<String> _selectedStudentIds = {};
  final Set<int> _selectedGrades = {};
  final Map<String, List<String>> _memberCache = {};

  List<int> get _availableGrades {
    final s = <int>{};
    for (final c in _cohorts) {
      if (c.grade > 0) s.add(c.grade);
    }
    final list = s.toList()..sort();
    return list;
  }

  bool _saving = false;

  bool get _isEditing => widget.initialMaterial != null;

  @override
  void initState() {
    super.initState();
    final mat = widget.initialMaterial;
    if (mat != null) {
      _titleCtrl.text = mat['title'] as String? ?? '';
      _descCtrl.text = mat['description'] as String? ?? '';
      final existingUrl = mat['url'] as String? ?? '';
      if (existingUrl.isNotEmpty) _links.add(existingUrl);
      // Load existing attachments if any
      final existing = mat['attachments'];
      if (existing is List) {
        for (final a in existing) {
          final u = (a is Map ? a['url'] : a?.toString()) ?? '';
          if (u.isNotEmpty && u != existingUrl) _links.add(u.toString());
        }
      }
      _selectedCourseId = mat['courseId'] as String?;
      _selectedSubject = mat['subject'] as String?;
      _targetType = mat['targetType'] as String? ?? 'EVERYONE';
      final cIds = mat['targetCohortIds'];
      if (cIds is List) _selectedCohortIds.addAll(cIds.map((e) => e.toString()));
      final sIds = mat['targetStudentIds'];
      if (sIds is List) _selectedStudentIds.addAll(sIds.map((e) => e.toString()));
      final gs = mat['targetGrades'];
      if (gs is List) {
        for (final g in gs) {
          final n = g is int ? g : int.tryParse('$g');
          if (n != null) _selectedGrades.add(n);
        }
      }
    }
    // Honor prefill from caller (period → attachments → create-new).
    // Only applied when we're NOT editing an existing material — edit
    // mode comes with its own targetType/audience.
    if (mat == null) {
      final preCohorts = widget.prefillCohortIds ?? const <String>[];
      final preStudents = widget.prefillStudentIds ?? const <String>[];
      if (preCohorts.isNotEmpty) {
        _targetType = 'COHORTS';
        _selectedCohortIds.addAll(preCohorts);
      }
      if (preStudents.isNotEmpty) {
        if (preCohorts.isEmpty) _targetType = 'STUDENTS';
        _selectedStudentIds.addAll(preStudents);
      }
    }
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _linkCtrl.dispose();
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

      if (_selectedSubject == null && widget.prefillSubject?.isNotEmpty == true) {
        _selectedSubject = widget.prefillSubject;
      }
      if (_selectedCourseId == null && widget.prefillCourseId?.isNotEmpty == true) {
        _selectedCourseId = widget.prefillCourseId;
      }

      final cohortMaps = results[3] as List<Map<String, dynamic>>;
      if (widget.prefillCourseId != null && results.length > 4 && _targetType == 'EVERYONE') {
        final peopleData = results[4] as Map<String, dynamic>;
        final items = peopleData['items'] as Map<String, dynamic>?;
        final studentIds = items?['studentUserIds'];
        if (studentIds is List && studentIds.isNotEmpty) {
          _targetType = 'STUDENTS';
          _selectedStudentIds.addAll(studentIds.map((e) => e.toString()));
        }
      }

      setState(() {
        _courses = courses;
        _allStudents = students;
        _schoolSubjects = subjects;
        _cohorts = cohortMaps.map((c) => (id: (c['id'] ?? '').toString(), name: (c['name'] ?? '').toString().replaceFirst(RegExp(r'^\d+\s*-\s*'), ''), grade: c['grade'] is int ? c['grade'] as int : int.tryParse('${c['grade'] ?? ''}') ?? 0)).where((c) => c.id.isNotEmpty).toList()..sort((a, b) => a.grade.compareTo(b.grade));
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
    void add(List<String> names) { for (final n in names) { if (seen.add(n)) result.add(n); } }
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

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
        'jpg', 'jpeg', 'png', 'webp', 'gif',
        'mp4', 'mov', 'mp3', 'wav',
        'zip', 'txt',
      ],
      allowMultiple: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _files.addAll(result.files));
    }
  }

  void _addLink() {
    final url = _linkCtrl.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        _links.add(url);
        _linkCtrl.clear();
        _showLinkInput = false;
      });
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherMeetingEnterTitle)));
      return;
    }
    if (_selectedSubject == null || _selectedSubject!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherMaterialPickSubject)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final effectiveTargetType = _selectedCohortIds.isNotEmpty ? 'COHORT' : _selectedStudentIds.isNotEmpty ? 'STUDENTS' : 'EVERYONE';

      // Upload all local files and collect their URLs
      final repo = ref.read(teacherMobileRepositoryProvider);
      final allAttachments = <Map<String, dynamic>>[];

      // Links first
      for (final link in _links) {
        allAttachments.add({'type': 'link', 'url': link, 'name': link});
      }

      // Upload files
      for (final file in _files) {
        if (file.path?.isNotEmpty == true) {
          try {
            final result = await repo.uploadAttachmentFile(file.path!, file.name);
            final uploadedUrl = (result['url'] ?? result['fileUrl'] ?? '').toString().trim();
            if (uploadedUrl.isNotEmpty) {
              allAttachments.add({'type': 'file', 'url': uploadedUrl, 'name': file.name});
            }
          } catch (_) {}
        }
      }

      final primaryUrl = allAttachments.isNotEmpty ? allAttachments.first['url'] as String : null;

      Map<String, dynamic>? createdMaterial;
      if (_isEditing) {
        await repo.updateTeacherMaterial(
          widget.initialMaterial!['id'] as String,
          <String, dynamic>{
            'title': title,
            'description': _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
            'url': primaryUrl,
            'attachments': allAttachments,
            'courseId': _selectedCourseId,
            'subject': _selectedSubject,
            'targetType': effectiveTargetType,
            'targetCohortIds': _selectedCohortIds.toList(),
            'targetStudentIds': _selectedStudentIds.toList(),
            'targetGrades': _selectedGrades.toList(),
          },
        );
      } else {
        createdMaterial = await repo.createTeacherMaterial(
          title: title,
          description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
          url: primaryUrl,
          courseId: _selectedCourseId,
          subject: _selectedSubject,
          targetType: effectiveTargetType,
          targetCohortIds: _selectedCohortIds.toList(),
          targetStudentIds: _selectedStudentIds.toList(),
          targetGrades: _selectedGrades.toList(),
          attachments: allAttachments,
        );
      }
      if (!mounted) return;
      // Return the created material's id when creating so callers (e.g.
      // the slot-attachments picker) can auto-attach. Editing keeps the
      // legacy `true` so existing list refreshers keep working.
      if (context.canPop()) {
        context.pop(_isEditing ? true : (createdMaterial?['id'] ?? true));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openCohortPicker() async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _CohortMultiPickerSheet(
        title: AppLocalizations.of(context)!.teacherMaterialPickerCohortsTitle,
        items: _cohorts.map((c) => _PickerItem2(id: c.id, label: c.name, subtitle: c.grade > 0 ? AppLocalizations.of(context)!.adminCohortGradeFormat(c.grade.toString()) : '')).toList(),
        selected: Set.from(_selectedCohortIds),
        onToggle: (id) => setState(() => _selectedCohortIds.contains(id) ? _selectedCohortIds.remove(id) : _selectedCohortIds.add(id)),
      ),
    );
  }

  Future<void> _openClassroomPicker(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _MatSinglePickerSheet(
        title: AppLocalizations.of(context)!.teacherMaterialPickerClassroomTitle,
        items: [
          _PickerItem2(id: '', label: AppLocalizations.of(context)!.teacherMaterialPickerNone, subtitle: ''),
          ..._courses.map((c) => _PickerItem2(id: c.id, label: c.name, subtitle: c.subject)),
        ],
        selected: _selectedCourseId ?? '',
        onSelect: (id) => setState(() => _selectedCourseId = id.isEmpty ? null : id),
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
        title: AppLocalizations.of(context)!.teacherMaterialPickerStudentsTitle,
        items: _allStudents
            .map((s) => _PickerItem(
                  id: s.studentId,
                  label: s.name,
                  subtitle: s.gradeLevel != null ? AppLocalizations.of(context)!.adminCohortGradeFormat(s.gradeLevel.toString()) : s.cohortName,
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

  Future<void> _openGradePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PersonPickerSheet(
        title: AppLocalizations.of(context)!.teacherMaterialPickerGradesTitle,
        items: _availableGrades
            .map((g) => _PickerItem(id: g.toString(), label: AppLocalizations.of(context)!.adminCohortGradeFormat(g.toString())))
            .toList(),
        selected: _selectedGrades.map((g) => g.toString()).toSet(),
        onToggle: (id) => setState(() {
          final g = int.tryParse(id);
          if (g == null) return;
          if (_selectedGrades.contains(g)) {
            _selectedGrades.remove(g);
          } else {
            _selectedGrades.add(g);
          }
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

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
          _isEditing ? l.teacherMaterialEditTitle : l.teacherMaterialAddTitle,
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
              label: Text(AppLocalizations.of(context)!.commonSave),
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
                // ── Audience first ──────────────────────────────────────────
                _SectionCard(
                  title: l.teacherMaterialAudienceTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MatAudiencePicker(icon: Icons.class_rounded, label: l.teacherMaterialAudienceClassrooms, summary: _selectedCourseId == null ? null : _courses.where((c) => c.id == _selectedCourseId).map((c) => c.name).firstOrNull ?? _selectedCourseId!, onTap: () async { await _openClassroomPicker(context); if (_selectedCourseId != null) _fetchMembersFor(_selectedCourseId!, isClassroom: true); }, cs: cs, theme: theme),
                      const SizedBox(height: 8),
                      _MatAudiencePicker(icon: Icons.groups_rounded, label: l.teacherMaterialAudienceCohorts, summary: _selectedCohortIds.isEmpty ? null : _cohorts.where((c) => _selectedCohortIds.contains(c.id)).map((c) => c.name).join(', '), onTap: () async { await _openCohortPicker(); for (final id in _selectedCohortIds) {
                        _fetchMembersFor(id);
                      } }, cs: cs, theme: theme),
                      const SizedBox(height: 8),
                      if (_availableGrades.isNotEmpty) ...[
                        _MatAudiencePicker(
                          icon: Icons.school_rounded,
                          label: l.teacherMaterialAudienceGrades,
                          summary: _selectedGrades.isEmpty
                              ? null
                              : (_selectedGrades.toList()..sort())
                                  .map((g) => l.adminCohortGradeFormat(g.toString()))
                                  .join(', '),
                          onTap: _openGradePicker,
                          cs: cs,
                          theme: theme,
                        ),
                        const SizedBox(height: 8),
                      ],
                      _MatAudiencePicker(icon: Icons.person_rounded, label: l.teacherMaterialAudienceStudents, summary: _selectedStudentIds.isEmpty ? null : l.teacherMaterialStudentCount(_selectedStudentIds.length), onTap: _openStudentPicker, cs: cs, theme: theme),
                      if (_previewMembers.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _MembersPreview(members: _previewMembers, cs: cs, theme: theme),
                      ],
                      if (_selectedCourseId == null &&
                          _selectedCohortIds.isEmpty &&
                          _selectedStudentIds.isEmpty &&
                          _selectedGrades.isEmpty) ...[
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context)!.teacherMeetingVisibleToEveryone, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Title + Description ──────────────────────────────────────
                _SectionCard(
                  title: l.teacherMaterialDetailsTitle,
                  child: Column(
                    children: [
                      if (_subjects.isNotEmpty) ...[
                        LiquidGlassDropdown<String?>(
                          label: l.teacherMaterialSubjectRequired,
                          value: _selectedSubject,
                          items: [
                            LiquidGlassDropdownItem(value: null, label: l.teacherMaterialSubjectSelect, icon: Icons.subject_rounded),
                            ..._subjects.map((s) => LiquidGlassDropdownItem(value: s, label: s, icon: Icons.menu_book_rounded)),
                            LiquidGlassDropdownItem(value: 'Other', label: l.teacherMaterialSubjectOther, icon: Icons.category_rounded),
                          ],
                          onChanged: (v) => setState(() => _selectedSubject = v),
                          searchHint: l.teacherMaterialSubjectSearch,
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextField(
                        controller: _titleCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(labelText: AppLocalizations.of(context)!.teacherMeetingTitleField, border: const OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descCtrl,
                        maxLines: 3,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.teacherMaterialDescriptionLabel,
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Attachments (multiple links + files) ───────────────────
                _SectionCard(
                  title: (_links.isNotEmpty || _files.isNotEmpty)
                      ? l.teacherMaterialAttachmentsWithCount(_links.length + _files.length)
                      : l.teacherMaterialAttachmentsTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Existing links ────────────────────────────────────
                      ..._links.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Row(children: [
                            Icon(Icons.link_rounded, size: 16, color: cs.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.value, overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600))),
                            IconButton(
                              icon: Icon(Icons.close_rounded, size: 14, color: cs.error),
                              onPressed: () => setState(() => _links.removeAt(e.key)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            ),
                          ]),
                        ),
                      )),
                      // ── Existing files ────────────────────────────────────
                      ..._files.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
                          ),
                          child: Row(children: [
                            Icon(Icons.insert_drive_file_rounded, size: 16, color: cs.primary),
                            const SizedBox(width: 8),
                            Expanded(child: Text(e.value.name, overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600))),
                            IconButton(
                              icon: Icon(Icons.close_rounded, size: 14, color: cs.error),
                              onPressed: () => setState(() => _files.removeAt(e.key)),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                            ),
                          ]),
                        ),
                      )),
                      // ── Inline link input ─────────────────────────────────
                      if (_showLinkInput) ...[
                        if (_links.isNotEmpty || _files.isNotEmpty) const SizedBox(height: 4),
                        Row(children: [
                          Expanded(
                            child: TextField(
                              controller: _linkCtrl,
                              autofocus: true,
                              keyboardType: TextInputType.url,
                              onSubmitted: (_) => _addLink(),
                              decoration: InputDecoration(
                                hintText: 'https://…',
                                prefixIcon: const Icon(Icons.link_rounded, size: 18),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                isDense: true,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          FilledButton(
                            onPressed: _addLink,
                            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), minimumSize: Size.zero),
                            child: Text(AppLocalizations.of(context)!.commonAdd),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () { _linkCtrl.clear(); setState(() => _showLinkInput = false); },
                            icon: Icon(Icons.close_rounded, size: 16, color: cs.onSurfaceVariant),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          ),
                        ]),
                        const SizedBox(height: 8),
                      ],
                      // ── Action buttons ────────────────────────────────────
                      if (!_showLinkInput)
                        if (_links.isNotEmpty || _files.isNotEmpty) const SizedBox(height: 4),
                      Row(children: [
                        if (!_showLinkInput)
                          OutlinedButton.icon(
                            onPressed: () => setState(() => _showLinkInput = true),
                            icon: const Icon(Icons.link_rounded, size: 15),
                            label: Text(AppLocalizations.of(context)!.teacherMaterialAddLink),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                            ),
                          ),
                        if (!_showLinkInput) const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.attach_file_rounded, size: 15),
                          label: Text(AppLocalizations.of(context)!.teacherMaterialAddFile),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

              ],
            ),
    );
  }
}

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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

class _PickerItem {
  const _PickerItem({required this.id, required this.label, this.subtitle = ''});
  final String id;
  final String label;
  final String subtitle;
}

class _PersonPickerSheet extends StatefulWidget {
  const _PersonPickerSheet({required this.title, required this.items, required this.selected, required this.onToggle});
  final String title;
  final List<_PickerItem> items;
  final Set<String> selected;
  final void Function(String) onToggle;

  @override
  State<_PersonPickerSheet> createState() => _PersonPickerSheetState();
}

class _PersonPickerSheetState extends State<_PersonPickerSheet> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  late final Set<String> _localSelected;

  @override
  void initState() {
    super.initState();
    _localSelected = Set.from(widget.selected);
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  List<_PickerItem> get _filtered {
    if (_query.trim().isEmpty) return widget.items;
    final q = _query.toLowerCase();
    return widget.items.where((i) => i.label.toLowerCase().contains(q) || i.subtitle.toLowerCase().contains(q)).toList();
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
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scroll) => Container(
        decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          children: [
            Container(margin: const EdgeInsets.symmetric(vertical: 10), width: 36, height: 4,
              decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
            Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.teacherMaterialSearchStudentsGrade,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              )),
            Expanded(child: ListView.builder(
              controller: scroll,
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final item = _filtered[i];
                final sel = _localSelected.contains(item.id);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: sel ? cs.primaryContainer : cs.surfaceContainerHigh,
                    child: Text(item.label.isNotEmpty ? item.label[0].toUpperCase() : '?',
                      style: TextStyle(fontWeight: FontWeight.w700, color: sel ? cs.onPrimaryContainer : cs.onSurface)),
                  ),
                  title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: item.subtitle.isNotEmpty ? Text(item.subtitle) : null,
                  trailing: sel ? Icon(Icons.check_circle_rounded, color: cs.primary) : Icon(Icons.radio_button_unchecked, color: cs.outlineVariant),
                  onTap: () => _toggle(item.id),
                );
              },
            )),
            Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.teacherMaterialDoneSelected(_localSelected.length)),
                ))),
          ],
        ),
      ),
    );
  }
}

// ── Teacher standalone materials screen (list) ─────────────────────────────────

class TeacherMaterialsStandaloneScreen extends ConsumerStatefulWidget {
  const TeacherMaterialsStandaloneScreen({super.key});

  @override
  ConsumerState<TeacherMaterialsStandaloneScreen> createState() =>
      _TeacherMaterialsStandaloneScreenState();
}

class _TeacherMaterialsStandaloneScreenState
    extends ConsumerState<TeacherMaterialsStandaloneScreen> {
  List<Map<String, dynamic>> _materials = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await ref.read(teacherMobileRepositoryProvider).listTeacherMaterials();
      if (!mounted) return;
      setState(() { _materials = items; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.teacherMaterialDeleteTitle),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(AppLocalizations.of(ctx)!.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true), child: Text(AppLocalizations.of(ctx)!.commonDelete)),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(teacherMobileRepositoryProvider).deleteTeacherMaterial(id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.outlineVariant),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.teacherMaterialListTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                const SizedBox(height: 4),
                Text(l.teacherMaterialTotalCount(_materials.length), style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ])),
              Container(width: 46, height: 46,
                decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.folder_rounded, size: 24, color: cs.onPrimary)),
            ]),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            LiquidGlassCard(color: cs.errorContainer,
              child: Row(children: [
                Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
                const SizedBox(width: 10),
                Expanded(child: Text(_error!, style: TextStyle(color: cs.onErrorContainer))),
                TextButton(onPressed: _load, child: Text(l.teacherMaterialRetry)),
              ])),
          if (_loading && _materials.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
          else if (_materials.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(40),
              child: Column(children: [
                Icon(Icons.folder_open_rounded, size: 48, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(l.teacherMaterialNoMaterials, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
              ])))
          else
            ..._materials.map((m) {
              final id = m['id'] as String? ?? '';
              final title = m['title'] as String? ?? '';
              final subject = m['subject'] as String? ?? '';
              final courseName = m['courseName'] as String? ?? '';
              final published = m['published'] as bool? ?? true;
              // Extract attachments + primary url so each material renders
              // its files/links inline as pills (so teachers can tap a
              // PDF straight from the list).
              final atts = <Map<String, dynamic>>[];
              final primaryUrl = (m['url'] ?? '').toString().trim();
              if (primaryUrl.isNotEmpty) {
                atts.add({'title': title.isEmpty ? 'Link' : title, 'url': primaryUrl});
              }
              final rawA = m['attachments'];
              if (rawA is List) {
                for (final a in rawA) {
                  if (a is Map) atts.add(Map<String, dynamic>.from(a));
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LiquidGlassCard(
                  border: Border.all(color: cs.outlineVariant),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(width: 44, height: 44,
                          decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.folder_rounded, size: 22, color: cs.onPrimary)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                          if (subject.isNotEmpty || courseName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text([subject, courseName].where((s) => s.isNotEmpty).join(' · '),
                              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: (published ? cs.primary : cs.surfaceContainerHighest),
                              borderRadius: BorderRadius.circular(6)),
                            child: Text(published ? l.teacherMaterialPublished : l.teacherMaterialDraft,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                color: published ? cs.onPrimary : cs.onSurfaceVariant))),
                        ])),
                        // Action buttons replace the chevron — edit and
                        // delete sit at the top-right so each is a
                        // single tap (no swipe required).
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18),
                          tooltip: 'Edit',
                          onPressed: () => context.push('/teacher/materials/add', extra: {...m, '_edit': true}).then((_) => _load()),
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, size: 18, color: cs.error),
                          tooltip: 'Delete',
                          onPressed: () => _delete(id),
                          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                        ),
                      ]),
                      if (atts.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: atts.map((a) {
                            final aTitle = (a['title'] ?? a['name'] ?? 'File').toString();
                            final url = (a['url'] ?? a['fileUrl'] ?? '').toString().trim();
                            final lower = url.toLowerCase();
                            IconData icon = Icons.attach_file_rounded;
                            if (lower.endsWith('.pdf')) {
                              icon = Icons.picture_as_pdf_rounded;
                            } else if (lower.endsWith('.png') || lower.endsWith('.jpg') ||
                                lower.endsWith('.jpeg') || lower.endsWith('.webp')) {
                              icon = Icons.image_rounded;
                            } else if (url.startsWith('http')) {
                              icon = Icons.link_rounded;
                            }
                            return InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: url.isEmpty
                                  ? null
                                  : () async {
                                      final uri = Uri.tryParse(url);
                                      if (uri != null && await canLaunchUrl(uri)) {
                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                      }
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: cs.secondaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: cs.outlineVariant),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(icon, size: 13, color: cs.onSecondaryContainer),
                                  const SizedBox(width: 5),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 160),
                                    child: Text(
                                      aTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: cs.onSecondaryContainer,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _PickerItem2 { const _PickerItem2({required this.id, required this.label, this.subtitle = ''}); final String id; final String label; final String subtitle; }

class _MatAudiencePicker extends StatelessWidget {
  const _MatAudiencePicker({required this.icon, required this.label, required this.summary, required this.onTap, required this.cs, required this.theme});
  final IconData icon; final String label; final String? summary; final VoidCallback onTap; final ColorScheme cs; final ThemeData theme;
  @override Widget build(BuildContext context) {
    final hasValue = summary != null;
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: hasValue ? cs.primaryContainer.withValues(alpha: 0.3) : cs.surfaceContainerLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: hasValue ? cs.primary.withValues(alpha: 0.4) : cs.outlineVariant)),
      child: Row(children: [
        Icon(icon, size: 18, color: hasValue ? cs.primary : cs.onSurfaceVariant), const SizedBox(width: 10),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)), const SizedBox(width: 8),
        if (hasValue) Expanded(child: Text(summary!, textAlign: TextAlign.end, style: theme.textTheme.bodyMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)) else const Spacer(),
        const SizedBox(width: 4), Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
      ]),
    ));
  }
}

class _MatSinglePickerSheet extends StatefulWidget {
  const _MatSinglePickerSheet({required this.title, required this.items, required this.selected, required this.onSelect});
  final String title; final List<_PickerItem2> items; final String selected; final ValueChanged<String> onSelect;
  @override State<_MatSinglePickerSheet> createState() => _MatSinglePickerSheetState();
}
class _MatSinglePickerSheetState extends State<_MatSinglePickerSheet> {
  String _query = ''; late String _selected;
  @override void initState() { super.initState(); _selected = widget.selected; }
  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; final theme = Theme.of(context);
    final q = _query.toLowerCase();
    final filtered = widget.items.where((i) => q.isEmpty || i.label.toLowerCase().contains(q)).toList();
    return DraggableScrollableSheet(expand: false, initialChildSize: 0.55, maxChildSize: 0.9, minChildSize: 0.35, builder: (ctx, sc) => Column(children: [
      Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
      Padding(padding: const EdgeInsets.fromLTRB(20,0,20,12), child: Text(widget.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
      Padding(padding: const EdgeInsets.fromLTRB(16,0,16,8), child: TextField(onChanged: (v) => setState(() => _query = v), decoration: InputDecoration(hintText: AppLocalizations.of(context)!.teacherMaterialSearchHint, prefixIcon: const Icon(Icons.search_rounded, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14)))),
      Expanded(child: ListView.builder(controller: sc, padding: const EdgeInsets.fromLTRB(12,4,12,16), itemCount: filtered.length, itemBuilder: (ctx, i) {
        final item = filtered[i]; final isSel = _selected == item.id;
        return RadioListTile<String>(value: item.id, groupValue: _selected, onChanged: (v) { setState(() => _selected = v ?? ''); widget.onSelect(v ?? ''); Navigator.of(context).pop(); }, title: Text(item.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: isSel ? FontWeight.w700 : FontWeight.w400)), subtitle: item.subtitle.isNotEmpty ? Text(item.subtitle, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)) : null, selected: isSel, activeColor: cs.primary);
      })),
    ]));
  }
}

class _CohortMultiPickerSheet extends StatefulWidget {
  const _CohortMultiPickerSheet({required this.title, required this.items, required this.selected, required this.onToggle});
  final String title; final List<_PickerItem2> items; final Set<String> selected; final ValueChanged<String> onToggle;
  @override State<_CohortMultiPickerSheet> createState() => _CohortMultiPickerSheetState();
}
class _CohortMultiPickerSheetState extends State<_CohortMultiPickerSheet> {
  late Set<String> _selected;
  @override void initState() { super.initState(); _selected = Set.from(widget.selected); }
  void _toggle(String id) { setState(() => _selected.contains(id) ? _selected.remove(id) : _selected.add(id)); widget.onToggle(id); }
  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; final theme = Theme.of(context);
    return DraggableScrollableSheet(expand: false, initialChildSize: 0.55, maxChildSize: 0.9, minChildSize: 0.35, builder: (ctx, sc) => Column(children: [
      Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
      Padding(padding: const EdgeInsets.fromLTRB(20,0,20,12), child: Row(children: [
        Text(widget.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const Spacer(),
        if (_selected.isNotEmpty) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)), child: Text(AppLocalizations.of(context)!.teacherMaterialSelectedCount(_selected.length), style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 12))),
      ])),
      Expanded(child: ListView.builder(controller: sc, padding: const EdgeInsets.fromLTRB(12,4,12,16), itemCount: widget.items.length, itemBuilder: (ctx, i) {
        final item = widget.items[i]; final isSel = _selected.contains(item.id);
        return CheckboxListTile(value: isSel, onChanged: (_) => _toggle(item.id), title: Text(item.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: isSel ? FontWeight.w700 : FontWeight.w400)), subtitle: item.subtitle.isNotEmpty ? Text(item.subtitle, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)) : null, activeColor: cs.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
      })),
    ]));
  }
}

class _MembersPreview extends StatelessWidget {
  const _MembersPreview({required this.members, required this.cs, required this.theme});
  final List<String> members; final ColorScheme cs; final ThemeData theme;
  @override Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: cs.surfaceContainerLowest, borderRadius: BorderRadius.circular(12), border: Border.all(color: cs.outlineVariant)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(AppLocalizations.of(context)!.teacherMaterialMembersWillReceive(members.length), style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 4, children: members.map((name) => Chip(label: Text(name, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, padding: const EdgeInsets.symmetric(horizontal: 4), visualDensity: VisualDensity.compact)).toList()),
      ]),
    );
  }
}
