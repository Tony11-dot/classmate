// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/env.dart';
import '../../common/media/pdf_viewer_screen.dart';
import '../../common/media/image_viewer_screen.dart';
import '../data/class_materials_repository.dart';

/// One shared period material rendered as a tappable pill.
///
/// Unlike the generic [AttachmentPill], the caption is the pill label and is
/// NEVER truncated — long captions wrap onto multiple lines. The uploader's
/// public name sits underneath so classmates know who shared it. A delete
/// affordance shows only when the caller is allowed to remove it.
class ClassMaterialPill extends StatelessWidget {
  const ClassMaterialPill({
    super.key,
    required this.material,
    this.onDelete,
  });

  final ClassMaterial material;
  final VoidCallback? onDelete;

  IconData get _icon {
    switch (material.kind) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'image':
        return Icons.image_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  String _resolve(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) return trimmed;
    if (trimmed.startsWith('/uploads') || trimmed.startsWith('/api/')) {
      final base = Env.stripApiSuffix(Env.apiBaseUrl).replaceAll(RegExp(r'/+$'), '');
      return '$base$trimmed';
    }
    return trimmed;
  }

  Future<void> _open(BuildContext context) async {
    final resolved = _resolve(material.fileUrl);
    if (resolved.isEmpty) return;
    final title = material.displayName;
    if (material.kind == 'pdf') {
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (_) => PdfViewerScreen(url: resolved, title: title),
      ));
      return;
    }
    if (material.kind == 'image') {
      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        builder: (_) => ImageViewerScreen(url: resolved, title: title),
      ));
      return;
    }
    final uri = Uri.tryParse(resolved);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      onTap: () => _open(context),
      onLongPress: onDelete,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.primary.withValues(alpha: 0.30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(_icon, size: 16, color: cs.primary),
                ),
                const SizedBox(width: 7),
                // Full caption — wraps, never ellipsised.
                Flexible(
                  child: Text(
                    material.displayName,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ),
                if (onDelete != null) ...[
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(Icons.close_rounded,
                        size: 15, color: cs.primary.withValues(alpha: 0.55)),
                  ),
                ],
              ],
            ),
            if (material.uploaderName.trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 23),
                child: Text(
                  material.uploaderName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
