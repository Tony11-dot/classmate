import 'package:flutter/material.dart';

import '../../../core/theme/cm_tokens.dart';

/// Exam year as a calendar-like badge on the left of an exam row.
class BagrutYearStub extends StatelessWidget {
  const BagrutYearStub({super.key, required this.year});

  final int year;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 54,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(
          alpha: cs.brightness == Brightness.dark ? 0.22 : 0.12,
        ),
        borderRadius: BorderRadius.circular(CmTokens.radiusSm),
      ),
      child: Text(
        '$year',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
