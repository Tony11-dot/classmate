import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/practice_providers.dart';
import 'practice_mode_specs.dart';

class PracticeHistoryDebugScreen extends ConsumerWidget {
  const PracticeHistoryDebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(practiceHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Practice History (Debug)')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions saved yet.'));
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
                  title: Text('${s.subject} • ${s.topicLabel}'),
                  subtitle: Text(
                    '${practiceModeLabel(s.mode)} • ${s.correct}/${s.answered} • ${s.accuracyPercent}% • XP ${s.xp} • ${s.totalQuestions}Q',
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
