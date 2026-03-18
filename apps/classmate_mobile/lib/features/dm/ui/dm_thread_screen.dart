import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/dm_repository.dart';
import '../domain/dm_models.dart';

class DmThreadScreen extends StatelessWidget {
  const DmThreadScreen({super.key, required this.threadId});

  final String threadId;

  @override
  Widget build(BuildContext context) {
    final repo = const DmRepository();
    final inbox = repo.inbox();
    final thread = repo.thread(threadId);
    final meta = inbox.firstWhere(
      (e) => e.id == threadId,
      orElse: () => inbox.first,
    );
    final cs = Theme.of(context).colorScheme;

    if (meta.requestState == DmRequestState.pendingIncoming) {
      return Scaffold(
        appBar: AppBar(title: Text(meta.title)),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message request',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${meta.otherUser.fullName} wants to start a chat with you.',
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/profile'),
                    child: Row(
                      children: [
                        CircleAvatar(child: Text(meta.otherUser.avatarText)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Open profile',
                            style: TextStyle(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.block_rounded),
                          label: const Text('Block'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Accept'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(meta.title),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.block_rounded)),
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.block_rounded)),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
            child: Wrap(
              spacing: 8,
              children: const [
                _TopPill(label: 'Clean DM'),
                _TopPill(label: 'Rich reactions'),
                _TopPill(label: 'Block / unblock anytime'),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              itemCount: thread.length,
              itemBuilder: (context, i) {
                final m = thread[i];
                return Align(
                  alignment: m.mine
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 320),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: m.mine
                          ? cs.primaryContainer.withValues(alpha: 0.9)
                          : cs.surfaceContainerHighest.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.text),
                        if (m.reactions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: [
                              for (final r in m.reactions)
                                _ReactionChip(emoji: r),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _clock(m.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Wrap(
                              spacing: 4,
                              children: const [
                                _MiniReactionButton(emoji: '❤️'),
                                _MiniReactionButton(emoji: '🔥'),
                                _MiniReactionButton(emoji: '😂'),
                                _MiniReactionButton(emoji: '✅'),
                                _MiniReactionButton(emoji: '👏'),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: meta.isGroup ? 'Message group' : 'Message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _clock(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(emoji),
    );
  }
}

class _MiniReactionButton extends StatelessWidget {
  const _MiniReactionButton({required this.emoji});

  final String emoji;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text(emoji, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

class _TopPill extends StatelessWidget {
  const _TopPill({required this.label});

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
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}
