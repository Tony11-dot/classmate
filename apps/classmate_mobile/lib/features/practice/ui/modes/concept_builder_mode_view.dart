import 'package:flutter/material.dart';
import '../../../../common/widgets/cm_ai_message.dart';
import '../../../../l10n/app_localizations.dart';
import 'mode_common.dart';

class ConceptBuilderModeView extends StatelessWidget {
  final ModeContextData d;
  const ConceptBuilderModeView({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
              color: d.accent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: d.accent),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.practiceModeConceptFirst,
                  style: d.theme.textTheme.titleSmall?.copyWith(
                    color: d.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                CMAiMessage(d.explanationOf(), compact: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.practiceModeNowSolveIt,
            style: d.theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          questionPromptPanel(d),
          const SizedBox(height: 16),
          answerList(d),
          const SizedBox(height: 12),
          answerFeedbackSection(d, explanationTitle: l.practiceModeConceptTitle),
          const SizedBox(height: 14),
          Row(
            children: [
              compactIconAction(
                onPressed: d.state.currentIndex > 0 ? d.previous : null,
                icon: Icons.arrow_back_rounded,
                tooltip: l.practiceModeActionPrevious,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: sharedPrimaryActionButton(
                  d,
                  preAnswerLabel: l.practiceModeActionSolveIt,
                  postAnswerLabel: l.practiceModeActionNextConcept,
                  preAnswerIcon: Icons.school_rounded,
                ),
              ),
              const SizedBox(width: 8),
              novaHintAction(d),
              compactIconAction(
                onPressed: d.end,
                icon: Icons.close_rounded,
                tooltip: l.practiceModeActionEndSession,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
