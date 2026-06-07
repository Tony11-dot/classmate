import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/realtime/realtime_listener.dart';
import '../../core/semester/school_semester.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/attachment_pill.dart';
import '../../ui/widgets/semester_filter_bar.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import '../classrooms/providers/classrooms_providers.dart';
import '../classrooms/providers/classrooms_repo_provider.dart';
import '../parent/data/parent_repository.dart';
import '../parent/data/viewed_student_context.dart';
import '../teacher_mobile/data/teacher_mobile_repository.dart';

const _assignmentStateNoDueDate = '__no_due_date__';
const _assignmentStateOverdue = '__overdue__';
const _assignmentStateDueSoon = '__due_soon__';
const _assignmentStateUpcoming = '__upcoming__';

final assignmentsFeedProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async {
    // Parent flow: /parent/assignments returns the flat list directly
    // (already aggregated server-side), so we skip the per-classroom
    // fan-out the student path does.
    final viewedStudentId = ref.watch(viewedStudentIdProvider);
    if (viewedStudentId != null) {
      final raw = await ref.read(parentRepositoryProvider)
          .getChildFeed('/parent/assignments', viewedStudentId);
      final list = raw is Map && raw['items'] is List ? raw['items'] as List : const [];
      return list
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList(growable: false);
    }

    // Aggregator first — `/student/assignments` returns every assignment
    // visible to this student (classroom + direct-target + cohort + grade)
    // in a single call. The per-classroom fan-out below misses everything
    // a teacher attaches by cohort/grade/student without picking a
    // courseId, which is the common case the user kept seeing as empty.
    final repo = ref.read(classroomsRepoProvider);
    try {
      final all = await repo.allStudentAssignments();
      if (all.isNotEmpty) {
        return all.map((m) {
          final mm = Map<String, dynamic>.from(m);
          return <String, dynamic>{
            ...mm,
            '_courseId': (mm['classroomId'] ?? '').toString(),
            '_courseName': (mm['classroomName'] ?? '').toString(),
            '_subject': (mm['subject'] ?? mm['classroomSubject'] ?? '').toString(),
            '_teacherName': (mm['teacherName'] ?? '').toString(),
          };
        }).toList(growable: false);
      }
    } catch (_) {
      // Aggregator missing on older API — fall through to legacy fan-out.
    }

    final classrooms = await ref.watch(orderedStudentClassroomsProvider.future);

    final results = await Future.wait(
      classrooms.map((classroom) async {
        final courseId = _stringValue(classroom, 'id');
        if (courseId.isEmpty) return const <Map<String, dynamic>>[];

        final response = await repo.assignments(courseId);
        final rawItems = _extractList(response, 'items');

        return rawItems.map((item) {
          return <String, dynamic>{
            ...item,
            '_courseId': courseId,
            '_courseName': _firstNonEmpty([
              _stringValue(classroom, 'name'),
              _stringValue(classroom, 'title'),
            ]),
            '_subject': _stringValue(classroom, 'subject'),
            '_teacherName': _firstNonEmpty([
              _stringValue(classroom, 'teacherName'),
              _stringValue(classroom, 'teacher'),
            ]),
          };
        }).toList(growable: false);
      }),
    );

    final items = results.expand((group) => group).toList(growable: false)
      ..sort((a, b) {
        final aDue = _parseFlexibleDate(_stringValue(a, 'dueAt'));
        final bDue = _parseFlexibleDate(_stringValue(b, 'dueAt'));
        if (aDue != null && bDue != null) {
          final byDue = aDue.compareTo(bDue);
          if (byDue != 0) return byDue;
        } else if (aDue != null) {
          return -1;
        } else if (bDue != null) {
          return 1;
        }

        final aCreated = _parseFlexibleDate(_stringValue(a, 'createdAt'));
        final bCreated = _parseFlexibleDate(_stringValue(b, 'createdAt'));
        if (aCreated != null && bCreated != null) {
          final byCreated = bCreated.compareTo(aCreated);
          if (byCreated != 0) return byCreated;
        } else if (aCreated != null) {
          return -1;
        } else if (bCreated != null) {
          return 1;
        }

        return _stringValue(a, 'title').compareTo(_stringValue(b, 'title'));
      });

    return items;
  },
);

String _stringValue(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return '';
  return value.toString().trim();
}

