import 'package:flutter/material.dart';

import 'components/message_request_banner.dart';
import '../models/message_request_models.dart';

class MessageRequestScreen extends StatelessWidget {
  const MessageRequestScreen({
    super.key,
    required this.threadId,
  });

  final String threadId;

  @override
  Widget build(BuildContext context) {
    final data = MessageRequestBannerData(
      threadId: threadId,
      senderName: 'Rachel Haddad',
      senderInitials: 'RH',
      firstMessage: 'Hey, can we talk about the assignment?',
      isIncoming: true,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Message request')),
      body: ListView(
        children: [
          MessageRequestBanner(
            data: data,
            onApprove: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Approve flow wiring next')),
              );
            },
            onBlock: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Block flow wiring next')),
              );
            },
          ),
        ],
      ),
    );
  }
}
