// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';

// ── List screen ────────────────────────────────────────────────────────────────

class TeacherMeetingsScreen extends ConsumerStatefulWidget {
  const TeacherMeetingsScreen({super.key});

  @override
  ConsumerState<TeacherMeetingsScreen> createState() => _TeacherMeetingsScreenState();
}

class _TeacherMeetingsScreenState extends ConsumerState<TeacherMeetingsScreen> {
  List<Map<String, dynamic>> _meetings = [];
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
      final items = await ref.read(teacherMobileRepositoryProvider).listTeacherMeetings();
      if (!mounted) return;
      setState(() { _meetings = items; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final lCtx = AppLocalizations.of(ctx)!;
        return AlertDialog(
          title: Text(lCtx.teacherCancelMeetingTitle),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(lCtx.actionCancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () => Navigator.of(ctx).pop(true), child: Text(lCtx.teacherCancelMeetingAction)),
          ],
        );
      },
    );
    if (confirmed != true) return;
    if (!mounted) return;
    await ref.read(teacherMobileRepositoryProvider).deleteTeacherMeeting(id);
    if (!mounted) return;
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();

    final upcoming = _meetings.where((m) {
      final d = DateTime.tryParse(m['startsAt'] as String? ?? '');
      return d != null && !d.isBefore(now);
    }).toList();
    final past = _meetings.where((m) {
      final d = DateTime.tryParse(m['startsAt'] as String? ?? '');
      return d != null && d.isBefore(now);
    }).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          LiquidGlassCard(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.outlineVariant),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.navMeetings, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                const SizedBox(height: 4),
                Text('${upcoming.length} ${l.teacherExamsUpcoming}  ·  ${past.length} ${l.teacherExamsPast}',
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ])),
              Container(width: 46, height: 46,
                decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
                child: Icon(Icons.video_call_rounded, size: 24, color: cs.onPrimaryContainer)),
            ]),
          ),
          const SizedBox(height: 16),

          if (_error != null)
            Padding(padding: const EdgeInsets.only(bottom: 12),
              child: LiquidGlassCard(color: cs.errorContainer,
                child: Row(children: [
                  Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_error!, style: TextStyle(color: cs.onErrorContainer))),
                  TextButton(onPressed: _load, child: Text(l.teacherRetry)),
                ]))),

          if (_loading && _meetings.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
          else if (_meetings.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(40),
              child: Column(children: [
                Icon(Icons.video_call_outlined, size: 48, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(l.teacherMeetingsEmpty, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
              ])))
          else ...[
            if (upcoming.isNotEmpty) ...[
              _SectionHeader(label: l.teacherExamsUpcoming, icon: Icons.upcoming_rounded, color: cs.primary),
              const SizedBox(height: 8),
              ...upcoming.map((m) => _MeetingCard(meeting: m, locale: locale, onDelete: () => _delete(m['id'] as String? ?? ''),
                onEdit: () => context.push('/teacher/meetings/add', extra: m).then((_) => _load()))),
              const SizedBox(height: 8),
            ],
            if (past.isNotEmpty) ...[
              _SectionHeader(label: l.teacherExamsPast, icon: Icons.history_rounded, color: cs.secondary),
              const SizedBox(height: 8),
              ...past.map((m) => _MeetingCard(meeting: m, locale: locale, onDelete: () => _delete(m['id'] as String? ?? ''),
                onEdit: () => context.push('/teacher/meetings/add', extra: m).then((_) => _load()))),
            ],
          ],
        ],
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({required this.meeting, required this.locale, required this.onDelete, required this.onEdit});
  final Map<String, dynamic> meeting;
  final String locale;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final title = meeting['title'] as String? ?? '';
    final link = meeting['link'] as String? ?? '';
    final subject = meeting['subject'] as String? ?? '';
    final courseName = meeting['courseName'] as String? ?? '';
    final startsAtRaw = meeting['startsAt'] as String? ?? '';
    final now = DateTime.now();
    DateTime? startsAt = startsAtRaw.isNotEmpty ? DateTime.tryParse(startsAtRaw) : null;
    final isUpcoming = startsAt != null && !startsAt.isBefore(now);
    final accentColor = isUpcoming ? cs.primary : cs.secondary;

    final timeLabel = startsAt != null
        ? '${DateFormat.yMMMd(locale).format(startsAt)} · ${DateFormat.Hm(locale).format(startsAt)}'
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LiquidGlassCard(
        border: Border.all(color: cs.outlineVariant),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Icon(isUpcoming ? Icons.upcoming_rounded : Icons.history_rounded, size: 22, color: cs.onPrimaryContainer)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
            if (subject.isNotEmpty || courseName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text([subject, courseName].where((s) => s.isNotEmpty).join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
            if (timeLabel.isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoChip(label: timeLabel, color: accentColor),
            ],
            if (link.isNotEmpty) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final uri = Uri.tryParse(link);
                  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: cs.outlineVariant)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.video_call_rounded, size: 14, color: cs.onPrimaryContainer),
                    const SizedBox(width: 6),
                    Text(AppLocalizations.of(context)!.teacherJoinMeeting, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onPrimaryContainer)),
                  ]),
                ),
              ),
            ],
          ])),
          Column(mainAxisSize: MainAxisSize.min, children: [
            IconButton(icon: const Icon(Icons.edit_rounded, size: 16), onPressed: onEdit,
              padding: const EdgeInsets.all(4), constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
            IconButton(icon: Icon(Icons.delete_outline_rounded, size: 16, color: cs.error), onPressed: onDelete,
              padding: const EdgeInsets.all(4), constraints: const BoxConstraints(minWidth: 28, minHeight: 28)),
          ]),
        ]),
      ),
    );
  }
}

