import 'package:classmate_mobile/core/theme/cm_tokens.dart';
import 'package:classmate_mobile/ui/widgets/cm_press.dart';
import 'package:flutter/material.dart';

import '../../ui/widgets/cm_search_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'domain/solution_subjects.dart';
import 'providers/solutions_flow_provider.dart';
import 'ui/widgets/solution_upload_sheet_content.dart';

class SolutionsScreen extends ConsumerStatefulWidget {
  const SolutionsScreen({super.key});

  @override
  ConsumerState<SolutionsScreen> createState() => _SolutionsScreenState();
}

class _SolutionsScreenState extends ConsumerState<SolutionsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(solutionsFlowProvider);
    final notifier = ref.read(solutionsFlowProvider.notifier);
    // Filter by the LOCALIZED subject title so search works in any language.
    final query = state.searchQuery.trim().toLowerCase();
    final subjects = query.isEmpty
        ? state.subjects
        : state.subjects
            .where((s) => solutionSubjectTitle(l, s.id).toLowerCase().contains(query))
            .toList(growable: false);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSolutionUploadSheet(context),
        icon: const Icon(Icons.upload_rounded),
        label: Text(l.solutionsUploadAction),
      ),
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primaryContainer,
                          Color.alphaBlend(cs.primary.withValues(alpha: 0.14), cs.primaryContainer),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: CmTokens.of(context).shadowMd,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: cs.onPrimaryContainer.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.lightbulb_rounded, color: cs.onPrimaryContainer),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l.titleSolutions,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4,
                                      color: cs.onPrimaryContainer,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l.savedQuestionsOpenSolutionsSubtitle,
                          style: TextStyle(
                            color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  CmSearchField(
                    controller: _searchCtrl,
                    hint: l.assignmentsSearchSubjects,
                    onChanged: notifier.search,
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          if (subjects.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  state.searchQuery.trim().isEmpty
                      ? l.solutionsNoSubjectsAvailable
                      : l.solutionsNoSubjectsMatch(state.searchQuery),
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            )
          else
            // Subjects as a 2-column grid of big icon tiles.
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return CmPress(
                    onTap: () {
                      notifier.selectSubject(subject);
                      context.push('/solutions/books');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(CmTokens.radiusLg),
                        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3), width: 0.8),
                        boxShadow: CmTokens.of(context).shadowSm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: cs.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              solutionSubjectIcon(subject.id),
                              size: 26,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            solutionSubjectTitle(l, subject.id),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.2),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.menu_book_rounded, size: 14, color: cs.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  l.solutionsBookCount(subject.books.length),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
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
