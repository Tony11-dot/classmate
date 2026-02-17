import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'assignments_controller.dart';

class AssignmentsCreateSheet extends ConsumerStatefulWidget {
  const AssignmentsCreateSheet({super.key});

  @override
  ConsumerState<AssignmentsCreateSheet> createState() =>
      _AssignmentsCreateSheetState();
}

class _AssignmentsCreateSheetState
    extends ConsumerState<AssignmentsCreateSheet> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final grade = TextEditingController(text: '10');
  final subjectId = TextEditingController(text: 'math');

  bool saving = false;
  String? err;

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    grade.dispose();
    subjectId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create Assignment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: desc,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: grade,
                      decoration: const InputDecoration(labelText: 'Grade'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: subjectId,
                      decoration: const InputDecoration(labelText: 'SubjectId'),
                    ),
                  ),
                ],
              ),
              if (err != null) ...[
                const SizedBox(height: 10),
                Text(err!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          setState(() {
                            saving = true;
                            err = null;
                          });
                          try {
                            final nav = Navigator.of(context);
                            final g = int.tryParse(grade.text.trim());
                            await ref
                                .read(assignmentsProvider.notifier)
                                .create(
                                  title: title.text.trim(),
                                  description: desc.text.trim().isEmpty
                                      ? null
                                      : desc.text.trim(),
                                  grade: g,
                                  subjectId: subjectId.text.trim().isEmpty
                                      ? null
                                      : subjectId.text.trim(),
                                );
                            if (mounted) nav.pop();
                          } catch (e) {
                            setState(() => err = e.toString());
                          } finally {
                            if (mounted) setState(() => saving = false);
                          }
                        },
                  child: Text(saving ? 'Creating…' : 'Create'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
