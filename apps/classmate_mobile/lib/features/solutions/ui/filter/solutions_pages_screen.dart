import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final state = ref.read(solutionsFlowProvider);
    _pageController = TextEditingController(text: state.pageNumber);
    _questionController = TextEditingController(text: state.questionNumber);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(solutionsFlowProvider);
    final notifier = ref.read(solutionsFlowProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: IconButton(
                onPressed: () => context.go('/solutions/books'),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              title: Text(state.selectedBook?.title ?? 'Page and question'),
              subtitle: const Text(
                'Jump straight to a page and question number.',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Page number',
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.75),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: notifier.setPageNumber,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Question number',
                filled: true,
                fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.75),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: notifier.setQuestionNumber,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                notifier.selectQuestion(
                  pageNumber: _pageController.text,
                  questionNumber: _questionController.text,
                );
                context.go('/solutions/questions');
              },
              child: const Text('View solutions'),
            ),
          ],
        ),
      ),
    );
  }
}
