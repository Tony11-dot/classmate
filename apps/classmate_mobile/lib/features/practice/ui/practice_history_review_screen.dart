import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../common/widgets/cm_rich_content.dart';
import '../domain/practice_history_models.dart';
import '../domain/practice_models.dart';
import 'practice_display_text.dart';
import 'practice_mode_specs.dart';

class PracticeHistoryReviewScreen extends StatefulWidget {
  final PracticeHistorySession session;

  const PracticeHistoryReviewScreen({super.key, required this.session});

  @override
  State<PracticeHistoryReviewScreen> createState() =>
      _PracticeHistoryReviewScreenState();
}

enum _SavedReviewFilter { all, wrong, correct }

String _practiceModeLabel(BuildContext context, PracticeMode mode) {
  final l = AppLocalizations.of(context)!;
  switch (mode) {
    case PracticeMode.practice:
      return l.practiceSetupModeLabelPractice;
    case PracticeMode.flashcards:
      return l.practiceSetupModeLabelFlashcards;
    case PracticeMode.speedRound:
      return l.practiceSetupModeLabelSpeedRound;
    case PracticeMode.examPrep:
      return l.practiceSetupModeLabelExamPrep;
    case PracticeMode.conceptBuilder:
      return l.practiceSetupModeLabelConceptBuilder;
    case PracticeMode.adaptive:
      return l.practiceSetupModeLabelAdaptive;
    case PracticeMode.bagrut:
      return l.practiceSetupModeLabelBagrut;
  }
}

class _PracticeHistoryReviewScreenState
    extends State<PracticeHistoryReviewScreen> {
  _SavedReviewFilter _filter = _SavedReviewFilter.all;
  bool _focus = false;
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final accent = practiceModeColor(widget.session.mode);

    final questions = widget.session.questions.where((q) {
      return switch (_filter) {
        _SavedReviewFilter.all => true,
        _SavedReviewFilter.wrong => !q.isCorrect,
        _SavedReviewFilter.correct => q.isCorrect,
      };
    }).toList();

    if (_index >= questions.length && questions.isNotEmpty) {
      _index = questions.length - 1;
    }
    if (questions.isEmpty) {
      _index = 0;
    }

    final visible = _focus && questions.isNotEmpty
        ? <PracticeHistoryQuestion>[questions[_index]]
        : questions;

    return Scaffold(
      appBar: AppBar(title: Text(l.practiceSessionReviewTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: accent.withValues(alpha: 0.24)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.16),
                  accent.withValues(alpha: 0.06),
                ],
              ),
            ),
            child: Column(
              children: [
                Icon(
                  practiceModeIcon(widget.session.mode),
                  color: accent,
                  size: 44,
                ),
                const SizedBox(height: 10),
                Text(
                  localizedPracticeSubjectAndTopic(
                    context,
                    subject: widget.session.subject,
                    topicLabel: widget.session.topicLabel,
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_practiceModeLabel(context, widget.session.mode)} • ${widget.session.correct}/${widget.session.answered} • ${widget.session.accuracyPercent}% • ${l.practiceSessionMetricXp} ${widget.session.xp}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: Text(l.practiceSessionFilterAll),
                selected: _filter == _SavedReviewFilter.all,
                onSelected: (_) => setState(() {
                  _filter = _SavedReviewFilter.all;
                  _index = 0;
                }),
              ),
              ChoiceChip(
                label: Text(l.practiceSessionFilterWrong),
                selected: _filter == _SavedReviewFilter.wrong,
                onSelected: (_) => setState(() {
                  _filter = _SavedReviewFilter.wrong;
                  _index = 0;
                }),
              ),
              ChoiceChip(
                label: Text(l.practiceSessionFilterCorrect),
                selected: _filter == _SavedReviewFilter.correct,
                onSelected: (_) => setState(() {
                  _filter = _SavedReviewFilter.correct;
                  _index = 0;
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(
                value: false,
                label: Text(l.practiceSessionReviewLayoutStacked),
              ),
              ButtonSegment(
                value: true,
                label: Text(l.practiceSessionReviewLayoutFocus),
              ),
            ],
            selected: {_focus},
            onSelectionChanged: (v) {
              setState(() {
                _focus = v.first;
                _index = 0;
              });
            },
          ),
          const SizedBox(height: 12),
          if (questions.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                l.practiceSessionNoQuestionsForFilter,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ...visible.map((q) {
            final selectedLabel =
                (q.selectedIndex != null &&
                    q.selectedIndex! >= 0 &&
                    q.selectedIndex! < q.options.length)
                ? q.options[q.selectedIndex!]
              : l.practiceSessionNoAnswer;

            final correctLabel =
                (q.correctIndex >= 0 && q.correctIndex < q.options.length)
                ? q.options[q.correctIndex]
              : l.practiceSessionUnknownAnswer;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: q.isCorrect
                        ? Colors.green.withValues(alpha: 0.30)
                        : cs.outlineVariant.withValues(alpha: 0.32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            localizedPracticeTopicLabel(
                              context,
                              q.topicLabel,
                            ),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Icon(
                          q.isCorrect
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          color: q.isCorrect ? Colors.green : Colors.red,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DefaultTextStyle.merge(
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                      child: CMRichContent(data: q.prompt),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l.practiceSessionYourAnswer,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CMRichContent(data: selectedLabel),
                    const SizedBox(height: 10),
                    Text(
                      l.practiceSessionCorrectAnswer,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CMRichContent(data: correctLabel),
                    const SizedBox(height: 10),
                    Text(
                      l.practiceSessionExplanation,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    CMRichContent(data: q.explanation),
                  ],
                ),
              ),
            );
          }),
          if (_focus && questions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: _index > 0
                        ? () => setState(() => _index--)
                        : null,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '${_index + 1} / ${questions.length}',
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded),
                    onPressed: _index < questions.length - 1
                        ? () => setState(() => _index++)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
