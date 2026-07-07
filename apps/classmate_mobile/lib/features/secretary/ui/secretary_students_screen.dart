// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/realtime/realtime_listener.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/glass_search_field.dart';
import '../../admin/data/admin_repository.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _secOverviewProvider = FutureProvider.autoDispose<AdminOverview>((ref) {
  return ref.watch(adminRepositoryProvider).fetchOverview();
});

final _secAttendanceProvider = FutureProvider.autoDispose<List<CohortAttendance>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchAttendanceAnalytics();
});

final _secGradesProvider = FutureProvider.autoDispose<List<CohortGrades>>((ref) {
  return ref.watch(adminRepositoryProvider).fetchGradesAnalytics();
});

final _secCohortsProvider = FutureProvider.autoDispose<List<AdminCohort>>((ref) {
  return ref.watch(adminRepositoryProvider).listCohorts();
});

final _secRosterProvider =
    FutureProvider.autoDispose.family<List<AdminUser>, String>((ref, cohortId) {
  return ref.watch(adminRepositoryProvider).getCohortRoster(cohortId);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class SecretaryStudentsScreen extends ConsumerStatefulWidget {
  const SecretaryStudentsScreen({super.key});

  @override
  ConsumerState<SecretaryStudentsScreen> createState() =>
      _SecretaryStudentsScreenState();
}

class _SecretaryStudentsScreenState
    extends ConsumerState<SecretaryStudentsScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      final v = _searchCtrl.text.trim();
      if (v != _search) setState(() => _search = v);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final overviewAsync = ref.watch(_secOverviewProvider);
    final attendanceAsync = ref.watch(_secAttendanceProvider);
    final gradesAsync = ref.watch(_secGradesProvider);
    final cohortsAsync = ref.watch(_secCohortsProvider);

    ref.listen(realtimeEventProvider, (_, event) {
      if (event?.type == 'grade_updated' || event?.type == 'notification') {
        ref.invalidate(_secOverviewProvider);
        ref.invalidate(_secAttendanceProvider);
        ref.invalidate(_secGradesProvider);
        ref.invalidate(_secCohortsProvider);
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(_secOverviewProvider);
          ref.invalidate(_secAttendanceProvider);
          ref.invalidate(_secGradesProvider);
          ref.invalidate(_secCohortsProvider);
        },
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            // ── Hero summary ─────────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  16, 12 + MediaQuery.paddingOf(context).top, 16, 0),
              sliver: SliverToBoxAdapter(
                child: overviewAsync.when(
                  loading: () => const _SummaryCardSkeleton(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (o) => _SummaryCard(
                    students: o.students,
                    cohorts: o.cohorts,
                    attendance: attendanceAsync.value,
                    grades: gradesAsync.value,
                  ),
                ),
              ),
            ),

            // ── Search ───────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              sliver: SliverToBoxAdapter(
                child: GlassSearchField(
                  hintText: AppLocalizations.of(context)!.adminSearchPeople,
                  controller: _searchCtrl,
                ),
              ),
            ),

            // ── Cohorts + rosters ────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              sliver: cohortsAsync.when(
                loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator())),
                error: (e, _) =>
                    SliverToBoxAdapter(child: Text(AppLocalizations.of(context)!.commonErrorWith(e))),
                data: (cohorts) {
                  if (cohorts.isEmpty) {
                    return SliverToBoxAdapter(
                      child: _EmptyHint(
                        icon: Icons.groups_outlined,
                        message: AppLocalizations.of(context)!.adminNoCohortsYet,
                      ),
                    );
                  }

                  // Grade groups
                  final byGrade = <int, List<AdminCohort>>{};
                  for (final c in cohorts) {
                    byGrade.putIfAbsent(c.grade, () => []).add(c);
                  }
                  final grades = byGrade.keys.toList()..sort();

                  // Flatten to section items
                  final items = <_ListItem>[];
                  for (final g in grades) {
                    items.add(_GradeHeader(grade: g));
                    for (final c in byGrade[g]!) {
                      items.add(_CohortItem(cohort: c));
                    }
                  }

                  return SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      if (item is _GradeHeader) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                          child: Text(
                            AppLocalizations.of(ctx)!.adminSubjectsGrade(item.grade),
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      }
                      final c = (item as _CohortItem).cohort;
                      final attRate = attendanceAsync.value
                          ?.firstWhere((a) => a.cohortId == c.id,
                              orElse: () => CohortAttendance(
                                  cohortId: c.id,
                                  cohortName: c.name,
                                  grade: c.grade,
                                  rate: null,
                                  total: 0))
                          .rate;
                      final avgGrade = gradesAsync.value
                          ?.firstWhere((g) => g.cohortId == c.id,
                              orElse: () => CohortGrades(
                                  cohortId: c.id,
                                  cohortName: c.name,
                                  grade: c.grade,
                                  avgGrade: null))
                          .avgGrade;
                      return _CohortCard(
                        cohort: c,
                        attendanceRate: attRate,
                        avgGrade: avgGrade,
                        search: _search,
                        onTap: () => _openCohort(context, c),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCohort(BuildContext ctx, AdminCohort cohort) async {
    await Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => _SecretaryCohortDetailScreen(cohort: cohort),
      ),
    );
  }
}

