import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/solutions_models.dart';
import '../../domain/solution_subjects.dart';
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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(solutionsFlowProvider);
    final notifier = ref.read(solutionsFlowProvider.notifier);
    final subject = state.selectedSubject;
    final allBooks = notifier.booksForSelectedSubject();
    final books = _filtered(allBooks);
    final cs = Theme.of(context).colorScheme;

    final subjectTitle =
        subject == null ? l.solutionsBooksTitle : solutionSubjectTitle(l, subject.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
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
                                ? l.solutionsNoBooksYetForStudents
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
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                _BookCover(book: book),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: const TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l.solutionsBookPagesCount(book.pageCount),
                                        style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5),
                                      ),
                                    ],
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

/// Book cover thumbnail — shows the uploaded image, or a book glyph fallback.
class _BookCover extends StatelessWidget {
  const _BookCover({required this.book});

  final SolutionBook book;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final url = (book.coverUrl ?? '').trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 46,
        height: 60,
        child: url.isEmpty
            ? Container(
                color: cs.secondaryContainer,
                child: Icon(Icons.menu_book_rounded, size: 22, color: cs.onSecondaryContainer),
              )
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(color: cs.surfaceContainerHighest),
                errorWidget: (_, _, _) => Container(
                  color: cs.secondaryContainer,
                  child: Icon(Icons.menu_book_rounded, size: 22, color: cs.onSecondaryContainer),
                ),
              ),
      ),
    );
  }
}
