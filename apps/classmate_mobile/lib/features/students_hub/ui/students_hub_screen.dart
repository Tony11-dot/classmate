import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/glass_search_field.dart';
import '../data/students_hub_api.dart';
import 'student_detail_screen.dart';

/// Students hub home (teacher + admin): searchable roster with the grade next
/// to each name; tapping opens the full-screen 4-tab student page
/// (Insights / Grades / Notes / Profile).
class StudentsHubScreen extends ConsumerStatefulWidget {
  const StudentsHubScreen({super.key});

  @override
  ConsumerState<StudentsHubScreen> createState() => _StudentsHubScreenState();
}

class _StudentsHubScreenState extends ConsumerState<StudentsHubScreen> {
  final TextEditingController _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  void _open(HubStudent s) {
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(
        builder: (_) => StudentDetailScreen(
          studentId: s.studentId,
          studentName: s.name,
          grade: s.grade,
          cohortName: s.cohortName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final students = ref.watch(hubStudentsProvider);
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
              onRefresh: () async {
                ref.invalidate(hubStudentsProvider);
                await ref.read(hubStudentsProvider.future);
              },
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
                      l.teacherStudentsLabel,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: GlassSearchField(
                      hintText: l.notesSearchStudents,
                      controller: _searchCtl,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (filtered.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 120),
                      child: Center(child: Text(l.notesNoStudents)),
                    )
                  else
                    ...filtered.map((s) => _Row(student: s, onTap: () => _open(s))),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.student, required this.onTap});

  final HubStudent student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
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
                  radius: 21,
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
                      if ((student.cohortName ?? '').isNotEmpty)
                        Text(
                          student.cohortName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                if (student.grade != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l.solutionsGradeLabel(student.grade!),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ],
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