// ── Summary card ───────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.students,
    required this.cohorts,
    required this.attendance,
    required this.grades,
  });

  final int students;
  final int cohorts;
  final List<CohortAttendance>? attendance;
  final List<CohortGrades>? grades;

  int? get _avgAttendance {
    final list = attendance?.where((c) => c.rate != null && c.total > 0).toList();
    if (list == null || list.isEmpty) return null;
    return (list.map((c) => c.rate!).reduce((a, b) => a + b) / list.length).round();
  }

  int? get _avgGrade {
    final list = grades?.where((c) => c.avgGrade != null).toList();
    if (list == null || list.isEmpty) return null;
    return (list.map((c) => c.avgGrade!).reduce((a, b) => a + b) / list.length).round();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final aa = _avgAttendance;
    final ag = _avgGrade;
    final attendColor = aa == null ? cs.onSurfaceVariant
        : aa >= 90 ? Colors.green
        : aa >= 75 ? Colors.orange
        : cs.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          _SummaryTile(
            label: l.adminStudents,
            value: '$students',
            icon: Icons.school_rounded,
            color: cs.primary,
          ),
          const SizedBox(width: 10),
          _SummaryTile(
            label: l.navCohorts,
            value: '$cohorts',
            icon: Icons.groups_rounded,
            color: cs.secondary,
          ),
          const SizedBox(width: 10),
          _SummaryTile(
            label: l.navAttendance,
            value: aa != null ? '$aa%' : '—',
            icon: Icons.how_to_reg_rounded,
            color: attendColor,
          ),
          const SizedBox(width: 10),
          _SummaryTile(
            label: l.navGrades,
            value: ag != null ? '$ag' : '—',
            icon: Icons.grade_rounded,
            color: cs.tertiary,
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 17, color: color),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SummaryCardSkeleton extends StatelessWidget {
  const _SummaryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ── Cohort card ────────────────────────────────────────────────────────────────

class _CohortCard extends StatelessWidget {
  const _CohortCard({
    required this.cohort,
    required this.attendanceRate,
    required this.avgGrade,
    required this.search,
    required this.onTap,
  });

  final AdminCohort cohort;
  final int? attendanceRate;
  final int? avgGrade;
  final String search;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final rate = attendanceRate;
    final rateColor = rate == null
        ? cs.onSurfaceVariant
        : rate >= 90 ? Colors.green : rate >= 75 ? Colors.orange : cs.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            // Grade badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'G${cohort.grade}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name + count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cohort.name,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    AppLocalizations.of(context)!
                        .secretaryStudentsScreenStudentCount(cohort.studentCount),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            // Attendance + grade pills
            if (rate != null)
              _StatPill(
                  value: '$rate%',
                  icon: Icons.how_to_reg_rounded,
                  color: rateColor),
            if (avgGrade != null) ...[
              const SizedBox(width: 6),
              _StatPill(
                  value: '$avgGrade',
                  icon: Icons.grade_rounded,
                  color: cs.tertiary),
            ],
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.value, required this.icon, required this.color});

  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Cohort detail (read-only roster for secretary) ─────────────────────────────

class _SecretaryCohortDetailScreen extends ConsumerWidget {
  const _SecretaryCohortDetailScreen({required this.cohort});

  final AdminCohort cohort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final rosterAsync = ref.watch(_secRosterProvider(cohort.id));
    final gradesAsync = ref.watch(_secGradesProvider);

    // Per-student grade for this cohort (avg from grades analytics)
    final cohortAvgGrade = gradesAsync.value
        ?.firstWhere((g) => g.cohortId == cohort.id,
            orElse: () => CohortGrades(
                cohortId: cohort.id,
                cohortName: cohort.name,
                grade: cohort.grade,
                avgGrade: null))
        .avgGrade;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          cohort.name,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (cohortAvgGrade != null)
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!
                        .secretaryStudentsScreenAvg(cohortAvgGrade.toString()),
                    style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800, letterSpacing: 0.2),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: rosterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.commonErrorWith(e))),
        data: (students) {
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_outline_rounded,
                      size: 56, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text(AppLocalizations.of(context)!.adminNoStudentsInCohort,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (ctx, i) {
              final s = students[i];
              final initials = _initials(s.name);
              // The card itself shows only name + grade per the spec —
              // anything more lives behind the tap.
              return InkWell(
                onTap: () => _openStudentDetail(ctx, ref, s.id, s.name),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: cs.onPrimaryContainer),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                style: theme.textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700)),
                            Text(AppLocalizations.of(context)!.adminCohortGradeFormat(cohort.grade.toString()),
                                style: theme.textTheme.labelSmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 18),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Student detail sheet ──────────────────────────────────────────────────────

Future<void> _openStudentDetail(
  BuildContext context,
  WidgetRef ref,
  String studentId,
  String fallbackName,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _StudentDetailSheet(
      studentId: studentId,
      fallbackName: fallbackName,
    ),
  );
}

