import 'package:flutter/material.dart';
import 'mode_common.dart';

class ConceptBuilderModeView extends StatelessWidget {
  final ModeContextData d;
  const ConceptBuilderModeView({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    return questionCard(
      d,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sessionProgressStrip(d),
          const SizedBox(height: 12),
          modeBanner(d),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: d.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: d.accent.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Concept first',
                  style: d.theme.textTheme.titleSmall?.copyWith(
                    color: d.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                MathView(d.explanationOf()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Now solve it',
            style: d.theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          MathView(d.promptOf()),
          const SizedBox(height: 16),
          answerList(d),
          const SizedBox(height: 12),
          answerFeedbackSection(d, explanationTitle: 'Concept'),
          const SizedBox(height: 14),
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
                  preAnswerLabel: 'Solve it',
                  postAnswerLabel: 'Next concept',
                  preAnswerIcon: Icons.school_rounded,
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
