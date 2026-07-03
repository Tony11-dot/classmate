// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../student_notes/data/notes_api.dart';
import '../../student_notes/ui/note_editor_screen.dart';
import '../data/students_hub_api.dart';

/// Full-screen student page: Insights / Grades / Notes / Profile tabs.
/// Notes stay private per author (the Notes tab only shows the viewer's own
/// notes); Profile surfaces the student's approved parents with their phone
/// numbers and emails.
class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    this.grade,
    this.cohortName,
  });

  final String studentId;
  final String studentName;
  final int? grade;
  final String? cohortName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final subtitleBits = <String>[
      if (grade != null) l.solutionsGradeLabel(grade!),
      if ((cohortName ?? '').isNotEmpty) cohortName!,
    ];

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(studentName,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              if (subtitleBits.isNotEmpty)
                Text(
                  subtitleBits.join(' · '),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
            ],
          ),
          bottom: TabBar(
            labelStyle: theme.textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w800),
            tabs: [
              Tab(text: l.navInsights),
              Tab(text: l.navGrades),
              Tab(text: l.notesTitle),
              Tab(text: l.navProfile),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InsightsTab(studentId: studentId),
            _GradesTab(studentId: studentId),
            _NotesTab(studentId: studentId),
            _ProfileTab(studentId: studentId),
          ],
        ),
      ),
    );
  }
}

// ── Insights ─────────────────────────────────────────────────────────────────

