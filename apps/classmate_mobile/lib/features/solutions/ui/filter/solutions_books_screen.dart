import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/solutions_flow_provider.dart';

class SolutionsBooksScreen extends ConsumerWidget {
  const SolutionsBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(solutionsFlowProvider);
    final notifier = ref.read(solutionsFlowProvider.notifier);
    final books = notifier.booksForSelectedSubject();
    final subject = state.selectedSubject;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: IconButton(
                onPressed: () => context.go('/solutions'),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: Text(subject?.title ?? 'Books'),
              subtitle: const Text('Pick the book for the question you want.'),
            ),
            Expanded(
              child: subject == null
                  ? const Center(child: Text('Choose a subject first.'))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: books.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final book = books[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            notifier.selectBook(book);
                            context.go('/solutions/pages');
                          },
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHighest.withValues(
                                alpha: 0.75,
                              ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.menu_book_rounded),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    book.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