// ── Add/Edit meeting screen ────────────────────────────────────────────────────

class TeacherAddMeetingScreen extends ConsumerStatefulWidget {
  const TeacherAddMeetingScreen({super.key, this.prefillCourseId, this.prefillSubject, this.initialMeeting});
  final String? prefillCourseId;
  final String? prefillSubject;
  final Map<String, dynamic>? initialMeeting;

  @override
  ConsumerState<TeacherAddMeetingScreen> createState() => _TeacherAddMeetingScreenState();
}

class _TeacherAddMeetingScreenState extends ConsumerState<TeacherAddMeetingScreen> {
  List<TeacherCourse> _courses = [];
  List<({String id, String name, int grade})> _cohorts = [];
  List<String> _schoolSubjects = [];
  List<TeacherStudentWithLevel> _allStudents = [];
  bool _loading = true;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  String? _selectedCourseId;
  String? _selectedSubject;
  DateTime? _startsAt;
  DateTime? _endsAt;

  String _targetType = 'EVERYONE';
  final Set<String> _selectedCohortIds = {};
  final Set<String> _selectedStudentIds = {};
  final Set<int> _selectedGrades = {};
  final Map<String, List<String>> _memberCache = {};
  bool _saving = false;

  List<int> get _availableGrades {
    final s = <int>{};
    for (final c in _cohorts) {
      if (c.grade > 0) s.add(c.grade);
    }
    final list = s.toList()..sort();
    return list;
  }

