import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message_request_models.dart';
import '../providers/messages_repository_provider.dart';
import 'components/message_request_banner.dart';

class MessageRequestScreen extends ConsumerWidget {
  const MessageRequestScreen({
    super.key,
    required this.threadId,
  });

  final String threadId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = ref.watch(messageRequestProvider(threadId));

    return Scaffold(
      appBar: AppBar(title: const Text('Message request')),
      body: request.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Failed to load request: $error'),
        ),
        data: (detail) {
          final first = detail.messages.first;
          final data = MessageRequestBannerData(
            threadId: detail.id,
            senderName: detail.title,
            senderInitials: detail.participants.first.initials,
            firstMessage: first.text,
            isIncoming: true,
          );

          return ListView(
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
          );
        },
      ),
    );
  }
}
