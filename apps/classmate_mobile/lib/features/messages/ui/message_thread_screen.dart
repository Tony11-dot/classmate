import 'package:flutter/material.dart';

import '../../chat_core/ui/chat_composer.dart';
import 'components/message_bubble.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rows = const [
      (false, 'Hey Tony, can you send the notes?'),
      (true, 'Yes, I’ll send them here.'),
      (false, 'Perfect'),
    ];

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
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  final isMine = row.$1;
                  final text = row.$2;
                  return Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: MessageBubble(
                        isMine: isMine,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(text),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ChatComposer(
              controller: _controller,
              onSend: () {},
              onCamera: () {},
              onAttach: () {},
              onMic: () {},
            ),
          ],
        ),
      ),
    );
  }
}