  bool get _isEditing => widget.initialMeeting != null;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMeeting;
    if (m != null) {
      _titleCtrl.text = m['title'] as String? ?? '';
      _descCtrl.text = m['description'] as String? ?? '';
      _linkCtrl.text = m['link'] as String? ?? '';
      _selectedCourseId = m['courseId'] as String?;
      _selectedSubject = m['subject'] as String?;
      _targetType = m['targetType'] as String? ?? 'EVERYONE';
      final raw = m['startsAt'] as String? ?? '';
      if (raw.isNotEmpty) _startsAt = DateTime.tryParse(raw);
      final rawEnd = m['endsAt'] as String? ?? '';
      if (rawEnd.isNotEmpty) _endsAt = DateTime.tryParse(rawEnd);
      final cIds = m['targetCohortIds'];
      if (cIds is List) _selectedCohortIds.addAll(cIds.map((e) => e.toString()));
      final sIds = m['targetStudentIds'];
      if (sIds is List) _selectedStudentIds.addAll(sIds.map((e) => e.toString()));
      final gs = m['targetGrades'];
      if (gs is List) {
        for (final g in gs) {
          final n = g is int ? g : int.tryParse('$g');
          if (n != null) _selectedGrades.add(n);
        }
      }
    }
    Future<void>.microtask(_load);
  }

  @override
  void dispose() { _titleCtrl.dispose(); _descCtrl.dispose(); _linkCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final futures = <Future>[
        repo.fetchClassrooms(),
        repo.fetchAllStudents(),
        repo.fetchCohortsForPicker(),
        repo.fetchSubjects(),
        if (widget.prefillCourseId != null) repo.fetchClassroomPeople(widget.prefillCourseId!),
      ];
      final results = await Future.wait(futures);
      if (!mounted) return;

      final courses = results[0] as List<TeacherCourse>;
      final students = results[1] as List<TeacherStudentWithLevel>;
      final cohortMaps = results[2] as List<Map<String, dynamic>>;
      final subjects = results[3] as List<String>;

      if (_selectedSubject == null && widget.prefillSubject?.isNotEmpty == true) _selectedSubject = widget.prefillSubject;
      if (_selectedCourseId == null && widget.prefillCourseId?.isNotEmpty == true) _selectedCourseId = widget.prefillCourseId;

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

  Future<void> _openCohortPickerMtg() async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, useSafeArea: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _MtgCohortSheet(
        title: 'Select cohorts',
        items: _cohorts.map((c) => _MtgItem(id: c.id, label: c.name, subtitle: c.grade > 0 ? 'Grade ${c.grade}' : '')).toList(),
        selected: Set.from(_selectedCohortIds),
        onToggle: (id) => setState(() => _selectedCohortIds.contains(id) ? _selectedCohortIds.remove(id) : _selectedCohortIds.add(id)),
      ),
    );
  }

  Future<void> _openClassroomPickerMtg(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    await showModalBottomSheet<void>(
      context: context, isScrollControlled: true, useSafeArea: true,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => _MtgSingleSheet(
        title: 'Select classroom',
        items: [_MtgItem(id: '', label: 'None', subtitle: ''), ..._courses.map((c) => _MtgItem(id: c.id, label: c.name, subtitle: c.subject))],
        selected: _selectedCourseId ?? '',
        onSelect: (id) => setState(() => _selectedCourseId = id.isEmpty ? null : id),
      ),
    );
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final initial = isStart ? (_startsAt ?? DateTime.now()) : (_endsAt ?? (_startsAt?.add(const Duration(hours: 1)) ?? DateTime.now()));
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (time == null || !mounted) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() { if (isStart) { _startsAt = dt; } else { _endsAt = dt; } });
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();
    final link = _linkCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherMeetingEnterTitle)));
      return;
    }
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherMeetingEnterLink)));
      return;
    }
    final linkUri = Uri.tryParse(link);
    if (linkUri == null || !linkUri.isAbsolute || (!link.startsWith('http://') && !link.startsWith('https://'))) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherMeetingEnterValidUrl)));
      return;
    }
    if (_startsAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.teacherMeetingPickStartTime)));
      return;
    }
    setState(() => _saving = true);
    final effectiveTargetType = _selectedCohortIds.isNotEmpty ? 'COHORT' : _selectedStudentIds.isNotEmpty ? 'STUDENTS' : 'EVERYONE';
    try {
      if (_isEditing) {
        await ref.read(teacherMobileRepositoryProvider).updateTeacherMeeting(
          widget.initialMeeting!['id'] as String,
          <String, dynamic>{
            'title': title, 'description': _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
            'link': link, 'startsAt': _startsAt!.toIso8601String(),
            'endsAt': _endsAt?.toIso8601String(), 'courseId': _selectedCourseId, 'subject': _selectedSubject,
            'targetType': effectiveTargetType, 'targetCohortIds': _selectedCohortIds.toList(), 'targetStudentIds': _selectedStudentIds.toList(),
            'targetGrades': _selectedGrades.toList(),
          },
        );
      } else {
        await ref.read(teacherMobileRepositoryProvider).createTeacherMeeting(
          title: title,
          description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
          link: link,
          startsAt: _startsAt!.toIso8601String(),
          endsAt: _endsAt?.toIso8601String(),
          courseId: _selectedCourseId,
          subject: _selectedSubject,
          targetType: effectiveTargetType,
          targetCohortIds: _selectedCohortIds.toList(),
          targetStudentIds: _selectedStudentIds.toList(),
          targetGrades: _selectedGrades.toList(),
        );
      }
      if (!mounted) return;
      if (context.canPop()) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openStudentPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PersonPickerSheet(
        title: 'Select students',
        items: _allStudents.map((s) => _PickerItem(
          id: s.studentId, label: s.name,
          subtitle: s.gradeLevel != null ? 'Grade ${s.gradeLevel}' : s.cohortName)).toList(),
        selected: Set.from(_selectedStudentIds),
        onToggle: (id) => setState(() {
          if (_selectedStudentIds.contains(id)) { _selectedStudentIds.remove(id); }
          else { _selectedStudentIds.add(id); }
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
        title: 'Select grades',
        items: _availableGrades
            .map((g) => _PickerItem(id: g.toString(), label: 'Grade $g'))
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
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.pop()),
        title: Text(_isEditing ? 'Edit Meeting' : 'Schedule Meeting',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.actionSave))),
        ],
      ),
      body: _loading ? const Center(child: CmLoading())
          : ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              children: [
                // ── Audience first ──────────────────────────────────────────
                _SectionCard(title: 'Audience', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _MtgAudiencePicker(icon: Icons.class_rounded, label: 'Classrooms', summary: _selectedCourseId == null ? null : _courses.where((c) => c.id == _selectedCourseId).map((c) => c.name).firstOrNull ?? _selectedCourseId!, onTap: () async { await _openClassroomPickerMtg(context); if (_selectedCourseId != null) _fetchMembersFor(_selectedCourseId!, isClassroom: true); }, cs: cs, theme: theme),
                  const SizedBox(height: 8),
                  _MtgAudiencePicker(icon: Icons.groups_rounded, label: 'Cohorts', summary: _selectedCohortIds.isEmpty ? null : _cohorts.where((c) => _selectedCohortIds.contains(c.id)).map((c) => c.name).join(', '), onTap: () async { await _openCohortPickerMtg(); for (final id in _selectedCohortIds) {
                    _fetchMembersFor(id);
                  } }, cs: cs, theme: theme),
                  const SizedBox(height: 8),
                  if (_availableGrades.isNotEmpty) ...[
                    _MtgAudiencePicker(
                      icon: Icons.school_rounded,
                      label: 'Grades',
                      summary: _selectedGrades.isEmpty
                          ? null
                          : (_selectedGrades.toList()..sort())
                              .map((g) => 'Grade $g')
                              .join(', '),
                      onTap: _openGradePicker,
                      cs: cs,
                      theme: theme,
                    ),
                    const SizedBox(height: 8),
                  ],
                  _MtgAudiencePicker(icon: Icons.person_rounded, label: 'Students', summary: _selectedStudentIds.isEmpty ? null : '${_selectedStudentIds.length} student${_selectedStudentIds.length == 1 ? '' : 's'}', onTap: _openStudentPicker, cs: cs, theme: theme),
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
                ])),
                const SizedBox(height: 12),

                // ── Details ─────────────────────────────────────────────────
                _SectionCard(title: 'Meeting Details', child: Column(children: [
                  if (_subjects.isNotEmpty) ...[
                    LiquidGlassDropdown<String?>(
                      label: 'Subject',
                      value: _selectedSubject,
                      items: [
                        const LiquidGlassDropdownItem(value: null, label: 'No subject', icon: Icons.subject_rounded),
                        ..._subjects.map((s) => LiquidGlassDropdownItem(value: s, label: s, icon: Icons.menu_book_rounded)),
                            const LiquidGlassDropdownItem(value: 'Other', label: 'Other', icon: Icons.category_rounded),
                      ],
                      onChanged: (v) => setState(() => _selectedSubject = v),
                      searchHint: 'Search subjects...'),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.teacherMeetingTitleField, border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl, maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.teacherMaterialDescriptionLabel, alignLabelWithHint: true, border: const OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _linkCtrl,
                    decoration: InputDecoration(labelText: AppLocalizations.of(context)!.teacherMeetingLinkField, prefixIcon: const Icon(Icons.link_rounded), border: const OutlineInputBorder(), hintText: 'https://meet.google.com/...')),
                  const SizedBox(height: 12),
                  // Start time
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => _pickDateTime(isStart: true),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.teacherMeetingStartTime, border: const OutlineInputBorder(),
                        suffixIcon: _startsAt != null ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => setState(() => _startsAt = null)) : const Icon(Icons.schedule_rounded)),
                      child: Text(
                        _startsAt != null ? DateFormat('yMMMd · HH:mm', locale).format(_startsAt!) : 'Pick start time',
                        style: TextStyle(color: _startsAt != null ? cs.onSurface : cs.onSurfaceVariant)))),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () => _pickDateTime(isStart: false),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.teacherMeetingEndTime, border: const OutlineInputBorder(),
                        suffixIcon: _endsAt != null ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () => setState(() => _endsAt = null)) : const Icon(Icons.schedule_rounded)),
                      child: Text(
                        _endsAt != null ? DateFormat('yMMMd · HH:mm', locale).format(_endsAt!) : 'Pick end time',
                        style: TextStyle(color: _endsAt != null ? cs.onSurface : cs.onSurfaceVariant)))),
                ])),
                const SizedBox(height: 12),

              ],
            ),
    );
  }
}

