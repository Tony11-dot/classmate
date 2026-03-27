import '../domain/chat_context_type.dart';

class ChatActionPolicy {
  final ChatContextType contextType;
  final bool canReply;
  final bool canReact;
  final bool canForward;
  final bool canPin;
  final bool canViewInfo;
  final bool canEditOwnText;
  final bool canDeleteOwn;
  final bool canDeleteForEveryone;
  final bool canModeratorDelete;
  final bool canSendVoiceNotes;
  final bool canSendFiles;
  final bool canSendImages;
  final bool canSendVideo;
  final bool canUseApprovalFlow;
  final bool canBlockUsers;

  const ChatActionPolicy({
    required this.contextType,
    required this.canReply,
    required this.canReact,
    required this.canForward,
    required this.canPin,
    required this.canViewInfo,
    required this.canEditOwnText,
    required this.canDeleteOwn,
    required this.canDeleteForEveryone,
    required this.canModeratorDelete,
    required this.canSendVoiceNotes,
    required this.canSendFiles,
    required this.canSendImages,
    required this.canSendVideo,
    required this.canUseApprovalFlow,
    required this.canBlockUsers,
  });

  factory ChatActionPolicy.messages() => const ChatActionPolicy(
        contextType: ChatContextType.messages,
        canReply: true,
        canReact: true,
        canForward: true,
        canPin: true,
        canViewInfo: true,
        canEditOwnText: true,
        canDeleteOwn: true,
        canDeleteForEveryone: true,
        canModeratorDelete: true,
        canSendVoiceNotes: true,
        canSendFiles: true,
        canSendImages: true,
        canSendVideo: true,
        canUseApprovalFlow: true,
        canBlockUsers: true,
      );

  factory ChatActionPolicy.classroom() => const ChatActionPolicy(
        contextType: ChatContextType.classroom,
        canReply: true,
        canReact: true,
        canForward: true,
        canPin: true,
        canViewInfo: true,
        canEditOwnText: true,
        canDeleteOwn: true,
        canDeleteForEveryone: false,
        canModeratorDelete: true,
        canSendVoiceNotes: true,
        canSendFiles: true,
        canSendImages: true,
        canSendVideo: true,
        canUseApprovalFlow: false,
        canBlockUsers: false,
      );

  factory ChatActionPolicy.nova() => const ChatActionPolicy(
        contextType: ChatContextType.nova,
        canReply: false,
        canReact: false,
        canForward: false,
        canPin: false,
        canViewInfo: false,
        canEditOwnText: false,
        canDeleteOwn: false,
        canDeleteForEveryone: false,
        canModeratorDelete: false,
        canSendVoiceNotes: false,
        canSendFiles: true,
        canSendImages: true,
        canSendVideo: false,
        canUseApprovalFlow: false,
        canBlockUsers: false,
      );
}
