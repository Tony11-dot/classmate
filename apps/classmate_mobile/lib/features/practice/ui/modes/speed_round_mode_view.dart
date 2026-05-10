import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'mode_common.dart';

class SpeedRoundModeView extends StatelessWidget {
  final ModeContextData d;
  const SpeedRoundModeView({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return questionCard(
      d,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: d.accent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: d.accent),
            ),
            child: Row(
              children: [
                Icon(Icons.flash_on_rounded, color: d.accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.practiceModeSpeedRoundBanner,
                    style: d.theme.textTheme.labelLarge?.copyWith(
                      color: d.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  l.practiceSetupSecondsShort(d.state.secondsRemaining),
                  style: d.theme.textTheme.titleMedium?.copyWith(
                    color: d.accent,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          sessionProgressStrip(d),
          const SizedBox(height: 14),
          questionPromptPanel(d),
          const SizedBox(height: 14),
          answerList(d),
          const SizedBox(height: 12),
          answerFeedbackSection(d),
          const SizedBox(height: 12),
          if (d.showExplanation) ...[
            explanationCard(d, title: l.practiceModeFastFeedback),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              Expanded(
                child: sharedPrimaryActionButton(
                  d,
                  preAnswerLabel: l.practiceModeActionLockIn,
                  postAnswerLabel: l.practiceModeActionNext,
                  preAnswerIcon: Icons.bolt_rounded,
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
