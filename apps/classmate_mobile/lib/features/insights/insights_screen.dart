import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../lifedoc/announcements_provider.dart';
import 'domain/insights_models.dart';
import 'providers/insights_providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  void _openTutorFromInsights(
    BuildContext context, {
    required String prompt,
    String? title,
    String? subject,
  }) {
    context.go(
      Uri(
        path: '/tutor',
        queryParameters: {
          if (prompt.trim().isNotEmpty) 'prompt': prompt.trim(),
          if ((title ?? '').trim().isNotEmpty) 'title': title!.trim(),
          if ((subject ?? '').trim().isNotEmpty) 'subject': subject!.trim(),
        },
      ).toString(),
    );
  }

  String _fmtPercent(double? value) {
    if (value == null) return '—';
    return '${value.toStringAsFixed(1)}%';
  }

  String _fmtNum(num? value) {
    if (value == null) return '—';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  String _trendLabel(UnifiedPracticeTrend? trend) {
    final delta = trend?.deltaAccuracy;
    if (delta == null) return 'Baseline';
    if (delta >= 6) return 'Improving';
    if (delta <= -6) return 'Dropping';
    return 'Stable';
  }

  IconData _trendIcon(UnifiedPracticeTrend? trend) {
    final delta = trend?.deltaAccuracy;
    if (delta == null) return Icons.timeline_rounded;
    if (delta >= 6) return Icons.trending_up_rounded;
    if (delta <= -6) return Icons.trending_down_rounded;
    return Icons.show_chart_rounded;
  }

  String _predictiveHeadline(
    UnifiedStudentInsights unified,
    List<dynamic> announcements,
  ) {
    final avg = unified.grades.average ?? 100;
    final rate = unified.attendance.attendanceRate ?? 100;
    final delta = unified.practice.trend?.deltaAccuracy ?? 0;

    if (avg < 70 || rate < 85 || delta <= -6) {
      return 'Intervention window is open';
    }
    if (announcements.length >= 3) {
      return 'Several signals need tightening';
    }
    return 'Momentum can compound this week';
  }

  String _predictiveBody(UnifiedStudentInsights unified) {
    final weak = (unified.grades.weakestSubject ?? '').trim();
    final best = (unified.grades.bestSubject ?? '').trim();
    final rate = unified.attendance.attendanceRate ?? 100;
    final delta = unified.practice.trend?.deltaAccuracy ?? 0;

    if (rate < 85) {
      return 'Protect attendance first. Better presence now will raise every other signal faster.';
    }
    if (weak.isNotEmpty && delta <= -6) {
      return '$weak plus a falling practice trend is the biggest risk combo right now. Fix that before expanding.';
    }
    if (best.isNotEmpty) {
      return '$best is your leverage point. Use it to build confidence while you patch weaker areas.';
    }
    return 'Keep stacking short focused sessions. The next few days matter more than a perfect long-term plan.';
  }

  List<_PredictiveCardVm> _predictiveCards(
    UnifiedStudentInsights unified,
    List<dynamic> announcements,
  ) {
    final weakTopic = unified.practice.weakTopics.isNotEmpty
        ? unified.practice.weakTopics.first
        : null;

    return <_PredictiveCardVm>[
      _PredictiveCardVm(
        title: 'Intervention score',
        body:
            '${announcements.length} active signal${announcements.length == 1 ? '' : 's'} are shaping your next move.',
        icon: Icons.crisis_alert_rounded,
      ),
      _PredictiveCardVm(
        title: 'Fastest recovery path',
        body: weakTopic == null
            ? 'Attendance + consistency first.'
            : 'Revisit ${weakTopic.topicLabel} in ${weakTopic.subject} before pushing harder.',
        icon: Icons.route_rounded,
      ),
      _PredictiveCardVm(
        title: 'Projected direction',
        body:
            '${_trendLabel(unified.practice.trend)} based on recent 7d vs 30d practice behavior.',
        icon: _trendIcon(unified.practice.trend),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unifiedAsync = ref.watch(unifiedStudentInsightsProvider);
    final aiAsync = ref.watch(aiInsightsSummaryProvider);
    final announcements = ref.watch(announcementsProvider);
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(unifiedStudentInsightsProvider);
        ref.invalidate(aiInsightsSummaryProvider);
        ref.invalidate(serverInsightsProvider);
        await Future.wait([
          ref.read(unifiedStudentInsightsProvider.future),
          ref.read(aiInsightsSummaryProvider.future),
          ref.read(serverInsightsProvider.future),
        ]);
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          unifiedAsync.when(
            loading: () => const _StateCard(
              title: 'Insights loading',
              subtitle: 'Building your predictive dashboard.',
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (error, _) => _StateCard(
              title: 'Insights are not ready yet',
              subtitle: error.toString(),
              child: const SizedBox.shrink(),
            ),
            data: (unified) {
              if (unified == null) {
                return const _StateCard(
                  title: 'No insight signal yet',
                  subtitle:
                      'Start practicing and using school tools so ClassMate can build your academic picture.',
                  child: SizedBox.shrink(),
                );
              }

              final predictive = _predictiveCards(unified, announcements);

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primaryContainer.withValues(alpha: 0.96),
                          cs.secondaryContainer.withValues(alpha: 0.82),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Insights v3',
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _predictiveHeadline(unified, announcements),
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _predictiveBody(unified),
                          style: text.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _HeroMetric(
                                label: 'Grade avg',
                                value: _fmtNum(unified.grades.average),
                                icon: Icons.grade_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _HeroMetric(
                                label: 'Attendance',
                                value: _fmtPercent(
                                  unified.attendance.attendanceRate,
                                ),
                                icon: Icons.how_to_reg_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _HeroMetric(
                                label: 'Accuracy',
                                value: _fmtPercent(
                                  unified.practice.overallAccuracy * 100,
                                ),
                                icon: Icons.check_circle_rounded,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _ActionChip(
                              icon: Icons.psychology_alt_rounded,
                              label: 'Open NOVA',
                              onTap: () => _openTutorFromInsights(
                                context,
                                prompt:
                                    'Help me fix my weakest area based on my latest ClassMate insights.',
                                title: 'Predictive recovery plan',
                              ),
                            ),
                            _ActionChip(
                              icon: Icons.play_circle_fill_rounded,
                              label: 'Practice now',
                              onTap: () => context.go('/practice'),
                            ),
                            _ActionChip(
                              icon: Icons.campaign_rounded,
                              label: 'Announcements',
                              onTap: () => context.go('/announcements'),
                            ),
                            _ActionChip(
                              icon: Icons.notifications_active_rounded,
                              label: 'Notifications',
                              onTap: () => context.go('/notifications'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StateCard(
                    title: 'Predictive modules',
                    subtitle:
                        'The strongest forward-looking signals from your current student data.',
                    child: Column(
                      children: predictive
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _PredictiveCard(item: item),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StateCard(
                    title: 'Announcements pressure',
                    subtitle:
                        'The announcement engine is now feeding the dashboard directly.',
                    child: Column(
                      children: announcements
                          .take(3)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _MiniLine(
                                label: item.source.toUpperCase(),
                                value: item.title,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  aiAsync.when(
                    loading: () => const _StateCard(
                      title: 'AI coach summary',
                      subtitle: 'Loading AI guidance.',
                      child: SizedBox(
                        height: 60,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    error: (error, _) => _StateCard(
                      title: 'AI coach summary',
                      subtitle: error.toString(),
                      child: const SizedBox.shrink(),
                    ),
                    data: (ai) {
                      if (ai == null) {
                        return const _StateCard(
                          title: 'AI coach summary',
                          subtitle: 'No AI summary yet.',
                          child: SizedBox.shrink(),
                        );
                      }

                      return _StateCard(
                        title: ai.headline.isEmpty
                            ? 'AI coach summary'
                            : ai.headline,
                        subtitle: ai.summary,
                        child: Column(
                          children: [
                            ...ai.cards
                                .take(3)
                                .map(
                                  (card) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _MiniLine(
                                      label: card.title,
                                      value: card.body,
                                    ),
                                  ),
                                ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FilledButton.icon(
                                onPressed: () => _openTutorFromInsights(
                                  context,
                                  prompt: ai.suggestedPrompt.isEmpty
                                      ? 'Build me a recovery plan from my latest insights.'
                                      : ai.suggestedPrompt,
                                  title: 'AI study coach',
                                ),
                                icon: const Icon(Icons.psychology_alt_rounded),
                                label: const Text('Ask NOVA'),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _StateCard(
                    title: 'School tools',
                    subtitle:
                        'Jump directly into the student routes that now matter most.',
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ActionChip(
                          icon: Icons.grade_rounded,
                          label: 'Grades',
                          onTap: () => context.go('/grades'),
                        ),
                        _ActionChip(
                          icon: Icons.how_to_reg_rounded,
                          label: 'Attendance',
                          onTap: () => context.go('/attendance'),
                        ),
                        _ActionChip(
                          icon: Icons.notifications_rounded,
                          label: 'Notifications',
                          onTap: () => context.go('/notifications'),
                        ),
                        _ActionChip(
                          icon: Icons.campaign_rounded,
                          label: 'Announcements',
                          onTap: () => context.go('/announcements'),
                        ),
                        _ActionChip(
                          icon: Icons.lightbulb_rounded,
                          label: 'Solutions',
                          onTap: () => context.go('/solutions'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PredictiveCardVm {
  final String title;
  final String body;
  final IconData icon;

  const _PredictiveCardVm({
    required this.title,
    required this.body,
    required this.icon,
  });
}

class _PredictiveCard extends StatelessWidget {
  const _PredictiveCard({required this.item});

  final _PredictiveCardVm item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: cs.surface.withValues(alpha: 0.9),
            child: Icon(item.icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  item.body,
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  const _MiniLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
