import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/tutor_providers.dart';
import '../providers/tutor_repository_provider.dart';
import 'nova_chat_screen.dart';

class TutorHomeScreen extends ConsumerWidget {
  const TutorHomeScreen({super.key});

  static const brandTitle = 'NOVA';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(tutorSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(brandTitle),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(tutorSessionsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _newChatFlow(context, ref),
        child: const Icon(Icons.add),
      ),
      body: sessions.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No chats yet'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => _newChatFlow(context, ref),
                    child: const Text('Start a chat'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final s = (list[i] as Map).cast<String, dynamic>();
              final id = (s['id'] ?? '') as String;
              final title = (s['title'] ?? s['topic'] ?? 'Chat') as String;
              final subject = (s['subject'] ?? 'GENERAL') as String;
              final characterName =
                  (s['characterName'] ?? s['character']?['name'] ?? 'Tutor')
                      as String;

              return ListTile(
                title: Text(title),
                subtitle: Text('$characterName • $subject'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  if (id.isEmpty) return;
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NovaChatScreen(
                        sessionId: id,
                        characterName: characterName,
                        subject: subject,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: $e', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => ref.invalidate(tutorSessionsProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _newChatFlow(BuildContext context, WidgetRef ref) async {
    final subject = await _pickSubject(context, ref);
    if (subject == null) return;

    // ignore: use_build_context_synchronously
    final pick = await _pickCharacter(context, ref, subject);
    if (pick == null) return;

    final repo = ref.read(tutorRepositoryProvider);

    try {
      final res = await repo.createSession(
        characterId: pick.id,
        subject: subject == 'ALL' ? null : subject,
      );
      final sessionId = (res['session']?['id'] ?? res['id'] ?? '') as String;
      if (sessionId.isEmpty) {
        throw Exception('Missing session id');
      }

      // refresh list immediately
      ref.invalidate(tutorSessionsProvider);
      // ignore: use_build_context_synchronously
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => NovaChatScreen(
            sessionId: sessionId,
            characterName: pick.name,
            subject: subject == 'ALL' ? 'GENERAL' : subject,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start chat: $e')));
    }
  }

  Future<String?> _pickSubject(BuildContext context, WidgetRef ref) async {
    final subjects = await ref
        .read(tutorStudentSubjectsProvider.future)
        .catchError((_) => <dynamic>[]);

    // Normalize into strings (best-effort)
    final set = <String>{};
    for (final x in subjects) {
      if (x is String) {
        set.add(x.toUpperCase());
      } else if (x is Map) {
        final v = (x['code'] ?? x['subject'] ?? x['name'] ?? x['id']);
        if (v is String && v.trim().isNotEmpty) set.add(v.toUpperCase());
      }
    }

    final items = <String>[
      'ALL',
      if (set.isEmpty) ...<String>[
        'GENERAL',
        'MATH',
        'PHYSICS',
        'CS',
        'ENGLISH',
      ] else
        ...set.toList()..sort(),
    ];

    return showModalBottomSheet<String>(
      // ignore: use_build_context_synchronously
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'New chat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text('Pick a subject'),
              ),
              for (final s in items)
                ListTile(
                  title: Text(s),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(s),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<_CharPick?> _pickCharacter(
    BuildContext context,
    WidgetRef ref,
    String subject,
  ) async {
    List<dynamic> all = <dynamic>[];

    if (subject == 'ALL') {
      // merge a few popular subjects + GENERAL (best-effort)
      final subs = <String>['GENERAL', 'MATH', 'PHYSICS', 'CS', 'ENGLISH'];
      for (final s in subs) {
        final list = await ref
            .read(tutorCharactersProvider(s).future)
            .catchError((_) => <dynamic>[]);
        all.addAll(list);
      }
    } else {
      all = await ref
          .read(tutorCharactersProvider(subject).future)
          .catchError((_) => <dynamic>[]);
      if (all.isEmpty && subject != 'GENERAL') {
        final g = await ref
            .read(tutorCharactersProvider('GENERAL').future)
            .catchError((_) => <dynamic>[]);
        all = g;
      }
    }

    // de-dupe by id
    final seen = <String>{};
    final chars = <_CharPick>[];
    for (final x in all) {
      if (x is! Map) continue;
      final m = x.cast<String, dynamic>();
      final id = (m['id'] ?? '') as String;
      if (id.isEmpty || seen.contains(id)) continue;
      seen.add(id);

      final name = ((m['name'] ?? 'Tutor') as String);
      final sub = ((m['subject'] ?? 'GENERAL') as String);
      final tone = (m['tone'] as String?)?.trim();
      final style = (m['explainStyle'] as String?)?.trim();

      chars.add(
        _CharPick(
          id: id,
          name: name,
          subtitle: [
            sub,
            if (tone != null && tone.isNotEmpty) tone,
            if (style != null && style.isNotEmpty) style,
          ].join(' • '),
        ),
      );
    }

    if (chars.isEmpty) {
      if (!context.mounted) return null;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No characters available for this subject'),
        ),
      );
      return null;
    }

    return showModalBottomSheet<_CharPick>(
      // ignore: use_build_context_synchronously
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  'Pick a tutor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              for (final c in chars)
                ListTile(
                  title: Text(c.name),
                  subtitle: Text(c.subtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).pop(c),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _CharPick {
  const _CharPick({
    required this.id,
    required this.name,
    required this.subtitle,
  });
  final String id;
  final String name;
  final String subtitle;
}
