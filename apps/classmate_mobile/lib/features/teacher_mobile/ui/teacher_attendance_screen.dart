import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../schedule/schedule_empty_state_copy.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import 'teacher_shared_widgets.dart';
import '../../../ui/widgets/cm_loading.dart';

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

Color _statusColor(BuildContext context, String status) {
  final cs = Theme.of(context).colorScheme;
  switch (status.trim().toUpperCase()) {
    case AttendanceStatus.present: return const Color(0xFF22C55E);
    case AttendanceStatus.absent: return cs.error;
    case AttendanceStatus.late: return const Color(0xFFF59E0B);
    case AttendanceStatus.excused: return const Color(0xFF60A5FA);
    default: return cs.onSurfaceVariant;
  }
}

String _statusLabel(BuildContext context, String status) {
  final l = AppLocalizations.of(context)!;
  switch (status.trim().toUpperCase()) {
    case AttendanceStatus.present:
      return l.attendanceStatusPresent;
    case AttendanceStatus.absent:
      return l.attendanceStatusAbsent;
    case AttendanceStatus.late:
      return l.attendanceStatusLate;
    case AttendanceStatus.excused:
      return l.attendanceStatusExcused;
    default:
      return status;
  }
}

class TeacherAttendanceScreen extends ConsumerStatefulWidget {
  const TeacherAttendanceScreen({
    super.key,
    this.initialCohortId,
    this.initialPeriod,
    this.initialDate,
    this.initialSlotId,
  });

  final String? initialCohortId;
  final int? initialPeriod;
  final String? initialDate;
  final String? initialSlotId;

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
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _classNoteCtrl = TextEditingController();
  final TextEditingController _studentSearchCtrl = TextEditingController();