class _MtgItem { const _MtgItem({required this.id, required this.label, this.subtitle = ''}); final String id; final String label; final String subtitle; }

class _MtgAudiencePicker extends StatelessWidget {
  const _MtgAudiencePicker({required this.icon, required this.label, required this.summary, required this.onTap, required this.cs, required this.theme});
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

class _MtgSingleSheet extends StatefulWidget {
  const _MtgSingleSheet({required this.title, required this.items, required this.selected, required this.onSelect});
  final String title; final List<_MtgItem> items; final String selected; final ValueChanged<String> onSelect;
  @override State<_MtgSingleSheet> createState() => _MtgSingleSheetState();
}
class _MtgSingleSheetState extends State<_MtgSingleSheet> {
  String _q = ''; late String _sel;
  @override void initState() { super.initState(); _sel = widget.selected; }
  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; final theme = Theme.of(context);
    final filtered = widget.items.where((i) => _q.isEmpty || i.label.toLowerCase().contains(_q.toLowerCase())).toList();
    return DraggableScrollableSheet(expand: false, initialChildSize: 0.55, maxChildSize: 0.9, minChildSize: 0.35, builder: (ctx, sc) => Column(children: [
      Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
      Padding(padding: const EdgeInsets.fromLTRB(20,0,20,12), child: Text(widget.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
      Padding(padding: const EdgeInsets.fromLTRB(16,0,16,8), child: TextField(onChanged: (v) => setState(() => _q = v), decoration: InputDecoration(hintText: 'Search…', prefixIcon: const Icon(Icons.search_rounded, size: 20), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14)))),
      Expanded(child: ListView.builder(controller: sc, padding: const EdgeInsets.fromLTRB(12,4,12,16), itemCount: filtered.length, itemBuilder: (ctx, i) {
        final item = filtered[i]; final isSel = _sel == item.id;
        return RadioListTile<String>(value: item.id, groupValue: _sel, onChanged: (v) { setState(() => _sel = v ?? ''); widget.onSelect(v ?? ''); Navigator.of(context).pop(); }, title: Text(item.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: isSel ? FontWeight.w700 : FontWeight.w400)), subtitle: item.subtitle.isNotEmpty ? Text(item.subtitle, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)) : null, selected: isSel, activeColor: cs.primary);
      })),
    ]));
  }
}

