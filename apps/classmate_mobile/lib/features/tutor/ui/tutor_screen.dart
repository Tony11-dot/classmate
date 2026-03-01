import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/characters_provider.dart';
import '../providers/tutor_repository_provider.dart';

class TutorScreen extends ConsumerWidget {
  const TutorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charsAsync = ref.watch(charactersProvider(null));

    return Scaffold(
      appBar: AppBar(title: const Text('AI Tutor')),
      body: charsAsync.when(
        data: (chars) {
          if (chars.isEmpty) {
            return const Center(child: Text('No characters found.'));
          }

          return ListView.separated(
            itemCount: chars.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final c = chars[index] as Map<String, dynamic>;
              final name = (c['name'] ?? 'Unknown') as String;
              final subject = (c['subject'] ?? 'GENERAL') as String;
              final tone = c['tone'] as String?;
              final explain = c['explainStyle'] as String?;
              final characterId = (c['id'] ?? '') as String;

              return ListTile(
                title: Text(name),
                subtitle: Text(
                  [
                    subject,
                    if (tone != null && tone.isNotEmpty) 'tone: $tone',
                    if (explain != null && explain.isNotEmpty) 'style: $explain',
                  ].join(' • '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  if (characterId.isEmpty) return;
                  final repo = ref.read(tutorRepositoryProvider);
                  try {
                    final res = await repo.createSession(
                      characterId: characterId,
                      subject: subject,
                    );
                    final session = (res['session'] ?? res) as Map<String, dynamic>;
                    final sessionId = (session['id'] ?? '') as String;

                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TutorChatScreen(
                          sessionId: sessionId,
                          title: name,
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to start session: $e')),
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class TutorChatScreen extends StatelessWidget {
  const TutorChatScreen({
    super.key,
    required this.sessionId,
    required this.title,
  });

  final String sessionId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('Session: $sessionId\n\nPhase 2: messages + reply'),
      ),
    );
  }
}
