import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';
import '../../chat_core/utils/chat_time.dart';
import 'new_chat_screen.dart';
import 'blocked_people_screen.dart';

class MessagesInboxScreen extends ConsumerStatefulWidget {
  const MessagesInboxScreen({super.key});

  @override
  ConsumerState<MessagesInboxScreen> createState() =>
      _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends ConsumerState<MessagesInboxScreen> {
  final TextEditingController _searchCtl = TextEditingController();

  Future<void> _refreshInbox() async {
    ref.invalidate(messagesInboxProvider);
    await ref.read(messagesInboxProvider.future);
  }

  Future<void> _startNewChat() async {
    final threadId = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const NewChatScreen(),
      ),
    );
    if (!mounted || threadId == null || threadId.trim().isEmpty) {
      return;
    }
    ref.invalidate(messagesInboxProvider);
    context.pushNamed('dm_thread', pathParameters: {'id': threadId.trim()});
  }

  void _openBlockedPeople() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BlockedPeopleScreen(),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              l.titleMessages,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          IconButton(
            tooltip: l.messagesBlockedPeopleTitle,
            onPressed: _openBlockedPeople,
            icon: const Icon(Icons.block_rounded),
          ),
          const SizedBox(width: 4),
          FilledButton.icon(
            onPressed: _startNewChat,
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: Text(l.messagesStartChatAction),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavCover(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 108,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                scheme.surface.withValues(alpha: 0),
                scheme.surface.withValues(alpha: 0.76),
                scheme.surface,
              ],
            ),
          ),
        ),
      ),
    );
  }

  DateTime? _parseInboxTimestamp(String raw) {
    return parseChatTimestamp(raw);
  }

  String _threadTimestamp(MessageThreadSummary item) {
    final raw = item.lastMessageAtRaw.trim();
    if (raw.isNotEmpty) return raw;
    return item.lastMessageAt.trim();
  }

  void _sortInboxByRecency(List<MessageThreadSummary> items) {
    final indexed = items.asMap().entries.toList();

    indexed.sort((a, b) {
      final ad = _parseInboxTimestamp(_threadTimestamp(a.value));
      final bd = _parseInboxTimestamp(_threadTimestamp(b.value));

      if (ad != null && bd != null) {
        final byDate = bd.compareTo(ad);
        if (byDate != 0) return byDate;
      } else if (ad != null) {
        return -1;
      } else if (bd != null) {
        return 1;
      }

      // Preserve original server order when timestamps are missing/ambiguous.
      return a.key.compareTo(b.key);
    });

    final sorted = indexed.map((e) => e.value).toList(growable: false);
    items
      ..clear()
      ..addAll(sorted);
  }

  String _formatInboxTrailingLabel(MessageThreadSummary item) {
    return formatChatInboxTrailingLabel(
      item.lastMessageDate,
      fallback: item.lastMessageAt.trim(),
    );
  }

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final inbox = ref.watch(messagesInboxProvider);
    final query = _searchCtl.text.trim().toLowerCase();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: inbox.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text(l.messagesLoadFailed(error.toString()))),
          data: (items) {
            final filtered = items.where((item) {
              if (query.isEmpty) return true;
              return item.title.toLowerCase().contains(query) ||
                  item.subtitle.toLowerCase().contains(query);
            }).toList();

            _sortInboxByRecency(filtered);

            final requests = filtered
                .where((item) => item.requestState.name == 'pendingIncoming')
                .toList();

            final chats = filtered
                .where((item) => item.requestState.name != 'pendingIncoming')
                .toList();

            if (filtered.isEmpty) {
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _refreshInbox,
                    child: ListView(
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 136),
                      children: [
                        _header(context),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                          child: TextField(
                            controller: _searchCtl,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: l.messagesSearchHint,
                              prefixIcon: const Icon(Icons.search_rounded),
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 180),
                        Center(child: Text(l.messagesNoResults)),
                      ],
                    ),
                  ),
                  _bottomNavCover(context),
                ],
              );
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _refreshInbox,
                  child: ListView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 136),
                    children: [
                      _header(context),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                        child: TextField(
                          controller: _searchCtl,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: l.messagesSearchHint,
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      if (requests.isNotEmpty) ...[
                        _SectionHeader(
                          title: l.messagesRequestsSection,
                          subtitle: l.messagesPendingApprovals,
                        ),
                        ...requests.map(
                          (item) => _InboxRow(
                            item: item,
                            trailingLabel: _formatInboxTrailingLabel(item),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (chats.isNotEmpty) ...[
                        _SectionHeader(
                          title: requests.isEmpty
                              ? l.messagesChatsSection
                              : l.messagesAllChatsSection,
                          subtitle: l.messagesConversationCount(chats.length),
                        ),
                        ...chats.map(
                          (item) => _InboxRow(
                            item: item,
                            trailingLabel: _formatInboxTrailingLabel(item),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _bottomNavCover(context),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _InboxRow extends StatelessWidget {
  const _InboxRow({required this.item, required this.trailingLabel});

  final MessageThreadSummary item;
  final String trailingLabel;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isRequest = item.requestState.name == 'pendingIncoming';
    final showUnread = item.unreadCount > 0;
    final trailingText = trailingLabel.trim().isEmpty
        ? item.lastMessageAt.trim()
        : trailingLabel.trim();
    final borderColor = isRequest || showUnread
        ? scheme.primary.withValues(alpha: 0.2)
        : scheme.outlineVariant.withValues(alpha: 0.18);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: scheme.surface.withValues(alpha: 0.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (isRequest) {
              context.pushNamed(
                'dm_thread',
                pathParameters: {'id': item.id},
              );
            } else {
              context.pushNamed('dm_thread', pathParameters: {'id': item.id});
            }
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: scheme.surfaceContainerLowest,
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  blurRadius: 14,
                  spreadRadius: -10,
                  offset: const Offset(0, 8),
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isRequest || showUnread
                    ? scheme.primaryContainer
                    : scheme.surfaceContainerHigh,
                  backgroundImage:
                      item.isGroup &&
                          (item.groupAvatarUrl ?? '').trim().isNotEmpty
                      ? NetworkImage(item.groupAvatarUrl!.trim())
                      : null,
                  child:
                      item.isGroup &&
                          (item.groupAvatarUrl ?? '').trim().isNotEmpty
                      ? null
                      : Text(
                          item.initials.replaceAll(',', ''),
                          style: const TextStyle(fontWeight: FontWeight.w800),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: item.isUnread || isRequest
                                        ? FontWeight.w800
                                        : FontWeight.w700,
                                  ),
                            ),
                          ),
                          if (item.isGroup) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: scheme.surfaceContainerHighest,
                              ),
                              child: Text(
                                l.classroomsThreadTypeGroup,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle.replaceAll('\n', '  '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: item.isUnread
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      trailingText,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: (showUnread || isRequest)
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: (showUnread || isRequest)
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isRequest)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.requestState.name == 'pendingIncoming'
                              ? l.messagesRequestReviewStatus
                              : l.chatMessageInfoPending,
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    else if (showUnread)
                      Container(
                        constraints: const BoxConstraints(minWidth: 22),
                        height: 22,
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${item.unreadCount}',
                          style: TextStyle(
                            color: scheme.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 22),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
