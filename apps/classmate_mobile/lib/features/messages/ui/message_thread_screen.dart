import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/message_thread_models.dart';
import '../providers/messages_repository_provider.dart';
import 'components/message_bubble.dart';
import 'components/message_input.dart';
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
  int? _replyIndex;
  List<MessageItem> _localMessages = const [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _localMessages = [
        ..._localMessages,
        MessageItem(
          id: 'local-${DateTime.now().millisecondsSinceEpoch}',
          senderId: 'me',
          senderName: 'You',
          text: text,
          timeLabel: 'Now',
          isMine: true,
        ),
      ];
      _controller.clear();
      _replyIndex = null;
    });
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
            final rows = _localMessages.isEmpty
                ? detail.messages
                : <MessageItem>[...detail.messages, ..._localMessages];
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
                        child: Text(
                          detail.isGroup
                              ? detail.title
                                  .split(' ')
                                  .take(2)
                                  .map((e) => e[0])
                                  .join()
                              : detail.participants.last.initials,
                        ),
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
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    itemCount: rows.length,
                    itemBuilder: (context, index) {
                      final row = rows[index];
                      return Align(
                        alignment: row.isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: GestureDetector(
                            onHorizontalDragEnd: (_) {
                              setState(() => _replyIndex = index);
                            },
                            onLongPress: () async {
                              final selected =
                                  await showModalBottomSheet<String>(
                                context: context,
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
                                        onTap: () => Navigator.of(sheetContext)
                                            .pop('reply'),
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.info_outline_rounded,
                                        ),
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
                                  rows[index] = MessageItem(
                                    id: row.id,
                                    senderId: row.senderId,
                                    senderName: row.senderName,
                                    text: row.text,
                                    timeLabel: row.timeLabel,
                                    isMine: row.isMine,
                                    reaction: reaction,
                                    isPinned: row.isPinned,
                                  );
                                  _localMessages = rows.skip(detail.messages.length).toList();
                                });
                                return;
                              }

                              if (selected == 'info') {
                                if (!context.mounted) return;
                                showModalBottomSheet<void>(
                                  context: context,
                                  showDragHandle: true,
                                  builder: (sheetContext) => SafeArea(
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: [
                                        const ListTile(
                                          title: Text('Message info'),
                                        ),
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
                                          subtitle: Text(
                                            row.isMine ? row.timeLabel : '—',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
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
                                MessageBubble(
                                  isMine: row.isMine,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(row.text),
                                        const SizedBox(height: 6),
                                        Text(
                                          row.timeLabel,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if ((row.reaction ?? '').trim().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 4,
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: Text(row.reaction!),
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
                MessageInput(
                  controller: _controller,
                  onSend: _send,
                  onPickImage: () {},
                  onPickFile: () {},
                  onRecord: () {},
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