List<Map<String, dynamic>> _extractList(Map<String, dynamic> json, String key) {
  final raw = json[key];
  if (raw is! List) return const <Map<String, dynamic>>[];
  return raw
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

DateTime? _parseFlexibleDate(String? raw) {
  final value = (raw ?? '').trim();
  if (value.isEmpty) return null;

  final iso = DateTime.tryParse(value);
  if (iso != null) return iso;

  final slash = RegExp(r'^(\d{1,2})\/(\d{1,2})\/(\d{2,4})$').firstMatch(value);
  if (slash != null) {
    final first = int.tryParse(slash.group(1)!);
    final second = int.tryParse(slash.group(2)!);
    final yearRaw = int.tryParse(slash.group(3)!);
    if (first != null && second != null && yearRaw != null) {
      final year = yearRaw < 100 ? 2000 + yearRaw : yearRaw;
      if (second > 12) {
        return DateTime.tryParse(
          '$year-${first.toString().padLeft(2, '0')}-${second.toString().padLeft(2, '0')}',
        );
      }
      return DateTime.tryParse(
        '$year-${second.toString().padLeft(2, '0')}-${first.toString().padLeft(2, '0')}',
      );
    }
  }

  final dash = RegExp(r'^(\d{1,2})-(\d{1,2})-(\d{2,4})$').firstMatch(value);
  if (dash != null) {
    final first = int.tryParse(dash.group(1)!);
    final second = int.tryParse(dash.group(2)!);
    final yearRaw = int.tryParse(dash.group(3)!);
    if (first != null && second != null && yearRaw != null) {
      final year = yearRaw < 100 ? 2000 + yearRaw : yearRaw;
      if (first > 12) {
        return DateTime.tryParse(
          '$year-${second.toString().padLeft(2, '0')}-${first.toString().padLeft(2, '0')}',
        );
      }
      return DateTime.tryParse(
        '$year-${first.toString().padLeft(2, '0')}-${second.toString().padLeft(2, '0')}',
      );
    }
  }

  return null;
}

String _friendlyDateLabel(BuildContext context, String? raw) {
  final parsed = _parseFlexibleDate(raw);
  if (parsed == null) {
    final fallback = (raw ?? '').trim();
    return fallback.isEmpty
        ? AppLocalizations.of(context)!.assignmentsNoDueDate
        : fallback;
  }

  return MaterialLocalizations.of(context).formatMediumDate(parsed);
}

String _friendlyDateTimeLabel(BuildContext context, String? raw) {
  final parsed = _parseFlexibleDate(raw);
  if (parsed == null) {
    final fallback = (raw ?? '').trim();
    return fallback.isEmpty ? AppLocalizations.of(context)!.profileNotAvailable : fallback;
  }

  final hour = parsed.hour == 0 && parsed.minute == 0
      ? null
      : MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay.fromDateTime(parsed),
          alwaysUse24HourFormat: true,
        );
  final date = _friendlyDateLabel(context, raw);
  return hour == null ? date : '$date • $hour';
}

String _friendlyError(BuildContext context, Object error) {
  final l = AppLocalizations.of(context)!;
  final raw = error.toString().replaceFirst('Exception: ', '').trim();
  if (raw.isEmpty) {
    return l.assignmentsLoadError;
  }
  final lowered = raw.toLowerCase();
  if (lowered.contains('timeout')) {
    return l.assignmentsLoadTimeout;
  }
  if (lowered.contains('socket') || lowered.contains('network')) {
    return l.assignmentsLoadNetwork;
  }
  return raw;
}

String _statusForAssignment(Map<String, dynamic> assignment) {
  final due = _parseFlexibleDate(_stringValue(assignment, 'dueAt'));
  if (due == null) return _assignmentStateNoDueDate;

  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);
  final endOfSoon = startOfToday.add(const Duration(days: 7));
  final normalizedDue = DateTime(due.year, due.month, due.day);

  if (normalizedDue.isBefore(startOfToday)) return _assignmentStateOverdue;
  if (!normalizedDue.isAfter(endOfSoon)) return _assignmentStateDueSoon;
  return _assignmentStateUpcoming;
}

String _statusLabel(BuildContext context, String status) {
  final l = AppLocalizations.of(context)!;
  switch (status) {
    case _assignmentStateOverdue:
      return l.assignmentsStatusOverdue;
    case _assignmentStateDueSoon:
      return l.assignmentsStatusDueSoon;
    case _assignmentStateUpcoming:
      return l.assignmentsStatusUpcoming;
    case _assignmentStateNoDueDate:
    default:
      return l.assignmentsNoDueDate;
  }
}

