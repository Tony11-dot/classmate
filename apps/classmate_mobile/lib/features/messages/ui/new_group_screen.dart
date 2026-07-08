import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';

class NewGroupScreen extends ConsumerStatefulWidget {
  const NewGroupScreen({
    super.key,
    required this.people,
  });

  final List<MessageDirectoryPerson> people;

  @override
  ConsumerState<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends ConsumerState<NewGroupScreen> {
  final TextEditingController _searchCtl = TextEditingController();
  final TextEditingController _nameCtl = TextEditingController();
  final Set<String> _selected = <String>{};
  bool _submitting = false;

  @override
  void dispose() {
    _searchCtl.dispose();
    _nameCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final q = _searchCtl.text.trim().toLowerCase();
    final filtered = widget.people.where((p) {
      if (q.isEmpty) return true;
      return p.displayName.toLowerCase().contains(q) ||
          p.gradeLabel.toLowerCase().contains(q) ||
          p.schoolName.toLowerCase().contains(q);
    }).toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.messagesNewGroupTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: TextField(
                controller: _nameCtl,
                textCapitalization: TextCapitalization.words,
                maxLength: 50,
                decoration: InputDecoration(
                  hintText: l.messagesGroupNameHint,
                  prefixIcon: const Icon(Icons.group_rounded),
                  counterText: '', // hide the counter — keeps UI clean
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchCtl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: l.messagesSearchPeopleHint,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            if (_selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l.classroomDetailSelectedCount(_selected.length),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final person = filtered[index];
                  final selected = _selected.contains(person.userId);
                  return ListTile(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selected.remove(person.userId);
                        } else {
                          _selected.add(person.userId);
                        }
                      });
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
                    trailing: Checkbox(
                      value: selected,
                      onChanged: (_) {
                        setState(() {
                          if (selected) {
                            _selected.remove(person.userId);
                          } else {
                            _selected.add(person.userId);
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_selected.length < 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l.messagesGroupMinMembers,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    // A group needs the creator + at least 2 others (1-on-1
                    // chats use the direct-message flow), matching the backend
                    // ArrayMinSize(2) on memberIds.
                    onPressed: _submitting || _selected.length < 2 || _nameCtl.text.trim().isEmpty
                        ? null
                        : () async {
                            setState(() => _submitting = true);
                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);
                            try {
                              final detail = await ref
                                  .read(messagesRepositoryProvider)
                                  .createGroup(
                                    title: _nameCtl.text.trim(),
                                    memberIds: _selected.toList(growable: false),
                                  );
                              if (!mounted) return;
                              ref.invalidate(messagesInboxProvider);
                              nav.pop(detail.id);
                            } catch (_) {
                              // Surface failures (e.g. validation, network) as a
                              // snackbar instead of an uncaught fatal error.
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(l.commonError)),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _submitting = false);
                              }
                            }
                          },
                    child: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.messagesCreateGroupAction),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
