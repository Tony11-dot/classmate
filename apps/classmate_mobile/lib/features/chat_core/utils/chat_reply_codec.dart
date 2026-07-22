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
    this.newAssignment = 'New assignment',
    this.newMaterial = 'New material',
    this.newMeeting = 'New meeting',
  });

  factory ChatPreviewLabels.of(AppLocalizations l) => ChatPreviewLabels(
        photo: l.chatPreviewPhoto,
        voice: l.chatPreviewVoice,
        video: l.chatPreviewVideo,
        attachment: l.chatPreviewAttachment,
        message: l.chatPreviewMessage,
        deleted: l.chatMessageBubbleDeletedMessage,
        newAssignment: l.chatPublishAssignment,
        newMaterial: l.chatPublishMaterial,
        newMeeting: l.chatPublishMeeting,
      );

  final String photo;
  final String voice;
  final String video;
  final String attachment;
  final String message;
  final String deleted;
  final String newAssignment;
  final String newMaterial;
  final String newMeeting;
}

/// A server-baked "teacher just published X" marker:
/// `[PUBLISH:assignment:<id>] <title>` (types: assignment | material |
/// meeting). The chat renders these as a card with a View button; previews
/// render them as "📘 New assignment: <title>".
final RegExp _publishMarkerRe =
    RegExp(r'^\[PUBLISH:(assignment|material|meeting):([^\]\s]+)\]\s*(.*)$');

({String type, String id, String title})? parsePublishMarker(String raw) {
  final m = _publishMarkerRe.firstMatch(raw.trim());
  if (m == null) return null;
  return (
    type: m.group(1)!,
    id: m.group(2)!,
    title: (m.group(3) ?? '').trim(),
  );
}

String publishPreviewText(
  ({String type, String id, String title}) p,
  ChatPreviewLabels labels,
) {
  final label = switch (p.type) {
    'assignment' => '📘 ${labels.newAssignment}',
    'material' => '📚 ${labels.newMaterial}',
    _ => '📅 ${labels.newMeeting}',
  };
  return p.title.isEmpty ? label : '$label: ${p.title}';
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
/// Media extension → kind classifier working on filenames, absolute device
/// paths AND full URLs (query strings stripped, last path segment taken). A
/// preview must NEVER surface a raw path — worst case it says "attachment".
String? _classifyMediaName(String value, ChatPreviewLabels labels) {
  var v = value.trim().toLowerCase();
  if (v.isEmpty) return null;
  // Strip URL query/fragment, then reduce to the last path segment.
  final q = v.indexOf('?');
  if (q != -1) v = v.substring(0, q);
  final h = v.indexOf('#');
  if (h != -1) v = v.substring(0, h);
  final lastSlash = v.lastIndexOf('/');
  if (lastSlash != -1) v = v.substring(lastSlash + 1);
  if (!v.contains('.')) return null;
  final ext = v.split('.').last;
  if (['m4a', 'aac', 'mp3', 'wav', 'ogg', 'opus', 'caf'].contains(ext)) {
    return '🎤 ${labels.voice}';
  }
  if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'bmp'].contains(ext)) {
    return '📷 ${labels.photo}';
  }
  if (['mp4', 'mov', 'm4v', 'webm', 'avi', 'mkv', '3gp'].contains(ext)) {
    return '🎥 ${labels.video}';
  }
  if (ext == 'pdf') return '📄 $v';
  if (['doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'zip', 'txt']
      .contains(ext)) {
    return '📎 $v';
  }
  return null;
}

bool _looksLikePathOrUrl(String v) =>
    v.startsWith('http://') ||
    v.startsWith('https://') ||
    v.startsWith('file://') ||
    v.startsWith('/');

String? _formatAttachmentMarker(String raw, ChatPreviewLabels labels) {
  final trimmed = raw.trim();

  // "Teacher just published X" cards.
  final publish = parsePublishMarker(trimmed);
  if (publish != null) return publishPreviewText(publish, labels);

  // Bare media filenames / device paths / CDN URLs (e.g. "IMG_2.jpg",
  // "/var/…/trim.4AF2.mp4", "https://cdn…/clip.mp4?X-Amz-…") that arrive
  // without a [KIND] marker — classify by extension so a preview never shows
  // a raw filename or path.
  final lower = trimmed.toLowerCase();
  if (!lower.contains(' ') && lower.contains('.')) {
    final classified = _classifyMediaName(trimmed, labels);
    if (classified != null) return classified;
    // Unclassifiable but clearly a path/URL — say "attachment", never leak it.
    if (_looksLikePathOrUrl(lower)) return '📎 ${labels.attachment}';
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
      // The remainder is whatever the sender's device produced — often a full
      // path or CDN URL for classroom video/file sends. Classify it; only show
      // it verbatim when it's a plain human-looking filename.
      final filename = rest.isEmpty ? '' : rest;
      if (filename.isEmpty) return '📎 ${labels.attachment}';
      final classified = _classifyMediaName(filename, labels);
      if (classified != null) return classified;
      if (_looksLikePathOrUrl(filename.toLowerCase()) ||
          filename.contains('/')) {
        return '📎 ${labels.attachment}';
      }
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
