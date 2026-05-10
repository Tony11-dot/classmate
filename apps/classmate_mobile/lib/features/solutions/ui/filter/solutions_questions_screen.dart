import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/solutions_api.dart';
import '../../data/solutions_live_mapper.dart';
import '../../domain/solutions_models.dart';
import '../widgets/solution_asset_preview_sheet.dart';
import '../../providers/solutions_flow_provider.dart';
import '../widgets/solution_upload_sheet_content.dart';
import '../../../../ui/widgets/cm_loading.dart';

final liveExactSolutionsPageProvider =
    FutureProvider.family<LiveSolutionsPage, int>((ref, page) async {
      final state = ref.watch(solutionsFlowProvider);
      final api = ref.watch(solutionsApiProvider);

      final subject = state.selectedSubject?.title;
      final bookTitle = state.selectedBook?.title;
      final pageNumber = int.tryParse(state.pageNumber.trim());
      final questionNumber = state.questionNumber.trim();

      final isAllQuestions =
          questionNumber.isEmpty || questionNumber == 'all';

      if ((subject ?? '').trim().isEmpty ||
          (bookTitle ?? '').trim().isEmpty ||
          pageNumber == null ||
          isAllQuestions) {
        // 'all' / empty → return empty here; liveSamePageSolutionsPageProvider
        // already shows everything on the page.
        return const LiveSolutionsPage(
          items: <QuestionSolutionCard>[],
          hasMore: false,
          page: 1,
        );
      }

      final raw = await api.fetchSolutions(
        subject: subject,
        bookTitle: bookTitle,
        pageNumber: pageNumber,
        questionNumber: questionNumber,
        page: page,
        limit: 10,
      );

      return SolutionsLiveMapper.mapPage(raw);
    });

final liveSamePageSolutionsPageProvider =
    FutureProvider.family<LiveSolutionsPage, int>((ref, page) async {
      final state = ref.watch(solutionsFlowProvider);
      final api = ref.watch(solutionsApiProvider);

      final subject = state.selectedSubject?.title;
      final bookTitle = state.selectedBook?.title;
      final pageNumber = int.tryParse(state.pageNumber.trim());

      if ((subject ?? '').trim().isEmpty ||
          (bookTitle ?? '').trim().isEmpty ||
          pageNumber == null) {
        return const LiveSolutionsPage(
          items: <QuestionSolutionCard>[],
          hasMore: false,
          page: 1,
        );
      }

      final raw = await api.fetchSolutions(
        subject: subject,
        bookTitle: bookTitle,
        pageNumber: pageNumber,
        page: page,
        limit: 10,
      );

      final mapped = SolutionsLiveMapper.mapPage(raw);
      final filtered = mapped.items
          .where((e) => e.questionNumber != state.questionNumber.trim())
          .toList(growable: false);

      return LiveSolutionsPage(
        items: filtered,
        hasMore: mapped.hasMore,
        page: mapped.page,
      );
    });

class SolutionsQuestionsScreen extends ConsumerStatefulWidget {
  const SolutionsQuestionsScreen({super.key});

  @override
  ConsumerState<SolutionsQuestionsScreen> createState() =>
      _SolutionsQuestionsScreenState();
}

