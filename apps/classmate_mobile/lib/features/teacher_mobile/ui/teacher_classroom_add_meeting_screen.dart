// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../data/teacher_mobile_repository.dart';

class TeacherClassroomAddMeetingScreen extends ConsumerStatefulWidget {
  const TeacherClassroomAddMeetingScreen({
    super.key,
    required this.courseId,
    this.courseName = '',
  });

  final String courseId;
  final String courseName;

  @override
  ConsumerState<TeacherClassroomAddMeetingScreen> createState() =>
      _TeacherClassroomAddMeetingScreenState();
}

class _TeacherClassroomAddMeetingScreenState
    extends ConsumerState<TeacherClassroomAddMeetingScreen> {
  final _titleCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  /// Combines a [DateTime] date and a [TimeOfDay] into a single [DateTime].
  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final link = _linkCtrl.text.trim();

    final l = AppLocalizations.of(context)!;
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherMeetingTitleRequired)),
      );
      return;
    }
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherMeetingLinkRequired)),
      );
      return;
    }
    if (_startDate == null || _startTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.teacherMeetingDateTimeRequired)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final startsAt = _combine(_startDate!, _startTime!).toIso8601String();
      String? endsAt;
      if (_endTime != null) {
        final endDateResolved = _endDate ?? _startDate!;
        endsAt = _combine(endDateResolved, _endTime!).toIso8601String();
      }

      await ref.read(teacherMobileRepositoryProvider).createClassroomMeeting(
            courseId: widget.courseId,
            title: title,
            link: link,
            startsAt: startsAt,
            endsAt: endsAt,
          );
      if (context.mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final dateFmt = DateFormat.yMMMd(locale);
    final timeFmt = DateFormat.jm(locale);

    // Helper to format a TimeOfDay for display via intl.
    String formatTime(TimeOfDay t) {
      final dt = DateTime(2000, 1, 1, t.hour, t.minute);
      return timeFmt.format(dt);
    }

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
          AppLocalizations.of(context)!.teacherScheduleMeetingTitle,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.event_available_rounded, size: 18),
              label: Text(AppLocalizations.of(context)!.teacherScheduleButton),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          MediaQuery.of(context).viewInsets.bottom + 120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Meeting Details ────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: cs.outlineVariant),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Meeting Details',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.teacherMeetingTitleField,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _linkCtrl,
                    keyboardType: TextInputType.url,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.teacherMeetingLinkField,
                      hintText: 'e.g. https://zoom.us/j/...',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.videocam_outlined),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text(
                      'e.g. https://zoom.us/j/...',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── When ──────────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: cs.outlineVariant),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'When',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),

                  // Start date + time
                  Row(
                    children: [
                      // Start date
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: _pickStartDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.meetingStartDateRequired,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.calendar_today_rounded),
                            ),
                            child: Text(
                              _startDate != null
                                  ? dateFmt.format(_startDate!)
                                  : AppLocalizations.of(context)!.meetingStartDateRequired,
                              style: TextStyle(
                                color: _startDate != null
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Start time
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: _pickStartTime,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.meetingStartTimeRequired,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.access_time_rounded),
                            ),
                            child: Text(
                              _startTime != null
                                  ? formatTime(_startTime!)
                                  : AppLocalizations.of(context)!.meetingStartTimeRequired,
                              style: TextStyle(
                                color: _startTime != null
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // End date + time (optional)
                  Row(
                    children: [
                      // End date
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: _pickEndDate,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.meetingEndDateOptional,
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.calendar_today_outlined),
                            ),
                            child: Text(
                              _endDate != null
                                  ? dateFmt.format(_endDate!)
                                  : AppLocalizations.of(context)!.meetingEndDateOptional,
                              style: TextStyle(
                                color: _endDate != null
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // End time
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: _pickEndTime,
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!.meetingEndTimeOptional,
                              border: const OutlineInputBorder(),
                              prefixIcon:
                                  const Icon(Icons.access_time_outlined),
                              suffixIcon: _endTime != null
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded,
                                          size: 18),
                                      tooltip: AppLocalizations.of(context)!.tooltipClearEndTime,
                                      onPressed: () => setState(() {
                                        _endTime = null;
                                        _endDate = null;
                                      }),
                                    )
                                  : null,
                            ),
                            child: Text(
                              _endTime != null
                                  ? formatTime(_endTime!)
                                  : AppLocalizations.of(context)!.meetingEndTimeOptional,
                              style: TextStyle(
                                color: _endTime != null
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_endTime != null && _endDate == null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'End date defaults to start date',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
