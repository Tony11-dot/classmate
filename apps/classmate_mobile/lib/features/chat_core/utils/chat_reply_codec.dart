import '../../../l10n/app_localizations.dart';

/// The localized words for each media kind. Kept as one bundle (rather than a
/// BuildContext lookup inside the codec) so the pure string functions below
/// stay callable from places without a context — controllers, tests — which
/// then just omit it and get the English defaults.
class ChatPreviewLabels {
  const ChatPreviewLabels({
    this.photo = 'Photo',
    this.voice = 'Voice message',
    this.video = 'Video',
    this.attachment = 'Attachment',
    this.message = 'Message',
    this.deleted = 'This message was deleted',
  });

  factory ChatPreviewLabels.of(AppLocalizations l) => ChatPreviewLabels(
        photo: l.chatPreviewPhoto,
        voice: l.chatPreviewVoice,
        video: l.chatPreviewVideo,
        attachment: l.chatPreviewAttachment,
        message: l.chatPreviewMessage,
        deleted: l.chatMessageBubbleDeletedMessage,
      );

  final String photo;
  final String voice;
  final String video;
  final String attachment;
  final String message;
  final String deleted;
}

const ChatPreviewLabels _en = ChatPreviewLabels();

/// One-line summary of a message, for anywhere a message is shown outside the
/// thread: the classroom card on the home screen, the DM inbox row, a reply
/// quote.
///
/// Text wins when there is any. Otherwise the message is described by its
/// kind, with the same emoji as the push notification — so one photo reads
/// "📷 Photo" on the lock screen, in the inbox, and in a reply quote instead
/// of three different things. Pass [labels] (from `ChatPreviewLabels.of(l)`)
/// wherever a localization context exists; the emoji stays constant across
/// locales, only the word translates.
///
/// [rawText] may still carry a wire marker (`[IMAGE] IMG_2.jpg`) because the
/// classroom endpoint bakes one into `text` when it stores media; those are
/// unwrapped rather than shown raw.
String messagePreviewText({
  required String kind,
  String rawText = '',
  ChatPreviewLabels labels = _en,
}) {
  final t = rawText.trim();
  if (t.isNotEmpty) {
    final pretty = _formatAttachmentMarker(t, labels);
    if (pretty != null) return pretty;
    final singleLine = t.replaceAll('\n', ' ');
    return singleLine.length <= 80 ? singleLine : '${singleLine.substring(0, 80)}…';
  }
  switch (kind.trim().toUpperCase()) {
    case 'IMAGE':
      return '📷 ${labels.photo}';
    case 'VOICE':
      return '🎤 ${labels.voice}';
    case 'VIDEO':
      return '🎥 ${labels.video}';
    case 'FILE':
    case 'DOC':
      return '📎 ${labels.attachment}';
    // Delete-for-everyone tombstone — the row exists but its content is gone.
    case 'DELETED':
      return '🚫 ${labels.deleted}';
    default:
      return '💬 ${labels.message}';
  }
}

String replyPreviewText(String text, {ChatPreviewLabels labels = _en}) {
  var t = text.trim();

  if (t.isEmpty) return labels.message;

  // Unwrap an encoded reply ("↪ Sender: <quoted> — <body>") down to just
  // THIS message's own content, so a reply-to-a-reply doesn't show the ↪
  // marker / nested quote — only the underlying text (or media type).
  if (t.startsWith('↪ ')) {
    final dash = t.lastIndexOf(' — ');
    if (dash != -1) {
      t = t.substring(dash + 3).trim(); // the body the sender actually wrote
    } else {
      // No body — fall back to the quoted content after "Sender: ".
      final colon = t.indexOf(': ');
      t = (colon != -1 ? t.substring(colon + 2) : t.substring(2)).trim();
    }
    if (t.isEmpty) return labels.message;
  }

  final pretty = _formatAttachmentMarker(t, labels);
  if (pretty != null) return pretty;

  final singleLine = t.replaceAll('\n', ' ');
  if (singleLine.length <= 80) return singleLine;

  return '${singleLine.substring(0, 80)}…';
}

/// Recognises the wire-format attachment markers the server bakes into
/// message text — `[IMAGE] name.png`, `[VOICE] ... [duration:N]`,
/// `[FILE] doc.pdf` — and returns a human snippet for reply previews.
String? _formatAttachmentMarker(String raw, ChatPreviewLabels labels) {
  // Bare media filenames (e.g. "chat-voice-123.m4a", "IMG_2.jpg") that arrive
  // without a [KIND] marker — classify by extension so a reply to media never
  // shows a raw filename.
  final lower = raw.toLowerCase().trim();
  if (!lower.contains(' ') && lower.contains('.')) {
    final ext = lower.split('.').last;
    if (['m4a', 'aac', 'mp3', 'wav', 'ogg', 'opus', 'caf'].contains(ext)) {
      return '🎤 ${labels.voice}';
    }
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'bmp'].contains(ext)) {
      return '📷 ${labels.photo}';
    }
    if (['mp4', 'mov', 'm4v', 'webm', 'avi', 'mkv'].contains(ext)) {
      return '🎥 ${labels.video}';
    }
    if (['pdf'].contains(ext)) return '📄 $raw';
    if (['doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'zip', 'txt'].contains(ext)) {
      return '📎 $raw';
    }
  }

  final m = RegExp(r'^\[(IMAGE|VOICE|FILE|VIDEO)\]\s*(.*)$').firstMatch(raw);
  if (m == null) return null;
  final kind = m.group(1)!;
  final rest = (m.group(2) ?? '').trim();

  switch (kind) {
    case 'IMAGE':
      return '📷 ${labels.photo}';
    case 'VOICE':
      final durationMatch = RegExp(r'\[duration:(\d+)\]').firstMatch(rest);
      if (durationMatch != null) {
        final secs = int.tryParse(durationMatch.group(1)!) ?? 0;
        final mm = (secs ~/ 60).toString();
        final ss = (secs % 60).toString().padLeft(2, '0');
        return '🎤 ${labels.voice} ($mm:$ss)';
      }
      return '🎤 ${labels.voice}';
    case 'FILE':
      final filename = rest.isEmpty ? 'file' : rest;
      final lowerName = filename.toLowerCase();
      if (lowerName.endsWith('.pdf')) return '📄 $filename';
      return '📎 $filename';
    case 'VIDEO':
      return '🎥 ${labels.video}';
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
