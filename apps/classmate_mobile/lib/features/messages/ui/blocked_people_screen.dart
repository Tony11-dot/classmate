import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/messages_repository_provider.dart';

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
    final threadId = (item['threadId'] ?? '').toString().trim();
    final name = (item['displayName'] ?? 'this person').toString().trim();
    if (threadId.isEmpty) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock person?'),
        content: Text('Allow $name to message you again?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Unblock'),
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
      SnackBar(content: Text('$name unblocked')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked people')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Failed to load blocked people: ${snapshot.error}'),
              ),
            );
          }

          final items = snapshot.data ?? const <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const Center(child: Text('No blocked people'));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final name = (item['displayName'] ?? 'Unknown user')
                    .toString()
                    .trim();
                final initials = (item['initials'] ?? '?').toString().trim().replaceAll(',', '');

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(initials.isEmpty ? '?' : initials)),
                    title: Text(name.isEmpty ? 'Unknown user' : name),
                    trailing: FilledButton(
                      onPressed: () => _unblock(item),
                      child: const Text('Unblock'),
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
