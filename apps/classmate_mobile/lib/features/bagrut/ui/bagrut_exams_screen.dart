import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/bagrut_api.dart';
import '../domain/bagrut_models.dart';
import '../domain/bagrut_subjects.dart';
import 'bagrut_exam_screen.dart';

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
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l.bagrutNoExams(subjectTitle),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: exams.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final e = exams[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(child: Text('${e.year % 100}'.padLeft(2, '0'))),
                  title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(
                    [
                      e.year.toString(),
                      if (e.term.trim().isNotEmpty) e.term.replaceAll('_', ' '),
                      l.bagrutFilesCount(e.files.length),
                    ].join(' · '),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => BagrutExamScreen(exam: e)),
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
