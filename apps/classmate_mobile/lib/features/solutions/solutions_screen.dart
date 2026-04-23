import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import 'providers/solutions_flow_provider.dart';
import 'ui/widgets/solution_upload_sheet_content.dart';

IconData _subjectIcon(String title) {
  final t = title.toLowerCase();
  if (t.contains('math') || t.contains('calcul') || t.contains('algebra')) {
    return Icons.calculate_rounded;
  }
  if (t.contains('phys')) return Icons.science_rounded;
  if (t.contains('chem') || t.contains('bio')) return Icons.biotech_rounded;
  if (t.contains('cs') || t.contains('computer') || t.contains('algorithm')) {
    return Icons.computer_rounded;
  }
  if (t.contains('english') || t.contains('lang') || t.contains('lit')) {
    return Icons.translate_rounded;
  }
  if (t.contains('hist')) return Icons.history_edu_rounded;
  if (t.contains('geo')) return Icons.public_rounded;
  if (t.contains('econ') || t.contains('biz')) return Icons.bar_chart_rounded;
  return Icons.menu_book_rounded;
}

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
    final subjects = notifier.filteredSubjects();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSolutionUploadSheet(context),
        icon: const Icon(Icons.upload_rounded),
        label: Text(l.solutionsUploadAction),
      ),
      body: CustomScrollView(
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
                          cs.primaryContainer.withValues(alpha: 0.95),
                          cs.surfaceContainerHigh.withValues(alpha: 0.95),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.22),
                      ),
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
                  TextField(
                    controller: _searchCtrl,
                    onChanged: notifier.search,
                    decoration: InputDecoration(
                      hintText: l.assignmentsSearchSubjects,
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest.withValues(
                        alpha: 0.7,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
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
                      borderRadius: BorderRadius.circular(22),
                      onTap: () {
                        notifier.selectSubject(subject);
                        context.push('/solutions/books');
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest.withValues(
                            alpha: 0.75,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: cs.outlineVariant.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: cs.primaryContainer,
                              child: Icon(
                                _subjectIcon(subject.title),
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
                                    subject.title,
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
