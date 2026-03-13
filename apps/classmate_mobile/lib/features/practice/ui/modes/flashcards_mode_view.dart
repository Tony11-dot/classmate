import 'package:flutter/material.dart';
import 'mode_common.dart';

class FlashcardsModeView extends StatelessWidget {
  final ModeContextData d;
  const FlashcardsModeView({super.key, required this.d});

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
              border: Border.all(color: d.accent.withValues(alpha: 0.22)),
            ),
            child: d.showExplanation
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Back of card',
                        style: d.theme.textTheme.labelLarge?.copyWith(
                          color: d.accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      explanationCard(d, title: 'Recall summary'),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Front of card',
                        style: d.theme.textTheme.labelLarge?.copyWith(
                          color: d.accent,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      MathView(d.promptOf()),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: d.openNova,
                  icon: const Icon(Icons.tips_and_updates_rounded),
                  label: const Text(
                    'NOVA hint',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    if (!d.showExplanation) {
                      d.onShowExplanation(true);
                      if (!d.answered) {
                        d.sessionCtl.submit(d.q?.correctIndex ?? 0);
                      }
                      return;
                    }
                    d.next();
                  },
                  icon: Icon(
                    d.showExplanation
                        ? Icons.arrow_forward_rounded
                        : Icons.visibility_rounded,
                  ),
                  label: Text(
                    d.showExplanation ? 'Next card' : 'Reveal',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
