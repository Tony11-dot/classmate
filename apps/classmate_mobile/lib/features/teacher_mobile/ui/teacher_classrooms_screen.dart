// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/contracts/school_subject.dart';
import '../../../core/http/cm_api.dart';
import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/liquid_glass_dropdown.dart';
import '../data/teacher_mobile_repository.dart';
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
  final TextEditingController _searchCtl = TextEditingController();

  // join code state per cohort (cohortId → code)

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

  void _showCreateClassroomSheet() {
    Navigator.of(context, rootNavigator: true)
        .push<bool>(
      // No fullscreenDialog — a normal push gets the global Cupertino slide
      // + edge swipe-back gesture (fullscreenDialog disables horizontal swipe).
      MaterialPageRoute(
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
                                  tooltip: AppLocalizations.of(context)!.teacherCreateClassroomTooltip,
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
                  hintText: AppLocalizations.of(context)!.teacherSearchClassrooms,
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
                final label = grade != null ? l.teacherClassroomsScreenGradeLabel(grade) : cohortName;
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

          ],
        ),
          ),
          // FAB positioned above the liquid-glass nav pill. Bumped from 100
          // after the iOS-26 nav polish made the pill taller and pushed it
          // up — 124px keeps a comfortable gap regardless.
          Positioned(
            right: 16,
            bottom: 124,
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
  /// Custom-subject text entry — only shown when the teacher picks
  /// "Other (type custom)" from the school subjects DDL.
  final _customSubjectCtrl = TextEditingController();
  /// nameEn of the picked school subject. Empty string == "Other" mode.
  String _subject = '';
  late Future<List<SchoolSubject>> _subjectsFuture;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _subjectsFuture = _loadSchoolSubjects();
  }

  Future<List<SchoolSubject>> _loadSchoolSubjects() async {
    final token = (ref.read(authSessionProvider).token ?? '').trim();
    if (token.isEmpty) return const [];
    final api = CMApi(token: token);
    try {
      final raw = await api.getJson('/me/subjects');
      final list = raw is Map ? raw['subjects'] : null;
      if (list is! List) return const [];
      return list
          .map(SchoolSubject.fromJson)
          .where((s) => s.nameEn.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    } finally {
      api.dispose();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _customSubjectCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    final subject = _subject.isEmpty
        ? _customSubjectCtrl.text.trim()
        : _subject;
    if (name.isEmpty || subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.teacherClassroomNameSubjectRequired)),
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
        SnackBar(content: Text(AppLocalizations.of(context)!.teacherClassroomCreated)),
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
              AppLocalizations.of(context)!.teacherClassroomsScreenNewClassroom,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.teacherClassroomNameRequired,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Subject picker — pulls the school's defined subjects so
            // teachers can't typo their way into a subject that doesn't
            // exist anywhere else. "Other (type custom)" reveals a
            // freeform field for one-off subjects the school hasn't
            // configured yet.
            FutureBuilder<List<SchoolSubject>>(
              future: _subjectsFuture,
              builder: (ctx, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const SizedBox(
                    height: 56,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                final subjects = snap.data ?? const <SchoolSubject>[];
                if (subjects.isEmpty) {
                  // School hasn't defined any subjects yet — fall back to
                  // a plain text field so teachers aren't blocked.
                  return TextField(
                    controller: _customSubjectCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.teacherSubjectRequired,
                      border: const OutlineInputBorder(),
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LiquidGlassDropdown<String>(
                      label: AppLocalizations.of(context)!.teacherSubjectRequired,
                      value: _subject,
                      searchHint: AppLocalizations.of(context)!.teacherMaterialSubjectSearch,
                      items: [
                        LiquidGlassDropdownItem(value: '__other__', label: AppLocalizations.of(context)!.teacherOtherCustomSubject),
                        for (final s in subjects)
                          LiquidGlassDropdownItem(value: s.nameEn, label: s.nameEn),
                      ],
                      onChanged: (v) => setState(() {
                        _subject = v == '__other__' ? '' : v;
                      }),
                    ),
                    if (_subject.isEmpty) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _customSubjectCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.teacherCustomSubjectLabel,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ],
                );
              },
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
                label: Text(AppLocalizations.of(context)!.teacherCreateClassroomButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
