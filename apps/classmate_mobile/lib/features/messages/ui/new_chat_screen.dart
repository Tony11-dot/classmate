import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';
import 'new_group_screen.dart';

class NewChatScreen extends ConsumerStatefulWidget {
  const NewChatScreen({super.key});

  @override
  ConsumerState<NewChatScreen> createState() => _NewChatScreenState();
}

final sameSchoolPeopleProvider =
    FutureProvider.autoDispose<List<MessageDirectoryPerson>>((ref) {
  return ref.read(messagesRepositoryProvider).fetchSameSchoolPeople();
});

class _NewChatScreenState extends ConsumerState<NewChatScreen> {
  final TextEditingController _searchCtl = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _openGroupFlow(List<MessageDirectoryPerson> people) async {
    final nav = Navigator.of(context);
    final threadId = await nav.push<String>(
      MaterialPageRoute<String>(
        builder: (_) => NewGroupScreen(people: people),
      ),
    );

    if (!mounted || threadId == null || threadId.trim().isEmpty) return;
    nav.pop(threadId.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final peopleValue = ref.watch(sameSchoolPeopleProvider);
    final q = _searchCtl.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tutorNewChat),
      ),
      body: SafeArea(
        child: peopleValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l.messagesPeopleLoadFailed(e.toString()))),
          data: (people) {
            final filtered = people.where((p) {
              if (q.isEmpty) return true;
              return p.displayName.toLowerCase().contains(q) ||
                  p.gradeLabel.toLowerCase().contains(q) ||
                  p.schoolName.toLowerCase().contains(q);
            }).toList(growable: false);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: TextField(
                    controller: _searchCtl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l.messagesSearchPeopleHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.group_rounded),
                  ),
                  title: Text(l.messagesNewGroupTitle),
                  subtitle: Text(l.messagesNewGroupSubtitle),
                  onTap: _creating ? null : () => _openGroupFlow(people),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final person = filtered[index];
                      return ListTile(
                        onTap: _creating
                            ? null
                            : () async {
                                final nav = Navigator.of(context);
                                setState(() => _creating = true);
                                try {
                                  final detail = await ref
                                      .read(messagesRepositoryProvider)
                                      .createDirectRequest(
                                        recipientUserId: person.userId,
                                        firstMessage: '',
                                      );
                                  if (!mounted) return;
                                  ref.invalidate(messagesInboxProvider);
                                  nav.pop(detail.id);
                                } finally {
                                  if (mounted) {
                                    setState(() => _creating = false);
                                  }
                                }
                              },
                        leading: CircleAvatar(
                          child: Text(
                            person.initials.trim().isEmpty ? '?' : person.initials.trim(),
                          ),
                        ),
                        title: Text(person.displayName),
                        subtitle: Text(
                          [
                            if (person.gradeLabel.trim().isNotEmpty) person.gradeLabel.trim(),
                            if (person.schoolName.trim().isNotEmpty) person.schoolName.trim(),
                          ].join(' • '),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
