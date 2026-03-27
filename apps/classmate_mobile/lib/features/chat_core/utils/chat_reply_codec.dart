String replyPreviewText(String text) {
  final t = text.trim();

  if (t.isEmpty) return 'Message';

  final singleLine = t.replaceAll('\n', ' ');
  if (singleLine.length <= 80) return singleLine;

  return '${singleLine.substring(0, 80)}…';
}

({String replyPrefix, String bodyText}) splitReplyRaw(String raw) {
  final v = raw.trim();
  if (!v.startsWith('↪ ')) {
    return (replyPrefix: '', bodyText: v);
  }

  final dash = v.lastIndexOf(' — ');
  if (dash == -1) {
    return (replyPrefix: '', bodyText: v);
  }

  return (
    replyPrefix: v.substring(0, dash + 3).trimRight(),
    bodyText: v.substring(dash + 3).trim(),
  );
}

String editableBodyText(String raw) => splitReplyRaw(raw).bodyText;

String preserveReplyOnEdit({
  required String originalRaw,
  required String updatedBody,
}) {
  final parts = splitReplyRaw(originalRaw);
  final body = updatedBody.trim();

  if (parts.replyPrefix.isEmpty) return body;
  if (body.isEmpty) return parts.replyPrefix.trimRight();

  return '${parts.replyPrefix} $body';
}

String composeReplyText({
  required String sender,
  required String preview,
  required String body,
}) {
  final cleanSender = sender.trim().isEmpty ? 'Someone' : sender.trim();
  final cleanPreview = replyPreviewText(preview);
  final cleanBody = body.trim();

  if (cleanBody.isEmpty) {
    return '↪ $cleanSender: $cleanPreview';
  }

  return '↪ $cleanSender: $cleanPreview — $cleanBody';
}