class _MtgCohortSheet extends StatefulWidget {
  const _MtgCohortSheet({required this.title, required this.items, required this.selected, required this.onToggle});
  final String title; final List<_MtgItem> items; final Set<String> selected; final ValueChanged<String> onToggle;
  @override State<_MtgCohortSheet> createState() => _MtgCohortSheetState();
}
class _MtgCohortSheetState extends State<_MtgCohortSheet> {
  late Set<String> _sel;
  @override void initState() { super.initState(); _sel = Set.from(widget.selected); }
  void _toggle(String id) { setState(() => _sel.contains(id) ? _sel.remove(id) : _sel.add(id)); widget.onToggle(id); }
  @override Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; final theme = Theme.of(context);
    return DraggableScrollableSheet(expand: false, initialChildSize: 0.55, maxChildSize: 0.9, minChildSize: 0.35, builder: (ctx, sc) => Column(children: [
      Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
      Padding(padding: const EdgeInsets.fromLTRB(20,0,20,12), child: Row(children: [
        Text(widget.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const Spacer(),
        if (_sel.isNotEmpty) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(20)), child: Text('${_sel.length} selected', style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 12))),
      ])),
      Expanded(child: ListView.builder(controller: sc, padding: const EdgeInsets.fromLTRB(12,4,12,16), itemCount: widget.items.length, itemBuilder: (ctx, i) {
        final item = widget.items[i]; final isSel = _sel.contains(item.id);
        return CheckboxListTile(value: isSel, onChanged: (_) => _toggle(item.id), title: Text(item.label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: isSel ? FontWeight.w700 : FontWeight.w400)), subtitle: item.subtitle.isNotEmpty ? Text(item.subtitle, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)) : null, activeColor: cs.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));
      })),
    ]));
  }
}

