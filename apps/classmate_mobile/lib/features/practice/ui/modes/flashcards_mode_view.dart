import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'mode_common.dart';

class FlashcardsModeView extends StatelessWidget {
  final ModeContextData d;
  const FlashcardsModeView({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final correctIndex = d.q?.correctIndex ?? 0;
    final fallbackWrongIndex = d.options.isEmpty
        ? 0
        : d.options.asMap().keys.firstWhere(
            (i) => i != correctIndex,
            orElse: () => 0,
          );

    void reflect(bool knewIt) {
      if (!d.answered) {
        d.sessionCtl.submit(knewIt ? correctIndex : fallbackWrongIndex);
      }
      d.next();
    }

    return questionCard(
      d,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          defaultQuestionHeader(d),
          const SizedBox(height: 12),
          sessionProgressStrip(d),
          const SizedBox(height: 18),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: d.accent.withValues(
                alpha: d.showExplanation ? 0.12 : 0.06,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: d.accent),
            ),
            child: d.showExplanation
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.practiceSessionBackOfCard,
                        style: d.theme.textTheme.labelLarge?.copyWith(
                          color: d.accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      explanationCard(d, title: l.practiceModeRecallSummary),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.practiceModeCardFront,
                        style: d.theme.textTheme.labelLarge?.copyWith(
                          color: d.accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      questionPromptPanel(d, withSave: false),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          if (!d.showExplanation)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: d.openNova,
                    icon: const Icon(Icons.tips_and_updates_rounded),
                    label: Text(
                      l.practiceModeActionNovaHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => d.onShowExplanation(true),
                    icon: const Icon(Icons.visibility_rounded),
                    label: Text(
                      l.practiceModeActionReveal,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                compactIconAction(
                  onPressed: d.end,
                  icon: Icons.close_rounded,
                  tooltip: l.practiceModeActionEndSession,
                ),
              ],
            )
          else ...[
            Text(
              l.practiceModeFeelingPrompt,
              style: d.theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () => reflect(false),
                  child: Text(l.practiceModeFeelingAgain),
                ),
                OutlinedButton(
                  onPressed: () => reflect(false),
                  child: Text(l.practiceModeFeelingHard),
                ),
                FilledButton(
                  onPressed: () => reflect(true),
                  child: Text(l.practiceModeFeelingGood),
                ),
                FilledButton(
                  onPressed: () => reflect(true),
                  child: Text(l.practiceModeFeelingEasy),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: novaHintAction(d)),
                const SizedBox(width: 8),
                compactIconAction(
                  onPressed: d.end,
                  icon: Icons.close_rounded,
                  tooltip: l.practiceModeActionEndSession,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
