import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/exams_repository.dart';
import 'domain/exam_models.dart';

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final exams = ref.read(examsRepositoryProvider).list();
    final cs = Theme.of(context).colorScheme;

    final filtered = filter == 'All'
        ? exams
        : exams.where((e) => e.subject == filter).toList(growable: false);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exams',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'All your upcoming exams, filters, and fast prep entry points in one clean place.',
                style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Math', 'Physics', 'Computer Science']
                    .map(
                      (x) => ChoiceChip(
                        label: Text(x),
                        selected: filter == x,
                        onSelected: (_) => setState(() => filter = x),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...filtered.map(
          (exam) => InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/exams/${exam.id}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam.title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    exam.topic == null || exam.topic!.trim().isEmpty
                        ? exam.subject
                        : '${exam.subject} • ${exam.topic}',
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                          exam.dateLabel,
                          exam.hourLabel,
                          exam.periodLabel,
                          exam.durationLabel,
                        ]
                        .whereType<String>()
                        .where((e) => e.trim().isNotEmpty)
                        .join(' • '),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaPill(label: exam.audience.label),
                      _MetaPill(label: '${exam.materials.length} materials'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}
