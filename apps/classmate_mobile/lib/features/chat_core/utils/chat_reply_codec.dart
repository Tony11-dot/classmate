String replyPreviewText(String text) {
  final t = text.trim();

  if (t.isEmpty) return 'Message';

  final pretty = _formatAttachmentMarker(t);
  if (pretty != null) return pretty;

  final singleLine = t.replaceAll('\n', ' ');
  if (singleLine.length <= 80) return singleLine;

  return '${singleLine.substring(0, 80)}…';
}

/// Recognises the wire-format attachment markers the server bakes into
/// message text — `[IMAGE] name.png`, `[VOICE] ... [duration:N]`,
/// `[FILE] doc.pdf` — and returns a human snippet for reply previews.
String? _formatAttachmentMarker(String raw) {
  final m = RegExp(r'^\[(IMAGE|VOICE|FILE)\]\s*(.*)$').firstMatch(raw);
  if (m == null) return null;
  final kind = m.group(1)!;
  final rest = (m.group(2) ?? '').trim();

  switch (kind) {
    case 'IMAGE':
      return '🖼️ Photo';
    case 'VOICE':
      final durationMatch = RegExp(r'\[duration:(\d+)\]').firstMatch(rest);
      if (durationMatch != null) {
        final secs = int.tryParse(durationMatch.group(1)!) ?? 0;
        final mm = (secs ~/ 60).toString();
        final ss = (secs % 60).toString().padLeft(2, '0');
        return '🎤 Voice message ($mm:$ss)';
      }
      return '🎤 Voice message';
    case 'FILE':
      final filename = rest.isEmpty ? 'file' : rest;
      final lower = filename.toLowerCase();
      if (lower.endsWith('.pdf')) return '📄 $filename';
      return '📎 $filename';
  }
  return null;
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
