import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/solutions_api.dart';
import '../../data/solutions_live_mapper.dart';
import '../../domain/solutions_models.dart';
import '../../domain/solution_subjects.dart';
import '../widgets/solution_asset_preview_sheet.dart';
import '../../providers/solutions_flow_provider.dart';
import '../widgets/solution_upload_sheet_content.dart';
import '../../../../ui/widgets/cm_loading.dart';

final liveExactSolutionsPageProvider =
    FutureProvider.family<LiveSolutionsPage, int>((ref, page) async {
      final state = ref.watch(solutionsFlowProvider);
      final api = ref.watch(solutionsApiProvider);

      final subject = state.selectedSubject?.id;
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

      final subject = state.selectedSubject?.id;
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

    final subjectLabel = state.selectedSubject == null
        ? l.titleSolutions
        : solutionSubjectTitle(l, state.selectedSubject!.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$subjectLabel • ${state.selectedBook?.title ?? ''}',
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
              '$subjectLabel • ${state.selectedBook?.title ?? l.solutionsBookLabel}',
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
              const Center(child: CmLoading())
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
              const Center(child: CmLoading())
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

class _SolutionCard extends ConsumerWidget {
  const _SolutionCard({required this.item});

  final QuestionSolutionCard item;

  /// "Grade 10 • Northside High" — drops whichever piece is missing.
  String _authorMeta(AppLocalizations l) {
    final parts = <String>[];
    if (item.grade != null) parts.add(l.solutionsGradeLabel(item.grade!));
    if ((item.schoolName ?? '').trim().isNotEmpty) parts.add(item.schoolName!.trim());
    return parts.join(' • ');
  }

  Future<void> _report(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.solutionsReportTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.solutionsReportBody, style: Theme.of(ctx).textTheme.bodyMedium),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l.solutionsReportReasonHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.tutorCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.solutionsReportAction)),
        ],
      ),
    );
    final reason = reasonCtrl.text;
    reasonCtrl.dispose();
    if (confirmed != true || !context.mounted) return;

    try {
      final res = await ref.read(solutionsApiProvider).reportSolution(
            uploadId: item.id,
            reason: reason,
          );
      if (!context.mounted) return;
      final already = res['alreadyReported'] == true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(already ? l.solutionsReportAlready : l.solutionsReportSubmitted)),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.solutionsReportFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final meta = _authorMeta(l);
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(meta, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5)),
                    ],
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
              IconButton(
                tooltip: l.solutionsReportAction,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.flag_outlined, size: 20, color: cs.onSurfaceVariant),
                onPressed: () => _report(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(item.caption),
          const SizedBox(height: 12),
          if (item.assets.isNotEmpty)
            SolutionMediaStrip(assets: item.assets),
        ],
      ),
    );
  }
}
