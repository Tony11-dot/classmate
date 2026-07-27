import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'classnotes_models.dart';

/// The row of things a synced page carries: voice notes you can play, files you
/// can open, and links you can follow.
///
/// The native ClassNotes app uploads each of these next to the page render, so a
/// page in this tab isn't a flat picture — everything on it still works.
class CnAttachmentBar extends StatelessWidget {
  const CnAttachmentBar({super.key, required this.attachments});

  final List<CnAttachment> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final attachment in attachments)
            if (attachment.kind == CnAttachmentKind.audio)
              _VoiceNoteChip(attachment: attachment)
            else
              _OpenChip(attachment: attachment),
        ],
      ),
    );
  }
}

/// A voice note recorded on the iPad, played back here. One player per chip,
/// disposed with the widget so scrolling a long notebook can't leak audio
/// sessions.
class _VoiceNoteChip extends StatefulWidget {
  const _VoiceNoteChip({required this.attachment});

  final CnAttachment attachment;

  @override
  State<_VoiceNoteChip> createState() => _VoiceNoteChipState();
}

class _VoiceNoteChipState extends State<_VoiceNoteChip> {
  AudioPlayer? _player;
  bool _loading = false;
  bool _failed = false;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final existing = _player;
    if (existing != null) {
      if (existing.playing) {
        await existing.pause();
      } else {
        // Replaying from the end should start over, not sit finished.
        if (existing.processingState == ProcessingState.completed) {
          await existing.seek(Duration.zero);
        }
        await existing.play();
      }
      return;
    }

    setState(() => _loading = true);
    try {
      final file = await writeAttachmentToTempFile(widget.attachment);
      if (file == null) throw Exception('no payload');
      final player = AudioPlayer();
      await player.setFilePath(file.path);
      if (!mounted) {
        await player.dispose();
        return;
      }
      setState(() {
        _player = player;
        _loading = false;
      });
      await player.play();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final player = _player;
    return _Chip(
      onTap: _failed ? null : _toggle,
      color: cs.primary.withValues(alpha: 0.10),
      borderColor: cs.primary.withValues(alpha: 0.35),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_loading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
            )
          else
            StreamBuilder<PlayerState>(
              stream: player?.playerStateStream,
              builder: (context, snapshot) {
                final playing = snapshot.data?.playing ?? false;
                final done =
                    snapshot.data?.processingState == ProcessingState.completed;
                return Icon(
                  _failed
                      ? Icons.error_outline_rounded
                      : (playing && !done
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                  size: 18,
                  color: cs.primary,
                );
              },
            ),
          const SizedBox(width: 7),
          Text(
            _failed ? "Couldn't play" : _label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    final seconds = widget.attachment.durationSeconds;
    final name = widget.attachment.name.isEmpty
        ? 'Voice note'
        : widget.attachment.name;
    if (seconds == null || seconds <= 0) return name;
    final total = seconds.round();
    final minutes = total ~/ 60;
    final rest = (total % 60).toString().padLeft(2, '0');
    return '$name  $minutes:$rest';
  }
}

/// A file or a link. Files are written to a temp file and handed to the system
/// viewer; links open in the browser.
class _OpenChip extends StatefulWidget {
  const _OpenChip({required this.attachment});

  final CnAttachment attachment;

  @override
  State<_OpenChip> createState() => _OpenChipState();
}

class _OpenChipState extends State<_OpenChip> {
  bool _busy = false;

  Future<void> _open() async {
    setState(() => _busy = true);
    var failed = false;
    try {
      if (widget.attachment.kind == CnAttachmentKind.link) {
        final raw = widget.attachment.url ?? '';
        final uri = Uri.tryParse(raw);
        failed = uri == null ||
            !await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final file = await writeAttachmentToTempFile(widget.attachment);
        failed = file == null ||
            !await launchUrl(Uri.file(file.path),
                mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      failed = true;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't open ${widget.attachment.name}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLink = widget.attachment.kind == CnAttachmentKind.link;
    return _Chip(
      onTap: _busy ? null : _open,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
      borderColor: cs.outlineVariant,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_busy)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
            )
          else
            Icon(
              isLink ? Icons.link_rounded : Icons.description_outlined,
              size: 18,
              color: cs.primary,
            ),
          const SizedBox(width: 7),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 190),
            child: Text(
              widget.attachment.name.isEmpty
                  ? (isLink ? 'Link' : 'File')
                  : widget.attachment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.child,
    required this.color,
    required this.borderColor,
    this.onTap,
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 0.8),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Writes an attachment's payload to a temp file so the platform can play or
/// open it. Named by content hash, so opening the same note twice reuses the
/// file instead of filling the cache.
Future<File?> writeAttachmentToTempFile(CnAttachment attachment) async {
  final bytes = attachment.bytes;
  if (bytes == null || bytes.isEmpty) return null;
  final directory = await getTemporaryDirectory();
  final folder = Directory('${directory.path}/classnotes');
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }
  final name = '${bytes.length}_${bytes.hashCode.toUnsigned(32)}'
      '.${attachment.fileExtension}';
  final file = File('${folder.path}/$name');
  if (!await file.exists()) {
    await file.writeAsBytes(bytes, flush: true);
  }
  return file;
}
