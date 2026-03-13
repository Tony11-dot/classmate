import 'package:flutter/material.dart';
import 'mode_common.dart';

class BagrutModeView extends StatelessWidget {
  final ModeContextData d;
  const BagrutModeView({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    return questionCard(
      d,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: d.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: d.accent.withValues(alpha: 0.22)),
            ),
            child: Row(
              children: [
                Icon(Icons.description_rounded, color: d.accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bagrut mode · official-style paper flow',
                    style: d.theme.textTheme.labelLarge?.copyWith(
                      color: d.accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          sessionProgressStrip(d),
          const SizedBox(height: 14),
          MathView(d.promptOf()),
          const SizedBox(height: 16),
          if (d.showExplanation) ...[
            explanationCard(d, title: 'Official-style solution'),
            const SizedBox(height: 14),
          ],
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
                child: FilledButton.icon(
                  onPressed: () => d.onShowExplanation(!d.showExplanation),
                  icon: const Icon(Icons.description_rounded),
                  label: Text(
                    d.showExplanation ? 'Hide solution' : 'Show solution',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              compactIconAction(
                onPressed: d.end,
                icon: Icons.close_rounded,
                tooltip: 'End question',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
