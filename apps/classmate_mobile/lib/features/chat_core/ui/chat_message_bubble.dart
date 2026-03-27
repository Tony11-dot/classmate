import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
    this.replySender,
    this.replySnippet,
    this.maxWidth = 380,
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
  final String? replySender;
  final String? replySnippet;
  final double maxWidth;

  bool _isImageByUrl(String v) =>
      RegExp(r'\.(jpg|jpeg|png|webp|gif)$', caseSensitive: false).hasMatch(v);

  bool _isVoiceByUrl(String v) =>
      RegExp(r'\.(m4a|aac|mp3|wav)$', caseSensitive: false).hasMatch(v);

  bool _isPdfByUrl(String v) =>
      RegExp(r'\.pdf$', caseSensitive: false).hasMatch(v);

  Future<void> _openAttachment(
    BuildContext context,
    String url,
    String label,
  ) async {
    if (_isImageByUrl(url)) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ImageViewerScreen(url: url, label: label),
        ),
      );
      return;
    }

    if (_isPdfByUrl(url)) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(url: url, label: label),
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final parts = splitReplyRaw(rawText);
    final inlineReplyPrefix = parts.replyPrefix.trim();
    final body = parts.bodyText.trim();

    var resolvedReplySender = (replySender ?? '').trim();
    var resolvedReplySnippet = (replySnippet ?? '').trim();

    if (resolvedReplySender.isEmpty && inlineReplyPrefix.startsWith('↪ ')) {
      final afterArrow = inlineReplyPrefix.substring(2).trim();
      final colon = afterArrow.indexOf(':');
      if (colon != -1) {
        resolvedReplySender = afterArrow.substring(0, colon).trim();
        resolvedReplySnippet = afterArrow.substring(colon + 1).trim();
      } else {
        resolvedReplySnippet = afterArrow;
      }
      if (resolvedReplySnippet.endsWith('—')) {
        resolvedReplySnippet =
            resolvedReplySnippet.substring(0, resolvedReplySnippet.length - 1).trimRight();
      }
    }

    final lowerBody = body.toLowerCase();
    final lowerUrl = mediaUrl.toLowerCase();
    final hasMedia = mediaUrl.trim().isNotEmpty;

    final isImage = hasMedia && _isImageByUrl(lowerUrl);
    final isVoice = hasMedia && _isVoiceByUrl(lowerUrl);
    final isPdf = hasMedia && _isPdfByUrl(lowerUrl);
    final isFileLike = hasMedia && !isImage && !isVoice;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Column(
        crossAxisAlignment: isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            decoration: BoxDecoration(
              color: isMine
                  ? const Color(0xFF0A84FF).withValues(alpha: 0.16)
                  : const Color(0xFF171B22).withValues(alpha: 0.94),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: Radius.circular(isMine ? 22 : 8),
                bottomRight: Radius.circular(isMine ? 8 : 22),
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showName && !isMine) ...[
                  Text(
                    senderLabel,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                if (resolvedReplySender.isNotEmpty || resolvedReplySnippet.isNotEmpty || inlineReplyPrefix.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resolvedReplySender.isEmpty ? 'Reply' : resolvedReplySender,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          resolvedReplySnippet.isEmpty ? 'Message' : resolvedReplySnippet,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (isImage) ...[
                  GestureDetector(
                    onTap: () => _openAttachment(
                      contextForNavigation,
                      mediaUrl,
                      body.isEmpty ? 'Image' : body,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 180,
                          alignment: Alignment.center,
                          color: Colors.white.withValues(alpha: 0.06),
                          child: const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (body.isNotEmpty && !lowerBody.startsWith('[image]')) ...[
                    const SizedBox(height: 8),
                    Text(body, style: const TextStyle(color: Colors.white)),
                  ],
                ] else if (isVoice) ...[
                  ChatAudioBubble(url: mediaUrl),
                  if (body.isNotEmpty && !lowerBody.startsWith('[voice]')) ...[
                    const SizedBox(height: 8),
                    Text(body, style: const TextStyle(color: Colors.white)),
                  ],
                ] else if (isPdf || isFileLike) ...[
                  GestureDetector(
                    onTap: () => _openAttachment(
                      contextForNavigation,
                      mediaUrl,
                      body.isEmpty ? 'File' : body,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              isPdf
                                  ? Icons.picture_as_pdf_rounded
                                  : Icons.insert_drive_file_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              body.isEmpty ? mediaUrl.split('/').last : body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (body.isNotEmpty) ...[
                  Text(body, style: const TextStyle(color: Colors.white)),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (edited)
                      Text(
                        'edited',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (edited) const SizedBox(width: 6),
                    Text(
                      timeLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if ((reaction ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: Text(
                reaction!.trim(),
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
