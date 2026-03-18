import 'dart:io';
import 'package:flutter/material.dart';

import '../../domain/solutions_models.dart';

class SolutionAssetPreviewSheet extends StatelessWidget {
  const SolutionAssetPreviewSheet({super.key, required this.asset});

  final SolutionUploadAsset asset;

  bool get _isLocal =>
      (asset.filePath ?? '').trim().isNotEmpty &&
      (asset.remoteUrl ?? '').trim().isEmpty;

  bool get _isRemote => (asset.remoteUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget preview;

    if (asset.kind == SolutionAssetKind.image) {
      if (_isLocal) {
        preview = ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(File(asset.filePath!), fit: BoxFit.contain),
        );
      } else if (_isRemote) {
        preview = ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(asset.remoteUrl!, fit: BoxFit.contain),
        );
      } else {
        preview = const Text('Image not available');
      }
    } else {
      preview = Column(
        children: [
          const Icon(Icons.picture_as_pdf_outlined, size: 64),
          const SizedBox(height: 12),
          Text(asset.name),
          const SizedBox(height: 12),
          const Text('PDF preview not supported yet'),
        ],
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              asset.name,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: preview,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
