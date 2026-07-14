import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/bagrut_models.dart';
import '../domain/bagrut_subjects.dart';
import 'bagrut_file_view.dart';

/// Shows one exam's files grouped by kind (questions / answers / solution /
/// advanced), each tappable to open.
class BagrutExamScreen extends StatelessWidget {
  const BagrutExamScreen({super.key, required this.exam});

  final BagrutExam exam;

  String _kindLabel(AppLocalizations l, String kind) {
    switch (kind) {
      case BagrutFileKind.questions:
        return l.bagrutFileQuestions;
      case BagrutFileKind.answers:
        return l.bagrutFileAnswers;
      case BagrutFileKind.solution:
        return l.bagrutFileSolution;
      case BagrutFileKind.advanced:
        return l.bagrutFileAdvanced;
      default:
        return kind;
    }
  }

  IconData _kindIcon(String kind) {
    switch (kind) {
      case BagrutFileKind.questions:
        return Icons.quiz_rounded;
      case BagrutFileKind.answers:
        return Icons.checklist_rounded;
      case BagrutFileKind.solution:
        return Icons.lightbulb_rounded;
      case BagrutFileKind.advanced:
        return Icons.auto_awesome_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // Order files by the canonical kind order for a consistent layout.
    final ordered = <BagrutExamFile>[];
    for (final kind in BagrutFileKind.all) {
      final f = exam.fileOfKind(kind);
      if (f != null) ordered.add(f);
    }
    for (final f in exam.files) {
      if (!ordered.contains(f)) ordered.add(f);
    }

    return Scaffold(
      appBar: AppBar(title: Text(exam.title)),
      body: ordered.isEmpty
          ? Center(child: Text(l.bagrutNoFiles))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ordered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final f = ordered[i];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: Icon(_kindIcon(f.kind), size: 30),
                    title: Text(_kindLabel(l, f.kind),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(f.fileName ?? (f.isPdf ? 'PDF' : 'Image')),
                    trailing: const Icon(Icons.open_in_new_rounded),
                    onTap: () => openBagrutFile(
                      context,
                      url: f.url,
                      title: _kindLabel(l, f.kind),
                      isPdf: f.isPdf,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
