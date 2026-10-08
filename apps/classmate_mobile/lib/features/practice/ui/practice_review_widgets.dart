import 'package:flutter/material.dart';

import '../../../core/theme/cm_tokens.dart';

/// Small round status mark on a review card (correct / wrong / skipped).
class ReviewStatusDot extends StatelessWidget {
  const ReviewStatusDot({super.key, required this.answered, required this.correct});

  final bool answered;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = !answered
        ? cs.surfaceContainerHighest
        : correct
        ? Colors.green
        : Colors.red;
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(
        !answered
            ? Icons.remove_rounded
            : correct
            ? Icons.check_rounded
            : Icons.close_rounded,
        size: 15,
        color: answered ? Colors.white : cs.onSurfaceVariant,
      ),
    );
  }
}

/// Answer text in a soft tinted box (green = correct, red = wrong).
class ReviewAnswerBox extends StatelessWidget {
  const ReviewAnswerBox({super.key, required this.child, this.tone});

  final Widget child;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = cs.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: tone == null
            ? cs.surfaceContainerHigh
            : tone!.withValues(alpha: dark ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(CmTokens.radiusSm),
      ),
      child: child,
    );
  }
}

/// Score colour shared by history/review: green ≥80%, amber ≥50%, else red.
Color practiceAccuracyColor(BuildContext context, int percent) {
  final tokens = CmTokens.of(context);
  if (percent >= 80) return tokens.good;
  if (percent >= 50) return tokens.warn;
  return Theme.of(context).colorScheme.error;
}

/// "8/10 · 80%" score pill tinted by accuracy.
class PracticeScorePill extends StatelessWidget {
  const PracticeScorePill({
    super.key,
    required this.correct,
    required this.answered,
    required this.percent,
  });

  final int correct;
  final int answered;
  final int percent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tone = practiceAccuracyColor(context, percent);
    final dark = cs.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: dark ? 0.22 : 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$correct/$answered · $percent%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: dark
              ? Color.lerp(tone, Colors.white, 0.35)
              : Color.lerp(tone, Colors.black, 0.25),
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
