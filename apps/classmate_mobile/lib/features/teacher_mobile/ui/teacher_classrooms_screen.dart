import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

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
  ConsumerState<TeacherClassroomsScreen> createState() => _TeacherClassroomsScreenState();
}

class _TeacherClassroomsScreenState extends ConsumerState<TeacherClassroomsScreen> {
  TeacherAssessmentBundle? _bundle;
  String? _selectedCohortId;
  List<TeacherStudent> _students = const <TeacherStudent>[];
  TeacherJoinCode? _joinCode;
  bool _loading = true;
  bool _joinCodeBusy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bundle = await ref.read(teacherMobileRepositoryProvider).fetchAssessments();
      if (!mounted) return;
      setState(() {
        _bundle = bundle;
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
      _joinCode = null;
      _error = null;
      _loading = true;
    });
    try {
      final students = await ref.read(teacherMobileRepositoryProvider).fetchCohortStudents(cohortId);
      if (!mounted) return;
      setState(() {
        _students = students;
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

  Future<void> _generateJoinCode() async {
    final cohortId = _selectedCohortId;
    if (cohortId == null) return;
    setState(() {
      _joinCodeBusy = true;
      _error = null;
    });
    try {
      final joinCode = await ref.read(teacherMobileRepositoryProvider).createJoinCode(cohortId);
      if (!mounted) return;
      setState(() => _joinCode = joinCode);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _joinCodeBusy = false);
    }
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
      cohorts.putIfAbsent(course.cohortId, () => <TeacherCourse>[]).add(course);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(l.navClassrooms, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            l.teacherClassroomsSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          if (_error != null)
            LiquidGlassCard(
              color: cs.errorContainer.withValues(alpha: 0.72),
              child: Text(_friendlyError(context, _error)),
            ),
          if (_loading && _bundle == null)
            const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
          else if (cohorts.isEmpty)
            LiquidGlassCard(
              color: cs.surface.withValues(alpha: 0.76),
              child: Text(l.teacherClassroomsNoCohorts),
            )
          else ...[
            ...cohorts.entries.map((entry) {
              final active = entry.key == _selectedCohortId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LiquidGlassCard(
                  color: active ? cs.primaryContainer.withValues(alpha: 0.46) : cs.surface.withValues(alpha: 0.76),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: active
                        ? [
                            cs.primaryContainer.withValues(alpha: 0.72),
                            cs.surface.withValues(alpha: 0.70),
                          ]
                        : [
                            cs.surface.withValues(alpha: 0.82),
                            cs.surfaceContainerHigh.withValues(alpha: 0.66),
                          ],
                  ),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => _openCohort(entry.key),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.teacherClassroomsCohort(entry.key),
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${entry.value.length} ${entry.value.length == 1 ? 'course' : 'courses'}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              active ? Icons.expand_less_rounded : Icons.expand_more_rounded,
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
                                color: cs.secondaryContainer.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.class_rounded, size: 16, color: cs.secondary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.subject.isNotEmpty ? course.subject : course.name,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                  ),
                                  if (course.name.isNotEmpty && course.name != course.subject)
                                    Text(course.name, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FilledButton.tonal(
                                  onPressed: () {
                                    context.push('/teacher/classroom/${course.id}', extra: <String, dynamic>{
                                      'name': course.name,
                                      'subject': course.subject,
                                      'cohortName': entry.value.first.cohortId,
                                      'grade': 0,
                                    });
                                  },
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.open_in_new_rounded, size: 14),
                                      const SizedBox(width: 4),
                                      Text(AppLocalizations.of(context)!.teacherOpenAction, style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.bar_chart_rounded, size: 18),
                                  onPressed: () => context.push(
                                    '/teacher/classroom/${course.id}/analytics',
                                    extra: <String, dynamic>{'name': course.name, 'subject': course.subject},
                                  ),
                                  style: IconButton.styleFrom(padding: const EdgeInsets.all(6), minimumSize: const Size(32, 32)),
                                  tooltip: 'Analytics',
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              );
            }),
            if (_selectedCohortId != null) ...[
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _joinCodeBusy ? null : _generateJoinCode,
                icon: _joinCodeBusy ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.qr_code_rounded),
                label: Text(
                  _joinCodeBusy
                      ? l.teacherClassroomsGeneratingJoinCode
                      : l.teacherClassroomsCreateJoinCode,
                ),
              ),
              if (_joinCode != null) ...[
                const SizedBox(height: 12),
                LiquidGlassCard(
                  color: cs.tertiaryContainer.withValues(alpha: 0.56),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.tertiaryContainer.withValues(alpha: 0.72),
                      cs.surface.withValues(alpha: 0.62),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.teacherClassroomsLiveJoinCode,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      SelectableText(_joinCode!.code, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 8)),
                      if (_joinCode!.expiresAt.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            l.teacherClassroomsExpiresAt(_joinCode!.expiresAt),
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                l.teacherClassroomsRoster,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
              else if (_students.isEmpty)
                LiquidGlassCard(
                  color: cs.surface.withValues(alpha: 0.76),
                  child: Text(l.teacherClassroomsNoStudents),
                )
              else
                ..._students.map(
                  (student) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: LiquidGlassCard(
                      color: cs.surface.withValues(alpha: 0.76),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.surface.withValues(alpha: 0.82),
                          cs.surfaceContainerHigh.withValues(alpha: 0.64),
                        ],
                      ),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
                      child: Row(
                        children: [
                          CircleAvatar(child: Text(student.name.isEmpty ? '?' : student.name.characters.first.toUpperCase())),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(student.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                if (student.email.isNotEmpty)
                                  Text(student.email, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  cs.secondaryContainer.withValues(alpha: 0.78),
                                  cs.surface.withValues(alpha: 0.56),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: cs.secondary.withValues(alpha: 0.12)),
                            ),
                            child: Text(
                              l.student,
                              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
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
    );
  }
}