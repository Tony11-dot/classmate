import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../data/bagrut_api.dart';
import '../domain/bagrut_models.dart';
import '../domain/bagrut_subjects.dart';
import 'bagrut_exam_screen.dart';
import 'bagrut_widgets.dart';

class BagrutExamsScreen extends ConsumerStatefulWidget {
  const BagrutExamsScreen({super.key, required this.subjectKey});

  final String subjectKey;

  @override
  ConsumerState<BagrutExamsScreen> createState() => _BagrutExamsScreenState();
}

class _BagrutExamsScreenState extends ConsumerState<BagrutExamsScreen> {
  late Future<List<BagrutExam>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(bagrutApiProvider).fetchExams(widget.subjectKey);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final subjectTitle = bagrutSubjectTitle(widget.subjectKey, locale);

    return Scaffold(
      appBar: AppBar(title: Text(subjectTitle)),
      body: FutureBuilder<List<BagrutExam>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CmLoading());
          }
          if (snap.hasError) {
            return Center(child: Text('${snap.error}'));
          }
          final exams = snap.data ?? const <BagrutExam>[];
          if (exams.isEmpty) {
            return Center(
              child: CmEmptyState(
                icon: bagrutSubjectByKey(widget.subjectKey)?.icon ?? Icons.description_outlined,
                title: l.bagrutNoExams(subjectTitle),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: exams.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final e = exams[i];
              return CmCard(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                // Cupertino route → back chevron + edge-swipe to leave.
                onTap: () => Navigator.of(context).push(
                  CupertinoPageRoute<void>(builder: (_) => BagrutExamScreen(exam: e)),
                ),
                child: Row(
                  children: [
                    BagrutYearStub(year: e.year),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (e.term.trim().isNotEmpty) CmPill(label: e.term.replaceAll('_', ' ')),
                              CmPill(
                                icon: Icons.attach_file_rounded,
                                label: l.bagrutFilesCount(e.files.length),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