Color _statusTone(BuildContext context, String status) {
  final cs = Theme.of(context).colorScheme;
  switch (status) {
    case _assignmentStateOverdue:
      return cs.errorContainer;
    case _assignmentStateDueSoon:
      return cs.tertiaryContainer;
    case _assignmentStateUpcoming:
      return cs.secondaryContainer;
    default:
      return cs.surfaceContainerHighest;
  }
}

String _previewBody(BuildContext context, Map<String, dynamic> assignment) {
  final body = _firstNonEmpty([
    _stringValue(assignment, 'body'),
    _stringValue(assignment, 'description'),
    _stringValue(assignment, 'instructions'),
  ]);
  if (body.isEmpty) {
    return AppLocalizations.of(context)!.assignmentsPreviewFallback;
  }
  return body.replaceAll(RegExp(r'\s+'), ' ');
}



class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  static const String _allSubjects = '__all_subjects__';
  static const String _allStates = '__all_states__';

  String _selectedSubject = _allSubjects;
  String _selectedState = _allStates;
  bool _showingPrevious = false;
  SemesterWindow? _selectedPast;

  List<Map<String, dynamic>> _filteredItems(List<Map<String, dynamic>> items) {
    return items.where((item) {
      final subject = _stringValue(item, '_subject');
      final status = _statusForAssignment(item);
      final matchesSubject = _selectedSubject == _allSubjects || subject == _selectedSubject;
      final matchesState = _selectedState == _allStates || status == _selectedState;
      return matchesSubject && matchesState;
    }).toList(growable: false);
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = _allSubjects;
      _selectedState = _allStates;
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(assignmentsFeedProvider);
    final l = AppLocalizations.of(context)!;

    // Refresh assignments list when teacher creates a new one
    ref.listen(realtimeEventProvider, (_, event) {
      if (event?.type == 'assignment_created') ref.invalidate(assignmentsFeedProvider);
    });

    return Scaffold(
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const _AssignmentsLoadingBody(),
        error: (error, stackTrace) => _AssignmentsErrorBody(
          subtitle: _friendlyError(context, error),
          onRetry: () => ref.invalidate(assignmentsFeedProvider),
        ),
        data: (items) {
          final subjects = items
              .map((item) => _stringValue(item, '_subject'))
              .where((value) => value.trim().isNotEmpty)
              .toSet()
              .toList()
            ..sort();
          final safeSubject = subjects.contains(_selectedSubject)
              ? _selectedSubject
              : _allSubjects;
          if (safeSubject != _selectedSubject) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _selectedSubject = safeSubject);
            });
          }

          const states = <String>[
            _assignmentStateDueSoon,
            _assignmentStateUpcoming,
            _assignmentStateOverdue,
            _assignmentStateNoDueDate,
          ];
          final filtered = _filteredItems(items);
          final semWindow = ref.watch(currentSemesterWindowProvider);
          final visible = visibleForSemester<Map<String, dynamic>>(
            filtered,
            (item) => _parseFlexibleDate(_stringValue(item, 'dueAt')) ??
                _parseFlexibleDate(_stringValue(item, 'createdAt')),
            semWindow,
            _showingPrevious,
            _selectedPast,
          );
          final dueSoonCount = items
              .where((item) => _statusForAssignment(item) == _assignmentStateDueSoon)
              .length;
          final overdueCount = items
              .where((item) => _statusForAssignment(item) == _assignmentStateOverdue)
              .length;
          final nextAssignment = items.isEmpty ? null : items.first;
          final hasActiveFilters = safeSubject != _allSubjects || _selectedState != _allStates;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(assignmentsFeedProvider);
              await ref.read(assignmentsFeedProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _HeroCard(
                  title: l.navAssignments,
                  subtitle: l.assignmentsHeroSubtitle,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.assignment_rounded,
                              label: l.total,
                              value: '${items.length}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.schedule_rounded,
                              label: l.assignmentsStatusDueSoon,
                              value: '$dueSoonCount',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.warning_amber_rounded,
                              label: l.assignmentsStatusOverdue,
                              value: '$overdueCount',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.menu_book_rounded,
                              label: l.assignmentsSubjectsMetric,
                              value: '${subjects.length}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SignalBanner(
                        icon: Icons.bolt_rounded,
                        title: nextAssignment == null
                            ? l.assignmentsNothingAssignedYet
                            : _statusLabel(context, _statusForAssignment(nextAssignment)),
                        body: nextAssignment == null
                            ? l.assignmentsNoAssignmentsForAccount
                            : l.assignmentsNextThingBody(
                                _stringValue(nextAssignment, 'title'),
                                _friendlyDateTimeLabel(
                                  context,
                                  _stringValue(nextAssignment, 'dueAt'),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  _EmptyStateCard(
                    title: l.classroomDetailNoAssignmentsTitle,
                    subtitle: l.assignmentsNoAssignmentsForAccount,
                    hint: l.assignmentsPullToCheckAgain,
                  )
                else ...[
                  _SectionCard(
                    title: l.filters,
                    subtitle: l.assignmentsFiltersSubtitle,
                    child: Column(
                      children: [
                        LiquidGlassDropdown<String>(
                          label: l.assignmentsSubjectLabel,
                          value: safeSubject,
                          items: [
                            LiquidGlassDropdownItem(
                              value: _allSubjects,
                              label: l.assignmentsAllSubjects,
                              icon: Icons.grid_view_rounded,
                            ),
                            ...subjects.map(
                              (subject) => LiquidGlassDropdownItem(
                                value: subject,
                                label: subject,
                                icon: Icons.menu_book_rounded,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedSubject = value);
                          },
                          searchHint: l.assignmentsSearchSubjects,
                        ),
                        const SizedBox(height: 10),
                        LiquidGlassDropdown<String>(
                          label: l.assignmentsStatusLabel,
                          value: _selectedState,
                          items: [
                            LiquidGlassDropdownItem(
                              value: _allStates,
                              label: l.assignmentsAllStatuses,
                              icon: Icons.filter_alt_rounded,
                            ),
                            ...states.map(
                              (state) => LiquidGlassDropdownItem(
                                value: state,
                                label: _statusLabel(context, state),
                                icon: state == _assignmentStateOverdue
                                    ? Icons.warning_rounded
                                    : state == _assignmentStateDueSoon
                                    ? Icons.schedule_rounded
                                    : state == _assignmentStateUpcoming
                                    ? Icons.upcoming_rounded
                                    : Icons.event_busy_rounded,
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedState = value);
                          },
                          searchHint: l.assignmentsSearchStatuses,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                l.assignmentsShowingSummary(visible.length, items.length),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            if (hasActiveFilters) ...[
                              const SizedBox(width: 12),
                              TextButton(
                                onPressed: _clearFilters,
                                child: Text(l.clear),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (semWindow != null) ...[
                    const SizedBox(height: 12),
                    SemesterFilterBar(
                      showingPrevious: _showingPrevious,
                      onChanged: (v) => setState(() { _showingPrevious = v; if (!v) _selectedPast = null; }),
                      selectedPast: _selectedPast,
                      onPastChanged: (w) => setState(() => _selectedPast = w),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (visible.isEmpty)
                    _EmptyStateCard(
                      title: l.assignmentsNoFilterMatchesTitle,
                      subtitle: l.assignmentsNoFilterMatchesSubtitle,
                      hint: hasActiveFilters
                          ? l.assignmentsClearFiltersHint
                          : l.assignmentsPullToCheckAgain,
                    )
                  else ...[
                    _SectionCard(
                      title: l.navAssignments,
                      subtitle: l.assignmentsListSubtitle,
                      child: Column(
                        children: visible
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _AssignmentCard(
                                  assignment: item,
                                  onTap: () => context.push(
                                    '/assignments/${_stringValue(item, 'id')}',
                                    extra: item,
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class AssignmentDetailScreen extends ConsumerStatefulWidget {
  const AssignmentDetailScreen({
    super.key,
    required this.assignmentId,
    this.initialAssignment,
  });

  final String assignmentId;
  final Map<String, dynamic>? initialAssignment;

  String get _courseId => _stringValue(initialAssignment ?? {}, '_courseId');

  @override
  ConsumerState<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends ConsumerState<AssignmentDetailScreen> {
  final List<_DraftAttachment> _draftAttachments = <_DraftAttachment>[];
  final _noteCtrl = TextEditingController();
  bool _submitting = false;
  bool _submitted = false;
  bool _initializedFromData = false;
  // Persisted submission (re-hydrated on entry so the student sees exactly
  // what they handed in, plus any grade / returned-for-re-solution note).
  List<Map<String, dynamic>> _submittedFiles = const [];
  String _submittedNote = '';
  String _statusValue = '';
  String _feedback = '';
  num? _grade;

  void _initFromAssignment(Map<String, dynamic> assignment) {
    if (_initializedFromData) return;
    _initializedFromData = true;
    final status = _stringValue(assignment, 'status').toUpperCase();
    final alreadySubmitted = assignment['submitted'] == true && status != 'RETURNED';
    final sub = assignment['submission'];
    final subMap = sub is Map ? Map<String, dynamic>.from(sub) : const <String, dynamic>{};
    final rawFiles = subMap['files'];
    final files = rawFiles is List
        ? rawFiles.whereType<Map>().map((f) => Map<String, dynamic>.from(f)).toList()
        : <Map<String, dynamic>>[];
    final note = (subMap['note'] ?? '').toString();
    final feedback = (subMap['feedback'] ?? assignment['feedback'] ?? '').toString();
    final grade = subMap['grade'] ?? assignment['grade'];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _submitted = alreadySubmitted;
        _submittedFiles = files;
        _submittedNote = note;
        _statusValue = status;
        _feedback = feedback;
        _grade = grade is num ? grade : num.tryParse('${grade ?? ''}');
        // If the teacher returned it for re-solution, pre-fill the prior note
        // so the student can revise rather than retype from scratch.
        if (status == 'RETURNED' && note.isNotEmpty && _noteCtrl.text.isEmpty) {
          _noteCtrl.text = note;
        }
      });
    });
  }

  Future<void> _pickFiles() async {
    final picked = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (!mounted || picked == null || picked.files.isEmpty) return;

    setState(() {
      for (final file in picked.files) {
        final path = (file.path ?? '').trim();
        final name = (file.name).trim();
        if (path.isEmpty || name.isEmpty) continue;
        final exists = _draftAttachments.any((item) => item.path == path);
        if (exists) continue;
        _draftAttachments.add(
          _DraftAttachment(
            path: path,
            name: name,
            sizeBytes: file.size,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _stageSubmission() async {
    if (_submitting) return;

    final note = _noteCtrl.text.trim();
    final hasFiles = _draftAttachments.isNotEmpty;

    // Allow submitting with just a note, just files, or both. Only block if truly empty.
    if (!hasFiles && note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.studentAssignmentValidationRequired)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      // Upload any attached files to get server-hosted URLs first.
      final teacherRepo = ref.read(teacherMobileRepositoryProvider);
      final uploadedFiles = <Map<String, String>>[];
      for (final a in _draftAttachments) {
        try {
          final res = await teacherRepo.uploadAttachmentFile(a.path, a.name);
          final url = (res['url'] ?? res['fileUrl'] ?? '').toString().trim();
          if (url.isNotEmpty) uploadedFiles.add({'url': url, 'name': a.name});
        } catch (_) {
          // If a single file fails, skip it and continue with the rest.
        }
      }

      // If the student added files but all uploads failed, warn them.
      if (hasFiles && uploadedFiles.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.studentAssignmentUploadFailed)),
        );
        return;
      }

      final courseId = widget._courseId;
      final repo = ref.read(classroomsRepoProvider);
      if (courseId.isNotEmpty) {
        // Classroom-scoped assignment.
        await repo.submitAssignment(
          courseId,
          widget.assignmentId,
          note: note.isNotEmpty ? note : null,
          files: uploadedFiles,
        );
      } else {
        // Teacher-wide assignment (no classroom id) — the feed's default.
        // Previously this branch did nothing, so hand-ins silently never
        // persisted. Now it posts to /student/assignments/:id/submit.
        await repo.submitTeacherAssignment(
          widget.assignmentId,
          note: note.isNotEmpty ? note : null,
          files: uploadedFiles,
        );
      }
      if (!mounted) return;
      setState(() { _submitted = true; _draftAttachments.clear(); _noteCtrl.clear(); });
      // Invalidate so the assignments list shows "submitted" on next visit
      ref.invalidate(assignmentsFeedProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.studentAssignmentSubmittedSnackbar)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.studentAssignmentSubmitFailed)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(assignmentsFeedProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const _DetailLoadingBody(),
        error: (error, stackTrace) => _DetailErrorBody(
          subtitle: _friendlyError(context, error),
          onRetry: () => ref.invalidate(assignmentsFeedProvider),
        ),
        data: (items) {
          final assignment = widget.initialAssignment != null &&
                  _stringValue(widget.initialAssignment!, 'id') == widget.assignmentId
              ? widget.initialAssignment!
              : items.firstWhere(
                  (item) => _stringValue(item, 'id') == widget.assignmentId,
                  orElse: () => <String, dynamic>{},
                );

          _initFromAssignment(assignment);

          if (assignment.isEmpty) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailTopBar(onBack: () => context.pop()),
                    const SizedBox(height: 24),
                    _EmptyStateCard(
                      title: l.assignmentsUnavailableTitle,
                      subtitle: l.assignmentsUnavailableSubtitle,
                      hint: l.assignmentsUnavailableHint,
                    ),
                  ],
                ),
              ),
            );
          }

          final dueLabel = _friendlyDateTimeLabel(context, _stringValue(assignment, 'dueAt'));
          final status = _statusForAssignment(assignment);
          final body = _previewBody(context, assignment);
          final courseName = _stringValue(assignment, '_courseName');
          final subject = _stringValue(assignment, '_subject');
          final teacherName = _stringValue(assignment, '_teacherName');

          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    20, 16, 20,
                    24 + MediaQuery.of(context).padding.bottom,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                          [
                            _DetailTopBar(onBack: () => context.pop()),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outlineVariant,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _Chip(
                                        label: _statusLabel(context, status),
                                        backgroundColor: _statusTone(context, status),
                                        foregroundColor: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      if (subject.isNotEmpty)
                                        _Chip(
                                          label: subject,
                                          backgroundColor: Theme.of(context).colorScheme.surface,
                                          foregroundColor: Theme.of(context).colorScheme.onSurface,
                                        ),
                                      if (courseName.isNotEmpty)
                                        _Chip(
                                          label: courseName,
                                          backgroundColor: Theme.of(context).colorScheme.surface,
                                          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _stringValue(assignment, 'title').isEmpty
                                        ? l.classroomDetailAssignmentFallback
                                        : _stringValue(assignment, 'title'),
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    body,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _SignalBanner(
                                    icon: Icons.schedule_rounded,
                                    title: dueLabel,
                                    body: status == _assignmentStateOverdue
                                        ? l.assignmentsOverdueBannerBody
                                        : l.assignmentsWorkAreaBannerBody,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: l.assignmentsDetailsSectionTitle,
                              subtitle: l.assignmentsDetailsSectionSubtitle,
                              child: Column(
                                children: [
                                  _DetailRow(label: l.assignmentsDetailDueLabel, value: dueLabel),
                                  _DetailRow(
                                    label: l.assignmentsSubjectLabel,
                                    value: subject.isEmpty ? l.profileNotAvailable : subject,
                                  ),
                                  _DetailRow(
                                    label: l.assignmentsDetailTeacherLabel,
                                    value: teacherName.isEmpty ? l.profileNotAvailable : teacherName,
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: l.assignmentsInstructionsTitle,
                              subtitle: l.assignmentsInstructionsSubtitle,
                              child: Text(
                                body,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  height: 1.55,
                                ),
                              ),
                            ),
                            // Teacher-attached files
                            Builder(builder: (context) {
                              final rawAtt = assignment['attachments'];
                              // De-dupe by url+name: some assignments were saved
                              // with the same file listed twice, which showed up
                              // as duplicate pills for the student.
                              final seen = <String>{};
                              final List<Map<String, dynamic>> pills = rawAtt is List
                                  ? rawAtt
                                      .whereType<Map>()
                                      .map((a) => Map<String, dynamic>.from(a))
                                      .where((a) {
                                        // De-dupe by URL first (same file is
                                        // sometimes stored under url + fileUrl
                                        // with different name/title fields);
                                        // fall back to name/title when no URL.
                                        final url = (a['url'] ?? a['fileUrl'] ?? '')
                                            .toString()
                                            .trim()
                                            .toLowerCase();
                                        final key = url.isNotEmpty
                                            ? url
                                            : (a['name'] ?? a['title'] ?? '')
                                                .toString()
                                                .trim()
                                                .toLowerCase();
                                        return key.isEmpty || seen.add(key);
                                      })
                                      .toList()
                                  : <Map<String, dynamic>>[];
                              if (pills.isEmpty) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 0, bottom: 16),
                                child: _SectionCard(
                                  title: AppLocalizations.of(context)!.teacherMaterialAttachmentsTitle,
                                  subtitle: AppLocalizations.of(context)!.studentFilesSharedByTeacher,
                                  child: AttachmentPills(attachments: pills),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            // Parents see the assignment + attachments read-only.
                            // The "Your submission" + Hand-in flow only renders
                            // when this is the student themselves (viewedStudentId
                            // is null — non-null means a parent is viewing a child).
                            if (ref.watch(viewedStudentIdProvider) != null)
                              const SizedBox.shrink()
                            else
                            _SectionCard(
                              title: AppLocalizations.of(context)!.studentYourSubmission,
                              subtitle: _submitted
                                  ? l.assignmentsScreenAlreadyHandedIn
                                  : l.assignmentsScreenAddNoteOrFiles,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_submitted) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF22C55E)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFF22C55E)
                                                .withValues(alpha: 0.4)),
                                      ),
                                      child: Row(children: [
                                        const Icon(Icons.check_circle_rounded,
                                            size: 18, color: Color(0xFF22C55E)),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(AppLocalizations.of(context)!.studentAssignmentHandedInBadge,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF22C55E))),
                                        ),
                                        Text(
                                          _friendlyDateTimeLabel(context,
                                              _stringValue(assignment, 'submittedAt')),
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant),
                                        ),
                                      ]),
                                    ),
                                    if (_submittedNote.trim().isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(_submittedNote.trim(),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              height: 1.4)),
                                    ],
                                    if (_submittedFiles.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      AttachmentPills(attachments: _submittedFiles),
                                    ],
                                    if (_grade != null) ...[
                                      const SizedBox(height: 12),
                                      Row(children: [
                                        const Icon(Icons.grade_rounded,
                                            size: 18, color: Color(0xFF6366F1)),
                                        const SizedBox(width: 8),
                                        Text(l.assignmentsScreenGradeLabel('${_grade! % 1 == 0 ? _grade!.toInt() : _grade!}'),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800)),
                                      ]),
                                    ],
                                    if (_feedback.trim().isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(l.assignmentsScreenFeedbackLabel(_feedback.trim()),
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              height: 1.4)),
                                    ],
                                  ] else ...[
                                    if (_statusValue == 'RETURNED' && _feedback.trim().isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B)
                                              .withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                              color: const Color(0xFFF59E0B)
                                                  .withValues(alpha: 0.4)),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.replay_rounded,
                                                size: 18,
                                                color: Color(0xFFB45309)),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      l.assignmentsScreenReturnedForResolution,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w800,
                                                          color: Color(
                                                              0xFFB45309))),
                                                  const SizedBox(height: 2),
                                                  Text(_feedback.trim(),
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Theme.of(
                                                                  context)
                                                              .colorScheme
                                                              .onSurfaceVariant)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    // Note field — optional text comment with submission
                                    TextField(
                                      controller: _noteCtrl,
                                      maxLines: 3,
                                      minLines: 1,
                                      textCapitalization: TextCapitalization.sentences,
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!.studentAssignmentAddNoteOptional,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed: _pickFiles,
                                      icon: const Icon(Icons.attach_file_rounded,
                                          size: 18),
                                      label: Text(_draftAttachments.isEmpty
                                          ? l.assignmentsScreenAttachFile
                                          : l.assignmentsScreenAddMoreFiles),
                                    ),
                                    if (_draftAttachments.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _draftAttachments
                                            .map((a) => _DraftChip(
                                                  attachment: a,
                                                  onRemove: () => setState(() =>
                                                      _draftAttachments.remove(a)),
                                                ))
                                            .toList(growable: false),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: _submitting
                                            ? null
                                            : _stageSubmission,
                                        icon: _submitting
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white),
                                              )
                                            : const Icon(Icons.send_rounded,
                                                size: 18),
                                        label: Text(_submitting
                                            ? l.assignmentsScreenHandingIn
                                            : l.assignmentsScreenHandIn),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
          );
        },
      ),
    );
  }
}

class _DraftAttachment {
  const _DraftAttachment({
    required this.path,
    required this.name,
    required this.sizeBytes,
  });

  final String path;
  final String name;
  final int sizeBytes;
}

class _AssignmentCard extends StatelessWidget {
  const _AssignmentCard({required this.assignment, required this.onTap});

  final Map<String, dynamic> assignment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final status = _statusForAssignment(assignment);
    final courseName = _stringValue(assignment, '_courseName');
    final subject = _stringValue(assignment, '_subject');
    final l = AppLocalizations.of(context)!;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: LiquidGlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(24),
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _stringValue(assignment, 'title').isEmpty
                        ? l.classroomDetailAssignmentFallback
                        : _stringValue(assignment, 'title'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _previewBody(context, assignment),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (assignment['submitted'] == true)
                  _Chip(
                    label: l.studentAssignmentHandedInBadge,
                    backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFF22C55E),
                  )
                else
                  _Chip(
                    label: _statusLabel(context, status),
                    backgroundColor: _statusTone(context, status),
                    foregroundColor: cs.onSurface,
                  ),
                if (subject.isNotEmpty)
                  _Chip(
                    label: subject,
                    backgroundColor: cs.surface,
                    foregroundColor: cs.onSurface,
                  ),
                if (courseName.isNotEmpty)
                  _Chip(
                    label: courseName,
                    backgroundColor: cs.surface,
                    foregroundColor: cs.onSurfaceVariant,
                  ),
                _Chip(
                  label: _friendlyDateLabel(context, _stringValue(assignment, 'dueAt')),
                  backgroundColor: cs.surface,
                  foregroundColor: cs.onSurfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(26),
      color: cs.primaryContainer,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      color: cs.primaryContainer,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(18),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SignalBanner extends StatelessWidget {
  const _SignalBanner({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(color: cs.onSurfaceVariant, height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: cs.outlineVariant),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: foregroundColor ?? cs.onSurface,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({
    required this.title,
    required this.subtitle,
    required this.hint,
  });

  final String title;
  final String subtitle;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, height: 1.35)),
          const SizedBox(height: 12),
          _Chip(
            label: hint,
            backgroundColor: cs.surface,
            foregroundColor: cs.onSurface,
          ),
        ],
      ),
    );
  }
}

