import 'package:flutter/material.dart';

class MessageRequestScreen extends StatelessWidget {
  const MessageRequestScreen({
    super.key,
    required this.threadId,
  });

  final String threadId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message request')),
      body: Center(
        child: Text('Request $threadId'),
      ),
    );
  }
}
