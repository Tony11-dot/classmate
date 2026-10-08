import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'mode_common.dart';

class ExamPrepModeView extends StatelessWidget {
  final ModeContextData d;
  const ExamPrepModeView({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return questionCard(
      d,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          modeInfoStrip(
            d,
            icon: Icons.assignment_rounded,
            text: l.practiceModeExamPrepBanner,
          ),
          const SizedBox(height: 14),
          sessionProgressStrip(d),
          const SizedBox(height: 14),
          questionPromptPanel(d),
          const SizedBox(height: 16),
          answerList(d),
          const SizedBox(height: 12),
          answerFeedbackSection(d),
          const SizedBox(height: 14),
          if (d.showExplanation) ...[
            explanationCard(d, title: l.practiceModeReview),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              compactIconAction(
                onPressed: d.state.currentIndex > 0 ? d.previous : null,
                icon: Icons.arrow_back_rounded,
                tooltip: l.practiceModeActionPrevious,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    if (!d.answered) {
                      if (d.selectedIndex == null) return;
                      d.sessionCtl.submit(d.selectedIndex!);
                    }
                    d.next();
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(
                    l.practiceModeActionNextQuestion,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              novaHintAction(d),
              compactIconAction(
                onPressed: d.end,
                icon: Icons.close_rounded,
                tooltip: l.practiceModeActionEndExam,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
