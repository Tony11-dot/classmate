import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';

class MessagesInboxScreen extends ConsumerStatefulWidget {
  const MessagesInboxScreen({super.key});

  @override
  ConsumerState<MessagesInboxScreen> createState() => _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends ConsumerState<MessagesInboxScreen> {
  final TextEditingController _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inbox = ref.watch(messagesInboxProvider);
    final query = _searchCtl.text.trim().toLowerCase();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Messages',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_rounded),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _searchCtl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search messages',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: inbox.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Failed to load messages: $error'),
                ),
                data: (items) {
                  final filtered = items.where((item) {
                    if (query.isEmpty) return true;
                    return item.title.toLowerCase().contains(query) ||
                        item.subtitle.toLowerCase().contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No messages found'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(messagesInboxProvider);
                      await ref.read(messagesInboxProvider.future);
                    },
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _InboxTile(item: item);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxTile extends StatelessWidget {
  const _InboxTile({required this.item});

  final MessageThreadSummary item;

  @override
  Widget build(BuildContext context) {
    final isRequest = item.requestState.name.startsWith('pending');
    return ListTile(
      onTap: () {
        if (isRequest) {
          context.go('/messages/request/${item.id}');
        } else {
          context.go('/messages/${item.id}');
        }
      },
      leading: CircleAvatar(
        backgroundImage:
            item.isGroup && (item.groupAvatarUrl ?? '').trim().isNotEmpty
                ? NetworkImage(item.groupAvatarUrl!.trim())
                : null,
        child: item.isGroup && (item.groupAvatarUrl ?? '').trim().isNotEmpty
            ? null
            : Text(item.initials),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.isGroup)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: const Text(
                'Group',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      subtitle: Text(
        item.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isRequest
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
            )
          : Text(item.lastMessageAt),
    );
  }
}
