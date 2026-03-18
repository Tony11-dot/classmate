import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/dm_models.dart';

final dmRepositoryProvider = Provider<DmRepository>(
  (ref) => const DmRepository(),
);

class DmRepository {
  const DmRepository();

  Future<List<DmThread>> listThreads() async {
    final now = DateTime.now();
    return <DmThread>[
      DmThread(
        id: 't-1',
        type: DmThreadType.direct,
        title: 'Ahmad K.',
        subtitle: 'You: got it',
        avatarText: 'AK',
        requestState: DmRequestState.accepted,
        isGroup: false,
        isBlocked: false,
        unreadCount: 2,
        updatedAt: now.subtract(const Duration(minutes: 8)),
        participants: const [
          DmUserLite(id: 'u-me', name: 'You', avatarText: 'YO'),
          DmUserLite(id: 'u-ahmad', name: 'Ahmad K.', avatarText: 'AK'),
        ],
      ),
      DmThread(
        id: 't-2',
        type: DmThreadType.direct,
        title: 'Maya R.',
        subtitle: 'Message request',
        avatarText: 'MR',
        requestState: DmRequestState.pendingIncoming,
        isGroup: false,
        isBlocked: false,
        unreadCount: 1,
        updatedAt: now.subtract(const Duration(hours: 1)),
        participants: const [
          DmUserLite(id: 'u-me', name: 'You', avatarText: 'YO'),
          DmUserLite(id: 'u-maya', name: 'Maya R.', avatarText: 'MR'),
        ],
      ),
      DmThread(
        id: 'g-1',
        type: DmThreadType.group,
        title: 'Math Legends',
        subtitle: 'Study group',
        avatarText: 'ML',
        requestState: DmRequestState.accepted,
        isGroup: true,
        isBlocked: false,
        unreadCount: 0,
        updatedAt: now.subtract(const Duration(hours: 3)),
        participants: const [
          DmUserLite(id: 'u-me', name: 'You', avatarText: 'YO'),
          DmUserLite(id: 'u-1', name: 'Ahmad K.', avatarText: 'AK'),
          DmUserLite(id: 'u-2', name: 'Maya R.', avatarText: 'MR'),
        ],
      ),
    ];
  }

  Future<List<DmMessage>> listMessages(String threadId) async {
    final now = DateTime.now();
    return <DmMessage>[
      DmMessage(
        id: 'm-1',
        senderId: 'u-other',
        senderName: 'Ahmad K.',
        isMine: false,
        kind: DmMessageKind.text,
        text: 'Hey, did you solve question 4?',
        mediaUrl: null,
        mediaMode: null,
        voiceDuration: null,
        createdAt: now.subtract(const Duration(minutes: 12)),
        reactions: const ['👍'],
      ),
      DmMessage(
        id: 'm-2',
        senderId: 'u-me',
        senderName: 'You',
        isMine: true,
        kind: DmMessageKind.image,
        text: 'Here is my work',
        mediaUrl: 'demo-image',
        mediaMode: DmMediaMode.keep,
        voiceDuration: null,
        createdAt: now.subtract(const Duration(minutes: 9)),
        reactions: const ['🔥'],
      ),
      DmMessage(
        id: 'm-3',
        senderId: 'u-other',
        senderName: 'Ahmad K.',
        isMine: false,
        kind: DmMessageKind.voice,
        text: '',
        mediaUrl: 'demo-voice',
        mediaMode: DmMediaMode.replay,
        voiceDuration: const Duration(seconds: 11),
        createdAt: now.subtract(const Duration(minutes: 4)),
        reactions: const [],
      ),
    ];
  }

  Future<void> acceptRequest(String threadId) async {}
  Future<void> blockUser(String threadId) async {}
  Future<void> unblockUser(String threadId) async {}
  Future<void> sendText(String threadId, String text) async {}
  Future<void> sendImage(
    String threadId,
    String path,
    DmMediaMode mode,
  ) async {}
  Future<void> sendVoice(
    String threadId,
    String path,
    DmMediaMode mode,
  ) async {}
  Future<void> createGroup(String title, List<String> userIds) async {}
}