class _AssignmentsLoadingBody extends StatelessWidget {
  const _AssignmentsLoadingBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _HeroCard(
          title: AppLocalizations.of(context)!.navAssignments,
          subtitle: AppLocalizations.of(context)!.assignmentsLoadingSubtitle,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _LoadingTile()),
                  SizedBox(width: 10),
                  Expanded(child: _LoadingTile()),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _LoadingTile()),
                  SizedBox(width: 10),
                  Expanded(child: _LoadingTile()),
                ],
              ),
              SizedBox(height: 14),
              _LoadingBanner(),
            ],
          ),
        ),
        SizedBox(height: 16),
        _LoadingSectionCard(),
      ],
    );
  }
}

class _AssignmentsErrorBody extends StatelessWidget {
  const _AssignmentsErrorBody({required this.subtitle, required this.onRetry});

  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        _HeroCard(
          title: l.assignmentsUnavailableTitle,
          subtitle: subtitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.assignmentsPullToRefreshRetry,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.retry),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onBack,
          child: SizedBox(
            width: 44,
            height: 44,
            child: LiquidGlassCard(
              padding: EdgeInsets.zero,
              borderRadius: BorderRadius.circular(16),
              color: cs.surfaceContainerLow,
              border: Border.all(color: cs.outlineVariant),
              child: const Center(child: Icon(Icons.arrow_back_rounded, size: 20)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            AppLocalizations.of(context)!.classroomDetailAssignmentFallback,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12, top: 2),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                child: Text(
                  label,
                  style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(value.isEmpty ? AppLocalizations.of(context)!.profileNotAvailable : value),
              ),
            ],
          ),
          if (!isLast) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: cs.outlineVariant,
            ),
          ],
        ],
      ),
    );
  }
}