  String get _formattedDate {
    final d = _selectedDate;
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
      _session = null;
      _drafts.clear();
    });
    if (_selectedCohortId != null && _selectedPeriod != null) {
      await _loadSessionForDate(_selectedCohortId!, _selectedPeriod!);
    }
  }

  Future<void> _loadSessionForDate(String cohortId, int period) async {
    setState(() { _loading = true; _error = null; });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final session = await repo.fetchAttendanceSessionForDate(
        cohortId: cohortId,
        date: _formattedDate,
        period: period,
        slotId: widget.initialSlotId,
      );
      if (!mounted) return;
      _classNoteCtrl.text = session.classNote;
      setState(() { _session = session; _loading = false; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _error = error.toString(); _loading = false; });
    }
  }

  @override
  void dispose() {
    _classNoteCtrl.dispose();
    _studentSearchCtrl.dispose();
    super.dispose();
  }

  void _cycleStatus(String studentId) {
    final current = _drafts[studentId]?.status ?? AttendanceStatus.present;
    final next = AttendanceStatus.values[(AttendanceStatus.values.indexOf(current) + 1) % AttendanceStatus.values.length];
    setState(() {
      _drafts[studentId] = TeacherAttendanceDraftRecord(
        studentId: studentId,
        status: next,
        note: _drafts[studentId]?.note ?? '',
      );
    });
  }

  /// True when the screen was opened for ONE specific period (from the
  /// schedule/home slot sheet) — we then skip the "Today's sessions" picker
  /// (and its misleading "today looks clear" copy) and just show that
  /// period's roster.
  bool get _fromSpecificSlot =>
      (widget.initialSlotId != null && widget.initialSlotId!.isNotEmpty) ||
      (widget.initialCohortId != null && widget.initialCohortId!.isNotEmpty);

  @override
  void initState() {
    super.initState();
    final initDate = widget.initialDate;
    if (initDate != null && initDate.isNotEmpty) {
      final dt = DateTime.tryParse(initDate);
      if (dt != null) _selectedDate = dt;
    }
    Future<void>.microtask(_loadToday);
  }

  Future<void> _loadToday() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final initCohortId = widget.initialCohortId;
    final initPeriod = widget.initialPeriod;
    final initSlotId = widget.initialSlotId;
    // Load the session if we have EITHER a cohort id OR a slot id — the
    // backend resolves the cohort from the slot when cohortId is empty, so
    // periods reached from the schedule (which may not carry a cohort id on
    // the slot map) still load their roster instead of falling through to
    // the "today looks clear" picker.
    final hasTarget = (initCohortId != null && initCohortId.isNotEmpty) ||
        (initSlotId != null && initSlotId.isNotEmpty);
    if (hasTarget && initPeriod != null) {
      try {
        final repo = ref.read(teacherMobileRepositoryProvider);
        final session = await repo.fetchAttendanceSessionForDate(
          cohortId: initCohortId ?? '',
          date: _formattedDate,
          period: initPeriod,
          slotId: initSlotId,
        );
        if (!mounted) return;
        setState(() {
          // Adopt the cohort the backend resolved (works whether we passed a
          // cohort id or only a slot id).
          _selectedCohortId = session.cohort.id.isNotEmpty ? session.cohort.id : initCohortId;
          _selectedPeriod = initPeriod;
          _session = session;
          _loading = false;
        });
        final today = await repo.fetchTodaySchedule();
        if (mounted) setState(() => _today = today);
      } catch (error) {
        // Surface the error (with a retry) instead of leaving the screen
        // blank — happens e.g. when a period has no cohort to attach
        // attendance to.
        if (mounted) {
          setState(() {
            _error = error.toString();
            _loading = false;
          });
        }
      }
      return;
    }

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
    if (cohort == null) return;
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
      final session = await repo.fetchAttendanceSessionForDate(
        cohortId: cohort.id,
        date: _formattedDate,
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
    // Always send all students — on first save this records the default PRESENT status.
    final allRecords = session.students.map(_draftFor).toList(growable: false);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(teacherMobileRepositoryProvider).saveBulkAttendance(
            cohortId: session.cohort.id,
            slotId: session.slotId ?? widget.initialSlotId,
            date: session.date,
            period: session.period,
            records: allRecords,
            classNote: _classNoteCtrl.text.trim().isEmpty ? null : _classNoteCtrl.text.trim(),
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
    final classNoteDirty = session != null && _classNoteCtrl.text.trim() != session.classNote;
    final dirtyCount = session == null ? 0 : session.students.where(_isDirty).length + (classNoteDirty ? 1 : 0);

    final markedCount = session == null ? 0 : session.students.length;
    final presentCount = session == null ? 0 : session.students.where((s) {
      final draft = _draftFor(s);
      return draft.status.toUpperCase() == AttendanceStatus.present;
    }).length;
    final absentCount = session == null ? 0 : session.students.where((s) {
      final draft = _draftFor(s);
      return draft.status.toUpperCase() == AttendanceStatus.absent;
    }).length;
    final lateCount = session == null ? 0 : session.students.where((s) {
      final draft = _draftFor(s);
      return draft.status.toUpperCase() == AttendanceStatus.late;
    }).length;
    // Late students DID attend — count them as present in the rate (only
    // ABSENT lowers it; Excused is a sanctioned absence, kept out of "present").
    final attPct = markedCount > 0 ? (presentCount + lateCount) / markedCount : 0.0;

    return Scaffold(
      body: SafeArea(
      child: RefreshIndicator(
      onRefresh: _loadToday,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          // ── Hero Banner ───────────────────────────────────────────────
          LiquidGlassCard(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.outlineVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // ← back button
                    GestureDetector(
                      onTap: () { if (context.canPop()) context.pop(); },
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: cs.onSurface),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.navAttendance, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                          const SizedBox(height: 4),
                          Text(l.teacherAttendanceSubtitle, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    // Date picker button
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 14, color: cs.primary),
                            const SizedBox(width: 6),
                            Text(_formattedDate, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: cs.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (session != null && markedCount > 0) ...[
                  const SizedBox(height: 16),
                  // Progress stats
                  Row(
                    children: [
                      _AttStatPill(value: '$presentCount', label: AppLocalizations.of(context)!.attendanceStatusPresent, color: cs.secondaryContainer, textColor: cs.onSecondaryContainer),
                      const SizedBox(width: 8),
                      _AttStatPill(value: '$absentCount', label: AppLocalizations.of(context)!.attendanceStatusAbsent, color: cs.errorContainer, textColor: cs.onErrorContainer),
                      const SizedBox(width: 8),
                      _AttStatPill(value: '${markedCount - presentCount - absentCount}', label: AppLocalizations.of(context)!.teacherAttendanceOther, color: cs.tertiaryContainer, textColor: cs.onTertiaryContainer),
                      const SizedBox(width: 8),
                      _AttStatPill(value: '$markedCount', label: AppLocalizations.of(context)!.teacherTotal, color: cs.surfaceContainerLow, textColor: cs.onSurfaceVariant),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Attendance progress bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppLocalizations.of(context)!.teacherAttendanceRateLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
                          Text('${(attPct * 100).round()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: attPct >= 0.85 ? const Color(0xFF22C55E) : attPct >= 0.7 ? const Color(0xFFF59E0B) : cs.error)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: attPct,
                          minHeight: 8,
                          backgroundColor: cs.outlineVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            attPct >= 0.85 ? const Color(0xFF22C55E) : attPct >= 0.7 ? const Color(0xFFF59E0B) : cs.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (session == null) ...[
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.teacherSelectSessionPrompt, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                ],
              ],
            ),
          ),
          if (!_fromSpecificSlot) ...[
          const SizedBox(height: 18),
          LiquidGlassCard(
            color: cs.surfaceContainerLow,
            border: Border.all(color: cs.outlineVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.teacherAttendanceTodaySessions,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                if (_loading && _today == null)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CmLoading()))
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
          ],
          const SizedBox(height: 14),
          if (_error != null)
            LiquidGlassCard(
              color: cs.errorContainer,
              child: Text(_friendlyError(context, _error), style: theme.textTheme.bodyMedium),
            ),
          if (session != null) ...[
            const SizedBox(height: 14),
            LiquidGlassCard(
              color: cs.surfaceContainerLow,
              border: Border.all(color: cs.outlineVariant),
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
                      _BulkStatusButton(label: l.attendanceStatusPresent, onTap: () => _setAllStatus(AttendanceStatus.present)),
                      _BulkStatusButton(label: l.attendanceStatusAbsent, onTap: () => _setAllStatus(AttendanceStatus.absent)),
                      _BulkStatusButton(label: l.attendanceStatusLate, onTap: () => _setAllStatus(AttendanceStatus.late)),
                      _BulkStatusButton(label: l.attendanceStatusExcused, onTap: () => _setAllStatus(AttendanceStatus.excused)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _classNoteCtrl,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.teacherAttendanceClassNotesLabel,
                hintText: l.teacherAttendanceClassNotesHint,
                prefixIcon: const Icon(Icons.notes_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _studentSearchCtrl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l.teacherSearchStudents,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
            const SizedBox(height: 10),

            ...session.students.where((s) {
              final q = _studentSearchCtrl.text.trim().toLowerCase();
              return q.isEmpty || s.name.toLowerCase().contains(q);
            }).map((student) {
              final draft = _draftFor(student);
              final statusColor = _statusColor(context, draft.status);
              final initial = student.name.trim().isNotEmpty ? student.name[0].toUpperCase() : '?';
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _cycleStatus(student.studentId),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(child: Text(initial, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: cs.onPrimaryContainer))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              student.name,
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _cycleStatus(student.studentId),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: statusColor, width: 1.5),
                              ),
                              child: Text(
                                _statusLabel(context, draft.status),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 14),
            // ── Save button ───────────────────────────────────────────────
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_rounded),
              label: Text(_saving
                  ? l.teacherAttendanceSaving
                  : dirtyCount > 0
                      ? l.teacherAttendanceSaveCount(dirtyCount)
                      : l.teacherAttendanceSaveAll),
            ),
          ],
        ],
      ),
    ),
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
        backgroundColor: cs.surface,
        side: BorderSide(color: cs.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label),
    );
  }
}

class _AttStatPill extends StatelessWidget {
  const _AttStatPill({required this.value, required this.label, required this.color, required this.textColor});
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textColor, height: 1.1)),
            Text(label, style: TextStyle(fontSize: 9, color: textColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}