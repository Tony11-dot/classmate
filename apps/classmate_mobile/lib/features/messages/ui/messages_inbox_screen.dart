// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../data/messages_repository.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';
import '../../chat_core/utils/chat_time.dart';
import '../../chat_core/utils/chat_reply_codec.dart';
import '../../chat_core/ui/chat_ticks.dart';
import 'new_chat_screen.dart';
import 'blocked_people_screen.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../core/realtime/realtime_listener.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';

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
    final threadId = await Navigator.of(context, rootNavigator: true).push<String>(
      CupertinoPageRoute<String>(
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
    // rootNavigator: true pushes ABOVE the app shell so the screen covers the
    // global top bar (logo + hamburger + tab pill) — a true full-screen page.
    // Pushing on the nearest (shell) navigator left that chrome visible.
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(builder: (_) => const BlockedPeopleScreen()),
    );
  }

  Future<void> _joinGroupByCode() async {
    var joining = false;
    String? errorMsg;
    final codeCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setS) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
                            child: Icon(Icons.group_add_rounded, color: cs.onPrimaryContainer, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(ctx)!.msgJoinGroupTitle, style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                Text(AppLocalizations.of(ctx)!.msgJoinGroupSubtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: codeCtrl,
                        autofocus: true,
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 4),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '• • • • • • • •',
                          hintStyle: TextStyle(color: cs.onSurfaceVariant),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest,
                          errorText: errorMsg,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: joining ? null : () async {
                            final code = codeCtrl.text.trim();
                            if (code.isEmpty) return;
                            joining = true;
                            setS(() { errorMsg = null; });
                            try {
                              final threadId = await (ref.read(messagesRepositoryProvider) as ApiMessagesRepository).joinGroupByCode(code: code);
                              if (!mounted) return;
                              ref.invalidate(messagesInboxProvider);
                              Navigator.of(ctx).pop();
                              if (threadId != null && threadId.isNotEmpty) {
                                context.pushNamed('dm_thread', pathParameters: {'id': threadId});
                              }
                            } catch (e) {
                              joining = false;
                              setS(() { errorMsg = e.toString().replaceFirst('Exception: ', ''); });
                            }
                          },
                          icon: joining
                              ? const CmLoading(size: 18)
                              : const Icon(Icons.group_add_rounded),
                          label: Text(joining ? AppLocalizations.of(ctx)!.chatJoining : AppLocalizations.of(ctx)!.chatJoinGroup),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
            tooltip: l.chatJoinGroupTooltip,
            onPressed: _joinGroupByCode,
            icon: const Icon(Icons.group_add_rounded),
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
    return const IgnorePointer(child: SizedBox.shrink());
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
      // Pinned chats stay on top (newest-first within each section) — the
      // server orders them this way too; keep the client sort in agreement.
      final pin = (b.value.isPinned ? 1 : 0) - (a.value.isPinned ? 1 : 0);
      if (pin != 0) return pin;
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
    final l = AppLocalizations.of(context)!;
    return formatChatInboxTrailingLabel(
      item.lastMessageDate,
      fallback: item.lastMessageAt.trim(),
      yesterday: l.yesterday,
    );
  }

  // ── Long-press chat actions (WhatsApp-style) ──────────────────────────────

  Future<bool> _confirm(String title, String message, String actionLabel,
      {bool destructive = true}) async {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: cs.error, foregroundColor: cs.onError)
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _runInboxAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        ref.invalidate(messagesInboxProvider);
      }
    }
  }

  Future<void> _showThreadActions(MessageThreadSummary item) async {
    final l = AppLocalizations.of(context)!;
    final repo = ref.read(messagesRepositoryProvider);
    final api = repo as ApiMessagesRepository;

    Widget action({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color? color,
    }) {
      return ListTile(
        leading: Icon(icon, color: color),
        title: Text(label,
            style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        onTap: () {
          Navigator.of(context).pop();
          onTap();
        },
      );
    }

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: false,
      // The sheet holds up to 7 rows — without this the default half-screen
      // cap clipped the last action (Block) behind the home indicator.
      isScrollControlled: true,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(ctx)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              action(
                icon: item.isPinned
                    ? Icons.push_pin_outlined
                    : Icons.push_pin_rounded,
                label: item.isPinned ? l.inboxActionUnpin : l.inboxActionPin,
                onTap: () => _runInboxAction(
                    () => repo.togglePinThread(threadId: item.id)),
              ),
              action(
                icon: item.isMuted
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                label: item.isMuted ? l.inboxActionUnmute : l.inboxActionMute,
                onTap: () => _runInboxAction(
                    () => api.toggleMuteThread(threadId: item.id)),
              ),
              action(
                icon: item.isUnread
                    ? Icons.mark_chat_read_rounded
                    : Icons.mark_chat_unread_rounded,
                label: item.isUnread
                    ? l.inboxActionMarkRead
                    : l.inboxActionMarkUnread,
                onTap: () => _runInboxAction(() => item.isUnread
                    ? repo.markThreadRead(threadId: item.id)
                    : repo.markThreadUnread(threadId: item.id)),
              ),
              const Divider(height: 1),
              action(
                icon: Icons.cleaning_services_rounded,
                label: l.inboxActionClear,
                color: Theme.of(ctx).colorScheme.error,
                onTap: () async {
                  if (await _confirm(l.inboxActionClear,
                      l.inboxActionClearConfirm, l.inboxActionClear)) {
                    await _runInboxAction(
                        () => repo.clearThread(threadId: item.id));
                    ref.invalidate(messageThreadProvider(item.id));
                  }
                },
              ),
              action(
                icon: Icons.delete_outline_rounded,
                label: l.inboxActionDeleteChat,
                color: Theme.of(ctx).colorScheme.error,
                onTap: () async {
                  if (await _confirm(
                      l.inboxActionDeleteChat,
                      l.inboxActionDeleteChatConfirm,
                      l.inboxActionDeleteChat)) {
                    await _runInboxAction(
                        () => repo.clearThread(threadId: item.id, hide: true));
                    ref.invalidate(messageThreadProvider(item.id));
                  }
                },
              ),
              if (!item.isGroup)
                action(
                  icon: Icons.block_rounded,
                  label: l.inboxActionBlock,
                  color: Theme.of(ctx).colorScheme.error,
                  onTap: () async {
                    if (await _confirm(l.inboxActionBlock,
                        l.inboxActionBlockConfirm, l.inboxActionBlock)) {
                      await _runInboxAction(
                          () => repo.blockDirectThread(threadId: item.id));
                    }
                  },
                ),
              const SizedBox(height: 8),
            ],
            ),
          ),
        );
      },
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
    // Real-time: refresh inbox when DM/group message arrives
    ref.listen(realtimeEventProvider, (_, event) {
      if (event?.type == 'dm_message') ref.invalidate(messagesInboxProvider);
    });
    final inbox = ref.watch(messagesInboxProvider);
    final query = _searchCtl.text.trim().toLowerCase();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: inbox.when(
          loading: () => const Center(child: CmLoading()),
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
                  CmRefreshIndicator(
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
                CmRefreshIndicator(
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
                            onLongPress: () => _showThreadActions(item),
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
                            onLongPress: () => _showThreadActions(item),
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
  const _InboxRow({
    required this.item,
    required this.trailingLabel,
    this.onLongPress,
  });

  final MessageThreadSummary item;
  final String trailingLabel;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isRequest = item.requestState.name == 'pendingIncoming';
    // isUnread covers both real unread messages AND a manual "mark as unread"
    // (unreadCount is 0 there — the badge falls back to a dot).
    final showUnread = item.isUnread;
    final trailingText = trailingLabel.trim().isEmpty
        ? item.lastMessageAt.trim()
        : trailingLabel.trim();
    final borderColor = isRequest || showUnread
        ? scheme.primary
        : scheme.outlineVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: scheme.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onLongPress: onLongPress,
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
                      // Decode at the display size (56px @2x) instead of full
                      // resolution — much smaller image-cache footprint.
                      ? ResizeImage(NetworkImage(item.groupAvatarUrl!.trim()), width: 112, height: 112)
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
                          if (item.isMuted) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.volume_off_rounded,
                                size: 15, color: scheme.onSurfaceVariant),
                          ],
                          if (item.isPinned) ...[
                            const SizedBox(width: 6),
                            Icon(Icons.push_pin_rounded,
                                size: 15, color: scheme.onSurfaceVariant),
                          ],
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
                      _InboxPreviewLine(item: item),
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
                    else if (showUnread && item.unreadCount > 0)
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
                    else if (showUnread)
                      // Manual "mark as unread" — no count, WhatsApp-style dot.
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          shape: BoxShape.circle,
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

/// The WhatsApp-style second line of an inbox row: delivery tick for your own
/// last message, "You:"/sender prefix, then the message content — text as-is,
/// media as emoji + localized kind ("🎤 Voice message"). Composed CLIENT-side
/// from the structured `lastMessage` payload so it follows the app language;
/// the server's `subtitle` string is only a fallback for empty threads.
class _InboxPreviewLine extends StatelessWidget {
  const _InboxPreviewLine({required this.item});

  final MessageThreadSummary item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: item.isUnread ? FontWeight.w600 : FontWeight.w400,
        );

    final lm = item.lastMessage;
    if (lm == null) {
      // Empty thread (or a pre-upgrade server). Request states already show a
      // chip on the trailing side, so the line can stay generic.
      final isRequest = item.requestState.name != 'none';
      final text = isRequest
          ? item.subtitle.replaceAll('\n', '  ')
          : l.classroomsNoMessagesYet;
      return Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style);
    }

    final labels = ChatPreviewLabels.of(l);
    final body = lm.text.trim().isEmpty
        ? messagePreviewText(kind: lm.kind, labels: labels)
        : replyPreviewText(lm.text, labels: labels);
    // Sender prefix, WhatsApp-style: in 1:1 chats your own messages carry only
    // the tick (a "You:" would be redundant next to it); groups name whoever
    // spoke last — "You:" for yourself, first name for anyone else.
    final prefix = !item.isGroup
        ? ''
        : lm.isOwn
            ? '${l.chatPreviewYou}: '
            : lm.senderName.trim().isNotEmpty
                ? '${lm.senderName.trim().split(' ').first}: '
                : '';

    return Row(
      children: [
        if (lm.isOwn) ...[
          ChatTicks(
            state: ChatTicks.stateOf(delivered: lm.delivered, seen: lm.seen),
            onAccentSurface: false,
            size: 15,
          ),
          const SizedBox(width: 3),
        ],
        Expanded(
          child: Text(
            '$prefix$body',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}
