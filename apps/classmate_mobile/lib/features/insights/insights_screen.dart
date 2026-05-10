import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../lifedoc/announcements_provider.dart';
import 'domain/insights_models.dart';
import 'providers/insights_providers.dart';
import '../../ui/widgets/cm_loading.dart';

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

  String _trendLabel(AppLocalizations l, UnifiedPracticeTrend? trend) {
    final delta = trend?.deltaAccuracy;
    if (delta == null) return l.insightsTrendBaseline;
    if (delta >= 6) return l.insightsTrendImproving;
    if (delta <= -6) return l.insightsTrendDropping;
    return l.insightsTrendStable;
  }

  IconData _trendIcon(UnifiedPracticeTrend? trend) {
    final delta = trend?.deltaAccuracy;
    if (delta == null) return Icons.timeline_rounded;
    if (delta >= 6) return Icons.trending_up_rounded;
    if (delta <= -6) return Icons.trending_down_rounded;
    return Icons.show_chart_rounded;
  }

  String _predictiveHeadline(
    AppLocalizations l,
    UnifiedStudentInsights unified,
    List<dynamic> announcements,
  ) {
    final avg = unified.grades.average ?? 100;
    final rate = unified.attendance.attendanceRate ?? 100;
    final delta = unified.practice.trend?.deltaAccuracy ?? 0;

    if (avg < 70 || rate < 85 || delta <= -6) {
      return l.insightsHeadlineIntervention;
    }
    if (announcements.length >= 3) {
      return l.insightsHeadlineSignals;
    }
    return l.insightsHeadlineMomentum;
  }

  String _predictiveBody(AppLocalizations l, UnifiedStudentInsights unified) {
    final weak = (unified.grades.weakestSubject ?? '').trim();
    final best = (unified.grades.bestSubject ?? '').trim();
    final rate = unified.attendance.attendanceRate ?? 100;
    final delta = unified.practice.trend?.deltaAccuracy ?? 0;

    if (rate < 85) {
      return l.insightsBodyAttendance;
    }
    if (weak.isNotEmpty && delta <= -6) {
      return l.insightsBodyWeakTrend(weak);
    }
    if (best.isNotEmpty) {
      return l.insightsBodyLeverage(best);
    }
    return l.insightsBodyConsistency;
  }

  List<_PredictiveCardVm> _predictiveCards(
    AppLocalizations l,
    UnifiedStudentInsights unified,
    List<dynamic> announcements,
  ) {
    final weakTopic = unified.practice.weakTopics.isNotEmpty
        ? unified.practice.weakTopics.first
        : null;

    return <_PredictiveCardVm>[
      _PredictiveCardVm(
        title: l.insightsInterventionScoreTitle,
        body: l.insightsInterventionScoreBody(announcements.length),
        icon: Icons.crisis_alert_rounded,
      ),
      _PredictiveCardVm(
        title: l.insightsRecoveryPathTitle,
        body: weakTopic == null
            ? l.insightsRecoveryPathDefault
            : l.insightsRecoveryPathTopic(
                weakTopic.topicLabel,
                weakTopic.subject,
              ),
        icon: Icons.route_rounded,
      ),
      _PredictiveCardVm(
        title: l.insightsProjectedDirectionTitle,
        body:
            l.insightsProjectedDirectionBody(
              _trendLabel(l, unified.practice.trend),
            ),
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
    final l = AppLocalizations.of(context)!;

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 160),
        children: [
          unifiedAsync.when(
            loading: () => _StateCard(
              title: l.insightsLoadingTitle,
              subtitle: l.insightsLoadingSubtitle,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: const Center(child: const CmLoading()),
              ),
            ),
            error: (error, _) => _StateCard(
              title: l.insightsNotReadyTitle,
              subtitle: error.toString(),
              child: const SizedBox.shrink(),
            ),
            data: (unified) {
              if (unified == null) {
                return _StateCard(
                  title: l.insightsEmptyTitle,
                  subtitle: l.insightsEmptySubtitle,
                  child: const SizedBox.shrink(),
                );
              }

              final predictive = _predictiveCards(l, unified, announcements);

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: cs.outlineVariant,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.titleInsights,
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _predictiveHeadline(l, unified, announcements),
                          style: text.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _predictiveBody(l, unified),
                          style: text.bodyMedium?.copyWith(
                            color: cs.onPrimaryContainer.withValues(alpha: 0.75),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _HeroMetric(
                                label: l.insightsGradeAverage,
                                value: _fmtNum(unified.grades.average),
                                icon: Icons.grade_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _HeroMetric(
                                label: l.navAttendance,
                                value: _fmtPercent(
                                  unified.attendance.attendanceRate,
                                ),
                                icon: Icons.how_to_reg_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _HeroMetric(
                                label: l.insightsAccuracy,
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
                              label: l.insightsOpenNova,
                              onTap: () => _openTutorFromInsights(
                                context,
                                prompt: l.insightsOpenNovaPrompt,
                                title: l.insightsPredictiveRecoveryPlanTitle,
                              ),
                            ),
                            _ActionChip(
                              icon: Icons.play_circle_fill_rounded,
                              label: l.insightsPracticeNow,
                              onTap: () => context.go('/practice'),
                            ),
                            _ActionChip(
                              icon: Icons.campaign_rounded,
                              label: l.navAnnouncements,
                              onTap: () => context.go('/announcements'),
                            ),
                            _ActionChip(
                              icon: Icons.notifications_active_rounded,
                              label: l.navNotifications,
                              onTap: () => context.go('/notifications'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StateCard(
                    title: l.insightsPredictiveModulesTitle,
                    subtitle: l.insightsPredictiveModulesSubtitle,
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
                    title: l.insightsAnnouncementsPressureTitle,
                    subtitle: l.insightsAnnouncementsPressureSubtitle,
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
                    loading: () => _StateCard(
                      title: l.insightsAiCoachTitle,
                      subtitle: l.insightsAiCoachLoadingSubtitle,
                      child: const SizedBox(
                        height: 60,
                        child: Center(child: const CmLoading()),
                      ),
                    ),
                    error: (error, _) => _StateCard(
                      title: l.insightsAiCoachTitle,
                      subtitle: error.toString(),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: () {
                            ref.invalidate(aiInsightsSummaryProvider);
                            ref.invalidate(serverInsightsProvider);
                          },
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: Text(l.insightsGenerateAction),
                        ),
                      ),
                    ),
                    data: (ai) {
                      if (ai == null) {
                        return _StateCard(
                          title: l.insightsAiCoachTitle,
                          subtitle: l.insightsAiCoachUnavailableSubtitle,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FilledButton.icon(
                              onPressed: () {
                                ref.invalidate(aiInsightsSummaryProvider);
                                ref.invalidate(serverInsightsProvider);
                              },
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: Text(l.insightsGenerateAction),
                            ),
                          ),
                        );
                      }

                      return _StateCard(
                        title: ai.headline.isEmpty
                            ? l.insightsAiCoachTitle
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
                            Row(
                              children: [
                                FilledButton.icon(
                                  onPressed: () => _openTutorFromInsights(
                                    context,
                                    prompt: ai.suggestedPrompt.isEmpty
                                        ? l.insightsAskNovaPrompt
                                        : ai.suggestedPrompt,
                                    title: l.insightsAiStudyCoachTitle,
                                  ),
                                  icon: const Icon(Icons.psychology_alt_rounded),
                                  label: Text(l.insightsAskNova),
                                ),
                                const SizedBox(width: 10),
                                FilledButton.tonalIcon(
                                  onPressed: () {
                                    ref.invalidate(aiInsightsSummaryProvider);
                                    ref.invalidate(serverInsightsProvider);
                                  },
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: Text(l.insightsRefreshAction),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _StateCard(
                    title: l.insightsSchoolToolsTitle,
                    subtitle: l.insightsSchoolToolsSubtitle,
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ActionChip(
                          icon: Icons.grade_rounded,
                          label: l.navGrades,
                          onTap: () => context.go('/grades'),
                        ),
                        _ActionChip(
                          icon: Icons.how_to_reg_rounded,
                          label: l.navAttendance,
                          onTap: () => context.go('/attendance'),
                        ),
                        _ActionChip(
                          icon: Icons.notifications_rounded,
                          label: l.navNotifications,
                          onTap: () => context.go('/notifications'),
                        ),
                        _ActionChip(
                          icon: Icons.campaign_rounded,
                          label: l.navAnnouncements,
                          onTap: () => context.go('/announcements'),
                        ),
                        _ActionChip(
                          icon: Icons.lightbulb_rounded,
                          label: l.navSolutions,
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(20),
      color: cs.surfaceContainerLow,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: cs.surface,
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
                  overflow: TextOverflow.ellipsis,
                  maxLines: 4,
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
    final cs = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(icon, size: 18, color: cs.primary),
      label: Text(label),
      onPressed: onTap,
      backgroundColor: cs.surface,
      side: BorderSide(color: cs.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(18),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
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
          Text(
            label,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
    return LiquidGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(22),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
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
