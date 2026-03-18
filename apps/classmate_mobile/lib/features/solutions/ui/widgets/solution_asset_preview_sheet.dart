import 'package:flutter/material.dart';

import '../../domain/solutions_models.dart';

class SolutionAssetPreviewSheet extends StatelessWidget {
  const SolutionAssetPreviewSheet({super.key, required this.asset});

  final SolutionUploadAsset asset;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              asset.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              asset.kind == SolutionAssetKind.pdf
                  ? 'PDF attachment'
                  : 'Image attachment',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    asset.kind == SolutionAssetKind.pdf
                        ? Icons.picture_as_pdf_outlined
                        : Icons.photo_outlined,
                    size: 42,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    asset.filePath?.trim().isNotEmpty == true
                        ? asset.filePath!
                        : (asset.remoteUrl?.trim().isNotEmpty == true
                              ? asset.remoteUrl!
                              : 'Preview source not available yet'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