class _DraftChip extends StatelessWidget {
  const _DraftChip({required this.attachment, required this.onRemove});

  final _DraftAttachment attachment;
  final VoidCallback onRemove;

  String _sizeLabel(BuildContext context) {
    final size = attachment.sizeBytes;
    if (size <= 0) return AppLocalizations.of(context)!.assignmentsFileSizeUnknown;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: cs.outlineVariant),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.insert_drive_file_rounded, size: 18),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  _sizeLabel(context),
                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.assignmentsRemoveAttachment,
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 92,
      child: LiquidGlassCard(
        borderRadius: BorderRadius.circular(18),
        color: cs.surfaceContainerLow,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LinearProgressIndicator(minHeight: 4),
          SizedBox(height: 12),
          _LoadingLine(widthFactor: 0.7),
          SizedBox(height: 8),
          _LoadingLine(widthFactor: 0.95),
        ],
      ),
    );
  }
}

class _LoadingSectionCard extends StatelessWidget {
  const _LoadingSectionCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(24),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LoadingLine(widthFactor: 0.3),
          SizedBox(height: 10),
          _LoadingLine(widthFactor: 0.85),
          SizedBox(height: 16),
          _LoadingTile(),
          SizedBox(height: 10),
          _LoadingTile(),
        ],
      ),
    );
  }
}

class _LoadingLine extends StatelessWidget {
  const _LoadingLine({required this.widthFactor});

  final double widthFactor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _DetailLoadingBody extends StatelessWidget {
  const _DetailLoadingBody();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          children: const [
            _DetailTopBar(onBack: _noop),
            SizedBox(height: 18),
            Expanded(child: _LoadingSectionCard()),
          ],
        ),
      ),
    );
  }
}

class _DetailErrorBody extends StatelessWidget {
  const _DetailErrorBody({required this.subtitle, required this.onRetry});

  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailTopBar(onBack: () => context.pop()),
            const SizedBox(height: 24),
            _SectionCard(
              title: l.assignmentsUnavailableTitle,
              subtitle: subtitle,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.retry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _noop() {}
