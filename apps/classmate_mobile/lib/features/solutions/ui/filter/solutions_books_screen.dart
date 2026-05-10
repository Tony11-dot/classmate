import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/solutions_models.dart';
import '../../providers/solutions_flow_provider.dart';

class SolutionsBooksScreen extends ConsumerStatefulWidget {
  const SolutionsBooksScreen({super.key});

  @override
  ConsumerState<SolutionsBooksScreen> createState() =>
      _SolutionsBooksScreenState();
}

class _SolutionsBooksScreenState extends ConsumerState<SolutionsBooksScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SolutionBook> _filtered(List<SolutionBook> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((b) => b.title.toLowerCase().contains(q)).toList();
  }

  Future<void> _showAddBookDialog(
    BuildContext context,
    String subjectId,
  ) async {
    final l = AppLocalizations.of(context)!;
    final titleCtrl = TextEditingController();
    final pagesCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.solutionsAddBookTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l.solutionsBookTitleHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pagesCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of pages',
                hintText: 'e.g. 240',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.tutorCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.solutionsAddBookAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final pageCount = int.tryParse(pagesCtrl.text.trim()) ?? 500;
    ref.read(solutionsFlowProvider.notifier)
        .addBook(subjectId, titleCtrl.text, pageCount: pageCount);
    titleCtrl.dispose();
    pagesCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(solutionsFlowProvider);
    final notifier = ref.read(solutionsFlowProvider.notifier);
    final subject = state.selectedSubject;
    final allBooks = notifier.booksForSelectedSubject();
    final books = _filtered(allBooks);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(subject?.title ?? l.solutionsBooksTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: subject == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showAddBookDialog(context, subject.id),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.solutionsAddBookAction),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l.solutionsSearchBooks,
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: subject == null
                ? Center(child: Text(l.solutionsChooseSubjectFirst))
                : books.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 52,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _query.trim().isEmpty
                                ? l.solutionsNoBooksYetBody(
                                    l.solutionsAddBookAction,
                                  )
                                : l.solutionsNoBooksMatch(_query),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                    itemCount: books.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            notifier.selectBook(book);
                            context.push('/solutions/pages');
                          },
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow.withValues(
                                alpha: 0.75,
                              ),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: cs.outlineVariant,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: cs.secondaryContainer,
                                  child: Icon(
                                    Icons.menu_book_rounded,
                                    size: 20,
                                    color: cs.onSecondaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 14),
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
