import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/dm_repository.dart';
import '../domain/dm_models.dart';

class DmInboxScreen extends StatelessWidget {
  const DmInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const DmRepository().inbox();
    final requests = items
        .where((e) => e.requestState == DmRequestState.pendingIncoming)
        .toList(growable: false);
    final chats = items
        .where((e) => e.requestState != DmRequestState.pendingIncoming)
        .toList(growable: false);
    final cs = Theme.of(context).colorScheme;

    Widget tile(DmInboxItem item) {
      return InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/dms/${item.id}'),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                child: Text(
                  item.otherUser.avatarText,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        Text(
                          _timeAgo(item.updatedAt),
                          style: TextStyle(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _Pill(label: item.isGroup ? 'Group' : 'DM'),
                        if (item.requestState == DmRequestState.pendingIncoming)
                          const _Pill(label: 'Request'),
                        if (item.unreadCount > 0)
                          _Pill(label: '${item.unreadCount} unread'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DMs',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Requests, direct messages, and study groups in one clean inbox.',
                style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => context.push('/dms/create-group'),
                      icon: const Icon(Icons.group_add_rounded),
                      label: const Text('Create group'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (requests.isNotEmpty) ...[
          const Text('Requests', style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...requests.map(tile),
          const SizedBox(height: 12),
        ],
        const Text('Chats', style: TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        ...chats.map(tile),
      ],
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
      ),
    );
  }
}
