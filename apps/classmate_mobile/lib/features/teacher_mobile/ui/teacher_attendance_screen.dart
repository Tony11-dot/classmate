import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../schedule/schedule_empty_state_copy.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

String _friendlyError(BuildContext context, String? error) {
  final l = AppLocalizations.of(context)!;
  final raw = (error ?? '').replaceFirst('Exception: ', '').trim();
  if (raw.isEmpty) return l.teacherAttendanceLoadError;
  final lowered = raw.toLowerCase();
  if (lowered.contains('timeout')) return l.teacherAttendanceLoadTimeout;
  if (lowered.contains('socket') || lowered.contains('network')) {
    return l.teacherAttendanceLoadNetwork;
  }
  return raw;
}

String _statusLabel(BuildContext context, String status) {
  final l = AppLocalizations.of(context)!;
  switch (status.trim().toUpperCase()) {
    case 'PRESENT':
      return l.attendanceStatusPresent;
    case 'ABSENT':
      return l.attendanceStatusAbsent;
    case 'LATE':
      return l.attendanceStatusLate;
    case 'EXCUSED':
      return l.attendanceStatusExcused;
    default:
      return status;
  }
}

class TeacherAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  ConsumerState<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends ConsumerState<TeacherAttendanceScreen> {
  TeacherTodaySchedule? _today;
  TeacherAttendanceSession? _session;
  String? _selectedCohortId;
  int? _selectedPeriod;
  final Map<String, TeacherAttendanceDraftRecord> _drafts = <String, TeacherAttendanceDraftRecord>{};
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadToday);
  }

  Future<void> _loadToday() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final today = await repo.fetchTodaySchedule();
      final slots = today.slots.where((slot) => slot.cohort != null && slot.course != null).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _today = today;
        _loading = false;
      });
      if (slots.isNotEmpty) {
        await _selectSlot(slots.first);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _selectSlot(TeacherTodaySlot slot) async {
    final cohort = slot.cohort;
    if (cohort == null || _today == null) return;
    setState(() {
      _selectedCohortId = cohort.id;
      _selectedPeriod = slot.period;
      _session = null;
      _drafts.clear();
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final session = await repo.fetchAttendanceSession(
        cohortId: cohort.id,
        date: _today!.date,
        period: slot.period,
      );
      if (!mounted) return;
      setState(() {
        _session = session;
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

  TeacherAttendanceDraftRecord _draftFor(TeacherAttendanceStudent student) {
    return _drafts[student.studentId] ??
        TeacherAttendanceDraftRecord(
          studentId: student.studentId,
          status: student.status,
          note: student.note,
        );
  }

  bool _isDirty(TeacherAttendanceStudent student) {
    final draft = _draftFor(student);
    return draft.status != student.status || draft.note != student.note;
  }

  Future<void> _save() async {
    final session = _session;
    if (session == null) return;
    final dirty = session.students.where(_isDirty).map(_draftFor).toList(growable: false);
    if (dirty.isEmpty) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(teacherMobileRepositoryProvider).saveBulkAttendance(
            cohortId: session.cohort.id,
            date: session.date,
            period: session.period,
            records: dirty,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.teacherAttendanceSaved)));
      final slot = _today?.slots.firstWhere(
        (item) => item.cohort?.id == session.cohort.id && item.period == session.period,
        orElse: () => TeacherTodaySlot(period: session.period, source: 'TEMPLATE', cohort: session.cohort, course: session.course),
      );
      if (slot != null) {
        await _selectSlot(slot);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _setAllStatus(String status) {
    final session = _session;
    if (session == null) return;
    setState(() {
      for (final student in session.students) {
        final current = _draftFor(student);
        _drafts[student.studentId] = TeacherAttendanceDraftRecord(
          studentId: student.studentId,
          status: status,
          note: current.note,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final session = _session;
    final slots = _today?.slots.where((slot) => slot.cohort != null && slot.course != null).toList(growable: false) ?? const <TeacherTodaySlot>[];
    final dirtyCount = session == null ? 0 : session.students.where(_isDirty).length;

    return RefreshIndicator(
      onRefresh: _loadToday,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(l.navAttendance, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            l.teacherAttendanceSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 18),
          LiquidGlassCard(
            color: cs.surface.withValues(alpha: 0.76),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.surface.withValues(alpha: 0.84),
                cs.surfaceContainerHigh.withValues(alpha: 0.64),
              ],
            ),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.teacherAttendanceTodaySessions,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (_loading && _today == null)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                else if (slots.isEmpty)
                  Text(ScheduleEmptyStateCopy.subtitle(l, l.today))
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: slots.map((slot) {
                      final active = slot.cohort?.id == _selectedCohortId && slot.period == _selectedPeriod;
                      return ChoiceChip(
                        label: Text(
                          '${slot.course?.name ?? l.teacherCourseFallback} • ${l.teacherPeriod(slot.period)}',
                        ),
                        selected: active,
                        onSelected: (_) => _selectSlot(slot),
                      );
                    }).toList(growable: false),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (_error != null)
            LiquidGlassCard(
              color: cs.errorContainer.withValues(alpha: 0.72),
              child: Text(_friendlyError(context, _error), style: theme.textTheme.bodyMedium),
            ),
          if (session != null) ...[
            const SizedBox(height: 14),
            LiquidGlassCard(
              color: cs.surface.withValues(alpha: 0.76),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.surface.withValues(alpha: 0.84),
                  cs.surfaceContainerHigh.withValues(alpha: 0.66),
                ],
              ),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.course.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    l.teacherAttendanceSessionSummary(
                      session.cohort.name,
                      session.cohort.grade,
                      session.date,
                      session.period,
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _BulkStatusButton(label: l.attendanceStatusPresent, onTap: () => _setAllStatus('PRESENT')),
                      _BulkStatusButton(label: l.attendanceStatusAbsent, onTap: () => _setAllStatus('ABSENT')),
                      _BulkStatusButton(label: l.attendanceStatusLate, onTap: () => _setAllStatus('LATE')),
                      _BulkStatusButton(label: l.attendanceStatusExcused, onTap: () => _setAllStatus('EXCUSED')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...session.students.map((student) {
              final draft = _draftFor(student);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LiquidGlassCard(
                  color: _isDirty(student) ? cs.primaryContainer.withValues(alpha: 0.36) : cs.surface.withValues(alpha: 0.74),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _isDirty(student)
                        ? [
                            cs.primaryContainer.withValues(alpha: 0.64),
                            cs.surface.withValues(alpha: 0.68),
                          ]
                        : [
                            cs.surface.withValues(alpha: 0.82),
                            cs.surfaceContainerHigh.withValues(alpha: 0.62),
                          ],
                  ),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(student.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                          if (_isDirty(student)) Chip(label: Text(l.teacherAttendanceChanged)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: draft.status,
                        decoration: InputDecoration(labelText: l.editProfileStatus),
                        items: const ['PRESENT', 'ABSENT', 'LATE', 'EXCUSED']
                            .map(
                              (status) => DropdownMenuItem<String>(
                                value: status,
                                child: Text(_statusLabel(context, status)),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _drafts[student.studentId] = TeacherAttendanceDraftRecord(
                              studentId: student.studentId,
                              status: value,
                              note: draft.note,
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: draft.note,
                        decoration: InputDecoration(labelText: l.teacherAttendanceNoteLabel),
                        onChanged: (value) {
                          setState(() {
                            _drafts[student.studentId] = TeacherAttendanceDraftRecord(
                              studentId: student.studentId,
                              status: _draftFor(student).status,
                              note: value,
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
            FilledButton.icon(
              onPressed: _saving || dirtyCount == 0 ? null : _save,
              icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_rounded),
              label: Text(
                _saving ? l.teacherAttendanceSaving : l.teacherAttendanceSaveCount(dirtyCount),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BulkStatusButton extends StatelessWidget {
  const _BulkStatusButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        backgroundColor: cs.surface.withValues(alpha: 0.32),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.22)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label),
    );
  }
}