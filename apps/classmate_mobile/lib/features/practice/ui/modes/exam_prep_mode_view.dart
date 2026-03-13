import 'package:flutter/material.dart';
import 'mode_common.dart';

class ExamPrepModeView extends StatelessWidget {
  final ModeContextData d;
  const ExamPrepModeView({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    return questionCard(
      d,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_rounded, color: d.accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Exam prep · quieter layout, answers reviewed after moving forward',
                  style: d.theme.textTheme.labelLarge?.copyWith(
                    color: d.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          sessionProgressStrip(d),
          const SizedBox(height: 14),
          MathView(d.promptOf()),
          const SizedBox(height: 16),
          answerList(d),
          const SizedBox(height: 12),
          answerFeedbackSection(d),
          const SizedBox(height: 14),
          if (d.showExplanation) ...[
            explanationCard(d, title: 'Review'),
            const SizedBox(height: 12),
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
                child: FilledButton.icon(
                  onPressed: () {
                    if (!d.answered) {
                      if (d.selectedIndex == null) return;
                      d.sessionCtl.submit(d.selectedIndex!);
                    }
                    d.next();
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    'Next question',
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
                tooltip: 'End exam',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
