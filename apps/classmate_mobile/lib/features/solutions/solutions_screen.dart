import 'package:flutter/material.dart';

class SolutionsScreen extends StatelessWidget {
  const SolutionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _Solution(
        subject: 'Math',
        title: 'Limits — step-by-step',
        prompt: 'Find lim(x→2) (x^2-4)/(x-2)',
        stats: '214 likes • 38 comments',
      ),
      _Solution(
        subject: 'Physics',
        title: 'Free fall — quick method',
        prompt: 'A ball is dropped from 20m. Find time to hit the ground.',
        stats: '131 likes • 19 comments',
      ),
      _Solution(
        subject: 'CS',
        title: 'Big-O intuition',
        prompt: 'Explain why binary search is O(log n).',
        stats: '89 likes • 12 comments',
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _Card(item: items[i]),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.item});
  final _Solution item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _Pill(item.subject),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_outline),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(item.prompt, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.favorite_border, size: 18),
                const SizedBox(width: 10),
                const Icon(Icons.chat_bubble_outline, size: 18),
                const SizedBox(width: 10),
                const Icon(Icons.upload_file, size: 18),
                const Spacer(),
                Text(item.stats, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Solution {
  _Solution({
    required this.subject,
    required this.title,
    required this.prompt,
    required this.stats,
  });
  final String subject;
  final String title;
  final String prompt;
  final String stats;
}
