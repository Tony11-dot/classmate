import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'mode_common.dart';

class BagrutModeView extends StatelessWidget {
  final ModeContextData d;
  const BagrutModeView({super.key, required this.d});

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
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: d.accent,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: d.accent),
            ),
            child: Row(
              children: [
                Icon(Icons.description_rounded, color: d.accent, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l.practiceModeBagrutBanner,
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
          questionPromptPanel(d),
          const SizedBox(height: 16),
          if (d.showExplanation) ...[
            explanationCard(d, title: l.practiceModeOfficialSolution),
            const SizedBox(height: 14),
          ],
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
                child: FilledButton.icon(
                  onPressed: () => d.onShowExplanation(!d.showExplanation),
                  icon: const Icon(Icons.description_rounded),
                  label: Text(
                    d.showExplanation
                        ? l.practiceModeActionHideSolution
                        : l.practiceModeActionShowSolution,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              compactIconAction(
                onPressed: d.end,
                icon: Icons.close_rounded,
                tooltip: l.practiceModeActionEndQuestion,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
