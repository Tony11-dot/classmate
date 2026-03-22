import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/dm_models.dart';
import '../providers/dm_providers.dart';

class DmInboxScreen extends ConsumerStatefulWidget {
  const DmInboxScreen({super.key});

  @override
  ConsumerState<DmInboxScreen> createState() => _DmInboxScreenState();
}

class _DmInboxScreenState extends ConsumerState<DmInboxScreen> {
  final TextEditingController _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(dmThreadsProvider);
    final cs = Theme.of(context).colorScheme;
    final query = _searchCtl.text.trim().toLowerCase();

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (items) {
        bool matches(DmThread e) {
          if (query.isEmpty) {
            return true;
          }
          return e.title.toLowerCase().contains(query) ||
              e.subtitle.toLowerCase().contains(query) ||
              e.avatarText.toLowerCase().contains(query);
        }

        final requests = items
            .where((e) => e.requestState == DmRequestState.pendingIncoming)
            .where(matches)
            .toList(growable: false);

        final chats = items
            .where((e) => e.requestState != DmRequestState.pendingIncoming)
            .where(matches)
            .toList(growable: false);

        Widget tile(DmThread thread) {
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => context.push('/dms/${thread.id}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.24),
                ),
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
                            if (thread.requestState ==
                                DmRequestState.pendingIncoming)
                              const _MetaPill(label: 'REQUEST'),
                            if (thread.isBlocked)
                              const _MetaPill(label: 'BLOCKED'),
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
                    'Messages',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Requests, direct messages, and study groups in one clean inbox.',
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchCtl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search messages...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      isDense: true,
                      filled: true,
                      fillColor: cs.surface.withValues(alpha: 0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.24),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: cs.outlineVariant.withValues(alpha: 0.24),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: cs.primary.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => context.push('/dms/create-group'),
                    icon: const Icon(Icons.group_add_rounded),
                    label: const Text('Create group'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (requests.isNotEmpty) ...[
              const Text(
                'Requests',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              ...requests.map(tile),
              const SizedBox(height: 12),
            ],
            const Text('Chats', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            if (chats.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  query.isEmpty ? 'No chats yet.' : 'No chats match "$query".',
                ),
              )
            else
              ...chats.map(tile),
          ],
        );
      },
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
