// ignore_for_file: use_build_context_synchronously
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/util/friendly_date.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/admin_repository.dart';

/// Admin Insights — search students by full name; each shows the grade they're
/// in. Tapping a student opens the same per-subject grades view teachers see
/// (every subject, every average, every grade). Body-only: shell supplies the
/// top bar.
class AdminInsightsScreen extends ConsumerStatefulWidget {
  const AdminInsightsScreen({super.key});

  @override
  ConsumerState<AdminInsightsScreen> createState() => _AdminInsightsScreenState();
}

class _AdminInsightsScreenState extends ConsumerState<AdminInsightsScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _students = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() => _load(''));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () => _load(q.trim()));
  }

  Future<void> _load(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final students = await ref.read(adminRepositoryProvider).getDdlStudents(q: q.isEmpty ? null : q);
      if (!mounted) return;
      setState(() {
        _students = students;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchCtrl,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l.adminInsightsSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _searchCtrl.clear();
                        _load('');
                        FocusScope.of(context).unfocus();
                      },
                    ),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CmLoading())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: cs.error)),
                      ),
                    )
                  : _students.isEmpty
                      ? Center(
                          child: Text(l.adminInsightsNoStudents,
                              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                          itemCount: _students.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final s = _students[i];
                            final id = '${s['id'] ?? ''}';
                            final name = '${s['name'] ?? ''}';
                            final grade = s['grade'];
                            final cohortName = '${s['cohortName'] ?? ''}';
                            final sub = <String>[
                              if (grade != null) l.adminCohortGradeFormat('$grade'),
                              if (cohortName.isNotEmpty) cohortName,
                            ].join(' · ');
                            return InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: id.isEmpty
                                  ? null
                                  : () => Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => AdminStudentGradesScreen(studentId: id, studentName: name),
                                        ),
                                      ),
                              child: LiquidGlassCard(
                                borderRadius: BorderRadius.circular(16),
                                color: cs.surfaceContainerLow,
                                border: Border.all(color: cs.outlineVariant),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
                                      child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                          style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w900)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                                          if (sub.isNotEmpty)
                                            Text(sub, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

/// Read-only per-student grades view for admins — every subject, its average,
/// and every grade. Mirrors the teacher student-grade detail, admin-scoped.
class AdminStudentGradesScreen extends ConsumerStatefulWidget {
  const AdminStudentGradesScreen({super.key, required this.studentId, required this.studentName});
  final String studentId;
  final String studentName;

  @override
  ConsumerState<AdminStudentGradesScreen> createState() => _AdminStudentGradesScreenState();
}

class _AdminStudentGradesScreenState extends ConsumerState<AdminStudentGradesScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
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
      final data = await ref.read(adminRepositoryProvider).getStudentGrades(widget.studentId);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final student = (_data?['student'] as Map?)?.cast<String, dynamic>() ?? const {};
    final name = '${student['name'] ?? widget.studentName}';
    final cohortName = '${student['cohortName'] ?? ''}';
    final grade = student['grade'];
    final subjects = ((_data?['subjects'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CmLoading())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
                    ),
                  )
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: [
                      // Hero
                      LiquidGlassCard(
                        borderRadius: BorderRadius.circular(20),
                        color: cs.primaryContainer,
                        border: Border.all(color: cs.outlineVariant),
                        child: Row(children: [
                          Container(
                            width: 52,
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(16)),
                            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w900, fontSize: 22)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: theme.textTheme.titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w800, color: cs.onPrimaryContainer)),
                                Text(
                                  [
                                    if (grade != null) l.adminCohortGradeFormat('$grade'),
                                    if (cohortName.isNotEmpty) cohortName,
                                  ].join(' · '),
                                  style: theme.textTheme.bodySmall?.copyWith(color: cs.onPrimaryContainer),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      if (subjects.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(l.adminInsightsNoGrades,
                                style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ),
                        )
                      else
                        ...subjects.map((subj) {
                          final subject = '${subj['subject'] ?? ''}';
                          final average = subj['average'];
                          final grades = ((subj['grades'] as List?) ?? const [])
                              .whereType<Map>()
                              .map((e) => e.cast<String, dynamic>())
                              .toList();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: LiquidGlassCard(
                              borderRadius: BorderRadius.circular(18),
                              color: cs.surfaceContainerLow,
                              border: Border.all(color: cs.outlineVariant),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: BorderRadius.circular(10)),
                                      child: Icon(Icons.menu_book_rounded, size: 16, color: cs.onSecondaryContainer),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(subject,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                    ),
                                    if (average != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                        decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(999)),
                                        child: Text('$average',
                                            style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w900, fontSize: 14)),
                                      ),
                                  ]),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  ...grades.map((gr) {
                                    final title = '${gr['title'] ?? ''}';
                                    final gVal = gr['grade'];
                                    final maxGrade = gr['maxGrade'] ?? 100;
                                    final date = '${gr['date'] ?? ''}';
                                    final published = gr['published'] == true;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: Row(children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(children: [
                                                Flexible(
                                                  child: Text(title,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                                                ),
                                                if (!published) ...[
                                                  const SizedBox(width: 6),
                                                  Icon(Icons.visibility_off_rounded, size: 13, color: cs.onSurfaceVariant),
                                                ],
                                              ]),
                                              if (date.isNotEmpty)
                                                Text(FriendlyDate.date(date),
                                                    style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(gVal == null ? '—' : '$gVal',
                                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                                        Text(' / $maxGrade',
                                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                      ]),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
      ),
    );
  }
}
