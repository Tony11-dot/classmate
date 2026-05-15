import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../providers/solutions_flow_provider.dart';

/// Special sentinel for "all questions on this page".
const String _kAllQuestions = 'all';
/// Displayed label for the sentinel.
const String _kAllLabel = 'All';

class SolutionsPagesScreen extends ConsumerStatefulWidget {
  const SolutionsPagesScreen({super.key});

  @override
  ConsumerState<SolutionsPagesScreen> createState() =>
      _SolutionsPagesScreenState();
}

class _SolutionsPagesScreenState extends ConsumerState<SolutionsPagesScreen> {
  late int _selectedPage;      // 1-based
  late int _selectedQuestion;  // 0 = All, 1..N = question numbers

  late FixedExtentScrollController _pageCtrl;
  late FixedExtentScrollController _questionCtrl;

  static const int _maxQuestions = 99;

  int get _maxPages =>
      ref.read(solutionsFlowProvider).selectedBook?.pageCount ?? 500;

  @override
  void initState() {
    super.initState();
    final s = ref.read(solutionsFlowProvider);

    _selectedPage = int.tryParse(s.pageNumber.trim()) ?? 1;
    final qStr = s.questionNumber.trim();
    _selectedQuestion = (qStr == _kAllQuestions || qStr.isEmpty)
        ? 0
        : (int.tryParse(qStr) ?? 0);

    _pageCtrl = FixedExtentScrollController(
        initialItem: (_selectedPage - 1).clamp(0, _maxPages - 1));
    _questionCtrl =
        FixedExtentScrollController(initialItem: _selectedQuestion);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _questionCtrl.dispose();
    super.dispose();
  }

  String get _questionValue =>
      _selectedQuestion == 0 ? _kAllQuestions : '$_selectedQuestion';

  void _search() {
    final notifier = ref.read(solutionsFlowProvider.notifier);
    notifier.selectQuestion(
      pageNumber: '$_selectedPage',
      questionNumber: _questionValue,
    );
    context.push('/solutions/questions');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final state = ref.watch(solutionsFlowProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final pageCount = state.selectedBook?.pageCount ?? 500;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.filters),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Book info banner ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(Icons.menu_book_rounded,
                          size: 18, color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.selectedSubject?.title ??
                                l.assignmentsSubjectLabel,
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          Text(
                            state.selectedBook?.title ?? l.solutionsBookLabel,
                            style: tt.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          if (pageCount < 9999)
                            Text('$pageCount pages',
                                style: tt.bodySmall
                                    ?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Labels ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(l.solutionsPageNumberLabel,
                          style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Center(
                      child: Text(l.solutionsQuestionNumberLabel,
                          style: tt.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── Drum pickers ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SolutionsDrumPicker(
                      controller: _pageCtrl,
                      itemCount: pageCount,
                      looping: true,
                      labelBuilder: (i) => '${i + 1}',
                      onChanged: (i) =>
                          setState(() => _selectedPage = i + 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('/',
                        style: tt.headlineMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ),
                  Expanded(
                    child: SolutionsDrumPicker(
                      controller: _questionCtrl,
                      itemCount: _maxQuestions + 1, // 0=All, 1..N
                      looping: false,
                      labelBuilder: (i) => i == 0 ? _kAllLabel : '$i',
                      onChanged: (i) =>
                          setState(() => _selectedQuestion = i),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Search button ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search_rounded),
                  label: Text(l.solutionsViewSolutionsAction),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Drum picker widget ────────────────────────────────────────────────────────

class SolutionsDrumPicker extends StatelessWidget {
  const SolutionsDrumPicker({super.key, 
    required this.controller,
    required this.itemCount,
    required this.labelBuilder,
    required this.onChanged,
    this.looping = true,
  });

  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onChanged;
  final bool looping;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const double itemExtent = 52;
    const double pickerHeight = 220;

    return SizedBox(
      height: pickerHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Selection highlight behind the wheel
          Positioned(
            left: 0, right: 0,
            child: Container(
              height: itemExtent,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: cs.primary.withValues(alpha: 0.25), width: 1.5),
              ),
            ),
          ),
          // The wheel itself
          CupertinoPicker(
            scrollController: controller,
            itemExtent: itemExtent,
            looping: looping,
            selectionOverlay: const SizedBox.shrink(),
            squeeze: 1.1,
            magnification: 1.18,
            useMagnifier: true,
            backgroundColor: Colors.transparent,
            onSelectedItemChanged: onChanged,
            children: List.generate(
              itemCount,
              (i) => Center(
                child: Text(
                  labelBuilder(i),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
