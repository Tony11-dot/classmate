import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../core/semester/school_semester.dart';
import '../../core/util/friendly_date.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import '../../ui/widgets/semester_filter_bar.dart';
import '../classrooms/providers/classrooms_providers.dart';
import '../classrooms/providers/classrooms_repo_provider.dart';
import '../parent/data/parent_repository.dart';
import '../parent/data/viewed_student_context.dart';
import '../../ui/widgets/cm_loading.dart';

final meetingsFeedProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async {
    // Parent flow: server pre-aggregates meetings across the child's
    // classrooms into a single response. Skip the per-classroom fan-out
    // that the student path does — same final shape, half the round-trips.
    final viewedStudentId = ref.watch(viewedStudentIdProvider);
    if (viewedStudentId != null) {
      final raw = await ref.read(parentRepositoryProvider)
          .getChildFeed('/parent/meetings', viewedStudentId);
      final list = raw is Map && raw['items'] is List ? raw['items'] as List : const [];
      return list
          .whereType<Map>()
          .map((m) {
            final mm = Map<String, dynamic>.from(m);
            // Rebadge classroom* keys to the underscore-prefixed schema
            // the rest of this screen reads.
            return <String, dynamic>{
              ...mm,
              '_courseId': mm['classroomId'] ?? '',
              '_courseName': mm['classroomName'] ?? '',
              '_subject': mm['classroomSubject'] ?? '',
            };
          })
          .toList(growable: false);
    }

    // Student flow: hit the aggregator that already merges classroom
    // meetings AND direct-target TeacherMeeting rows. Saves N-classroom
    // round-trips AND surfaces meetings created without a classroomId —
    // those previously fell through the per-classroom fan-out below.
    final repo = ref.read(classroomsRepoProvider);
    try {
      final all = await repo.allStudentMeetings();
      return all.map((m) {
        final mm = Map<String, dynamic>.from(m);
        return <String, dynamic>{
          ...mm,
          '_courseId': (mm['classroomId'] ?? '').toString(),
          '_courseName': (mm['classroomName'] ?? '').toString(),
          '_subject': (mm['classroomSubject'] ?? mm['subject'] ?? '').toString(),
        };
      }).toList(growable: false);
    } catch (_) {
      // Fall through to legacy per-classroom fan-out if the aggregator
      // is missing on an older API (defensive — production has it).
    }
    final classrooms = await ref.watch(orderedStudentClassroomsProvider.future);

    final results = await Future.wait(
      classrooms.map((classroom) async {
        final courseId = _stringValue(classroom, 'id');
        if (courseId.isEmpty) return const <Map<String, dynamic>>[];

        final response = await repo.meetings(courseId);
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
        final aUpdated = _parseFlexibleDate(_stringValue(a, 'updatedAt'));
        final bUpdated = _parseFlexibleDate(_stringValue(b, 'updatedAt'));
        if (aUpdated != null && bUpdated != null) {
          final byUpdated = bUpdated.compareTo(aUpdated);
          if (byUpdated != 0) return byUpdated;
        } else if (aUpdated != null) {
          return -1;
        } else if (bUpdated != null) {
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

        final aTitle = _stringValue(a, 'title');
        final bTitle = _stringValue(b, 'title');
        return aTitle.compareTo(bTitle);
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

const String _meetingAccessReady = '__meeting_access_ready__';
const String _meetingAccessNoLink = '__meeting_access_no_link__';

String _friendlyDateTimeLabel(BuildContext context, String? raw) {
  final parsed = _parseFlexibleDate(raw);
  if (parsed == null && (raw ?? '').trim().isEmpty) {
    return AppLocalizations.of(context)!.profileNotAvailable;
  }
  // A pure date (midnight) shows date-only; otherwise full timestamp.
  if (parsed != null && parsed.hour == 0 && parsed.minute == 0) {
    return FriendlyDate.date(raw);
  }
  return FriendlyDate.dateTime(raw);
}

String _friendlyError(BuildContext context, Object error) {
  final l = AppLocalizations.of(context)!;
  final raw = error.toString().replaceFirst('Exception: ', '').trim();
  if (raw.isEmpty) {
    return l.meetingsLoadError;
  }
  final lowered = raw.toLowerCase();
  if (lowered.contains('timeout')) {
    return l.meetingsLoadTimeout;
  }
  if (lowered.contains('socket') || lowered.contains('network')) {
    return l.meetingsLoadNetwork;
  }
  return raw;
}

String _displayMeetingTitle(BuildContext context, Map<String, dynamic> meeting) {
  final title = _stringValue(meeting, 'title');
  return title.isEmpty ? AppLocalizations.of(context)!.classroomDetailMeetingFallback : title;
}

String _meetingAccessValue(Map<String, dynamic> meeting) {
  return _normalizedMeetingUri(_stringValue(meeting, 'link')) == null
      ? _meetingAccessNoLink
      : _meetingAccessReady;
}

String _meetingAccessLabel(BuildContext context, String value) {
  final l = AppLocalizations.of(context)!;
  switch (value) {
    case _meetingAccessReady:
      return l.meetingsAccessReady;
    case _meetingAccessNoLink:
      return l.meetingsAccessNoLink;
    default:
      return value;
  }
}

String _meetingPreview(BuildContext context, Map<String, dynamic> meeting) {
  final l = AppLocalizations.of(context)!;
  final courseName = _stringValue(meeting, '_courseName');
  final subject = _stringValue(meeting, '_subject');
  final createdBy = _firstNonEmpty([
    _stringValue(meeting, '_teacherName'),
    _stringValue(meeting, 'createdBy'),
  ]);
  final parts = <String>[];
  if (courseName.isNotEmpty) parts.add(courseName);
  if (subject.isNotEmpty) parts.add(subject);
  if (createdBy.isNotEmpty) parts.add(l.meetingsSharedByValue(createdBy));
  if (parts.isEmpty) {
    return l.meetingsPreviewFallback;
  }
  return '${parts.join(' • ')}.';
}

String _meetingFilterSummary(
  BuildContext context, {
  required int shown,
  required int total,
  required String subjectValue,
  required String accessValue,
  required String allSubjectsValue,
  required String allAccessValue,
}) {
  final l = AppLocalizations.of(context)!;
  final subjectSegment = subjectValue == allSubjectsValue
      ? ''
      : l.meetingsSummarySubjectSegment(subjectValue);
  final accessSegment = accessValue == allAccessValue
      ? ''
      : l.meetingsSummaryAccessSegment(_meetingAccessLabel(context, accessValue));
  return l.meetingsShowingSummary(shown, total, subjectSegment, accessSegment);
}

Uri? _normalizedMeetingUri(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;

  Uri? uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) {
    uri = Uri.tryParse('https://$trimmed');
  }
  if (uri == null || uri.host.isEmpty) return null;
  if (uri.scheme != 'http' && uri.scheme != 'https') return null;
  return uri;
}

class MeetingsScreen extends ConsumerStatefulWidget {
  const MeetingsScreen({super.key});

  @override
  ConsumerState<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends ConsumerState<MeetingsScreen> {
  static const String _allSubjects = '__all_subjects__';
  static const String _allAccessStates = '__all_access_states__';

  String _selectedSubject = _allSubjects;
  String _selectedAccessState = _allAccessStates;
  bool _showingPrevious = false;
  SemesterWindow? _selectedPast;

  List<Map<String, dynamic>> _filteredItems(List<Map<String, dynamic>> items) {
    return items.where((item) {
      final subject = _stringValue(item, '_subject');
      final access = _meetingAccessValue(item);
      final matchesSubject = _selectedSubject == _allSubjects || subject == _selectedSubject;
      final matchesAccess =
          _selectedAccessState == _allAccessStates || access == _selectedAccessState;
      return matchesSubject && matchesAccess;
    }).toList(growable: false);
  }

  void _clearFilters() {
    setState(() {
      _selectedSubject = _allSubjects;
      _selectedAccessState = _allAccessStates;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(meetingsFeedProvider);

    return Scaffold(
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const _MeetingsLoadingBody(),
        error: (error, stackTrace) => _MeetingsErrorBody(
          subtitle: _friendlyError(context, error),
          onRetry: () => ref.invalidate(meetingsFeedProvider),
        ),
        data: (items) {
          final subjects = items
              .map((item) => _stringValue(item, '_subject'))
              .where((value) => value.isNotEmpty)
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

          final filtered = _filteredItems(items);
          // Semester split (by meeting date) — only when the school configured
          // semesters; otherwise window is null and everything stays in one list.
          final semWindow = ref.watch(currentSemesterWindowProvider);
          final visible = visibleForSemester<Map<String, dynamic>>(
            filtered,
            (m) => _parseFlexibleDate(_stringValue(m, 'startsAt')) ??
                _parseFlexibleDate(_stringValue(m, 'updatedAt')) ??
                _parseFlexibleDate(_stringValue(m, 'createdAt')),
            semWindow,
            _showingPrevious,
            _selectedPast,
          );
          final joinReadyCount = items
        .where((item) => _meetingAccessValue(item) == _meetingAccessReady)
              .length;
          final noLinkCount = items.length - joinReadyCount;
          final activeMeeting = items.isEmpty ? null : items.first;
          final hasActiveFilters =
              safeSubject != _allSubjects || _selectedAccessState != _allAccessStates;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(meetingsFeedProvider);
              await ref.read(meetingsFeedProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                _HeroCard(
                  title: l.navMeetings,
                  subtitle: l.meetingsHeroSubtitle,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.video_call_rounded,
                              label: l.total,
                              value: '${items.length}',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.link_rounded,
                              label: l.meetingsJoinReadyMetric,
                              value: '$joinReadyCount',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              icon: Icons.link_off_rounded,
                              label: l.meetingsNoLinkMetric,
                              value: '$noLinkCount',
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
                        title: activeMeeting == null
                            ? l.meetingsNoPostedTitle
                            : _meetingAccessLabel(context, _meetingAccessValue(activeMeeting)),
                        body: activeMeeting == null
                          ? l.meetingsEmptyForAccount
                            : l.meetingsLatestBody(
                                _displayMeetingTitle(context, activeMeeting),
                                _friendlyDateTimeLabel(
                                  context,
                                  _stringValue(activeMeeting, 'updatedAt'),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (items.isEmpty)
                  _EmptyStateCard(
                    title: l.classroomDetailNoMeetingsTitle,
                    subtitle: l.classroomDetailNoMeetingsSubtitle,
                    hint: l.meetingsPullToRefreshHint,
                  )
                else ...[
                  _SectionCard(
                    title: l.filters,
                    subtitle: l.meetingsFiltersSubtitle,
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
                          label: l.meetingsAccessLabel,
                          value: _selectedAccessState,
                          items: [
                            LiquidGlassDropdownItem(
                              value: _allAccessStates,
                              label: l.meetingsAllMeetings,
                              icon: Icons.filter_alt_rounded,
                            ),
                            LiquidGlassDropdownItem(
                              value: _meetingAccessReady,
                              label: l.meetingsAccessReady,
                              icon: Icons.link_rounded,
                            ),
                            LiquidGlassDropdownItem(
                              value: _meetingAccessNoLink,
                              label: l.meetingsAccessNoLinkYet,
                              icon: Icons.link_off_rounded,
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedAccessState = value);
                          },
                          searchHint: l.meetingsAccessSearchHint,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _meetingFilterSummary(
                                  context,
                                  shown: filtered.length,
                                  total: items.length,
                                  subjectValue: safeSubject,
                                  accessValue: _selectedAccessState,
                                  allSubjectsValue: _allSubjects,
                                  allAccessValue: _allAccessStates,
                                ),
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
                  const SizedBox(height: 16),
                  SemesterFilterBar(
                    visible: semWindow != null,
                    showingPrevious: _showingPrevious,
                    onChanged: (v) => setState(() { _showingPrevious = v; if (!v) _selectedPast = null; }),
                    selectedPast: _selectedPast,
                    onPastChanged: (w) => setState(() => _selectedPast = w),
                  ),
                  if (visible.isEmpty)
                    _EmptyStateCard(
                      title: l.meetingsNoMatchTitle,
                      subtitle: l.meetingsNoMatchSubtitle,
                      hint: hasActiveFilters ? l.announcementsClearFiltersHint : l.meetingsPullToRefreshHint,
                    )
                  else
                    _SectionCard(
                      title: l.navMeetings,
                      subtitle: l.meetingsListSubtitle,
                      child: ShowMoreList(
                        children: visible
                            .map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _MeetingCard(
                                  meeting: item,
                                  onTap: () => context.push(
                                    '/meetings/${_stringValue(item, 'id')}',
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
            ),
          );
        },
      ),
    );
  }
}

class MeetingDetailScreen extends ConsumerStatefulWidget {
  const MeetingDetailScreen({
    super.key,
    required this.meetingId,
    this.initialMeeting,
  });

  final String meetingId;
  final Map<String, dynamic>? initialMeeting;

  @override
  ConsumerState<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends ConsumerState<MeetingDetailScreen> {
  bool _openingLink = false;

  Future<void> _openMeetingLink(String raw) async {
    if (_openingLink) return;
    final l = AppLocalizations.of(context)!;
    final uri = _normalizedMeetingUri(raw);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.meetingsNoValidLinkAttached)),
      );
      return;
    }

    setState(() => _openingLink = true);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    setState(() => _openingLink = false);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.meetingsCouldNotOpenLink)),
      );
    }
  }

  void _copyMeetingLink(String raw) {
    final l = AppLocalizations.of(context)!;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.meetingsNoLinkToCopy)),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: trimmed));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.meetingsLinkCopied)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final async = ref.watch(meetingsFeedProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: async.when(
        skipLoadingOnRefresh: true,
        loading: () => const _DetailLoadingBody(),
        error: (error, stackTrace) => _DetailErrorBody(
          subtitle: _friendlyError(context, error),
          onRetry: () => ref.invalidate(meetingsFeedProvider),
        ),
        data: (items) {
          final meeting = widget.initialMeeting != null &&
                  _stringValue(widget.initialMeeting!, 'id') == widget.meetingId
              ? widget.initialMeeting!
              : items.firstWhere(
                  (item) => _stringValue(item, 'id') == widget.meetingId,
                  orElse: () => <String, dynamic>{},
                );

          if (meeting.isEmpty) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailTopBar(onBack: () => context.pop()),
                    const SizedBox(height: 24),
                    _EmptyStateCard(
                      title: l.meetingsUnavailableTitle,
                      subtitle: l.meetingsUnavailableSubtitle,
                      hint: l.meetingsUnavailableHint,
                    ),
                  ],
                ),
              ),
            );
          }

          final link = _stringValue(meeting, 'link');
          final normalizedLink = _normalizedMeetingUri(link);
          final courseName = _stringValue(meeting, '_courseName');
          final subject = _stringValue(meeting, '_subject');
          final teacherName = _firstNonEmpty([
            _stringValue(meeting, '_teacherName'),
            _stringValue(meeting, 'createdBy'),
          ]);
          final accessLabel = _meetingAccessLabel(context, _meetingAccessValue(meeting));

          return SafeArea(
            bottom: false,
            child: Stack(
              children: [
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            _DetailTopBar(onBack: () => context.pop()),
                            const SizedBox(height: 18),
                            LiquidGlassCard(
                              padding: const EdgeInsets.all(20),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outlineVariant,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _Chip(
                                        label: accessLabel,
                                        backgroundColor: (normalizedLink == null
                                                ? Theme.of(context).colorScheme.errorContainer
                                                : Theme.of(context).colorScheme.secondaryContainer)
                                            .withValues(alpha: 0.88),
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
                                    _displayMeetingTitle(context, meeting),
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _meetingPreview(context, meeting),
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      height: 1.45,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  _SignalBanner(
                                    icon: normalizedLink == null ? Icons.link_off_rounded : Icons.link_rounded,
                                    title: normalizedLink == null ? l.meetingsNoLinkAttachedYet : l.meetingsAttachedLinkTitle,
                                    body: normalizedLink == null
                                        ? l.meetingsAttachedLinkMissingBody
                                        : normalizedLink.toString(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: l.meetingsDetailsTitle,
                              subtitle: l.meetingsDetailsSubtitle,
                              child: Column(
                                children: [
                                  _DetailRow(
                                    label: l.classroomDetailTabPeople == l.classroomDetailTabPeople ? l.meetingsDetailClassroomLabel : l.meetingsDetailClassroomLabel,
                                    value: courseName.isEmpty ? l.profileNotAvailable : courseName,
                                  ),
                                  _DetailRow(
                                    label: l.assignmentsSubjectLabel,
                                    value: subject.isEmpty ? l.profileNotAvailable : subject,
                                  ),
                                  _DetailRow(
                                    label: l.meetingsSharedByLabel,
                                    value: teacherName.isEmpty ? l.profileNotAvailable : teacherName,
                                  ),
                                  _DetailRow(
                                    label: l.announcementsCreatedLabel,
                                    value: _friendlyDateTimeLabel(context, _stringValue(meeting, 'createdAt')),
                                  ),
                                  _DetailRow(
                                    label: l.assignmentsDetailUpdatedLabel,
                                    value: _friendlyDateTimeLabel(context, _stringValue(meeting, 'updatedAt')),
                                  ),
                                  _DetailRow(
                                    label: l.meetingsAccessLabel,
                                    value: accessLabel,
                                  ),
                                  _DetailRow(
                                    label: l.meetingsIdLabel,
                                    value: _stringValue(meeting, 'id'),
                                    isLast: true,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _SectionCard(
                              title: l.meetingsAttachedLinkTitle,
                              subtitle: l.meetingsAttachedLinkSubtitle,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LiquidGlassCard(
                                    padding: const EdgeInsets.all(14),
                                    borderRadius: BorderRadius.circular(18),
                                    color: Theme.of(context).colorScheme.surface,
                                    child: Text(
                                      link.isEmpty ? l.meetingsNoLinkAttachedYet : link,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: normalizedLink == null
                                            ? null
                                            : () => _openMeetingLink(link),
                                        icon: _openingLink
                                            ? const CmLoading(size: 16)
                                            : const Icon(Icons.open_in_new_rounded),
                                        label: Text(_openingLink ? l.meetingsOpening : l.meetingsOpenLink),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () => _copyMeetingLink(link),
                                        icon: const Icon(Icons.copy_rounded),
                                        label: Text(l.meetingsCopyLink),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: LiquidGlassCard(
                        padding: const EdgeInsets.all(14),
                        borderRadius: BorderRadius.circular(22),
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l.meetingsAccessPanelTitle,
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    normalizedLink == null
                                        ? l.meetingsNoValidLinkAttached
                                        : l.meetingsAccessPanelReadyBody,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: normalizedLink == null
                                  ? null
                                  : () => _openMeetingLink(link),
                              icon: const Icon(Icons.video_call_rounded),
                              label: Text(l.meetingsJoinAction),
                            ),
                          ],
                        ),
                      ),
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

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({required this.meeting, required this.onTap});

  final Map<String, dynamic> meeting;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accessValue = _meetingAccessValue(meeting);
    final access = _meetingAccessLabel(context, accessValue);
    final courseName = _stringValue(meeting, '_courseName');
    final subject = _stringValue(meeting, '_subject');

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
                    _displayMeetingTitle(context, meeting),
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
              _meetingPreview(context, meeting),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Chip(
                  label: access,
                  backgroundColor: (accessValue == _meetingAccessReady
                          ? cs.secondaryContainer
                          : cs.errorContainer)
                      .withValues(alpha: 0.86),
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
                  label: _friendlyDateTimeLabel(context, _stringValue(meeting, 'updatedAt')),
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: cs.onPrimaryContainer),
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
      color: cs.surfaceContainerLow,
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
      padding: const EdgeInsets.all(18),
      borderRadius: BorderRadius.circular(24),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant, height: 1.4)),
          const SizedBox(height: 10),
          Text(
            hint,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: onBack,
          tooltip: l.a11yBack,
          icon: const Icon(Icons.arrow_back_rounded),
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
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92,
                child: Text(
                  label,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value.isEmpty ? AppLocalizations.of(context)!.profileNotAvailable : value,
                  style: const TextStyle(fontWeight: FontWeight.w600, height: 1.4),
                ),
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

class _MeetingsLoadingBody extends StatelessWidget {
  const _MeetingsLoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CmLoading());
  }
}

class _MeetingsErrorBody extends StatelessWidget {
  const _MeetingsErrorBody({required this.subtitle, required this.onRetry});

  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 36),
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)!.meetingsCouldNotLoad, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry)),
          ],
        ),
      ),
    );
  }
}

class _DetailLoadingBody extends StatelessWidget {
  const _DetailLoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CmLoading());
  }
}

class _DetailErrorBody extends StatelessWidget {
  const _DetailErrorBody({required this.subtitle, required this.onRetry});

  final String subtitle;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailTopBar(onBack: () => Navigator.of(context).maybePop()),
            const SizedBox(height: 24),
            Text(AppLocalizations.of(context)!.meetingCouldNotLoad, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry)),
          ],
        ),
      ),
    );
  }
}