class _SolutionsQuestionsScreenState
    extends ConsumerState<SolutionsQuestionsScreen> {
  int _exactPage = 1;
  int _samePagePage = 1;

  final List<QuestionSolutionCard> _exactItems = <QuestionSolutionCard>[];
  final List<QuestionSolutionCard> _samePageItems = <QuestionSolutionCard>[];

  void _resetAndRefresh() {
    setState(() {
      _exactPage = 1;
      _samePagePage = 1;
      _exactItems.clear();
      _samePageItems.clear();
    });
    ref.invalidate(liveExactSolutionsPageProvider(1));
    ref.invalidate(liveSamePageSolutionsPageProvider(1));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(solutionsFlowProvider);
    final exactAsync = ref.watch(liveExactSolutionsPageProvider(_exactPage));
    final samePageAsync = ref.watch(
      liveSamePageSolutionsPageProvider(_samePagePage),
    );
    final cs = Theme.of(context).colorScheme;
    final exactPage = exactAsync.maybeWhen(data: (v) => v, orElse: () => null);
    final samePagePage = samePageAsync.maybeWhen(
      data: (v) => v,
      orElse: () => null,
    );

    ref.listen<AsyncValue<LiveSolutionsPage>>(
      liveExactSolutionsPageProvider(_exactPage),
      (_, next) {
        next.whenData((page) {
          if (!mounted) return;
          setState(() {
            if (_exactPage == 1) {
              _exactItems
                ..clear()
                ..addAll(page.items);
            } else {
              final ids = _exactItems.map((e) => e.id).toSet();
              _exactItems.addAll(page.items.where((e) => !ids.contains(e.id)));
            }
          });
        });
      },
    );

    ref.listen<AsyncValue<LiveSolutionsPage>>(
      liveSamePageSolutionsPageProvider(_samePagePage),
      (_, next) {
        next.whenData((page) {
          if (!mounted) return;
          setState(() {
            if (_samePagePage == 1) {
              _samePageItems
                ..clear()
                ..addAll(page.items);
            } else {
              final ids = _samePageItems.map((e) => e.id).toSet();
              _samePageItems.addAll(
                page.items.where((e) => !ids.contains(e.id)),
              );
            }
          });
        });
      },
    );

    Future<void> openUploadSheet() => showSolutionUploadSheet(
      context,
      initialPageNumber: state.pageNumber,
      initialQuestionNumber: state.questionNumber,
      onSuccess: _resetAndRefresh,
    );


    final exactHasMore = exactPage?.hasMore ?? false;
    final samePageHasMore = samePagePage?.hasMore ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${state.selectedSubject?.title ?? l.titleSolutions} • ${state.selectedBook?.title ?? ''}',
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openUploadSheet,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l.solutionsUploadAction),
      ),
      body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Text(
              '${state.selectedSubject?.title ?? l.assignmentsSubjectLabel} • ${state.selectedBook?.title ?? l.solutionsBookLabel}',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              l.solutionsPageQuestionSummary(
                state.pageNumber.isEmpty ? '—' : state.pageNumber,
                (state.questionNumber.isEmpty ||
                        state.questionNumber == 'all')
                    ? 'All questions'
                    : state.questionNumber,
              ),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              title: l.solutionsExactQuestionTitle,
              subtitle: _exactItems.isEmpty
                  ? l.solutionsExactQuestionEmptySubtitle
                  : l.solutionsUploadsFound(_exactItems.length),
            ),
            const SizedBox(height: 10),
            if (exactAsync.isLoading && _exactItems.isEmpty)
              const Center(child: const CmLoading())
            else if (_exactItems.isEmpty)
              _EmptyCard(
                text: l.solutionsExactQuestionEmptyBody,
              )
            else ...[
              ..._exactItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SolutionCard(
                    item: item,
                  ),
                ),
              ),
              if (exactHasMore)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _exactPage += 1),
                    icon: const Icon(Icons.expand_more_rounded),
                    label: Text(l.solutionsLoadMoreAction),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            _SectionTitle(
              title: l.solutionsSamePageTitle,
              subtitle: _samePageItems.isEmpty
                  ? l.solutionsSamePageEmptySubtitle
                  : l.solutionsSamePageFallbackSubtitle,
            ),
            const SizedBox(height: 10),
            if (samePageAsync.isLoading && _samePageItems.isEmpty)
              const Center(child: const CmLoading())
            else if (_samePageItems.isEmpty)
              _EmptyCard(
                text: l.solutionsSamePageEmptyBody,
              )
            else ...[
              ..._samePageItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SolutionCard(
                    item: item,
                  ),
                ),
              ),
              if (samePageHasMore)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _samePagePage += 1),
                    icon: const Icon(Icons.expand_more_rounded),
                    label: Text(l.solutionsLoadMoreAction),
                  ),
                ),
            ],
          ],
        ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: cs.onSurfaceVariant)),
    );
  }
}

class _SolutionCard extends StatelessWidget {
  const _SolutionCard({required this.item});

  final QuestionSolutionCard item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(item.uploaderInitials)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.uploaderName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l.solutionsPageQuestionSummary(
                        item.pageNumber,
                        item.questionNumber,
                      ),
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (item.verifiedByNova)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(l.solutionsVerifiedByNova),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(item.caption),
          if ((item.verificationNote ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                item.verificationNote!,
                style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (item.assets.isNotEmpty)
            SolutionMediaStrip(assets: item.assets),
        ],
      ),
    );
  }
}
