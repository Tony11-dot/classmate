import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_surfaces.dart';
import '../../bagrut/data/bagrut_api.dart';
import '../../bagrut/ui/bagrut_widgets.dart';
import '../../bagrut/domain/bagrut_models.dart';
import '../../bagrut/domain/bagrut_subjects.dart';
import 'manager_exam_form_screen.dart';

class ManagerBagrutExamsScreen extends ConsumerStatefulWidget {
  const ManagerBagrutExamsScreen({super.key, required this.subjectKey});

  final String subjectKey;

  @override
  ConsumerState<ManagerBagrutExamsScreen> createState() => _ManagerBagrutExamsScreenState();
}

class _ManagerBagrutExamsScreenState extends ConsumerState<ManagerBagrutExamsScreen> {
  late Future<List<BagrutExam>> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() { _future = ref.read(bagrutApiProvider).fetchExams(widget.subjectKey); });
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _addOrEdit([BagrutExam? existing]) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ManagerExamFormScreen(subjectKey: widget.subjectKey, existing: existing),
      ),
    );
    if (changed == true) _reload();
  }

  Future<void> _delete(BagrutExam e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete exam'),
        content: Text('Delete "${e.title}" and its files? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error, foregroundColor: Theme.of(ctx).colorScheme.onError),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(bagrutApiProvider).deleteExam(e.id);
      _reload();
    } catch (err) {
      _snack('$err');
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(title: Text(bagrutSubjectTitle(widget.subjectKey, locale))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEdit(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New exam'),
      ),
      body: FutureBuilder<List<BagrutExam>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CmLoading());
          }
          final exams = snap.data ?? const <BagrutExam>[];
          if (exams.isEmpty) {
            return ListView(children: const [
              CmEmptyState(
                icon: Icons.description_outlined,
                title: 'No exams yet',
                message: 'Tap "New exam".',
              ),
            ]);
          }
          final cs = Theme.of(context).colorScheme;
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: exams.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final e = exams[i];
              return CmCard(
                padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
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
                                label: '${e.files.length} files',
                                color: e.files.isEmpty ? null : CmTokens.of(context).good,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit_rounded),
                      onPressed: () => _addOrEdit(e),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                      onPressed: () => _delete(e),
                    ),
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

