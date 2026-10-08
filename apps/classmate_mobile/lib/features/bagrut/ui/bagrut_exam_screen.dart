import 'package:flutter/material.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_surfaces.dart';
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

  Color _kindColor(BuildContext context, String kind) {
    final cs = Theme.of(context).colorScheme;
    final tokens = CmTokens.of(context);
    switch (kind) {
      case BagrutFileKind.answers:
        return tokens.good;
      case BagrutFileKind.solution:
        return tokens.warn;
      case BagrutFileKind.advanced:
        return cs.tertiary;
      default:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          CmCard(
            tint: cs.primary,
            radius: CmTokens.radiusXl,
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CmIconTile(
                  icon: bagrutSubjectByKey(exam.subject)?.icon ?? Icons.description_rounded,
                  size: 56,
                  filled: true,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bagrutSubjectTitle(exam.subject, locale),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        exam.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          CmPill(icon: Icons.event_rounded, label: '${exam.year}', color: cs.primary),
                          if (exam.term.trim().isNotEmpty) CmPill(label: exam.term.replaceAll('_', ' ')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (ordered.isEmpty)
            CmEmptyState(icon: Icons.folder_off_rounded, title: l.bagrutNoFiles)
          else
            for (final f in ordered) ...[
              CmCard(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                onTap: () => openBagrutFile(
                  context,
                  url: f.url,
                  title: _kindLabel(l, f.kind),
                  isPdf: f.isPdf,
                ),
                child: Row(
                  children: [
                    CmIconTile(icon: _kindIcon(f.kind), color: _kindColor(context, f.kind), size: 48),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _kindLabel(l, f.kind),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            f.fileName ?? (f.isPdf ? 'PDF' : 'Image'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.open_in_new_rounded, size: 20, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}
