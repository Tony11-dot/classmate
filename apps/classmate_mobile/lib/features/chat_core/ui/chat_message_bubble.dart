import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../common/media/image_viewer_screen.dart';
import '../../common/media/pdf_viewer_screen.dart';
import '../utils/chat_reply_codec.dart';
import 'chat_audio_bubble.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.contextForNavigation,
    required this.rawText,
    required this.mediaUrl,
    required this.isMine,
    required this.showName,
    required this.senderLabel,
    required this.timeLabel,
    required this.edited,
    required this.reaction,
    this.reactions = const <String, List<String>>{},
    this.pinned = false,
    required this.forwarded,
    this.delivered = false,
    this.seen = false,
    required this.deleteState,
    this.voiceDurationSeconds,
    this.voiceUnread = false,
    this.onVoicePlayed,
    this.replySender,
    this.replySnippet,
    this.onReplyTap,
    this.onReactionTap,
    this.mediaMimeType,
    this.messageKind = 'TEXT',
    this.maxWidth = 236,
    this.previewMode = false,
    this.previewMaxHeight,
    this.showDeliveryStatus = true,
  });

  final BuildContext contextForNavigation;
  final String rawText;
  final String mediaUrl;
  final bool isMine;
  final bool showName;
  final String senderLabel;
  final String timeLabel;
  final bool edited;
  final String? reaction;
  final Map<String, List<String>> reactions;
  final bool pinned;
  final bool forwarded;
  final bool delivered;
  final bool seen;
  final String deleteState;
  final int? voiceDurationSeconds;
  final bool voiceUnread;
  final VoidCallback? onVoicePlayed;
  final String? replySender;
  final String? replySnippet;
  final VoidCallback? onReplyTap;
  final VoidCallback? onReactionTap;
  final String? mediaMimeType;
  final String messageKind;
  final double maxWidth;
  final bool previewMode;
  final double? previewMaxHeight;
  final bool showDeliveryStatus;

  bool _isImageByUrl(String v) => RegExp(
    r'\.(jpg|jpeg|png|webp|gif|heic|heif)(\?|$)',
    caseSensitive: false,
  ).hasMatch(v);

  bool _isVoiceByUrl(String v) =>
      RegExp(r'\.(m4a|aac|mp3|wav)(\?|$)', caseSensitive: false).hasMatch(v);

  bool _isVideoByUrl(String v) =>
      RegExp(r'\.(mp4|mov|m4v|webm)(\?|$)', caseSensitive: false).hasMatch(v);

  bool _isPdfByUrl(String v) =>
      RegExp(r'\.pdf(\?|$)', caseSensitive: false).hasMatch(v);

  bool _isImageByMeta(String kind, String mime) {
    final k = kind.trim().toUpperCase();
    final m = mime.trim().toLowerCase();
    return k == 'IMAGE' ||
        m.startsWith('image/') ||
        m.contains('jpeg') ||
        m.contains('jpg') ||
        m.contains('png') ||
        m.contains('webp') ||
        m.contains('gif') ||
        m.contains('heic') ||
        m.contains('heif');
  }

  bool _isVoiceByMeta(String kind, String mime) {
    final k = kind.trim().toUpperCase();
    final m = mime.trim().toLowerCase();
    return k == 'VOICE' ||
        m.startsWith('audio/') ||
        m.contains('mpeg') ||
        m.contains('mp4') ||
        m.contains('aac') ||
        m.contains('wav');
  }

  bool _isVideoByMeta(String kind, String mime) {
    final k = kind.trim().toUpperCase();
    final m = mime.trim().toLowerCase();
    return k == 'VIDEO' ||
        m.startsWith('video/') ||
        m.contains('mp4') ||
        m.contains('quicktime') ||
        m.contains('webm');
  }

  static bool _isLocalPath(String url) {
    if (url.startsWith('file://')) return true;
    if (!url.startsWith('/')) return false;
    // Server returns relative URLs like /uploads/dm/... which start with /
    // but are NOT local device files.  Only treat as local if it's a real
    // device path (iOS temp/cache/app directories).
    return url.startsWith('/private/') ||
        url.startsWith('/var/') ||
        url.startsWith('/tmp/') ||
        url.startsWith('/Users/');
  }

  String _resolveMediaUrl(String raw) {
    final value = raw.trim().replaceAll(',', '');
    if (value.isEmpty) return '';

    // Local file paths: keep as-is (optimistic messages, camera captures, etc.)
    if (_isLocalPath(value)) return value;

    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;

    const base = String.fromEnvironment('CM_API_BASE_URL');
    final normalizedBase = base.trim().replaceAll(RegExp(r'/+$'), '');
    if (normalizedBase.isEmpty) return value;

    final normalizedPath = value.startsWith('/') ? value : '/$value';
    return '$normalizedBase$normalizedPath';
  }

  Widget _buildImageWidget(String url, {required bool previewMode}) {
    final placeholder = Builder(builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Container(
        height: previewMode ? 132 : 180,
        alignment: Alignment.center,
        color: cs.surfaceContainerHigh,
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: cs.onSurfaceVariant),
        ),
      );
    });
    final errorPanel = Builder(builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return Container(
        height: previewMode ? 132 : 180,
        alignment: Alignment.center,
        color: cs.surfaceContainerHigh,
        child: Icon(Icons.broken_image_outlined, color: cs.onSurfaceVariant),
      );
    });
    if (_isLocalPath(url)) {
      final path = url.startsWith('file://') ? Uri.parse(url).toFilePath() : url;
      return Image.file(
        File(path),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, _) => errorPanel,
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (ctx, url) => placeholder,
      errorWidget: (ctx, url, err) => errorPanel,
    );
  }

  String _displayFileName(String resolvedMediaUrl) {
    final parsed = Uri.tryParse(resolvedMediaUrl);
    if (parsed != null && parsed.pathSegments.isNotEmpty) {
      final last = Uri.decodeComponent(parsed.pathSegments.last.trim());
      if (last.isNotEmpty) return last;
    }
    final parts = resolvedMediaUrl.split('/');
    return parts.isEmpty ? 'File' : parts.last;
  }

  bool _looksLikeFileName(String value) {
    return RegExp(
      r'^[^\/]+\.(jpg|jpeg|png|webp|gif|heic|heif|mp4|mov|m4v|webm|m4a|aac|mp3|wav|pdf|doc|docx|xls|xlsx|ppt|pptx)$',
      caseSensitive: false,
    ).hasMatch(value.trim());
  }

  bool _shouldHideAutogeneratedMediaLabel({
    required String body,
    required String resolvedMediaUrl,
    required bool hasMedia,
    required String kind,
    required String mime,
  }) {
    if (!hasMedia) return false;

    final normalizedBody = body.trim().replaceAll(',', '');
    if (normalizedBody.isEmpty) return true;

    final lowerBody = normalizedBody.toLowerCase();
    if (lowerBody == '[image]' ||
        lowerBody == '[video]' ||
        lowerBody == '[voice]' ||
        lowerBody == '[file]') {
      return true;
    }

    final fileName = _displayFileName(resolvedMediaUrl).trim().replaceAll(',', '');
    final stem = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    final candidates = <String>{
      fileName,
      fileName.replaceAll('_', ' '),
      stem,
      stem.replaceAll('_', ' '),
    }..removeWhere((e) => e.trim().isEmpty);

    if (candidates.any((e) => e.trim().toLowerCase() == lowerBody)) {
      return true;
    }

    final upperKind = kind.trim().toUpperCase();
    final lowerMime = mime.trim().toLowerCase();
    final isMediaish =
        upperKind == 'IMAGE' ||
        upperKind == 'VIDEO' ||
        upperKind == 'VOICE' ||
        upperKind == 'FILE' ||
        lowerMime.startsWith('image/') ||
        lowerMime.startsWith('video/') ||
        lowerMime.startsWith('audio/') ||
        lowerMime.contains('quicktime') ||
        lowerMime.contains('mp4') ||
        lowerMime.contains('webm') ||
        lowerMime.contains('mpeg') ||
        lowerMime.contains('aac') ||
        lowerMime.contains('wav') ||
        lowerMime.contains('pdf') ||
        lowerMime.contains('officedocument') ||
        lowerMime.contains('msword') ||
        lowerMime.contains('excel') ||
        lowerMime.contains('spreadsheet') ||
        lowerMime.contains('presentation');

    return isMediaish && _looksLikeFileName(normalizedBody);
  }

  Widget _buildChecks(BuildContext context) {
    final seenColor = const Color(0xFF53BDEB);
    final pendingColor = Colors.white;
    final deliveredColor = Colors.white;

    if (seen) {
      return SizedBox(
        width: 16,
        height: 12,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: -1,
              child: Icon(Icons.done_rounded, size: 13, color: seenColor),
            ),
            Positioned(
              left: 5,
              top: -1,
              child: Icon(Icons.done_rounded, size: 13, color: seenColor),
            ),
          ],
        ),
      );
    }
    if (delivered) {
      return SizedBox(
        width: 16,
        height: 12,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              top: -1,
              child: Icon(Icons.done_rounded, size: 13, color: deliveredColor),
            ),
            Positioned(
              left: 5,
              top: -1,
              child: Icon(Icons.done_rounded, size: 13, color: deliveredColor),
            ),
          ],
        ),
      );
    }
    return Transform.translate(
      offset: const Offset(0, -0.5),
      child: Icon(
        Icons.done_rounded,
        size: 13,
        color: pendingColor,
      ),
    );
  }

  Future<void> _openAttachment(
    BuildContext context,
    String url,
    String label, {
    String kind = '',
    String mime = '',
  }) async {
    if (_isImageByUrl(url) || _isImageByMeta(kind, mime)) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImageViewerScreen(url: url, label: label),
        ),
      );
      return;
    }

    if (_isVideoByUrl(url) || _isVideoByMeta(kind, mime)) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _InlineVideoViewerScreen(url: url)),
      );
      return;
    }
    if (_isPdfByUrl(url) || mime.trim().toLowerCase().contains('pdf')) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(url: url, label: label),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }

  @override
  Widget build(BuildContext context) {
    final deleteMode = deleteState.trim().toUpperCase();
    final isDeletedForEveryone = deleteMode == 'DELETED_FOR_EVERYONE';
    final isDeletedForMe = deleteMode == 'DELETED_FOR_ME';

    final parts = splitReplyRaw(rawText);
    final inlineReplyPrefix = parts.replyPrefix.trim().replaceAll(',', '');
    String bodyRaw = parts.bodyText.trim();
    // Strip all stacked "Forwarded\n" prefixes (re-forwarded messages accumulate them)
    bool stripped = true;
    while (stripped) {
      stripped = false;
      if (bodyRaw.startsWith('Forwarded\r\n')) {
        bodyRaw = bodyRaw.substring('Forwarded\r\n'.length).trim();
        stripped = true;
      } else if (bodyRaw.startsWith('Forwarded\n')) {
        bodyRaw = bodyRaw.substring('Forwarded\n'.length).trim();
        stripped = true;
      } else if (bodyRaw == 'Forwarded') {
        bodyRaw = '';
        stripped = true;
      } else {
        final legacyFwd = RegExp(r'^↪ Forwarded[：:]\s*').firstMatch(bodyRaw);
        if (legacyFwd != null) {
          bodyRaw = bodyRaw.substring(legacyFwd.end).trim();
          stripped = true;
        }
      }
    }
    final body = bodyRaw.replaceAll(',', '');
    final resolvedMime = (mediaMimeType ?? '').trim().replaceAll(',', '');

    var resolvedReplySender = (replySender ?? '').trim().replaceAll(',', '');
    var resolvedReplySnippet = (replySnippet ?? '').trim().replaceAll(',', '');

    if (resolvedReplySender.isEmpty && inlineReplyPrefix.startsWith('↪ ')) {
      final afterArrow = inlineReplyPrefix.substring(2).trim().replaceAll(',', '');
      final colon = afterArrow.indexOf(':');
      if (colon != -1) {
        resolvedReplySender = afterArrow.substring(0, colon).trim().replaceAll(',', '');
        resolvedReplySnippet = afterArrow.substring(colon + 1).trim().replaceAll(',', '');
      } else {
        resolvedReplySnippet = afterArrow;
      }
      if (resolvedReplySnippet.endsWith('—')) {
        resolvedReplySnippet = resolvedReplySnippet
            .substring(0, resolvedReplySnippet.length - 1)
            .trimRight();
      }
    }
    final resolvedMediaUrl = _resolveMediaUrl(mediaUrl);
    final lowerUrl = resolvedMediaUrl.toLowerCase();
    final lowerBody = body.toLowerCase();
    final hasMedia = resolvedMediaUrl.isNotEmpty;

    final hideAutogeneratedMediaLabel = _shouldHideAutogeneratedMediaLabel(
      body: body,
      resolvedMediaUrl: resolvedMediaUrl,
      hasMedia: hasMedia,
      kind: messageKind,
      mime: resolvedMime,
    );

    final isImage =
        hasMedia &&
        (_isImageByUrl(lowerUrl) || _isImageByMeta(messageKind, resolvedMime));
    final isVoice =
        hasMedia &&
        (_isVoiceByUrl(lowerUrl) || _isVoiceByMeta(messageKind, resolvedMime));
    final isPdf =
        hasMedia &&
        (_isPdfByUrl(lowerUrl) || resolvedMime.toLowerCase().contains('pdf'));
    final isVideo =
        hasMedia &&
        (_isVideoByUrl(lowerUrl) || _isVideoByMeta(messageKind, resolvedMime));
    final isFileLike = hasMedia && !isImage && !isVoice && !isVideo;
    final displayFileName = _displayFileName(resolvedMediaUrl);

    final showRealUserCaption =
        body.isNotEmpty &&
        !hideAutogeneratedMediaLabel &&
        !_looksLikeFileName(body);

    if (isDeletedForMe) {
      return const SizedBox.shrink();
    }

    // ─── Naked media: photos, voice & video float without a bubble shell ──────
    final bool hasMetaContent = forwarded ||
        pinned ||
        resolvedReplySender.isNotEmpty ||
        resolvedReplySnippet.isNotEmpty ||
        inlineReplyPrefix.isNotEmpty;
    final bool isNakedMedia = !isDeletedForEveryone &&
        !hasMetaContent &&
        (isImage || isVoice || isVideo);

    final theme = Theme.of(context);
    final outgoingBubbleColor = _accentBubbleColor(theme, isMine: true);
    final incomingBubbleColor = _accentBubbleColor(theme, isMine: false);

    if (isNakedMedia) {
      final Widget timeRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (edited)
            Text(
              'edited',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          if (edited) const SizedBox(width: 6),
          Text(
            timeLabel,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
          if (isMine) const SizedBox(width: 6),
          if (isMine && showDeliveryStatus) _buildChecks(context),
        ],
      );

      final List<Widget> nakedReactions = [
        if (reactions.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: reactions.entries.map((entry) {
              final emoji = entry.key.trim().replaceAll(',', '');
              final users = entry.value;
              if (emoji.isEmpty || users.isEmpty) return const SizedBox.shrink();
              final isMineReaction = users.contains('me');
              return InkWell(
                onTap: onReactionTap,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMineReaction
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isMineReaction
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(users.length.toString(), style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ] else if ((reaction ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 3),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onReactionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white),
              ),
              child: Text(reaction!.trim(), style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ];

      final Widget timeOverlay = Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(999),
        ),
        child: timeRow,
      );

      Widget mediaWidget;
      if (isImage) {
        mediaWidget = Stack(
          children: [
            GestureDetector(
              onTap: () => _openAttachment(
                contextForNavigation,
                resolvedMediaUrl,
                body.isEmpty ? 'Image' : body,
                kind: messageKind,
                mime: resolvedMime,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: previewMode ? 132 : 96,
                    maxHeight: previewMode ? 132 : 280,
                  ),
                  child: _buildImageWidget(resolvedMediaUrl, previewMode: previewMode),
                ),
              ),
            ),
            Positioned(bottom: 7, right: 10, child: timeOverlay),
          ],
        );
      } else if (isVoice) {
        mediaWidget = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatAudioBubble(
              url: resolvedMediaUrl,
              isMine: isMine,
              bubbleColor: isMine
                  ? outgoingBubbleColor
                  : incomingBubbleColor,
              durationSeconds: voiceDurationSeconds,
              isUnread: voiceUnread,
              onPlayed: onVoicePlayed,
              timeLabel: timeLabel,
              delivered: delivered,
              seen: seen,
            ),
            // timeRow removed — timestamp now inside the bubble
          ],
        );
      } else {
        // isVideo
        mediaWidget = Stack(
          children: [
            _InlineVideoBubble(
              url: resolvedMediaUrl,
              previewMode: previewMode,
              onTap: () => _openAttachment(
                contextForNavigation,
                resolvedMediaUrl,
                body.isEmpty ? 'Video' : body,
                kind: messageKind,
                mime: resolvedMime,
              ),
            ),
            Positioned(bottom: 7, right: 10, child: timeOverlay),
          ],
        );
      }

      final Widget nakedBubble = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showName && !isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 3, left: 2),
                child: Text(
                  senderLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            mediaWidget,
            if (showRealUserCaption && !isVoice)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 2, right: 2),
                child: _CollapsibleMessageText(
                  text: body,
                  previewMode: previewMode,
                ),
              ),
            ...nakedReactions,
          ],
        ),
      );

      if (!previewMode) return nakedBubble;
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: previewMaxHeight ?? 220,
        ),
        child: ClipRect(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: nakedBubble,
          ),
        ),
      );
    }

    // ─── Bubble path: text, files, deleted, media-with-reply/forwarded ────────
    Widget bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
            decoration: BoxDecoration(
              color: isMine ? outgoingBubbleColor : incomingBubbleColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showName && !isMine) ...[
                  Text(
                    senderLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                if (forwarded) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.forward_rounded,
                          size: 13,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Forwarded',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (pinned) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.push_pin_rounded,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pinned',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (resolvedReplySender.isNotEmpty ||
                    resolvedReplySnippet.isNotEmpty ||
                    inlineReplyPrefix.isNotEmpty) ...[
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onReplyTap,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 3,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(7, 4, 7, 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      resolvedReplySender.isEmpty
                                          ? 'Reply'
                                          : resolvedReplySender,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      resolvedReplySnippet.isEmpty
                                          ? 'Message'
                                          : resolvedReplySnippet,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                if (isDeletedForEveryone) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.block_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        'This message was deleted',
                        style: TextStyle(
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ] else if (isImage) ...[
                  GestureDetector(
                    onTap: () => _openAttachment(
                      contextForNavigation,
                      resolvedMediaUrl,
                      body.isEmpty ? 'Image' : body,
                      kind: messageKind,
                      mime: resolvedMime,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: previewMode ? 132 : 96,
                          maxHeight: previewMode ? 132 : 260,
                        ),
                        child: _buildImageWidget(resolvedMediaUrl, previewMode: previewMode),
                      ),
                    ),
                  ),
                  if (showRealUserCaption &&
                      !lowerBody.startsWith('[image]')) ...[
                    const SizedBox(height: 2),
                    _CollapsibleMessageText(
                      text: body,
                      previewMode: previewMode,
                    ),
                  ],
                ] else if (isVoice) ...[
                  ChatAudioBubble(
                    url: resolvedMediaUrl,
                    isMine: isMine,
                    bubbleColor: isMine
                        ? outgoingBubbleColor
                        : incomingBubbleColor,
                    durationSeconds: voiceDurationSeconds,
                    isUnread: voiceUnread,
                    onPlayed: onVoicePlayed,
                    timeLabel: timeLabel,
                    delivered: delivered,
                    seen: seen,
                  ),
                  if (showRealUserCaption &&
                      !lowerBody.startsWith('[voice]')) ...[
                    const SizedBox(height: 2),
                    _CollapsibleMessageText(
                      text: body,
                      previewMode: previewMode,
                    ),
                  ],
                ] else if (isVideo) ...[
                  _InlineVideoBubble(
                    url: resolvedMediaUrl,
                    previewMode: previewMode,
                    onTap: () => _openAttachment(
                      contextForNavigation,
                      resolvedMediaUrl,
                      body.isEmpty ? 'Video' : body,
                      kind: messageKind,
                      mime: resolvedMime,
                    ),
                  ),
                  if (showRealUserCaption) ...[
                    const SizedBox(height: 3),
                    _CollapsibleMessageText(
                      text: body,
                      previewMode: previewMode,
                    ),
                  ],
                ] else if (isPdf || isFileLike) ...[
                  GestureDetector(
                    onTap: () => _openAttachment(
                      contextForNavigation,
                      resolvedMediaUrl,
                      body.isEmpty ? 'File' : body,
                      kind: messageKind,
                      mime: resolvedMime,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(9, 9, 9, 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isPdf
                                  ? Icons.picture_as_pdf_rounded
                                  : Icons.insert_drive_file_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              showRealUserCaption ? body : displayFileName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (showRealUserCaption) ...[
                  _CollapsibleMessageText(text: body, previewMode: previewMode),
                ],
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (edited)
                      Text(
                        'edited',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (edited) const SizedBox(width: 6),
                    Text(
                      timeLabel,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                      ),
                    ),
                    if (isMine && showDeliveryStatus) const SizedBox(width: 6),
                    if (isMine && showDeliveryStatus) _buildChecks(context),
                  ],
                ),
              ],
            ),
          ),
          if (reactions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: reactions.entries.map((entry) {
                final emoji = entry.key.trim().replaceAll(',', '');
                final users = entry.value;
                if (emoji.isEmpty || users.isEmpty) {
                  return const SizedBox.shrink();
                }
                final isMineReaction = users.contains('me');
                return InkWell(
                  onTap: onReactionTap,
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isMineReaction
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: isMineReaction
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .outlineVariant
                                .withValues(alpha: 0.16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(
                          users.length.toString(),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else if ((reaction ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 3),
            InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onReactionTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white),
                ),
                child: Text(
                  reaction!.trim(),
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (!previewMode) {
      return bubble;
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: previewMaxHeight ?? 220,
      ),
      child: ClipRect(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: bubble,
        ),
      ),
    );
  }

  Color _accentBubbleColor(ThemeData theme, {required bool isMine}) {
    if (isMine) {
      // Own messages: primary-derived accent.
      final base = HSLColor.fromColor(theme.colorScheme.primary);
      return base
          .withLightness(theme.brightness == Brightness.dark ? 0.42 : 0.46)
          .withSaturation(base.saturation.clamp(0.24, 0.92))
          .toColor();
    }
    // Others' messages: neutral derived from onSurface so the bubble has real
    // contrast against the chat background — M3's surfaceContainerHighest is
    // too pale in light mode and bubbles disappear against the canvas.
    if (theme.brightness == Brightness.dark) {
      return Color.alphaBlend(
        theme.colorScheme.onSurface.withOpacity(0.18),
        theme.colorScheme.surface,
      );
    }
    // Light mode: deep slate-gray fill — pushed darker per user
    // feedback that the prior #C6CAD2 still felt washed out. Foreground
    // text switches to white at this darkness level via the bubble's
    // contrast-aware color (see _bubbleTextColor).
    return const Color(0xFF3A3F47);
  }
}

class _CollapsibleMessageText extends StatefulWidget {
  const _CollapsibleMessageText({
    required this.text,
    required this.previewMode,
  });

  final String text;
  final bool previewMode;

  @override
  State<_CollapsibleMessageText> createState() =>
      _CollapsibleMessageTextState();
}

class _CollapsibleMessageTextState extends State<_CollapsibleMessageText> {
  bool _expanded = false;

  static final _urlRegex = RegExp(
    r'https?://[^\s​-‍﻿]+|www\.[^\s​-‍﻿]+',
    caseSensitive: false,
  );

  TextSpan _buildRichSpan(String text) {
    final spans = <InlineSpan>[];
    int last = 0;
    for (final m in _urlRegex.allMatches(text)) {
      if (m.start > last) {
        spans.add(TextSpan(text: text.substring(last, m.start)));
      }
      final raw = m.group(0)!;
      final href = raw.startsWith('http') ? raw : 'https://$raw';
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: () async {
              final uri = Uri.tryParse(href);
              if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: Text(
              raw,
              style: const TextStyle(
                color: Colors.white,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white70,
              ),
            ),
          ),
        ),
      );
      last = m.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return TextSpan(
      style: const TextStyle(color: Colors.white),
      children: spans,
    );
  }

  @override
  Widget build(BuildContext context) {
    final collapsedMaxLines = widget.previewMode ? 5 : 8;
    final plainStyle = const TextStyle(color: Colors.white);
    final hasUrl = _urlRegex.hasMatch(widget.text);

    return LayoutBuilder(
      builder: (context, constraints) {
        final measSpan = TextSpan(text: widget.text, style: plainStyle);
        final painter = TextPainter(
          text: measSpan,
          maxLines: collapsedMaxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final exceeds = painter.didExceedMaxLines;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hasUrl
                ? Text.rich(
                    _buildRichSpan(widget.text),
                    maxLines: _expanded ? null : collapsedMaxLines,
                    overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  )
                : Text(
                    widget.text,
                    maxLines: _expanded ? null : collapsedMaxLines,
                    overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: plainStyle,
                  ),
            if (exceeds && !widget.previewMode) ...[
              const SizedBox(height: 3),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? 'Read less' : 'Read more',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    shadows: [Shadow(color: Colors.white, blurRadius: 10)],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _InlineVideoBubble extends StatefulWidget {
  const _InlineVideoBubble({
    required this.url,
    required this.onTap,
    this.previewMode = false,
  });

  final String url;
  final VoidCallback onTap;
  final bool previewMode;

  @override
  State<_InlineVideoBubble> createState() => _InlineVideoBubbleState();
}

class _InlineVideoBubbleState extends State<_InlineVideoBubble> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.url);
    if (uri != null) {
      _controller = VideoPlayerController.networkUrl(uri)
        ..initialize()
            .then((_) {
              if (mounted) setState(() {});
            })
            .catchError((_) {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized;

    final double fixedHeight = widget.previewMode ? 132 : 200;

    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: fixedHeight,
          width: double.infinity,
          child: ColoredBox(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                if (ready)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: c.value.size.width,
                      height: c.value.size.height,
                      child: VideoPlayer(c),
                    ),
                  )
                else
                  const Center(
                    child: Icon(Icons.videocam_rounded, color: Colors.white54, size: 40),
                  ),
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineVideoViewerScreen extends StatefulWidget {
  const _InlineVideoViewerScreen({required this.url});

  final String url;

  @override
  State<_InlineVideoViewerScreen> createState() =>
      _InlineVideoViewerScreenState();
}

class _InlineVideoViewerScreenState extends State<_InlineVideoViewerScreen> {
  VideoPlayerController? _controller;
  bool _showControls = true;

  String _fmt(Duration d) {
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.url);
    if (uri != null) {
      _controller = VideoPlayerController.networkUrl(uri)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller?.play();
          }
        }).catchError((_) {});
      _controller?.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggleControls() => setState(() => _showControls = !_showControls);

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final ready = c != null && c.value.isInitialized;
    final isPlaying = ready && c.value.isPlaying;
    final position = ready ? c.value.position : Duration.zero;
    final duration = ready ? c.value.duration : Duration.zero;
    final maxMs = duration.inMilliseconds <= 0 ? 1 : duration.inMilliseconds;
    final posMs = position.inMilliseconds.clamp(0, maxMs).toDouble();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Full-screen video ──────────────────────────────────────────
            if (ready)
              FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: c.value.size.width,
                  height: c.value.size.height,
                  child: VideoPlayer(c),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: Colors.white54)),

            // ── Controls overlay (shown/hidden on tap) ─────────────────────
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !_showControls,
                child: Column(
                  children: [
                    // ── Top bar ──────────────────────────────────────────
                    SafeArea(
                      bottom: false,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // ── Centre play/pause ────────────────────────────────
                    GestureDetector(
                      onTap: () async {
                        if (!ready) return;
                        isPlaying ? await c.pause() : await c.play();
                        setState(() {});
                      },
                      child: Container(
                        width: 72, height: 72,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // ── Bottom scrubber ──────────────────────────────────
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Slider(
                              value: posMs,
                              min: 0,
                              max: maxMs.toDouble(),
                              activeColor: Colors.white,
                              inactiveColor: Colors.white30,
                              onChanged: (v) async {
                                await c?.seekTo(Duration(milliseconds: v.round()));
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Text(_fmt(position),
                                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  const Spacer(),
                                  Text(_fmt(duration),
                                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
