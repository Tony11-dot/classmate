import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/notes_api.dart';
import 'student_notes_screen.dart';

/// Notes home — the searchable student browser (name + grade + note count).
/// Staff-only; the route is only wired into teacher/admin navigation and the
/// backend rejects any other role anyway.
class NotesStudentsScreen extends ConsumerStatefulWidget {
  const NotesStudentsScreen({super.key});

  @override
  ConsumerState<NotesStudentsScreen> createState() =>
      _NotesStudentsScreenState();
}

class _NotesStudentsScreenState extends ConsumerState<NotesStudentsScreen> {
  final TextEditingController _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(notesStudentsProvider);
    await ref.read(notesStudentsProvider.future);
  }

  void _openStudent(NoteStudent s) {
    Navigator.of(context, rootNavigator: true)
        .push(CupertinoPageRoute(
          builder: (_) => StudentNotesScreen(
            studentId: s.studentId,
            studentName: s.name,
          ),
        ))
        .then((_) => ref.invalidate(notesStudentsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final students = ref.watch(notesStudentsProvider);
    final query = _searchCtl.text.trim().toLowerCase();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: students.when(
          loading: () => const Center(child: CmLoading()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(e.toString(), textAlign: TextAlign.center),
            ),
          ),
          data: (items) {
            final filtered = query.isEmpty
                ? items
                : items
                    .where((s) => s.name.toLowerCase().contains(query))
                    .toList();
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 136),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                    child: Text(
                      l.notesTitle,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: TextField(
                      controller: _searchCtl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: l.notesSearchStudents,
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: Center(child: Text(l.notesNoStudents)),
                    )
                  else
                    ...filtered.map((s) => _StudentRow(
                          student: s,
                          onTap: () => _openStudent(s),
                          colorScheme: cs,
                        )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.student,
    required this.onTap,
    required this.colorScheme,
  });

  final NoteStudent student;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = colorScheme;
    final gradeBits = <String>[
      if (student.grade != null) l.solutionsGradeLabel(student.grade!),
      if ((student.cohortName ?? '').isNotEmpty) student.cohortName!,
    ];
    final initial =
        student.name.isNotEmpty ? student.name.characters.first : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primaryContainer,
                  child: Text(
                    initial.toUpperCase(),
                    style: TextStyle(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (gradeBits.isNotEmpty)
                        Text(
                          gradeBits.join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: student.noteCount > 0
                        ? cs.primary.withValues(alpha: 0.12)
                        : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    l.notesCount(student.noteCount),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: student.noteCount > 0
                          ? cs.primary
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
