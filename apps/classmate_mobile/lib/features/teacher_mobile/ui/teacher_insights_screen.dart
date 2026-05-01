import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';

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
      final classrooms = await repo.fetchClassrooms();

      // Collect unique cohort IDs with their cohort name
      final seen = <String>{};
      final cohortMap = <String, String>{}; // cohortId → cohortName
      for (final c in classrooms) {
        if (c.cohortId.isNotEmpty && seen.add(c.cohortId)) {
          cohortMap[c.cohortId] = c.cohort?.name ?? '';
        }
      }

      // Load students for each cohort in parallel
      final entries = <_StudentEntry>[];
      final seenStudents = <String>{};
      if (cohortMap.isNotEmpty) {
        final futures = cohortMap.entries.map((e) async {
          final students = await repo.fetchCohortStudents(e.key);
          return (cohortName: e.value, students: students);
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Hero card ────────────────────────────────────────────────────
          LiquidGlassCard(
            padding: const EdgeInsets.all(18),
            borderRadius: BorderRadius.circular(26),
            blurSigma: 18,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primaryContainer.withValues(alpha: 0.95),
                cs.surfaceContainerHigh.withValues(alpha: 0.95),
              ],
            ),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.45)),
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
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.teacherInsightsSubtitle,
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.insights_rounded, size: 26, color: cs.primary),
                    ),
                  ],
                ),
                if (!_loading && _error == null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: cs.primary.withValues(alpha: 0.18)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_rounded, size: 16, color: cs.primary),
                        const SizedBox(width: 6),
                        Text(
                          '${_all.length} ${l.teacherStudentsLabel}',
                          style: TextStyle(fontWeight: FontWeight.w700, color: cs.primary, fontSize: 13),
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
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l.teacherInsightsSearchHint,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Content ──────────────────────────────────────────────────────
          if (_loading)
            const Center(
              child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()),
            )
          else if (_error != null)
            LiquidGlassCard(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(20),
              blurSigma: 10,
              color: cs.errorContainer.withValues(alpha: 0.55),
              border: Border.all(color: cs.error.withValues(alpha: 0.22)),
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
              blurSigma: 10,
              color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.18)),
              child: Column(
                children: [
                  Icon(Icons.person_search_rounded, size: 40, color: cs.onSurfaceVariant.withValues(alpha: 0.5)),
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
                      blurSigma: 10,
                      color: cs.surface.withValues(alpha: 0.82),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [cs.primary, cs.tertiary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
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
