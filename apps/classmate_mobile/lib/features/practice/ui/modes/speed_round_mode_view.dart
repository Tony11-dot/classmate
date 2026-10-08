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
          modeInfoStrip(
            d,
            icon: Icons.flash_on_rounded,
            text: l.practiceModeSpeedRoundBanner,
            trailing: Text(
              l.practiceSetupSecondsShort(d.state.secondsRemaining),
              style: d.theme.textTheme.titleMedium?.copyWith(
                color: d.state.secondsRemaining <= 5
                    ? d.cs.error
                    : d.cs.onSurface,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
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
