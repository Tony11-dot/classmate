import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/dm_repository.dart';
import '../domain/dm_models.dart';
import '../providers/dm_providers.dart';

class DmInboxScreen extends ConsumerStatefulWidget {
  const DmInboxScreen({super.key});

  @override
  ConsumerState<DmInboxScreen> createState() => _DmInboxScreenState();
}

class _DmInboxScreenState extends ConsumerState<DmInboxScreen> {
  String? _dmInboxAbsUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) {
      return null;
    }
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    const configured = String.fromEnvironment(
      'CM_API_BASE_URL',
      defaultValue: 'http://127.0.0.1:3001',
    );
    final rawBase = configured.trim();
    final base = rawBase.endsWith('/')
        ? rawBase.substring(0, rawBase.length - 1)
        : rawBase;
    final path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }

  String _fmtInboxTime(DateTime dt) {
    final now = DateTime.now();
    final sameDay =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    if (sameDay) {
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        yesterday.year == dt.year &&
        yesterday.month == dt.month &&
        yesterday.day == dt.day;
    if (isYesterday) {
      return 'Yesterday';
    }
    return '${dt.day}/${dt.month}';
  }

  final TextEditingController _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Widget _threadAvatar(DmThread thread) {
    final avatar = (_dmInboxAbsUrl(thread.avatarUrl) ?? '').trim();
    if (avatar.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundImage: NetworkImage(avatar),
        backgroundColor: Colors.white.withValues(alpha: 0.08),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      child: Text(
        thread.avatarText,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(dmThreadsProvider);
    await ref.read(dmThreadsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(dmThreadsProvider);
    final repo = ref.read(dmRepositoryProvider);
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

        final incomingRequests = items
            .where((e) => e.requestState == DmRequestState.pendingIncoming)
            .where(matches)
            .toList(growable: false);

        final outgoingRequests = items
            .where((e) => e.requestState == DmRequestState.pendingOutgoing)
            .where(matches)
            .toList(growable: false);

        final chats = items
            .where(
              (e) =>
                  e.requestState != DmRequestState.pendingIncoming &&
                  e.requestState != DmRequestState.pendingOutgoing,
            )
            .where(matches)
            .toList(growable: false);

        Widget requestTile(DmThread thread, {required bool incoming}) {
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => context.push('/dms/${thread.id}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: incoming
                      ? cs.primary.withValues(alpha: 0.28)
                      : cs.outlineVariant.withValues(alpha: 0.20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _threadAvatar(thread),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    thread.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _fmtInboxTime(thread.updatedAt),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.55),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              thread.subtitle.isEmpty
                                  ? (incoming
                                        ? 'This chat needs your approval.'
                                        : 'Waiting for approval.')
                                  : thread.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (thread.isGroup)
                                  const _MetaPill(label: 'GROUP'),
                                _MetaPill(
                                  label: incoming ? 'REQUEST' : 'PENDING',
                                ),
                                if (thread.isBlocked)
                                  const _MetaPill(label: 'BLOCKED'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (incoming)
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              await repo.acceptRequest(thread.id);
                              if (!mounted) return;
                              await _refresh();
                            },
                            child: const Text('Accept'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              await repo.declineRequest(thread.id);
                              if (!mounted) return;
                              await _refresh();
                            },
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          tooltip: 'Block',
                          onPressed: () async {
                            await repo.blockUser(thread.id);
                            if (!mounted) return;
                            await _refresh();
                          },
                          icon: const Icon(Icons.block_rounded),
                        ),
                      ],
                    )
                  else
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: () => context.push('/dms/${thread.id}'),
                        child: const Text('Open'),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        Widget chatTile(DmThread thread) {
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => context.push('/dms/${thread.id}'),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _threadAvatar(thread),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                thread.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _fmtInboxTime(thread.updatedAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          thread.subtitle.isEmpty
                              ? 'Start chatting'
                              : thread.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.74),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (thread.isGroup) const _MetaPill(label: 'GROUP'),
                            if (thread.isBlocked)
                              const _MetaPill(label: 'BLOCKED'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (thread.unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${thread.unreadCount}',
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
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
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
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
              if (incomingRequests.isNotEmpty) ...[
                const Text(
                  'Pending requests',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                ...incomingRequests.map((e) => requestTile(e, incoming: true)),
                const SizedBox(height: 12),
              ],
              if (outgoingRequests.isNotEmpty) ...[
                const Text(
                  'Awaiting approval',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                ...outgoingRequests.map((e) => requestTile(e, incoming: false)),
                const SizedBox(height: 12),
              ],
              const Text(
                'Chats',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              if (chats.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    query.isEmpty
                        ? 'No chats yet.'
                        : 'No chats match "$query".',
                  ),
                )
              else
                ...chats.map(chatTile),
            ],
          ),
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
