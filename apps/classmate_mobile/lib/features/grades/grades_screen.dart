import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/prefs.dart';
import 'grades_models.dart';
import 'grades_providers.dart';
import 'subject_grades_screen.dart';

enum GradesSubjectSort { latestUpdated, az, highestLast, mostGrades }

extension _GradesSubjectSortLabel on GradesSubjectSort {
  String get label {
    switch (this) {
      case GradesSubjectSort.latestUpdated:
        return 'Latest updated';
      case GradesSubjectSort.az:
        return 'A → Z';
      case GradesSubjectSort.highestLast:
        return 'Highest last grade';
      case GradesSubjectSort.mostGrades:
        return 'Most grades';
    }
  }
}

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  GradesSubjectSort _sort = GradesSubjectSort.latestUpdated;

  @override
  void initState() {
    super.initState();
    Prefs.getString('grades_subject_sort').then((v) {
      if (v == null) return;
      for (final x in GradesSubjectSort.values) {
        if (x.name == v) {
          if (mounted) setState(() => _sort = x);
          return;
        }
      }
    });
  }

  List<GradeSubjectSummary> _sorted(List<GradeSubjectSummary> rows) {
    final out = [...rows];
    switch (_sort) {
      case GradesSubjectSort.latestUpdated:
        out.sort(
          (a, b) => (b.lastPostedAt ?? '').compareTo(a.lastPostedAt ?? ''),
        );
        break;
      case GradesSubjectSort.az:
        out.sort(
          (a, b) =>
              a.subjectId.toLowerCase().compareTo(b.subjectId.toLowerCase()),
        );
        break;
      case GradesSubjectSort.highestLast:
        out.sort((a, b) => (b.lastScore ?? -1).compareTo(a.lastScore ?? -1));
        break;
      case GradesSubjectSort.mostGrades:
        out.sort((a, b) => b.count.compareTo(a.count));
        break;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gradeSubjectsSummaryProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              const Text(
                'Subjects',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              DropdownButton<GradesSubjectSort>(
                value: _sort,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _sort = v);
                  Prefs.setString('grades_subject_sort', v.name);
                },
                items: [
                  for (final x in GradesSubjectSort.values)
                    DropdownMenuItem(value: x, child: Text(x.label)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, stack) => Center(child: Text(e.toString())),
            data: (rows) {
              final list = _sorted(rows);

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: RefreshIndicator(
                  key: ValueKey(_sort.name),
                  onRefresh: () async {
                    ref.invalidate(gradeSubjectsSummaryProvider);
                    await ref.read(gradeSubjectsSummaryProvider.future);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: list.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final s = list[i];
                      final last = s.lastScore == null ? '—' : '${s.lastScore}';
                      final meta = 'Last: $last • Count: ${s.count}';

                      return Material(
                        borderRadius: BorderRadius.circular(18),
                        color: Theme.of(context).cardColor,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SubjectGradesScreen(subjectId: s.subjectId),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.subjectId,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  meta,
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
