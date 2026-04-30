import 'chat_message_kind.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String text;
  final ChatMessageKind kind;
  final String? mediaUrl;
  final String? mediaMimeType;
  final int? voiceDurationSeconds;
  final bool voicePlayed;
  final DateTime createdAt;
  final DateTime? editedAt;
  final String? replyToMessageId;
  final String? replyToSenderName;
  final String? replyToText;
  final String? replyToKind;
  final String? replyToMediaUrl;
  final Map<String, List<String>> reactions;
  final bool deletedForMe;
  final bool deletedForEveryone;
  final bool pinned;
  final bool isOwn;
  final bool isOptimistic;
  final bool forwarded;
  final bool delivered;
  final bool seen;
  final DateTime? deliveredAt;
  final DateTime? seenAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.text,
    required this.kind,
    this.mediaUrl,
    this.mediaMimeType,
    this.voiceDurationSeconds,
    this.voicePlayed = false,
    required this.createdAt,
    this.editedAt,
    this.replyToMessageId,
    this.replyToSenderName,
    this.replyToText,
    this.replyToKind,
    this.replyToMediaUrl,
    this.reactions = const <String, List<String>>{},
    this.deletedForMe = false,
    this.deletedForEveryone = false,
    this.pinned = false,
    required this.isOwn,
    this.isOptimistic = false,
    this.forwarded = false,
    this.delivered = false,
    this.seen = false,
    this.deliveredAt,
    this.seenAt,
  });

  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? text,
    ChatMessageKind? kind,
    String? mediaUrl,
    String? mediaMimeType,
    int? voiceDurationSeconds,
    bool? voicePlayed,
    DateTime? createdAt,
    DateTime? editedAt,
    String? replyToMessageId,
    String? replyToSenderName,
    String? replyToText,
    String? replyToKind,
    String? replyToMediaUrl,
    Map<String, List<String>>? reactions,
    bool? deletedForMe,
    bool? deletedForEveryone,
    bool? pinned,
    bool? isOwn,
    bool? isOptimistic,
    bool? forwarded,
    bool? delivered,
    bool? seen,
    DateTime? deliveredAt,
    DateTime? seenAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      text: text ?? this.text,
      kind: kind ?? this.kind,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaMimeType: mediaMimeType ?? this.mediaMimeType,
      voiceDurationSeconds: voiceDurationSeconds ?? this.voiceDurationSeconds,
      voicePlayed: voicePlayed ?? this.voicePlayed,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToSenderName: replyToSenderName ?? this.replyToSenderName,
      replyToText: replyToText ?? this.replyToText,
      replyToKind: replyToKind ?? this.replyToKind,
      replyToMediaUrl: replyToMediaUrl ?? this.replyToMediaUrl,
      reactions: reactions ?? this.reactions,
      deletedForMe: deletedForMe ?? this.deletedForMe,
      deletedForEveryone: deletedForEveryone ?? this.deletedForEveryone,
      pinned: pinned ?? this.pinned,
      isOwn: isOwn ?? this.isOwn,
      isOptimistic: isOptimistic ?? this.isOptimistic,
      forwarded: forwarded ?? this.forwarded,
      delivered: delivered ?? this.delivered,
      seen: seen ?? this.seen,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      seenAt: seenAt ?? this.seenAt,
    );
  }
}
