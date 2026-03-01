import 'package:flutter/material.dart';

class NovaChatScreen extends StatefulWidget {
  const NovaChatScreen({
    super.key,
    required this.sessionId,
    required this.title,
  });

  final String sessionId;
  final String title;

  @override
  State<NovaChatScreen> createState() => _NovaChatScreenState();
}

class _NovaChatScreenState extends State<NovaChatScreen> {
  final _controller = TextEditingController();
  final List<_Message> _messages = [];
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NOVA')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return _MessageBubble(message: msg);
                    },
                  ),
          ),
          _InputBar(
            controller: _controller,
            isSending: _isSending,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message.user(text));
      _controller.clear();
      _isSending = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _messages.add(_Message.ai("This is where NOVA will respond."));
      _isSending = false;
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Ask anything.\nNOVA is ready.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message(this.text, this.isUser);

  factory _Message.user(String text) => _Message(text, true);
  factory _Message.ai(String text) => _Message(text, false);
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _Message message;

  @override
  Widget build(BuildContext context) {
    final align = message.isUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final color = message.isUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    final textColor = message.isUser ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: const BoxConstraints(maxWidth: 300),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(message.text, style: TextStyle(color: textColor)),
        ),
      ],
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: "Message NOVA...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24)),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: isSending
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Icon(Icons.send),
              onPressed: isSending ? null : onSend,
            ),
          ],
        ),
      ),
    );
  }
}