class _InsightsTab extends ConsumerWidget {
  const _InsightsTab({required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final insights = ref.watch(hubInsightsProvider(studentId));

    return insights.when(
      loading: () => const Center(child: CmLoading()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (d) {
        final hasAnything = d.gradeCount > 0 ||
            d.attendanceRate != null ||
            d.practiceAttempts > 0;
        if (!hasAnything) {
          return Center(child: Text(l.hubNoInsights));
        }
        String pct(num? v) => v == null ? '—' : '${v.round()}%';
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            Row(
              children: [
                _Stat(
                    label: l.hubAverageLabel,
                    value: pct(d.gradeAverage),
                    icon: Icons.grade_rounded),
                const SizedBox(width: 10),
                _Stat(
                    label: l.teacherAttendanceRateLabel,
                    value: pct(d.attendanceRate),
                    icon: Icons.fact_check_rounded),
                const SizedBox(width: 10),
                _Stat(
                    label: l.hubAccuracyLabel,
                    value: pct(d.practiceAccuracy),
                    icon: Icons.auto_awesome_rounded),
              ],
            ),
            const SizedBox(height: 16),
            if ((d.bestSubject ?? '').isNotEmpty)
              _KV(label: l.hubBestSubject, value: d.bestSubject!),
            if ((d.weakestSubject ?? '').isNotEmpty)
              _KV(label: l.hubWeakestSubject, value: d.weakestSubject!),
            _KV(
                label: '${l.navAttendance}',
                value:
                    '✓ ${d.present}   ✗ ${d.absent}   ⏰ ${d.late}'),
            if (d.weakTopics.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(l.hubWeakTopics,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in d.weakTopics.take(8))
                    Chip(
                      label: Text(t),
                      backgroundColor: cs.errorContainer.withValues(alpha: .35),
                      side: BorderSide.none,
                    ),
                ],
              ),
            ],
            if (d.strongTopics.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(l.hubStrongTopics,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in d.strongTopics.take(8))
                    Chip(
                      label: Text(t),
                      backgroundColor:
                          cs.primaryContainer.withValues(alpha: .45),
                      side: BorderSide.none,
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: cs.primary),
            const SizedBox(height: 6),
            Text(value,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Grades ───────────────────────────────────────────────────────────────────

class _GradesTab extends ConsumerWidget {
  const _GradesTab({required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final grades = ref.watch(hubGradesProvider(studentId));

    return grades.when(
      loading: () => const Center(child: CmLoading()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (subjects) {
        if (subjects.isEmpty) return Center(child: Text(l.hubNoGrades));
        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
          itemCount: subjects.length,
          itemBuilder: (ctx, i) {
            final s = subjects[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: Text(s.subject,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      s.average == null ? '—' : '${s.average!.round()}',
                      style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w900, color: cs.primary),
                    ),
                  ),
                  children: [
                    for (final g in s.grades)
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(g.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                              fontWeight: FontWeight.w600)),
                                  Text(
                                    [
                                      if (g.date != null)
                                        DateFormat.yMMMd()
                                            .format(g.date!.toLocal()),
                                      if (!g.published) l.hubUnpublished,
                                    ].join(' · '),
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                            color: cs.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${_trim(g.grade)}/${_trim(g.maxGrade)}',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String _trim(num v) =>
      v == v.roundToDouble() ? '${v.round()}' : '$v';
}

// ── Notes (private per author) ───────────────────────────────────────────────

class _NotesTab extends ConsumerWidget {
  const _NotesTab({required this.studentId});
  final String studentId;

  Future<void> _openEditor(BuildContext context, WidgetRef ref,
      {StudentNote? note}) async {
    await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => NoteEditorScreen(studentId: studentId, note: note),
      ),
    );
    ref.invalidate(studentNotesProvider(studentId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final page = ref.watch(studentNotesProvider(studentId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'hub_note_fab',
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.edit_note_rounded),
        label: Text(l.notesNewNote),
      ),
      body: page.when(
        loading: () => const Center(child: CmLoading()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (data) {
          if (data.notes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sticky_note_2_outlined,
                      size: 48, color: cs.onSurfaceVariant),
                  const SizedBox(height: 10),
                  Text(l.notesNoNotes,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      l.notesNoNotesHint,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            itemCount: data.notes.length,
            itemBuilder: (ctx, i) {
              final note = data.notes[i];
              final title =
                  note.title.trim().isEmpty ? l.notesUntitled : note.title;
              final preview = note.body.replaceAll('\n', ' ').trim();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Material(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    onTap: () => _openEditor(context, ref, note: note),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          if (preview.isNotEmpty)
                            Text(preview,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant)),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat.MMMd()
                                .add_jm()
                                .format(note.updatedAt),
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
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

// ── Profile ──────────────────────────────────────────────────────────────────

class _ProfileTab extends ConsumerWidget {
  const _ProfileTab({required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final profile = ref.watch(hubProfileProvider(studentId));

    return profile.when(
      loading: () => const Center(child: CmLoading()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (p) {
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          children: [
            Text(l.hubStudentSection,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            _InfoCard(
              rows: [
                _InfoRow(icon: Icons.person_rounded, value: p.name),
                if ((p.email ?? '').isNotEmpty)
                  _InfoRow(icon: Icons.mail_rounded, value: p.email!),
                if (p.gradeAverage != null)
                  _InfoRow(
                      icon: Icons.grade_rounded,
                      value:
                          '${l.hubAverageLabel}: ${p.gradeAverage!.round()}%'),
                if (p.attendanceRate != null)
                  _InfoRow(
                      icon: Icons.fact_check_rounded,
                      value:
                          '${l.teacherAttendanceRateLabel}: ${p.attendanceRate!.round()}%'),
              ],
            ),
            const SizedBox(height: 20),
            Text(l.hubParentsSection,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (p.parents.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.family_restroom_rounded,
                        color: cs.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Text(l.hubNoParents,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              )
            else
              for (final parent in p.parents)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _InfoCard(
                    rows: [
                      _InfoRow(
                          icon: Icons.family_restroom_rounded,
                          value: parent.name,
                          bold: true),
                      if ((parent.phone ?? '').isNotEmpty)
                        _InfoRow(
                            icon: Icons.phone_rounded, value: parent.phone!),
                      if ((parent.email ?? '').isNotEmpty)
                        _InfoRow(
                            icon: Icons.mail_rounded, value: parent.email!),
                    ],
                  ),
                ),
          ],
        );
      },
    );
  }
}

class _InfoRow {
  const _InfoRow({required this.icon, required this.value, this.bold = false});
  final IconData icon;
  final String value;
  final bool bold;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(r.icon, size: 18, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SelectableText(
                      r.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            r.bold ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
