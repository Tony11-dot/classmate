import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../providers/solutions_flow_provider.dart';

class SolutionsPagesScreen extends ConsumerStatefulWidget {
  const SolutionsPagesScreen({super.key});

  @override
  ConsumerState<SolutionsPagesScreen> createState() =>
      _SolutionsPagesScreenState();
}

class _SolutionsPagesScreenState extends ConsumerState<SolutionsPagesScreen> {
  late final TextEditingController _pageController;
  late final TextEditingController _questionController;

  @override
  void initState() {
    super.initState();
    final s = ref.read(solutionsFlowProvider);
    _pageController = TextEditingController(text: s.pageNumber);
    _questionController = TextEditingController(text: s.questionNumber);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(solutionsFlowProvider);
    final notifier = ref.read(solutionsFlowProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.filters),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: cs.primaryContainer,
                  child: Icon(
                    Icons.menu_book_rounded,
                    size: 20,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.selectedSubject?.title ?? l.assignmentsSubjectLabel,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        state.selectedBook?.title ?? l.solutionsBookLabel,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l.solutionsPagesFilterHint,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _pageController,
            keyboardType: TextInputType.number,
            onChanged: notifier.setPageNumber,
            decoration: InputDecoration(
              labelText: l.solutionsPageNumberLabel,
              hintText: l.solutionsPageNumberHint,
              prefixIcon: const Icon(Icons.menu_outlined),
              filled: true,
              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _questionController,
            keyboardType: TextInputType.text,
            onChanged: notifier.setQuestionNumber,
            decoration: InputDecoration(
              labelText: l.solutionsQuestionNumberLabel,
              hintText: l.solutionsQuestionNumberHint,
              prefixIcon: const Icon(Icons.help_outline_rounded),
              filled: true,
              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              notifier.selectQuestion(
                pageNumber: _pageController.text,
                questionNumber: _questionController.text,
              );
              context.push('/solutions/questions');
            },
            icon: const Icon(Icons.search_rounded),
            label: Text(l.solutionsViewSolutionsAction),
          ),
        ],
      ),
    );
  }
}
