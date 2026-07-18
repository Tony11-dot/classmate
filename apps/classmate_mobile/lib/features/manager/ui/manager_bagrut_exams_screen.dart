import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/widgets/cm_loading.dart';
import '../../bagrut/data/bagrut_api.dart';
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
    setState(() => _future = ref.read(bagrutApiProvider).fetchExams(widget.subjectKey));
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
              Padding(padding: EdgeInsets.all(48), child: Center(child: Text('No exams yet. Tap "New exam".'))),
            ]);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: exams.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final e = exams[i];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text([
                    e.year.toString(),
                    if (e.term.trim().isNotEmpty) e.term.replaceAll('_', ' '),
                    '${e.files.length} files',
                  ].join(' · ')),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_rounded), onPressed: () => _addOrEdit(e)),
                      IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.red), onPressed: () => _delete(e)),
                    ],
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
