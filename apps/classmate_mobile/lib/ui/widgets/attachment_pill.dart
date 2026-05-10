import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Renders a single attachment (link or file) as a tappable pill.
/// Opens in-app browser for both links and files.
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

  Future<void> _open() async {
    final uri = Uri.tryParse(url);
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
      onTap: _open,
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
/// Each attachment is a Map with keys: url, name, type.
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
