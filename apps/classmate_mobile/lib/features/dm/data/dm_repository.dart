import '../domain/dm_models.dart';

class DmRepository {
  const DmRepository();

  List<DmInboxItem> inbox() {
    return <DmInboxItem>[
      DmInboxItem(
        id: 'req-1',
        isGroup: false,
        title: 'Layan Haddad',
        subtitle: 'Sent you a first message request',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        unreadCount: 1,
        requestState: DmRequestState.pendingIncoming,
        otherUser: const DmProfileLite(
          id: 'u-layan',
          fullName: 'Layan Haddad',
          handle: '@layan',
          avatarText: 'LH',
          status: 'Working on math',
        ),
      ),
      DmInboxItem(
        id: 'chat-1',
        isGroup: false,
        title: 'Omar Darwish',
        subtitle: 'Can you send the physics sheet?',
        updatedAt: DateTime.now().subtract(const Duration(minutes: 35)),
        unreadCount: 2,
        requestState: DmRequestState.accepted,
        otherUser: const DmProfileLite(
          id: 'u-omar',
          fullName: 'Omar Darwish',
          handle: '@omar',
          avatarText: 'OD',
          status: 'Physics grind',
        ),
      ),
      DmInboxItem(
        id: 'group-1',
        isGroup: true,
        title: 'Math Legends',
        subtitle: 'Rama: page 112 question 4 is solved',
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
        requestState: DmRequestState.accepted,
        otherUser: const DmProfileLite(
          id: 'g-math',
          fullName: 'Math Legends',
          handle: '@group',
          avatarText: 'ML',
          status: 'Group chat',
        ),
      ),
    ];
  }

  List<DmMessage> thread(String threadId) {
    return <DmMessage>[
      DmMessage(
        id: 'm1',
        senderId: 'u-omar',
        text: 'Hey, did you solve the mechanics question?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 26)),
        reactions: const ['👍', '🔥'],
        mine: false,
      ),
      DmMessage(
        id: 'm2',
        senderId: 'me',
        text: 'Yeah. I can send the setup and final result.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
        reactions: const ['✅'],
        mine: true,
      ),
      DmMessage(
        id: 'm3',
        senderId: 'u-omar',
        text: 'Perfect. Send it when you can.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 12)),
        reactions: const [],
        mine: false,
      ),
    ];
  }
}