class _MembersPreview extends StatelessWidget {
  const _MembersPreview({required this.members, required this.cs, required this.theme});
  final List<String> members;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${members.length} member${members.length == 1 ? '' : 's'} will receive this',
            style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 4, children: members.map((name) => Chip(
          label: Text(name, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          visualDensity: VisualDensity.compact,
        )).toList()),
      ]),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16), borderRadius: BorderRadius.circular(20),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        child,
      ]));
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: color), const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800, color: color, letterSpacing: 0.3)),
      const SizedBox(width: 8),
      Expanded(child: Divider(color: color)),
    ]);
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)));
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
      if (_localSelected.contains(id)) { _localSelected.remove(id); }
      else { _localSelected.add(id); }
    });
    widget.onToggle(id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
      builder: (ctx, scroll) => Container(
        decoration: BoxDecoration(color: cs.surfaceContainerLow, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(children: [
          Container(margin: const EdgeInsets.symmetric(vertical: 10), width: 36, height: 4,
            decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
          Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(controller: _searchCtrl, onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(hintText: 'Search students or grade...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), isDense: true))),
          Expanded(child: ListView.builder(controller: scroll, itemCount: _filtered.length,
            itemBuilder: (ctx, i) {
              final item = _filtered[i]; final sel = _localSelected.contains(item.id);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: sel ? cs.primaryContainer : cs.surfaceContainerHigh,
                  child: Text(item.label.isNotEmpty ? item.label[0].toUpperCase() : '?',
                    style: TextStyle(fontWeight: FontWeight.w700, color: sel ? cs.onPrimaryContainer : cs.onSurface))),
                title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: item.subtitle.isNotEmpty ? Text(item.subtitle) : null,
                trailing: sel ? Icon(Icons.check_circle_rounded, color: cs.primary) : Icon(Icons.radio_button_unchecked, color: cs.outlineVariant),
                onTap: () => _toggle(item.id));
            })),
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(width: double.infinity,
              child: FilledButton(onPressed: () => Navigator.of(context).pop(),
                child: Text('Done (${_localSelected.length} selected)')))),
        ]),
      ),
    );
  }
}
