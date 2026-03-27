import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../chat_core/domain/chat_request_state.dart';
import '../../chat_core/ui/chat_composer.dart';
import '../../chat_core/ui/chat_message_bubble.dart';
import '../../chat_core/utils/chat_reply_codec.dart';
import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';
import 'components/message_reply_preview.dart';
import 'components/message_reaction_bar.dart';

class MessageThreadScreen extends ConsumerStatefulWidget {
  const MessageThreadScreen({
    super.key,
    required this.threadId,
  });

  final String threadId;

  @override
  ConsumerState<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends ConsumerState<MessageThreadScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> _reactionByMessageId = <String, String>{};
  int? _replyIndex;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(MessageThreadDetail detail) async {
    final text = _controller.text.trim();
    if (text.isEmpty || !detail.canSend) return;

    final rows = detail.messages;
    final replyToMessageId =
        _replyIndex == null ? null : rows[_replyIndex!].id;

    await ref.read(messagesRepositoryProvider).sendMessage(
      threadId: widget.threadId,
      text: text,
      replyToMessageId: replyToMessageId,
    );

    if (!mounted) return;

    _controller.clear();
    setState(() {
      _replyIndex = null;
    });

    ref.invalidate(messageThreadProvider(widget.threadId));
    ref.invalidate(messagesInboxProvider);
    _pinToBottom();
  }

