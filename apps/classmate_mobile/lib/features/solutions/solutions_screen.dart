import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/widgets/glass_search_field.dart';
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
              padding: EdgeInsets.fromLTRB(
                16,
                16 + MediaQuery.paddingOf(context).top,
                16,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_rounded,
                              color: cs.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l.titleSolutions,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l.savedQuestionsOpenSolutionsSubtitle,
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  GlassSearchField(
                    hintText: l.assignmentsSearchSubjects,
                    controller: _searchCtrl,
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.separated(
                itemCount: subjects.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () {
                        notifier.selectSubject(subject);
                        context.push('/solutions/books');
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow.withValues(
                            alpha: 0.75,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: cs.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: cs.primaryContainer,
                              child: Icon(
                                solutionSubjectIcon(subject.id),
                                size: 22,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    solutionSubjectTitle(l, subject.id),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l.solutionsBookCount(subject.books.length),
                                    style: TextStyle(
                                      color: cs.onSurfaceVariant,
                                    ),
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
