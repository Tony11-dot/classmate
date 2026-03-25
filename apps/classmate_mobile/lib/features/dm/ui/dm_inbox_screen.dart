import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/dm_repository.dart';
import '../domain/dm_models.dart';
import '../providers/dm_providers.dart';
import 'create_group_screen.dart';

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

  String? _dmInboxAbsUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return null;
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

    if (value.startsWith('file:///uploads/')) {
      final repaired = value.replaceFirst('file://', '');
      return repaired.startsWith('/') ? '$base$repaired' : '$base/$repaired';
    }

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
    if (isYesterday) return 'Yesterday';
    return '${dt.day}/${dt.month}';
  }

  Future<void> _refresh() async {
    ref.invalidate(dmThreadsProvider);
    await ref.read(dmThreadsProvider.future);
  }

  Widget _threadAvatar(DmThread thread) {
    final avatar = (_dmInboxAbsUrl(thread.avatarUrl) ?? '').trim();

    Widget fallback() {
      return CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        child: Text(
          thread.avatarText,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
            height: 1.05,
          ),
        ),
      );
    }

    if (avatar.isEmpty) return fallback();

    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      child: ClipOval(
        child: Image.network(
          avatar,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(dmThreadsProvider);
    final repo = ref.read(dmRepositoryProvider);
    final cs = Theme.of(context).colorScheme;
    final query = _searchCtl.text.trim().toLowerCase();

    bool matches(DmThread e) {
      if (query.isEmpty) return true;
      return e.title.toLowerCase().contains(query) ||
          e.subtitle.toLowerCase().contains(query) ||
          e.avatarText.toLowerCase().contains(query);
    }

    Widget requestTile(DmThread thread, {required bool incoming}) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push('/dms/${thread.id}'),
        onLongPress: () async {
          final action = await showModalBottomSheet<String>(
            context: context,
            showDragHandle: true,
            builder: (sheetContext) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.open_in_new_rounded),
                    title: const Text('Open'),
                    onTap: () => Navigator.pop(sheetContext, 'open'),
                  ),
                  if (incoming)
                    ListTile(
                      leading: const Icon(Icons.check_rounded),
                      title: const Text('Accept'),
                      onTap: () => Navigator.pop(sheetContext, 'accept'),
                    ),
                  if (incoming)
                    ListTile(
                      leading: const Icon(Icons.close_rounded),
                      title: const Text('Decline'),
                      onTap: () => Navigator.pop(sheetContext, 'decline'),
                    ),
                  ListTile(
                    leading: const Icon(Icons.block_rounded),
                    title: const Text('Block'),
                    onTap: () => Navigator.pop(sheetContext, 'block'),
                  ),
                ],
              ),
            ),
          );

          if (!mounted || action == null) return;
          if (action == 'open') {
            context.push('/dms/${thread.id}');
            return;
          }
          if (action == 'accept') {
            await repo.acceptRequest(thread.id);
            if (!mounted) return;
            await _refresh();
            return;
          }
          if (action == 'decline') {
            await repo.declineRequest(thread.id);
            if (!mounted) return;
            await _refresh();
            return;
          }
          if (action == 'block') {
            await repo.blockUser(thread.id);
            if (!mounted) return;
            await _refresh();
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: cs.surface.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: incoming
                  ? cs.primary.withValues(alpha: 0.28)
                  : cs.outlineVariant.withValues(alpha: 0.20),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _threadAvatar(thread),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  thread.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              if (thread.isGroup) ...[
                                const SizedBox(width: 6),
                                const _MetaPill(label: 'GROUP'),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _fmtInboxTime(thread.updatedAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: 0.55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetaPill(label: incoming ? 'REQUEST' : 'PENDING'),
                        if (thread.isBlocked) const _MetaPill(label: 'BLOCKED'),
                      ],
                    ),
                    const SizedBox(height: 8),
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
            ],
          ),
        ),
      );
    }

    Widget chatTile(DmThread thread) {
      return InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.push('/dms/${thread.id}'),
        onLongPress: () async {
          final action = await showModalBottomSheet<String>(
            context: context,
            showDragHandle: true,
            builder: (sheetContext) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.open_in_new_rounded),
                    title: const Text('Open'),
                    onTap: () => Navigator.pop(sheetContext, 'open'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('Info'),
                    onTap: () => Navigator.pop(sheetContext, 'info'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.block_rounded),
                    title: const Text('Block'),
                    onTap: () => Navigator.pop(sheetContext, 'block'),
                  ),
                ],
              ),
            ),
          );

          if (!mounted || action == null) return;
          if (action == 'open') {
            context.push('/dms/${thread.id}');
            return;
          }
          if (action == 'info') {
            context.push('/dms/${thread.id}');
            return;
          }
          if (action == 'block') {
            await repo.blockUser(thread.id);
            if (!mounted) return;
            await _refresh();
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  thread.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                  ),
                                ),
                              ),
                              if (thread.isGroup) ...[
                                const SizedBox(width: 6),
                                const _MetaPill(label: 'GROUP'),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _fmtInboxTime(thread.updatedAt),
                          style: TextStyle(
                            fontSize: 10,
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
                        if (thread.isBlocked) const _MetaPill(label: 'BLOCKED'),
                      ],
                    ),
                  ],
                ),
              ),
              if (thread.unreadCount > 0) ...[
                const SizedBox(width: 6),
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
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'dm-create-group',
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const CreateGroupScreen()));
          if (!mounted) return;
          await _refresh();
        },
        child: const Icon(Icons.group_add_rounded),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) {
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

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Messages',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Direct messages, requests, and study groups.',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchCtl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search chats',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: cs.surface.withValues(alpha: 0.60),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: cs.primary.withValues(alpha: 0.28),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (incomingRequests.isNotEmpty) ...[
                  const Text(
                    'Requests',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  ...incomingRequests.map(
                    (e) => requestTile(e, incoming: true),
                  ),
                  const SizedBox(height: 10),
                ],
                if (outgoingRequests.isNotEmpty) ...[
                  const Text(
                    'Awaiting approval',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  ...outgoingRequests.map(
                    (e) => requestTile(e, incoming: false),
                  ),
                  const SizedBox(height: 10),
                ],
                const Text(
                  'Chats',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                if (chats.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(14),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
