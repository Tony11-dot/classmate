import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../providers/messages_repository_provider.dart';
import '../../../ui/widgets/cm_loading.dart';

class BlockedPeopleScreen extends ConsumerStatefulWidget {
  const BlockedPeopleScreen({super.key});

  @override
  ConsumerState<BlockedPeopleScreen> createState() => _BlockedPeopleScreenState();
}

class _BlockedPeopleScreenState extends ConsumerState<BlockedPeopleScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(messagesRepositoryProvider).listBlockedPeople();
  }

  Future<void> _reload() async {
    setState(() {
      _future = ref.read(messagesRepositoryProvider).listBlockedPeople();
    });
  }

  Future<void> _unblock(Map<String, dynamic> item) async {
    final l = AppLocalizations.of(context)!;
    final threadId = (item['threadId'] ?? '').toString().trim();
    final name = (item['displayName'] ?? l.messagesBlockedPersonFallback)
        .toString()
        .trim();
    if (threadId.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.messagesUnblockPersonTitle),
        content: Text(l.messagesUnblockPersonBody(name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.classroomDetailCancelTooltip),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.messagesUnblockAction),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await ref.read(messagesRepositoryProvider).unblockDirectThread(
      threadId: threadId,
    );

    if (!mounted) return;
    await _reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.messagesUnblockedToast(name))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.messagesBlockedPeopleTitle)),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CmLoading());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l.messagesBlockedPeopleLoadFailed(snapshot.error.toString()),
                ),
              ),
            );
          }

          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return Center(child: Text(l.messagesNoBlockedPeople));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final name = (item['displayName'] ?? l.messagesUnknownUser)
                    .toString()
                    .trim();
                final initials = (item['initials'] ?? '?').toString().trim().replaceAll(',', '');

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(initials.isEmpty ? '?' : initials)),
                    title: Text(name.isEmpty ? l.messagesUnknownUser : name),
                    trailing: FilledButton(
                      onPressed: () => _unblock(item),
                      child: Text(l.messagesUnblockAction),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
