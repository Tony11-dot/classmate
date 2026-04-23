import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/practice_providers.dart';
import 'practice_display_text.dart';
import 'practice_mode_specs.dart';

class PracticeHistoryDebugScreen extends ConsumerWidget {
  const PracticeHistoryDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(practiceHistoryProvider);
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l.practiceHistoryDebugTitle)),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('${l.practiceHistoryErrorPrefix} $e'),
        ),
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(child: Text(l.practiceHistoryEmpty));
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (context, i) {
              final s = sessions[i];

              final accent = practiceModeColor(s.mode);

              return Container(
                margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: accent.withValues(alpha: 0.22)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: accent.withValues(alpha: 0.14),
                    child: Icon(
                      practiceModeIcon(s.mode),
                      color: accent,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    localizedPracticeSubjectAndTopic(
                      context,
                      subject: s.subject,
                      topicLabel: s.topicLabel,
                    ),
                  ),
                  subtitle: Text(
                    '${practiceModeLabel(context, s.mode)} • ${s.correct}/${s.answered} • ${s.accuracyPercent}% • ${l.practiceSessionMetricXp} ${s.xp} • ${l.practiceSetupQuestionsCount(s.totalQuestions)}',
                  ),
                  trailing: Text(
                    '${s.completedAt.hour}:${s.completedAt.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
