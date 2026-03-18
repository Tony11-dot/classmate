import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/dm_models.dart';
import '../providers/dm_providers.dart';

class DmInboxScreen extends ConsumerWidget {
  const DmInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dmThreadsProvider);

    return Scaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (threads) {
          final requests = threads
              .where((t) => t.requestState == DmRequestState.pendingIncoming)
              .toList();
          final chats = threads
              .where((t) => t.requestState != DmRequestState.pendingIncoming)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'DMs',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.push('/dms/create-group'),
                    icon: const Icon(Icons.group_add_rounded),
                    label: const Text('Create group'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (requests.isNotEmpty) ...[
                const Text(
                  'Requests',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                ...requests.map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ThreadTile(thread: t),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              const Text(
                'Chats',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...chats.map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ThreadTile(thread: t),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({required this.thread});
  final DmThread thread;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/dms/${thread.id}'),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.24)),
        ),
        child: Row(
          children: [
            CircleAvatar(child: Text(thread.avatarText)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thread.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    thread.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (thread.isGroup) const _MetaPill(label: 'GROUP'),
                      if (thread.requestState == DmRequestState.pendingIncoming)
                        const _MetaPill(label: 'REQUEST'),
                      if (thread.isBlocked) const _MetaPill(label: 'BLOCKED'),
                    ],
                  ),
                ],
              ),
            ),
            if (thread.unreadCount > 0)
              CircleAvatar(
                radius: 12,
                child: Text(
                  '${thread.unreadCount}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}
