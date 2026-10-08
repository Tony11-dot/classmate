import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';

import '../../../ui/widgets/cm_search_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/students_hub_api.dart';
import 'student_detail_screen.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

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
        bottom: false,
        child: students.when(
          loading: () => const Center(child: CmLoading()),
          error: (e, _) => Center(
            child: CmEmptyState(
              icon: Icons.error_outline_rounded,
              title: l.commonError,
              message: e.toString(),
            ),
          ),
          data: (items) {
            final filtered = query.isEmpty
                ? items
                : items
                      .where((s) => s.name.toLowerCase().contains(query))
                      .toList();
            return CmRefreshIndicator(
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
                padding: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  136 + MediaQuery.paddingOf(context).bottom,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
                    child: Text(
                      l.teacherStudentsLabel,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                    child: CmSearchField(
                      controller: _searchCtl,
                      hint: l.notesSearchStudents,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  if (filtered.isEmpty)
                    CmEmptyState(
                      icon: Icons.person_search_rounded,
                      title: l.notesNoStudents,
                    )
                  else
                    ...filtered.map(
                      (s) => _Row(student: s, onTap: () => _open(s)),
                    ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CmCard(
        onTap: onTap,
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if ((student.cohortName ?? '').isNotEmpty)
                    Text(
                      student.cohortName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (student.grade != null) ...[
              const SizedBox(width: 8),
              CmPill(
                label: l.solutionsGradeLabel(student.grade!),
                color: cs.primary,
              ),
            ],
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
