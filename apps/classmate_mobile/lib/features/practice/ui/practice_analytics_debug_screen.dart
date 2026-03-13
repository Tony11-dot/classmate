import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/math/math_view.dart';
import '../providers/practice_providers.dart';
import 'practice_mode_specs.dart';

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

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Practice Analytics'),
      ),
      body: analytics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (snapshot) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              _SectionTitle(title: 'Overall'),
              _TopicTile(
                title: 'Recent sessions',
                subtitle:
                    '${snapshot.overall.sessions} sessions • '
                    '${snapshot.overall.correct}/${snapshot.overall.answered} correct • '
                    '${snapshot.overall.accuracyPercent}% • '
                    'XP ${snapshot.overall.xp}',
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Weakest topics'),
              if (snapshot.weakestTopics.isEmpty)
                const Card(child: ListTile(title: Text('No topic data yet'))),
              ...snapshot.weakestTopics.map(
                (t) => _TopicTile(
                  title: t.topicLabel,
                  subtitle:
                      '${t.correct}/${t.totalQuestions} • '
                      '${t.accuracyPercent}% • '
                      '${t.totalQuestions}Q',
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Strongest topics'),
              if (snapshot.strongestTopics.isEmpty)
                const Card(child: ListTile(title: Text('No topic data yet'))),
              ...snapshot.strongestTopics.map(
                (t) => _TopicTile(
                  title: t.topicLabel,
                  subtitle:
                      '${t.correct}/${t.totalQuestions} • '
                      '${t.accuracyPercent}% • '
                      '${t.totalQuestions}Q',
                ),
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Mode performance'),
              if (snapshot.modeStats.isEmpty)
                const Card(child: ListTile(title: Text('No mode data yet'))),
              ...snapshot.modeStats.map(
                (m) => _ModeTile(
                  icon: practiceModeIcon(m.mode),
                  label: practiceModeLabel(m.mode),
                  subtitle:
                      '${m.sessions} sessions • '
                      '${m.correct}/${m.answered} • '
                      '${m.accuracyPercent}% • '
                      'XP ${m.xp}',
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
          backgroundColor: accent.withValues(alpha: 0.18),
          child: Icon(icon, color: accent, size: 18),
        ),
        title: MathView(
          title,
          compact: true,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: accent,
          ),
        ),
        subtitle: MathView(subtitle, compact: true),
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
        title: MathView(label, compact: true),
        subtitle: MathView(subtitle, compact: true),
      ),
    );
  }
}
