import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context)!;
    final request = ref.watch(messageRequestProvider(threadId));
    final repo = ref.read(messagesRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.messagesRequestTitle)),
      body: request.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text(l.messagesRequestLoadFailed(error.toString())),
        ),
        data: (detail) {
          final first = detail.messages.first;
          final firstParticipant = detail.participants.first;
          final data = MessageRequestBannerData(
            threadId: detail.id,
            senderName: detail.title,
            senderInitials: firstParticipant.initials,
            firstMessage: first.text,
            isIncoming: true,
          );

          return ListView(
            children: [
              MessageRequestBanner(
                data: data,
                onApprove: () async {
                  await repo.approveRequest(threadId: detail.id);
                  ref.invalidate(messagesInboxProvider);
                  ref.invalidate(messageRequestProvider(threadId));
                  if (!context.mounted) return;
                  context.pushReplacementNamed(
                    'dm_thread',
                    pathParameters: {'id': detail.id},
                  );
                },
                onBlock: () async {
                  await repo.blockRequest(threadId: detail.id);
                  ref.invalidate(messagesInboxProvider);
                  ref.invalidate(messageRequestProvider(threadId));
                  if (!context.mounted) return;
                  context.go('/messages');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
