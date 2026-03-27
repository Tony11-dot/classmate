class ChatReplyParts {
  final String? repliedMessageId;
  final String? repliedSenderName;
  final String? repliedPreview;
  final String body;

  const ChatReplyParts({
    required this.body,
    this.repliedMessageId,
    this.repliedSenderName,
    this.repliedPreview,
  });

  bool get hasReply =>
      (repliedMessageId?.isNotEmpty ?? false) ||
      (repliedSenderName?.isNotEmpty ?? false) ||
      (repliedPreview?.isNotEmpty ?? false);

  String get bodyText => body.trim();

  String get replyPrefix {
    final sender = (repliedSenderName ?? '').trim();
    final preview = (repliedPreview ?? '').trim();
    if (sender.isEmpty && preview.isEmpty) return '';
    if (sender.isEmpty) return '↪ $preview —';
    if (preview.isEmpty) return '↪ $sender —';
    return '↪ $sender: $preview —';
  }
}

const String _replySep = '\n———\n';
const String _metaSep = '||';

String replyPreviewText([
  String? raw,
  String? senderName,
  String? previewText,
]) {
  if ((previewText ?? '').trim().isNotEmpty ||
      (senderName ?? '').trim().isNotEmpty) {
    final sender = (senderName ?? '').trim();
    final preview = (previewText ?? '').trim();
    if (sender.isEmpty && preview.isEmpty) return '';
    if (sender.isEmpty) return preview;
    if (preview.isEmpty) return sender;
    return '$sender: $preview';
  }

  final parts = splitReplyRaw(raw);
  final preview = parts.bodyText;
  if (preview.isEmpty) return 'Message';
  return preview;
}

ChatReplyParts splitReplyRaw(String? raw) {
  final text = (raw ?? '').trim();
  if (text.isEmpty) {
    return const ChatReplyParts(body: '');
  }

  if (text.contains(_replySep)) {
    final pieces = text.split(_replySep);
    if (pieces.length >= 2) {
      final meta = pieces.first.trim();
      final body = pieces.sublist(1).join(_replySep).trim();
      final metaParts = meta.split(_metaSep);

      final repliedMessageId =
          metaParts.isNotEmpty ? metaParts[0].trim().ifEmptyToNull() : null;
      final repliedSenderName =
          metaParts.length > 1 ? metaParts[1].trim().ifEmptyToNull() : null;
      final repliedPreview = metaParts.length > 2
          ? metaParts.sublist(2).join(_metaSep).trim().ifEmptyToNull()
          : null;

      return ChatReplyParts(
        repliedMessageId: repliedMessageId,
        repliedSenderName: repliedSenderName,
        repliedPreview: repliedPreview,
        body: body,
      );
    }
  }

  if (text.startsWith('↪ ')) {
    final dash = text.lastIndexOf(' — ');
    if (dash != -1) {
      final prefix = text.substring(2, dash).trim();
      final body = text.substring(dash + 3).trim();

      String? sender;
      String? preview;

      final colon = prefix.indexOf(':');
      if (colon != -1) {
        sender = prefix.substring(0, colon).trim().ifEmptyToNull();
        preview = prefix.substring(colon + 1).trim().ifEmptyToNull();
      } else {
        preview = prefix.ifEmptyToNull();
      }

      return ChatReplyParts(
        repliedSenderName: sender,
        repliedPreview: preview,
        body: body,
      );
    }
  }

  return ChatReplyParts(body: text);
}

String editableBodyText(String? raw) {
  return splitReplyRaw(raw).bodyText;
}

String preserveReplyOnEdit({
  required String? originalRaw,
  String? newBody,
  String? updatedBody,
}) {
  final nextBody = (newBody ?? updatedBody ?? '').trim();
  final oldParts = splitReplyRaw(originalRaw);
  if (!oldParts.hasReply) return nextBody;
  return composeReplyText(
    repliedMessageId: oldParts.repliedMessageId,
    repliedSenderName: oldParts.repliedSenderName,
    repliedPreview: oldParts.repliedPreview,
    body: nextBody,
  );
}

String composeReplyText({
  String? repliedMessageId,
  String? repliedSenderName,
  String? repliedPreview,
  String? sender,
  String? preview,
  required String body,
}) {
  final cleanBody = body.trim();
  final id = (repliedMessageId ?? '').trim();
  final resolvedSender = (repliedSenderName ?? sender ?? '').trim();
  final resolvedPreview = (repliedPreview ?? preview ?? '').trim();

  final hasReply =
      id.isNotEmpty || resolvedSender.isNotEmpty || resolvedPreview.isNotEmpty;
  if (!hasReply) return cleanBody;

  final meta = [id, resolvedSender, resolvedPreview].join(_metaSep);
  return '$meta$_replySep$cleanBody';
}

extension on String {
  String? ifEmptyToNull() => trim().isEmpty ? null : trim();
}
