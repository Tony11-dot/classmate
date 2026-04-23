import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'mode_common.dart';

class AdaptiveModeView extends StatelessWidget {
  final ModeContextData d;
  const AdaptiveModeView({super.key, required this.d});

  String _difficultyLine(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final correct = d.state.stats.correct;
    final answered = d.state.stats.answered;
    if (answered == 0) return l.practiceModeAdaptiveWarmup;
    final ratio = correct / answered;
    if (ratio > 0.8) return l.practiceModeAdaptiveTrendingUp;
    if (ratio < 0.4) return l.practiceModeAdaptiveEasingDown;
    return l.practiceModeAdaptiveSteady;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return questionCard(
      d,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  d.accent.withValues(alpha: 0.18),
                  d.accent.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: d.accent.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: d.accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _difficultyLine(context),
                    style: d.theme.textTheme.labelLarge?.copyWith(
                      color: d.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
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
            explanationCard(d, title: l.practiceModeAdaptiveFeedback),
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
                child: sharedPrimaryActionButton(
                  d,
                  preAnswerLabel: l.practiceModeActionCheckAdapt,
                  postAnswerLabel: l.practiceModeActionContinue,
                  preAnswerIcon: Icons.auto_graph_rounded,
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
