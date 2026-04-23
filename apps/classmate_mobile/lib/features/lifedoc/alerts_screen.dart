import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../insights/providers/insights_providers.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(unifiedStudentInsightsProvider);
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (data) {
        final cards = <_AlertCard>[
          if ((data?.attendance.attendanceRate ?? 100) < 90)
            _AlertCard(
              tone: _AlertTone.warning,
              icon: Icons.warning_amber_rounded,
              title: l.alertsAttendanceTitle,
              body: l.alertsAttendanceBody(
                data!.attendance.attendanceRate!.toStringAsFixed(1),
              ),
            ),
          if ((data?.grades.weakestSubject ?? '').trim().isNotEmpty)
            _AlertCard(
              tone: _AlertTone.focus,
              icon: Icons.flag_rounded,
              title: l.alertsWeakestSubjectTitle,
              body: l.alertsWeakestSubjectBody(data!.grades.weakestSubject!),
            ),
          if (data?.practice.weakTopics.isNotEmpty == true)
            _AlertCard(
              tone: _AlertTone.focus,
              icon: Icons.psychology_rounded,
              title: l.alertsPracticeWeakAreaTitle,
              body: l.alertsPracticeWeakAreaBody(
                data!.practice.weakTopics.first.topicLabel,
                data.practice.weakTopics.first.subject,
              ),
            ),
          if ((data?.practice.trend?.deltaAccuracy ?? 0) < -5)
            _AlertCard(
              tone: _AlertTone.warning,
              icon: Icons.trending_down_rounded,
              title: l.alertsPracticeTrendDroppedTitle,
              body: l.alertsPracticeTrendDroppedBody,
            ),
        ];

        cards.sort((a, b) => a.tone == _AlertTone.warning ? -1 : 1);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            LiquidGlassCard(
              padding: const EdgeInsets.all(18),
              borderRadius: BorderRadius.circular(26),
              blurSigma: 18,
              gradient: LinearGradient(
                colors: [
                  cs.errorContainer.withValues(alpha: 0.86),
                  cs.tertiaryContainer.withValues(alpha: 0.66),
                ],
              ),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.alertsTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l.alertsSubtitle,
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (cards.isEmpty)
              _EmptyBody(
                message: l.alertsEmpty,
              )
            else
              ...cards.map(
                (card) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _AlertCardView(card: card),
                ),
              ),
          ],
        );
      },
    );
  }
}

enum _AlertTone { warning, focus }

class _AlertCard {
  const _AlertCard({
    required this.tone,
    required this.icon,
    required this.title,
    required this.body,
  });

  final _AlertTone tone;
  final IconData icon;
  final String title;
  final String body;
}

class _AlertCardView extends StatelessWidget {
  const _AlertCardView({required this.card});

  final _AlertCard card;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = card.tone == _AlertTone.warning
        ? cs.errorContainer.withValues(alpha: 0.72)
        : cs.primaryContainer.withValues(alpha: 0.72);

    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      blurSigma: 12,
      color: bg,
      border: Border.all(
        color: cs.outlineVariant.withValues(alpha: 0.16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: cs.surface.withValues(alpha: 0.7),
            child: Icon(card.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  card.body,
                  style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBody extends StatelessWidget {
  const _EmptyBody({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(18),
      blurSigma: 10,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
      border: Border.all(
        color: cs.outlineVariant.withValues(alpha: 0.16),
      ),
      child: Text(
        message,
        style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
      ),
    );
  }
}
