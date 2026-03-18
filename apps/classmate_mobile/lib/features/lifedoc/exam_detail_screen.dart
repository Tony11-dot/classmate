import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/exams_repository.dart';

class ExamDetailScreen extends ConsumerWidget {
  const ExamDetailScreen({super.key, required this.examId});

  final String examId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exam = ref.read(examsRepositoryProvider).byId(examId);
    final cs = Theme.of(context).colorScheme;

    Widget line(String label, String? value) {
      if ((value ?? '').trim().isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
            children: [
              TextSpan(
                text: '$label: ',
                style: TextStyle(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(text: value),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(exam.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exam.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                line('Subject', exam.subject),
                line('Topic', exam.topic),
                line('Teacher', exam.teacher),
                line('Date', exam.dateLabel),
                line('Hour', exam.hourLabel),
                line('Period', exam.periodLabel),
                line('Duration', exam.durationLabel),
                line('Audience', exam.audience.label),
                line('Caption', exam.caption),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attached materials',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                if (exam.materials.isEmpty)
                  Text(
                    'No materials attached yet.',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  )
                else
                  ...exam.materials.map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.7,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.attach_file_rounded),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${m.name} • ${m.kind}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cs.surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart prep',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Jump into NOVA with this exact exam context, or review subject-level signals from Insights before you study.',
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () => context.push(
                        Uri(
                          path: '/tutor',
                          queryParameters: {
                            'title': exam.title,
                            'subject': exam.subject,
                            'prompt':
                                'Help me prepare for ${exam.title} in ${exam.subject}. Focus on ${exam.topic ?? exam.subject}.',
                          },
                        ).toString(),
                      ),
                      icon: const Icon(Icons.psychology_rounded),
                      label: const Text('Study with NOVA'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/insights'),
                      icon: const Icon(Icons.insights_rounded),
                      label: const Text('Open Insights'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.event_available_rounded),
                      label: const Text('Add to calendar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
