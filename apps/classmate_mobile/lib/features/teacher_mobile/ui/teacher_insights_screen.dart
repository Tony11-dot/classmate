import 'package:flutter/material.dart';

import '../../../ui/widgets/cm_search_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

// ── data model ──────────────────────────────────────────────────────────────

class _StudentEntry {
  const _StudentEntry({
    required this.studentId,
    required this.name,
    required this.email,
    required this.cohortName,
  });

  final String studentId;
  final String name;
  final String email;
  final String cohortName;
}

// ── screen ──────────────────────────────────────────────────────────────────

class TeacherInsightsScreen extends ConsumerStatefulWidget {
  const TeacherInsightsScreen({super.key});

  @override
  ConsumerState<TeacherInsightsScreen> createState() => _TeacherInsightsScreenState();
}

class _TeacherInsightsScreenState extends ConsumerState<TeacherInsightsScreen> {
  List<_StudentEntry> _all = const [];
  bool _loading = true;
  String? _error;
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);

      // Fetch only THIS teacher's cohorts (from their schedule slots)
      final cohortsRaw = await repo.fetchTeacherCohorts();
      final cohortMap = <String, String>{};
      for (final c in cohortsRaw) {
        final id = (c['id'] ?? '').toString();
        final name = (c['name'] ?? '').toString();
        if (id.isNotEmpty) cohortMap[id] = name;
      }

      // Load students for each cohort, ignoring failures gracefully
      final entries = <_StudentEntry>[];
      final seenStudents = <String>{};
      if (cohortMap.isNotEmpty) {
        final futures = cohortMap.entries.map((e) async {
          try {
            final students = await repo.fetchCohortStudents(e.key);
            return (cohortName: e.value, students: students);
          } catch (_) {
            return (cohortName: e.value, students: <TeacherStudent>[]);
          }
        });
        final results = await Future.wait(futures);
        for (final r in results) {
          for (final s in r.students) {
            if (seenStudents.add(s.studentId)) {
              entries.add(_StudentEntry(
                studentId: s.studentId,
                name: s.name,
                email: s.email,
                cohortName: r.cohortName,
              ));
            }
          }
        }
        entries.sort((a, b) => a.name.compareTo(b.name));
      }

      if (!mounted) return;
      setState(() {
        _all = entries;
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

  List<_StudentEntry> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all.where((s) => s.name.toLowerCase().contains(q) || s.email.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final filtered = _filtered;

    return CmRefreshIndicator(
      onRefresh: _load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 100),
        children: [
          // ── Hero card ────────────────────────────────────────────────────
          CmCard(
            tint: cs.primary,
            radius: CmTokens.radiusXl,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.teacherInsightsTitle,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.teacherInsightsSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      if (!_loading && _error == null) ...[
                        const SizedBox(height: 10),
                        CmPill(
                          icon: Icons.people_rounded,
                          label: '${_all.length} ${l.teacherStudentsLabel}',
                          color: cs.primary,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const CmIconTile(icon: Icons.insights_rounded, size: 52, filled: true),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Search bar ───────────────────────────────────────────────────
          CmSearchField(
            controller: _searchCtrl,
            hint: l.teacherInsightsSearchHint,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 16),

          // ── Content ──────────────────────────────────────────────────────
          if (_loading)
            const Center(
              child: Padding(padding: EdgeInsets.all(32), child: CmLoading()),
            )
          else if (_error != null)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(CmTokens.radiusLg),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.teacherCouldNotLoad,
                      style: TextStyle(fontWeight: FontWeight.w700, color: cs.onErrorContainer),
                    ),
                  ),
                  FilledButton(onPressed: _load, child: Text(l.retry)),
                ],
              ),
            )
          else if (filtered.isEmpty)
            CmEmptyState(icon: Icons.person_search_rounded, title: l.teacherInsightsNoStudents)
          else
            ...filtered.map((student) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CmCard(
                  onTap: () => context.push(
                    '/teacher/student/${student.studentId}',
                    extra: <String, dynamic>{'name': student.name},
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                  child: Row(
                    children: [
                      CmMonogram(name: student.name),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            if (student.cohortName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              CmPill(icon: Icons.groups_rounded, label: student.cohortName),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
