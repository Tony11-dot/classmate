import 'package:flutter/material.dart';

class MessageThreadScreen extends StatelessWidget {
  const MessageThreadScreen({
    super.key,
    required this.threadId,
  });

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message')),
      body: Center(
        child: Text('Thread $threadId'),
      ),
    );
  }
}
