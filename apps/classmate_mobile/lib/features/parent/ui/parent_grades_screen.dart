import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/parent_models.dart';
import '../data/parent_repository.dart';

class ParentGradesScreen extends ConsumerWidget {
  const ParentGradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final studentId = ref.watch(selectedChildProvider);

    if (studentId == null) {
      return const _NoChildPicked(label: 'grades');
    }

    final grades = ref.watch(parentGradesProvider(studentId));

    return Scaffold(
      backgroundColor: cs.surface,
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(parentGradesProvider(studentId)),
        child: grades.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _Error(message: '$e'),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No grades yet.')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, i) => _GradeTile(grade: list[i]),
            );
          },
        ),
      ),
    );
  }
}

class _GradeTile extends StatelessWidget {
  const _GradeTile({required this.grade});
  final ParentGrade grade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              grade.scoreLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade.title?.isNotEmpty == true ? grade.title! : (grade.subject ?? 'Assignment'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if ((grade.subject ?? '').isNotEmpty && grade.title != null)
                  Text(
                    grade.subject!,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
                  ),
                if ((grade.createdAt ?? '').isNotEmpty)
                  Text(
                    grade.createdAt!,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) {
    return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(message)));
  }
}

class _NoChildPicked extends StatelessWidget {
  const _NoChildPicked({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Pick a child from the home screen to see their $label.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
