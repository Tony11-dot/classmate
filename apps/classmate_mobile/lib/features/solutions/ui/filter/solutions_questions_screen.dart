import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SolutionsQuestionsScreen extends StatelessWidget {
  const SolutionsQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final data = extra is Map
        ? Map<String, dynamic>.from(extra)
        : <String, dynamic>{};

    final subject = (data['subject'] ?? 'Subject').toString();
    final book = (data['book'] ?? 'Book').toString();
    final page = (data['page'] ?? '1').toString();
    final question = (data['question'] ?? '1').toString();

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Question results')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: cs.surfaceContainerLow.withValues(alpha: 0.88),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Page $page · Question $question',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.filter_alt_rounded, size: 38, color: cs.primary),
                const SizedBox(height: 10),
                Text(
                  'Filter applied',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Now wire this selection into the solutions feed query so the feed shows only matching solutions for this subject, book, page, and question.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.go('/solutions'),
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Back to solutions feed'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
