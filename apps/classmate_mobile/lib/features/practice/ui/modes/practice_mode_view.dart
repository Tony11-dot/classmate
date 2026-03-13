import 'package:flutter/material.dart';
import 'mode_common.dart';

class PracticeModeView extends StatelessWidget {
  final ModeContextData d;
  const PracticeModeView({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    return questionCard(
      d,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          defaultQuestionHeader(d),
          const SizedBox(height: 12),
          sessionProgressStrip(d),
          const SizedBox(height: 16),
          answerList(d),
          const SizedBox(height: 16),
          if (d.showExplanation) ...[
            answerFeedbackSection(d),
            const SizedBox(height: 14),
          ],
          Row(
            children: [
              compactIconAction(
                onPressed: d.state.currentIndex > 0 ? d.previous : null,
                icon: Icons.arrow_back_rounded,
                tooltip: 'Previous',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: sharedPrimaryActionButton(
                  d,
                  preAnswerLabel: 'Check answer',
                  postAnswerLabel: 'Next',
                  preAnswerIcon: Icons.check_rounded,
                ),
              ),
              const SizedBox(width: 8),
              novaHintAction(d),
              compactIconAction(
                onPressed: d.end,
                icon: Icons.close_rounded,
                tooltip: 'End session',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
