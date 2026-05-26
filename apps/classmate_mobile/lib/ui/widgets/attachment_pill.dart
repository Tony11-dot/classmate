// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../features/common/media/pdf_viewer_screen.dart';
import '../../features/common/media/image_viewer_screen.dart';
import '../../core/config/env.dart';

/// Renders a single attachment (link or file) as a tappable pill.
/// PDFs and images open in the in-app viewer; all other files use the browser.
class AttachmentPill extends StatelessWidget {
  const AttachmentPill({
    super.key,
    required this.url,
    required this.name,
    this.type = 'link',
  });

  final String url;
  final String name;
  /// 'link' | 'file' | 'pdf' | 'image'
  final String type;

  IconData get _icon {
    final t = type.toLowerCase();
    if (t == 'pdf') return Icons.picture_as_pdf_rounded;
    if (t == 'image') return Icons.image_rounded;
    if (t == 'file') return Icons.insert_drive_file_rounded;
    return Icons.link_rounded;
  }

  /// Resolve relative server paths to full URLs.
  String _resolve(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
    if (trimmed.startsWith('/uploads') || trimmed.startsWith('/api/')) {
      final base = Env.apiBaseUrl.replaceAll(RegExp(r'/+$'), '').replaceAll(RegExp(r'/api/?$'), '');
      return '$base$trimmed';
    }
    return trimmed;
  }

  Future<void> _open(BuildContext context) async {
    final resolved = _resolve(url);
    if (resolved.isEmpty) return;

    // Presigned URLs (?token=…) and CDN URLs (#fragments) break a naive
    // endsWith('.pdf') / endsWith('.jpg') check — strip query + fragment
    // before sniffing the extension, then also peek at the filename for
    // `.pdf` / `.jpg` anywhere as a last-resort fallback.
    final pathOnly = Uri.tryParse(resolved)?.path.toLowerCase() ?? resolved.toLowerCase();
    final t = type.toLowerCase();
    final nameLower = name.toLowerCase();
    final isPdf = t == 'pdf' ||
        pathOnly.endsWith('.pdf') ||
        nameLower.endsWith('.pdf');
    final isImage = t == 'image' ||
        pathOnly.endsWith('.jpg') || pathOnly.endsWith('.jpeg') ||
        pathOnly.endsWith('.png') || pathOnly.endsWith('.webp') ||
        nameLower.endsWith('.jpg') || nameLower.endsWith('.jpeg') ||
        nameLower.endsWith('.png') || nameLower.endsWith('.webp');

    if (!context.mounted) return;
    if (isPdf) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PdfViewerScreen(url: resolved, title: name.isNotEmpty ? name : 'Document'),
      ));
      return;
    }
    if (isImage) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ImageViewerScreen(url: resolved, title: name.isNotEmpty ? name : 'Image'),
      ));
      return;
    }
    final uri = Uri.tryParse(resolved);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final isFile = type != 'link';
    final displayName = name.isNotEmpty ? name : url;

    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isFile
              ? cs.primaryContainer.withValues(alpha: 0.25)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isFile
                ? cs.primary.withValues(alpha: 0.35)
                : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon, size: 15, color: cs.primary),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                displayName,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: cs.primary.withValues(alpha: 0.5),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.open_in_new_rounded, size: 11, color: cs.primary.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

/// Renders a list of attachments as a wrap of pills.
class AttachmentPills extends StatelessWidget {
  const AttachmentPills({super.key, required this.attachments});

  final List<Map<String, dynamic>> attachments;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: attachments.map((a) => AttachmentPill(
        url: (a['url'] ?? '').toString(),
        name: (a['name'] ?? a['fileName'] ?? '').toString(),
        type: (a['type'] ?? 'link').toString(),
      )).toList(),
    );
  }
}
