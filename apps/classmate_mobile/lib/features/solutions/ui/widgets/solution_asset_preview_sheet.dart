import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../domain/solutions_models.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/widgets/cm_loading.dart';

/// Opens a full-screen, swipeable gallery starting at [initialIndex].
/// Supports both local/remote images and local/remote PDFs.
void openSolutionGallery(
  BuildContext context, {
  required List<SolutionUploadAsset> assets,
  int initialIndex = 0,
}) {
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (ctx, anim, sec) => _GalleryScreen(
        assets: assets,
        initialIndex: initialIndex,
      ),
    ),
  );
}

class _GalleryScreen extends StatefulWidget {
  const _GalleryScreen({required this.assets, required this.initialIndex});

  final List<SolutionUploadAsset> assets;
  final int initialIndex;

  @override
  State<_GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<_GalleryScreen> {
  late final PageController _pageController;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final total = widget.assets.length;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Gallery
          PageView.builder(
            controller: _pageController,
            itemCount: total,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) {
              final asset = widget.assets[i];
              return _AssetPage(asset: asset);
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: Material(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(99),
              child: IconButton(
                tooltip: l.a11yClose,
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ),

          // Page indicator
          if (total > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${_current + 1} / $total',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),

          // Dot indicators bottom
          if (total > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(total, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: i == _current ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _current ? Colors.white : Colors.white38,
                    borderRadius: BorderRadius.circular(99),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }
}

class _AssetPage extends StatelessWidget {
  const _AssetPage({required this.asset});
  final SolutionUploadAsset asset;

  bool get _isLocalFile => (asset.filePath ?? '').trim().isNotEmpty;
  bool get _isRemote => (asset.remoteUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (asset.kind == SolutionAssetKind.pdf) {
      return _PdfPage(asset: asset);
    }

    // Image
    Widget img;
    if (_isLocalFile) {
      img = Image.file(File(asset.filePath!), fit: BoxFit.contain);
    } else if (_isRemote) {
      img = Image.network(
        asset.remoteUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (ctx, err, trace) => const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.white54, size: 64),
        ),
      );
    } else {
      img = const Center(
        child: Icon(Icons.image_not_supported_rounded, color: Colors.white54, size: 64),
      );
    }

    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(child: img),
    );
  }
}

class _PdfPage extends StatelessWidget {
  const _PdfPage({required this.asset});
  final SolutionUploadAsset asset;

  @override
  Widget build(BuildContext context) {
    return _InlinePdfView(asset: asset, darkMode: true);
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Instagram-style card media strip (used inside _SolutionCard)
// ──────────────────────────────────────────────────────────────────────────────

/// A horizontally scrollable strip of media thumbnails with stacked-card feel.
/// Tapping any thumb opens the full gallery at that index.
class SolutionMediaStrip extends StatefulWidget {
  const SolutionMediaStrip({super.key, required this.assets});

  final List<SolutionUploadAsset> assets;

  @override
  State<SolutionMediaStrip> createState() => _SolutionMediaStripState();
}

class _SolutionMediaStripState extends State<SolutionMediaStrip> {
  final _scrollController = ScrollController();
  int _currentVisible = 0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assets = widget.assets;
    if (assets.isEmpty) return const SizedBox.shrink();

    final total = assets.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.92),
            itemCount: total,
            onPageChanged: (i) => setState(() => _currentVisible = i),
            itemBuilder: (ctx, i) {
              final asset = assets[i];
              return GestureDetector(
                onTap: () => openSolutionGallery(ctx, assets: assets, initialIndex: i),
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: i < total - 1 ? 10 : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _Thumb(asset: asset),
                  ),
                ),
              );
            },
          ),
        ),
        if (total > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == _currentVisible ? 16 : 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: i == _currentVisible
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(99),
              ),
            )),
          ),
        ],
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.asset});
  final SolutionUploadAsset asset;

  bool get _isLocalFile => (asset.filePath ?? '').trim().isNotEmpty;
  bool get _isRemote => (asset.remoteUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (asset.kind == SolutionAssetKind.pdf) {
      // PDF thumbnail — show first page via pdfrx or a nice placeholder
      if (_isLocalFile || _isRemote) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: cs.surfaceContainerLow),
            _PdfThumb(asset: asset),
            // PDF badge
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PDF',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        );
      }
      return Container(
        color: cs.surfaceContainerLow,
        child: Icon(Icons.picture_as_pdf_rounded, size: 48, color: cs.onSurfaceVariant),
      );
    }

    // Image
    if (_isLocalFile) {
      return Image.file(File(asset.filePath!), fit: BoxFit.cover);
    }
    if (_isRemote) {
      return Image.network(
        asset.remoteUrl!,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: cs.surfaceContainerLow,
            child: const Center(child: CmLoading()),
          );
        },
        errorBuilder: (ctx, err, trace) => Container(
          color: cs.surfaceContainerLow,
          child: Icon(Icons.broken_image_rounded, color: cs.onSurfaceVariant, size: 36),
        ),
      );
    }

    return Container(
      color: cs.surfaceContainerLow,
      child: Icon(Icons.image_rounded, color: cs.onSurfaceVariant, size: 36),
    );
  }
}

class _PdfThumb extends StatelessWidget {
  const _PdfThumb({required this.asset});
  final SolutionUploadAsset asset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHigh,
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_rounded,
            size: 52,
            color: cs.error,
          ),
          const SizedBox(height: 10),
          Text(
            asset.name.trim().isEmpty ? l.solutionAssetPreviewSheetPdfDocument : asset.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _InlinePdfView extends StatefulWidget {
  const _InlinePdfView({required this.asset, required this.darkMode});

  final SolutionUploadAsset asset;
  final bool darkMode;

  @override
  State<_InlinePdfView> createState() => _InlinePdfViewState();
}

class _InlinePdfViewState extends State<_InlinePdfView> {
  String? _localPath;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      final localFile = (widget.asset.filePath ?? '').trim();
      if (localFile.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _localPath = localFile;
          _loading = false;
        });
        return;
      }

      final remote = (widget.asset.remoteUrl ?? '').trim();
      if (remote.isEmpty) {
        throw Exception('Missing PDF source');
      }

      final uri = Uri.parse(remote);
      final res = await http.get(uri).timeout(const Duration(seconds: 20));
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final dir = await getTemporaryDirectory();
      final safeName = widget.asset.id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final file = File(
        '${dir.path}/solution_pdf_${safeName}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(res.bodyBytes, flush: true);

      if (!mounted) return;
      setState(() {
        _localPath = file.path;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    if (_loading) {
      return const Center(child: CmLoading(color: Colors.white));
    }

    if (_localPath != null) {
      return PDFView(
        filePath: _localPath!,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        pageSnap: true,
        fitPolicy: FitPolicy.BOTH,
        preventLinkNavigation: false,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_rounded, color: Colors.white54, size: 64),
            const SizedBox(height: 12),
            Text(
              widget.asset.name.trim().isEmpty ? l.solutionAssetPreviewSheetPdfDocument : widget.asset.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? l.solutionAssetPreviewSheetUnableToPreview,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                AppLocalizations.of(context)!.solutionPreviewFailFallback,
                style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
