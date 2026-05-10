// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import 'teacher_create_classroom_screen.dart';

String _friendlyError(BuildContext context, String? error) {
  final l = AppLocalizations.of(context)!;
  final raw = (error ?? '').replaceFirst('Exception: ', '').trim();
  if (raw.isEmpty) return l.teacherClassroomsLoadError;
  final lowered = raw.toLowerCase();
  if (lowered.contains('timeout')) return l.teacherClassroomsLoadTimeout;
  if (lowered.contains('socket') || lowered.contains('network')) {
    return l.teacherClassroomsLoadNetwork;
  }
  return raw;
}

class TeacherClassroomsScreen extends ConsumerStatefulWidget {
  const TeacherClassroomsScreen({super.key});

  @override
  ConsumerState<TeacherClassroomsScreen> createState() =>
      _TeacherClassroomsScreenState();
}

class _TeacherClassroomsScreenState
    extends ConsumerState<TeacherClassroomsScreen> {
  TeacherAssessmentBundle? _bundle;
  String? _selectedCohortId;
  List<TeacherStudent> _students = const <TeacherStudent>[];
  final TextEditingController _searchCtl = TextEditingController();

  // join code state per cohort (cohortId → code)
  final Map<String, TeacherJoinCode> _joinCodes = {};
  final Map<String, bool> _joinCodeBusy = {};

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
    _searchCtl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final classrooms =
          await ref.read(teacherMobileRepositoryProvider).fetchClassrooms();
      if (!mounted) return;
      // Wrap in a bundle-compatible shape so the existing render code works
      setState(() {
        _bundle = TeacherAssessmentBundle(courses: classrooms, assessments: const []);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openCohort(String cohortId) async {
    setState(() {
      _selectedCohortId = cohortId;
      _students = const <TeacherStudent>[];
      _error = null;
      _loading = true;
    });
    try {
      final results = await Future.wait([
        ref
            .read(teacherMobileRepositoryProvider)
            .fetchCohortStudents(cohortId),
        if (!_joinCodes.containsKey(cohortId))
          ref
              .read(teacherMobileRepositoryProvider)
              .getOrCreateJoinCode(cohortId)
        else
          Future<TeacherJoinCode>.value(_joinCodes[cohortId]!),
      ]);
      if (!mounted) return;
      setState(() {
        _students = results[0] as List<TeacherStudent>;
        _joinCodes[cohortId] = results[1] as TeacherJoinCode;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _resetJoinCode(String cohortId) async {
    setState(() => _joinCodeBusy[cohortId] = true);
    try {
      final code = await ref
          .read(teacherMobileRepositoryProvider)
          .resetJoinCode(cohortId);
      if (!mounted) return;
      setState(() => _joinCodes[cohortId] = code);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _joinCodeBusy[cohortId] = false);
    }
  }

  void _showCreateClassroomSheet() {
    Navigator.of(context, rootNavigator: true)
        .push<bool>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => TeacherCreateClassroomScreen(
          onCreated: _load,
        ),
      ),
    )
        .then((created) {
      if (created == true && mounted) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final courses = _bundle?.courses ?? const <TeacherCourse>[];
    final cohorts = <String, List<TeacherCourse>>{};
    for (final course in courses) {
      if (course.cohortId.isEmpty) continue;
      cohorts
          .putIfAbsent(course.cohortId, () => <TeacherCourse>[])
          .add(course);
    }

    // Flat list of all courses — each card navigates to classroom detail
    final allCourses = courses.toList()
      ..sort((a, b) {
        final ga = a.cohort?.grade ?? 99;
        final gb = b.cohort?.grade ?? 99;
        if (ga != gb) return ga.compareTo(gb);
        return a.name.compareTo(b.name);
      });

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 130),
          children: [
            // ── Header card — matches student "Your Classrooms" style ──────
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: LiquidGlassCard(
                borderRadius: BorderRadius.circular(28),
                color: cs.primaryContainer,
                border: Border.all(color: cs.outlineVariant),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 62, height: 62,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          color: cs.primaryContainer,
                        ),
                        child: Icon(Icons.forum_rounded, size: 30, color: cs.onPrimaryContainer),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l.navClassrooms,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.w900),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Create classroom',
                                  onPressed: _showCreateClassroomSheet,
                                  icon: const Icon(Icons.add_rounded),
                                ),
                              ],
                            ),
                            Text(
                              allCourses.isEmpty
                                  ? l.teacherClassroomsNoCohorts
                                  : '${allCourses.length} ${l.navClassrooms.toLowerCase()}',
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(color: cs.onPrimaryContainer),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // ── Search bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: _searchCtl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search classrooms…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchCtl.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () { _searchCtl.clear(); FocusScope.of(context).unfocus(); },
                        ),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (_error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(_friendlyError(context, _error), style: TextStyle(color: cs.onErrorContainer)),
              ),
            if (_loading && _bundle == null)
              const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
            else if (allCourses.isEmpty)
              const SizedBox.shrink()
            else ...[
              ...allCourses.where((course) {
                final q = _searchCtl.text.trim().toLowerCase();
                if (q.isEmpty) return true;
                return course.name.toLowerCase().contains(q) ||
                    course.subject.toLowerCase().contains(q) ||
                    (course.cohort?.name ?? '').toLowerCase().contains(q);
              }).map((course) {
                final grade = course.cohort?.grade;
                final cohortName = course.cohort?.name ?? '';
                final label = grade != null ? 'Grade $grade' : cohortName;
                final subtitle = [
                  if (course.subject.isNotEmpty) course.subject,
                  if (cohortName.isNotEmpty && cohortName != label) cohortName,
                ].join(' · ');
                // Two-part card: colored top (name) + dark bottom (subject)
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => context.push('/teacher/classroom/${course.id}', extra: <String, dynamic>{
                      'name': course.name,
                      'subject': course.subject,
                      'cohortName': cohortName,
                      'grade': grade ?? 0,
                    }),
                    borderRadius: BorderRadius.circular(20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Top — accent color, classroom name
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                            color: cs.primaryContainer,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    course.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                if (label.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: cs.onPrimaryContainer.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(label,
                                        style: TextStyle(color: cs.onPrimaryContainer, fontSize: 11, fontWeight: FontWeight.w700)),
                                  ),
                              ],
                            ),
                          ),
                          // Bottom — surface / dark, subject info
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 9, 16, 9),
                            color: cs.surfaceContainerLow,
                            child: Text(
                              subtitle.isEmpty ? course.subject : subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],

            // KEEP existing cohort/people section for the old code path
            if (false) ...[
              ...cohorts.entries.map((entry) {
                final active = entry.key == _selectedCohortId;
                final code = _joinCodes[entry.key];
                final busy = _joinCodeBusy[entry.key] == true;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LiquidGlassCard(
                    color: active ? cs.primaryContainer : cs.surfaceContainerLow,
                    border: Border.all(color: cs.outlineVariant),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => active
                              ? setState(() => _selectedCohortId = null)
                              : _openCohort(entry.key),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.teacherClassroomsCohort(entry.key),
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      '${entry.value.length} ${entry.value.length == 1 ? 'course' : 'courses'}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                active
                                    ? Icons.expand_less_rounded
                                    : Icons.expand_more_rounded,
                                color: cs.onSurfaceVariant,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...entry.value.map((course) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: cs.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.class_rounded,
                                        size: 16,
                                        color: cs.onSecondaryContainer),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          course.subject.isNotEmpty
                                              ? course.subject
                                              : course.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14),
                                        ),
                                        if (course.name.isNotEmpty &&
                                            course.name != course.subject)
                                          Text(course.name,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      cs.onSurfaceVariant)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FilledButton.tonal(
                                        onPressed: () {
                                          context.push(
                                            '/teacher/classroom/${course.id}',
                                            extra: <String, dynamic>{
                                              'name': course.name,
                                              'subject': course.subject,
                                              'cohortName':
                                                  entry.value.first.cohort
                                                          ?.name ??
                                                      entry.value.first
                                                          .cohortId,
                                              'grade': 0,
                                            },
                                          );
                                        },
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.open_in_new_rounded,
                                                size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .teacherOpenAction,
                                              style: const TextStyle(
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: const Icon(
                                            Icons.bar_chart_rounded,
                                            size: 18),
                                        onPressed: () => context.push(
                                          '/teacher/classroom/${course.id}/analytics',
                                          extra: <String, dynamic>{
                                            'name': course.name,
                                            'subject': course.subject
                                          },
                                        ),
                                        style: IconButton.styleFrom(
                                            padding: const EdgeInsets.all(6),
                                            minimumSize:
                                                const Size(32, 32)),
                                        tooltip: 'Analytics',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),

                        // ── Static join code section ───────────────────────
                        if (active) ...[
                          const Divider(height: 20),
                          if (_loading && code == null)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Center(child: CmLoading()),
                            )
                          else if (code != null) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Join Code',
                                        style: theme.textTheme.labelMedium
                                            ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: cs.onSurfaceVariant),
                                      ),
                                      const SizedBox(height: 4),
                                      SelectableText(
                                        code.code,
                                        style: theme.textTheme.headlineMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 6,
                                          color: cs.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Copy button
                                IconButton.filledTonal(
                                  icon: const Icon(Icons.copy_rounded,
                                      size: 18),
                                  tooltip: 'Copy code',
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: code.code));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                          content: Text('Code copied!')),
                                    );
                                  },
                                ),
                                // Reset button
                                busy
                                    ? const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        ),
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.refresh_rounded,
                                            size: 18,
                                            color: cs.onSurfaceVariant),
                                        tooltip: 'Reset code',
                                        onPressed: () =>
                                            _resetJoinCode(entry.key),
                                      ),
                              ],
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                );
              }),

              // ── Roster ─────────────────────────────────────────────────────
              if (_selectedCohortId != null) ...[
                const SizedBox(height: 8),
                Text(
                  l.teacherClassroomsRoster,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                if (_loading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CmLoading(),
                    ),
                  )
                else if (_students.isEmpty)
                  LiquidGlassCard(
                    color: cs.surfaceContainerLow,
                    child: Text(l.teacherClassroomsNoStudents),
                  )
                else
                  ..._students.map(
                    (student) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LiquidGlassCard(
                        color: cs.surfaceContainerLow,
                        border: Border.all(color: cs.outlineVariant),
                        child: Row(
                          children: [
                            CircleAvatar(
                              child: Text(
                                student.name.isEmpty
                                    ? '?'
                                    : student.name.characters.first
                                        .toUpperCase(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700),
                                  ),
                                  if (student.email.isNotEmpty)
                                    Text(
                                      student.email,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: cs.onSurfaceVariant),
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: cs.outlineVariant),
                              ),
                              child: Text(
                                l.student,
                                style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ],
        ),
          ),
          // FAB positioned above the liquid-glass nav pill (~ 100 px from bottom)
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              heroTag: 'fab_create_classroom',
              backgroundColor: cs.primaryContainer,
              foregroundColor: cs.onPrimaryContainer,
              onPressed: _showCreateClassroomSheet,
              child: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Create Classroom bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CreateClassroomSheet extends ConsumerStatefulWidget {
  const _CreateClassroomSheet({required this.onCreated});

  final VoidCallback onCreated;

  @override
  ConsumerState<_CreateClassroomSheet> createState() =>
      _CreateClassroomSheetState();
}

class _CreateClassroomSheetState extends ConsumerState<_CreateClassroomSheet> {
  final _nameCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final subject = _subjectCtrl.text.trim();
    if (name.isEmpty || subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and subject are required.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(teacherMobileRepositoryProvider).createClassroom(
            name: name,
            subject: subject,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onCreated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Classroom created!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Classroom',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Classroom name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _subjectCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Subject *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.add_rounded),
                label: const Text('Create Classroom'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
