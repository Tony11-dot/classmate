import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/glass_search_field.dart';

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

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final filtered = _filtered;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 16 + MediaQuery.paddingOf(context).top, 16, MediaQuery.of(context).padding.bottom + 100),
        children: [
          // ── Hero card ────────────────────────────────────────────────────
          LiquidGlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(24),
            color: cs.primaryContainer,
            border: Border.all(color: cs.outlineVariant),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.teacherInsightsTitle,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.teacherInsightsSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onPrimaryContainer),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.insights_rounded, size: 26, color: cs.onPrimaryContainer),
                    ),
                  ],
                ),
                if (!_loading && _error == null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_rounded, size: 16, color: cs.onPrimaryContainer),
                        const SizedBox(width: 6),
                        Text(
                          '${_all.length} ${l.teacherStudentsLabel}',
                          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onPrimaryContainer, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Search bar ───────────────────────────────────────────────────
          GlassSearchField(
            hintText: l.teacherInsightsSearchHint,
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 16),

          // ── Content ──────────────────────────────────────────────────────
          if (_loading)
            const Center(
              child: Padding(padding: EdgeInsets.all(32), child: CmLoading()),
            )
          else if (_error != null)
            LiquidGlassCard(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(20),
              color: cs.errorContainer,
              border: Border.all(color: cs.error),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.teacherCouldNotLoad, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  FilledButton(onPressed: _load, child: Text(l.retry)),
                ],
              ),
            )
          else if (filtered.isEmpty)
            LiquidGlassCard(
              padding: const EdgeInsets.all(24),
              borderRadius: BorderRadius.circular(20),
              color: cs.surfaceContainerLow,
              border: Border.all(color: cs.outlineVariant),
              child: Column(
                children: [
                  Icon(Icons.person_search_rounded, size: 40, color: cs.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    l.teacherInsightsNoStudents,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: filtered.map((student) {
                final initials = _initials(student.name);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => context.push(
                      '/teacher/student/${student.studentId}',
                      extra: <String, dynamic>{'name': student.name},
                    ),
                    borderRadius: BorderRadius.circular(18),
                    child: LiquidGlassCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      borderRadius: BorderRadius.circular(18),
                      color: cs.surfaceContainerLow,
                      border: Border.all(color: cs.outlineVariant),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: cs.onPrimaryContainer,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  student.name,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (student.cohortName.isNotEmpty)
                                  Text(
                                    student.cohortName,
                                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
