import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'grades_models.dart';
import 'grades_providers.dart';

enum SubjectGradesSort { newest, highest, titleAz }

extension _SubjectGradesSortLabel on SubjectGradesSort {
  String get label {
    switch (this) {
      case SubjectGradesSort.newest:
        return 'Newest';
      case SubjectGradesSort.highest:
        return 'Highest score';
      case SubjectGradesSort.titleAz:
        return 'Title A → Z';
    }
  }
}

class SubjectGradesScreen extends ConsumerStatefulWidget {
  final String subjectId;
  const SubjectGradesScreen({super.key, required this.subjectId});

  @override
  ConsumerState<SubjectGradesScreen> createState() =>
      _SubjectGradesScreenState();
}

class _SubjectGradesScreenState extends ConsumerState<SubjectGradesScreen> {
  SubjectGradesSort _sort = SubjectGradesSort.newest;

  List<GradeRow> _sorted(List<GradeRow> rows) {
    final out = [...rows];
    switch (_sort) {
      case SubjectGradesSort.newest:
        out.sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
        break;
      case SubjectGradesSort.highest:
        out.sort((a, b) => (b.score ?? -1).compareTo(a.score ?? -1));
        break;
      case SubjectGradesSort.titleAz:
        out.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gradesBySubjectProvider(widget.subjectId));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectId),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<SubjectGradesSort>(
              value: _sort,
              onChanged: (v) => setState(() => _sort = v ?? _sort),
              items: [
                for (final x in SubjectGradesSort.values)
                  DropdownMenuItem(value: x, child: Text(x.label)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text(e.toString())),
        data: (rows) {
          final list = _sorted(rows);
          if (list.isEmpty) return const Center(child: Text('No grades yet.'));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(gradesBySubjectProvider(widget.subjectId));
              await ref.read(gradesBySubjectProvider(widget.subjectId).future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final g = list[i];
                final score = g.score == null ? '—' : '${g.score}';
                final when = (g.createdAt ?? '').isEmpty ? '' : g.createdAt!;
                final teacher = (g.teacherId ?? '').isEmpty
                    ? ''
                    : ' • ${g.teacherId}';

                return Card(
                  child: ListTile(
                    title: Text(
                      g.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text('$when$teacher'),
                    trailing: Text(
                      score,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