class _StudentDetailSheet extends ConsumerStatefulWidget {
  const _StudentDetailSheet({required this.studentId, required this.fallbackName});
  final String studentId;
  final String fallbackName;

  @override
  ConsumerState<_StudentDetailSheet> createState() => _StudentDetailSheetState();
}

class _StudentDetailSheetState extends ConsumerState<_StudentDetailSheet> {
  bool _loading = true;
  Map<String, dynamic>? _user;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final raw = await ref
          .read(adminRepositoryProvider)
          .getUserDetailRaw(widget.studentId);
      if (!mounted) return;
      setState(() {
        _user = raw;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(child: Text(_error!, style: TextStyle(color: cs.error))),
                      )
                    : _buildBody(scrollCtrl, theme, cs),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ScrollController scrollCtrl, ThemeData theme, ColorScheme cs) {
    final l = AppLocalizations.of(context)!;
    final u = _user ?? const <String, dynamic>{};
    final name = (u['name'] ?? widget.fallbackName).toString();
    final username = (u['username'] ?? '').toString();
    final email = (u['email'] ?? '').toString();
    final phone = (u['phone'] ?? '').toString();
    final legalName = (u['legalName'] ?? '').toString();
    final grade = u['grade'];
    final cohort = u['cohort'] is Map ? Map<String, dynamic>.from(u['cohort']) : null;
    final cohorts = (u['cohorts'] is List)
        ? (u['cohorts'] as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList()
        : const <Map<String, dynamic>>[];
    final classrooms = (u['classrooms'] is List)
        ? (u['classrooms'] as List).whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList()
        : const <Map<String, dynamic>>[];

    return ListView(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      children: [
        Text(name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        if (legalName.isNotEmpty && legalName != name) ...[
          const SizedBox(height: 2),
          Text(legalName, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ],
        const SizedBox(height: 18),

        _DetailGroup(title: l.secretaryStudentsScreenIdentity, items: [
          if (username.isNotEmpty) (l.secretaryStudentsScreenUsername, username),
          if (email.isNotEmpty) (l.secretaryStudentsScreenEmail, email),
          if (phone.isNotEmpty) (l.secretaryStudentsScreenPhone, phone),
        ]),

        if (cohort != null || grade != null) ...[
          const SizedBox(height: 16),
          _DetailGroup(title: l.secretaryStudentsScreenCohort, items: [
            if (grade != null) (l.secretaryStudentsScreenGrade, grade.toString()),
            if (cohort?['name'] != null) (l.secretaryStudentsScreenPrimaryCohort, cohort!['name'].toString()),
          ]),
        ],

        if (cohorts.length > 1) ...[
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.secretaryAllCohorts, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: cohorts
                .map((c) => Chip(
                      label: Text((c['name'] ?? '').toString()),
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
        ],

        if (classrooms.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.secretaryClassrooms, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          ...classrooms.map((c) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.class_rounded, size: 18, color: cs.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text((c['name'] ?? '').toString(),
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            [
                              if ((c['subject'] ?? '').toString().isNotEmpty) c['subject'].toString(),
                              if ((c['teacherName'] ?? '').toString().isNotEmpty)
                                l.secretaryStudentsScreenTeacher(c['teacherName'].toString()),
                            ].join(' · '),
                            style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}

class _DetailGroup extends StatelessWidget {
  const _DetailGroup({required this.title, required this.items});
  final String title;
  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map((e) => Padding(
                      padding: EdgeInsets.only(top: e.key == 0 ? 0 : 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 96,
                            child: Text(e.value.$1,
                                style: theme.textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ),
                          Expanded(
                            child: Text(e.value.$2,
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ── List item types ───────────────────────────────────────────────────────────

sealed class _ListItem {}

class _GradeHeader extends _ListItem {
  _GradeHeader({required this.grade});
  final int grade;
}

class _CohortItem extends _ListItem {
  _CohortItem({required this.cohort});
  final AdminCohort cohort;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _initials(String name) {
  if (name.isEmpty) return 'CM';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  final word = parts[0];
  if (word.length >= 2) return '${word[0]}${word[1]}'.toUpperCase();
  return word[0].toUpperCase();
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 56, color: cs.outlineVariant),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