  void _pinToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _openMessageInfoSheet(
    BuildContext modalContext,
    MessageItem row,
  ) async {
    await showModalBottomSheet<void>(
      context: modalContext,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(title: Text('Message info')),
            ListTile(
              title: const Text('Sent'),
              subtitle: Text(row.timeLabel),
            ),
            ListTile(
              title: const Text('Delivered'),
              subtitle: Text(row.timeLabel),
            ),
            ListTile(
              title: const Text('Seen'),
              subtitle: Text(row.isMine ? row.timeLabel : '—'),
            ),
            ListTile(
              title: const Text('Type'),
              subtitle: Text(row.kind),
            ),
          ],
        ),
      ),
    );
  }

  String _avatarText(MessageThreadDetail detail) {
    if (detail.isGroup) {
      final parts = detail.title
          .split(' ')
          .where((v) => v.trim().isNotEmpty)
          .take(2)
          .map((e) => e[0].toUpperCase())
          .join();
      return parts.isEmpty ? 'G' : parts;
    }

    final others = detail.participants.where((p) {
      final lower = p.displayName.trim().toLowerCase();
      return lower != 'you';
    }).toList();

    if (others.isNotEmpty && others.first.initials.trim().isNotEmpty) {
      return others.first.initials.trim().toUpperCase();
    }

    return detail.title.isNotEmpty ? detail.title[0].toUpperCase() : '?';
  }

  Widget _pendingBanner(BuildContext context, MessageThreadDetail detail) {
    final scheme = Theme.of(context).colorScheme;
    final isOutgoing =
        detail.requestState == ChatRequestState.pendingOutgoing;
    final title = isOutgoing ? 'Waiting for approval' : 'Message request';
    final subtitle = isOutgoing
        ? 'You can send more once the other person approves this chat.'
        : 'Review the request to start chatting.';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOutgoing ? Icons.hourglass_top_rounded : Icons.mark_chat_unread_rounded,
            color: scheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _startsGroup(List<MessageItem> rows, int index) {
    if (index == 0) return true;
    final prev = rows[index - 1];
    final cur = rows[index];
    return prev.senderId != cur.senderId;
  }

  bool _endsGroup(List<MessageItem> rows, int index) {
    if (index == rows.length - 1) return true;
    final next = rows[index + 1];
    final cur = rows[index];
    return next.senderId != cur.senderId;
  }

  @override
  Widget build(BuildContext context) {
    final thread = ref.watch(messageThreadProvider(widget.threadId));

    return Scaffold(
      body: SafeArea(
        child: thread.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) =>
              Center(child: Text('Failed to load thread: $error')),
          data: (detail) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(messagesRepositoryProvider).markThreadRead(
                    threadId: widget.threadId,
                  );
              ref.invalidate(messagesInboxProvider);
            });

            final rows = detail.messages;
            final replyingText =
                _replyIndex == null ? '' : rows[_replyIndex!].text;

            return Column(
              children: [
                AppBar(
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      CircleAvatar(
                        child: Text(_avatarText(detail)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          detail.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!detail.canSend ||
                    detail.requestState == ChatRequestState.pendingOutgoing ||
                    detail.requestState == ChatRequestState.pendingIncoming)
                  _pendingBanner(context, detail),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      final startsGroup = _startsGroup(rows, index);
                      final endsGroup = _endsGroup(rows, index);

                      return Align(
                        alignment: row.isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: startsGroup ? 8 : 2,
                            bottom: endsGroup ? 4 : 2,
                          ),
                          child: GestureDetector(
                            onHorizontalDragEnd: (_) {
                              setState(() => _replyIndex = index);
                            },
                            onLongPress: () async {
                              final navigator = Navigator.of(context);
                              final selected =
                                  await showModalBottomSheet<String>(
                                context: navigator.context,
                                showDragHandle: true,
                                builder: (sheetContext) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MessageReactionBar(
                                        onReact: (reaction) {
                                          Navigator.of(sheetContext).pop(
                                            'react:$reaction',
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      ListTile(
                                        leading: const Icon(Icons.reply_rounded),
                                        title: const Text('Reply'),
                                        onTap: () =>
                                            Navigator.of(sheetContext).pop('reply'),
                                      ),
                                      ListTile(
                                        leading:
                                            const Icon(Icons.info_outline_rounded),
                                        title: const Text('Message info'),
                                        onTap: () =>
                                            Navigator.of(sheetContext).pop('info'),
                                      ),
                                    ],
                                  ),
                                ),
                              );

                              if (!mounted || selected == null) return;

                              if (selected == 'reply') {
                                setState(() => _replyIndex = index);
                                return;
                              }

                              if (selected.startsWith('react:')) {
                                final reaction =
                                    selected.substring('react:'.length).trim();
                                if (reaction.isEmpty) return;
                                setState(() {
                                  _reactionByMessageId[row.id] = reaction;
                                });
                                return;
                              }

                              if (selected == 'info') {
                                await _openMessageInfoSheet(navigator.context, row);
                              }
                            },
                            child: Column(
                              crossAxisAlignment: row.isMine
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (row.isPinned)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 2,
                                      bottom: 4,
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.push_pin_rounded,
                                          size: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Pinned',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ChatMessageBubble(
                                  contextForNavigation: context,
                                  rawText: row.text,
                                  mediaUrl: row.mediaUrl ?? '',
                                  isMine: row.isMine,
                                  showName: detail.isGroup && startsGroup && !row.isMine,
                                  senderLabel: row.senderName,
                                  timeLabel: row.timeLabel,
                                  edited: false,
                                  reaction: _reactionByMessageId[row.id] ?? row.reaction,
                                  replySender: row.replyPreview?.senderName,
                                  replySnippet: row.replyPreview?.text,
                                  maxWidth: 340,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_replyIndex != null)
                  MessageReplyPreview(
                    sender: rows[_replyIndex!].isMine
                        ? 'You'
                        : rows[_replyIndex!].senderName,
                    text: replyingText,
                    onCancel: () {
                      setState(() => _replyIndex = null);
                    },
                  ),
                ChatComposer(
                  controller: _controller,
                  replyingTo: _replyIndex == null
                      ? null
                      : (
                          senderName: rows[_replyIndex!].isMine
                              ? 'You'
                              : rows[_replyIndex!].senderName,
                          text: replyPreviewText(rows[_replyIndex!].text),
                        ),
                  onCancelReply: () {
                    setState(() => _replyIndex = null);
                  },
                  onSend: () => _send(detail),
                  onCamera: () {},
                  onAttach: () {},
                  onMic: () {},
                  enabled: detail.canSend,
                  hintText: detail.canSend ? 'Message' : 'Waiting for approval',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
