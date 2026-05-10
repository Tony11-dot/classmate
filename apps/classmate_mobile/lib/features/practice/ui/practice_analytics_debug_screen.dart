import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/cm_ai_message.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/practice_providers.dart';
import 'practice_display_text.dart';
import 'practice_mode_specs.dart';
import '../../../ui/widgets/cm_loading.dart';

Color _subjectAccent(String subject) {
  switch (subject.toLowerCase()) {
    case 'math':
      return const Color(0xFF2563EB);
    case 'physics':
      return const Color(0xFF7C3AED);
    case 'chemistry':
      return const Color(0xFF14B8A6);
    case 'biology':
      return const Color(0xFF16A34A);
    case 'computer science':
    case 'cs':
      return const Color(0xFFF59E0B);
    case 'english':
      return const Color(0xFFEC4899);
    case 'arabic':
      return const Color(0xFFDC2626);
    case 'hebrew':
      return const Color(0xFF0EA5E9);
    default:
      return const Color(0xFF64748B);
  }
}

IconData _subjectIcon(String subject) {
  switch (subject.toLowerCase()) {
    case 'math':
      return Icons.calculate_rounded;
    case 'physics':
      return Icons.bolt_rounded;
    case 'chemistry':
      return Icons.science_rounded;
    case 'biology':
      return Icons.eco_rounded;
    case 'computer science':
    case 'cs':
      return Icons.memory_rounded;
    case 'english':
      return Icons.menu_book_rounded;
    case 'arabic':
    case 'hebrew':
      return Icons.translate_rounded;
    default:
      return Icons.analytics_rounded;
  }
}

String _inferSubjectFromTitle(String title) {
  final t = title.trim();
  if (t.contains('•')) return t.split('•').first.trim();

  final l = t.toLowerCase();
  if (l.contains('math') || l.contains('algebra') || l.contains('geometry')) {
    return 'Math';
  }
  if (l.contains('physics')) {
    return 'Physics';
  }
  if (l.contains('chemistry')) {
    return 'Chemistry';
  }
  if (l.contains('biology')) {
    return 'Biology';
  }
  if (l.contains('computer') || l.contains('programming') || l.contains('cs')) {
    return 'Computer Science';
  }
  if (l.contains('arabic')) {
    return 'Arabic';
  }
  if (l.contains('hebrew')) {
    return 'Hebrew';
  }
  if (l.contains('english')) {
    return 'English';
  }
  return 'General';
}

class PracticeAnalyticsDebugScreen extends ConsumerWidget {
  const PracticeAnalyticsDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(practiceAnalyticsProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(l.practiceAnalyticsTitle),
      ),
      body: analytics.when(
        loading: () => const Center(child: const CmLoading()),
        error: (e, _) => Center(
          child: Text('${l.practiceHistoryErrorPrefix} $e'),
        ),
        data: (snapshot) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _SectionTitle(title: l.practiceAnalyticsSectionOverall),
              _TopicTile(
                title: l.practiceAnalyticsRecentSessionsTitle,
                subtitle: l.practiceAnalyticsRecentSessionsSummary(
                  snapshot.overall.sessions,
                  snapshot.overall.correct,
                  snapshot.overall.answered,
                  snapshot.overall.accuracyPercent,
                  snapshot.overall.xp,
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: l.practiceAnalyticsSectionWeakestTopics),
              if (snapshot.weakestTopics.isEmpty)
                Card(child: ListTile(title: Text(l.practiceAnalyticsNoTopicData))),
              ...snapshot.weakestTopics.map(
                (t) => _TopicTile(
                  title: localizedPracticeTopicLabel(context, t.topicLabel),
                  subtitle:
                      '${t.correct}/${t.totalQuestions} • '
                      '${t.accuracyPercent}% • '
                      '${l.practiceSetupQuestionsCount(t.totalQuestions)}',
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: l.practiceAnalyticsSectionStrongestTopics),
              if (snapshot.strongestTopics.isEmpty)
                Card(child: ListTile(title: Text(l.practiceAnalyticsNoTopicData))),
              ...snapshot.strongestTopics.map(
                (t) => _TopicTile(
                  title: localizedPracticeTopicLabel(context, t.topicLabel),
                  subtitle:
                      '${t.correct}/${t.totalQuestions} • '
                      '${t.accuracyPercent}% • '
                      '${l.practiceSetupQuestionsCount(t.totalQuestions)}',
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: l.practiceAnalyticsSectionModePerformance),
              if (snapshot.modeStats.isEmpty)
                Card(child: ListTile(title: Text(l.practiceAnalyticsNoModeData))),
              ...snapshot.modeStats.map(
                (m) => _ModeTile(
                  icon: practiceModeIcon(m.mode),
                  label: practiceModeLabel(context, m.mode),
                  subtitle: l.practiceAnalyticsRecentSessionsSummary(
                    m.sessions,
                    m.correct,
                    m.answered,
                    m.accuracyPercent,
                    m.xp,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TopicTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final subject = _inferSubjectFromTitle(title);
    final accent = _subjectAccent(subject);
    final icon = _subjectIcon(subject);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: accent,
          child: Icon(icon, color: accent, size: 18),
        ),
        title: CMAiMessage(
          title,
          compact: true,
          textStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ),
        subtitle: CMAiMessage(
          subtitle,
          compact: true,
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _ModeTile({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: CMAiMessage(
          label,
          compact: true,
          textStyle: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: CMAiMessage(
          subtitle,
          compact: true,
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
