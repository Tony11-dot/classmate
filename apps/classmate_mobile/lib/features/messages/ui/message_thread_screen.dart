import 'package:flutter/material.dart';

import 'components/message_bubble.dart';
import 'components/message_input.dart';
import 'components/message_reply_preview.dart';
import 'components/message_reaction_bar.dart';

class MessageThreadScreen extends StatefulWidget {
  const MessageThreadScreen({
    super.key,
    required this.threadId,
  });

  final String threadId;

  @override
  State<MessageThreadScreen> createState() => _MessageThreadScreenState();
}

class _MessageThreadScreenState extends State<MessageThreadScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<({bool isMine, String text, String time, String? reaction})>
  _rows = <({bool isMine, String text, String time, String? reaction})>[
    (isMine: false, text: 'Hey Tony, can you send the notes?', time: '2:11 PM', reaction: null),
    (isMine: true, text: 'Yes, I’ll send them here.', time: '2:12 PM', reaction: '👍'),
    (isMine: false, text: 'Perfect', time: '2:13 PM', reaction: null),
  ];

  int? _replyIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _rows.add((
        isMine: true,
        text: text,
        time: 'Now',
        reaction: null,
      ));
      _controller.clear();
      _replyIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final replyingText = _replyIndex == null ? '' : _rows[_replyIndex!].text;

    return Scaffold(
      body: SafeArea(
        child: Column(
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
                  const CircleAvatar(child: Text('ON')),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Omar Nassar',
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
                itemCount: _rows.length,
                itemBuilder: (context, index) {
                  final row = _rows[index];
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
                          final selected = await showModalBottomSheet<String>(
                            context: context,
                            showDragHandle: true,
                            builder: (context) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MessageReactionBar(
                                    onReact: (reaction) {
                                      Navigator.of(context).pop('react:$reaction');
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  ListTile(
                                    leading: const Icon(Icons.reply_rounded),
                                    title: const Text('Reply'),
                                    onTap: () => Navigator.of(context).pop('reply'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.info_outline_rounded),
                                    title: const Text('Message info'),
                                    onTap: () => Navigator.of(context).pop('info'),
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
                            final reaction = selected.substring('react:'.length).trim();
                            if (reaction.isEmpty) return;
                            setState(() {
                              _rows[index] = (
                                isMine: row.isMine,
                                text: row.text,
                                time: row.time,
                                reaction: reaction,
                              );
                            });
                            return;
                          }

                          if (selected == 'info') {
                            showModalBottomSheet<void>(
                              context: context,
                              showDragHandle: true,
                              builder: (context) => SafeArea(
                                child: ListView(
                                  shrinkWrap: true,
                                  children: [
                                    const ListTile(title: Text('Message info')),
                                    ListTile(
                                      title: const Text('Sent'),
                                      subtitle: Text(row.time),
                                    ),
                                    ListTile(
                                      title: const Text('Delivered'),
                                      subtitle: Text(row.time),
                                    ),
                                    ListTile(
                                      title: const Text('Seen'),
                                      subtitle: Text(row.isMine ? row.time : '—'),
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
                            MessageBubble(
                              isMine: row.isMine,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(row.text),
                                    const SizedBox(height: 6),
                                    Text(
                                      row.time,
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
                                padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
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
                sender: _rows[_replyIndex!].isMine ? 'You' : 'Omar Nassar',
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
        ),
      ),
    );
  }
}
