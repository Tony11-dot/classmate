import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'classnotes_attachments.dart';
import 'classnotes_models.dart';
import 'classnotes_repository.dart';

/// Full-screen read-only notebook viewer — a vertical scroll of the notebook's
/// pages, mirroring the native ClassNotes `NotebookViewerScreen`. Opened when a
/// cover is tapped in the library. Pages that have been synced up from the
/// native app (rendered PNG data URLs) are painted over the paper; pages with
/// no synced image — and older notebooks with none at all — fall back to blank
/// paper in the notebook's template style.
///
/// A synced page is not a flat picture: tap it to zoom in and pan around the
/// handwriting, and use the chips underneath to play the voice notes and open
/// the files and links that were dropped on that page on the iPad.
class ClassNotesNotebookScreen extends ConsumerWidget {
  const ClassNotesNotebookScreen({super.key, required this.notebook});

  final CnNotebook notebook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final asyncPages = ref.watch(classNotesPagesProvider(notebook.id));
    final pages = asyncPages.asData?.value ?? const <CnPage>[];
    final byIndex = {for (final p in pages) p.pageIndex: p};

    // With real content, show every page (indices are 0-based). Without any
    // synced image, keep the old cap — a handful of blank pages conveys the
    // paper style without an endless empty scroll; the true count is in the meta.
    final highestIndex = byIndex.keys.isEmpty
        ? -1
        : byIndex.keys.reduce((a, b) => a > b ? a : b);
    final rendered = pages.isEmpty
        ? notebook.pageCount.clamp(1, 12)
        : (notebook.pageCount > highestIndex + 1
            ? notebook.pageCount
            : highestIndex + 1);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailHeader(notebook: notebook),
            // Subtle progress while the page images are fetched; the paper
            // placeholders render underneath so the layout never jumps.
            SizedBox(
              height: 2,
              child: asyncPages.isLoading
                  ? LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.transparent,
                      color: cs.primary.withValues(alpha: 0.5),
                    )
                  : null,
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                itemCount: rendered,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (_, i) {
                  final page = byIndex[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _NotebookPage(
                        template: notebook.template,
                        dataUrl: page?.dataUrl,
                        pageNumber: i + 1,
                        title: notebook.title,
                      ),
                      CnAttachmentBar(
                        attachments: page?.attachments ?? const <CnAttachment>[],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.notebook});

  final CnNotebook notebook;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: cs.onSurface,
            onPressed: () => Navigator.of(context).maybePop(),
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          // A small spine-tinted chip of the cover colour, so the detail reads
          // as "this notebook".
          Container(
            width: 22,
            height: 30,
            decoration: BoxDecoration(
              color: notebook.coverColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notebook.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${notebook.pageCount} ${notebook.pageCount == 1 ? 'page' : 'pages'}  ·  '
                  '${notebook.template.label}  ·  ${_formatDate(notebook.updatedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

/// A single page in the notebook's paper style: 3:4, rounded, hairline border
/// + soft shadow. When [dataUrl] carries a synced PNG it is painted over the
/// paper (contained); otherwise the template lines are drawn on blank paper as
/// the placeholder/fallback.
///
/// A synced page is tappable: it opens full-screen where you can pinch and drag
/// to read small handwriting, the way you would on the iPad.
class _NotebookPage extends StatelessWidget {
  const _NotebookPage({
    required this.template,
    this.dataUrl,
    this.pageNumber,
    this.title,
  });

  final CnTemplate template;

  /// `data:image/png;base64,...` for a synced page, or null for blank paper.
  final String? dataUrl;

  /// 1-based page number, shown in the zoomed view's title.
  final int? pageNumber;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    // Warm off-white / near-black paper, following the theme's mode.
    final paper = isDark ? const Color(0xFF17191C) : const Color(0xFFFCFBF7);
    final lines = cs.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.9);

    final bytes = decodeDataUrl(dataUrl);

    final page = AspectRatio(
      aspectRatio: 3 / 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: paper,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: cs.outlineVariant, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: bytes == null
              // No synced image — draw the paper template as the placeholder.
              ? CustomPaint(
                  painter: _PagePainter(template: template, lineColor: lines),
                  size: Size.infinite,
                )
              // Synced page image, contained over the paper background.
              : Image.memory(
                  bytes,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  gaplessPlayback: true,
                  // Corrupt/undecodable payload → fall back to blank paper.
                  errorBuilder: (context, error, stack) => CustomPaint(
                    painter:
                        _PagePainter(template: template, lineColor: lines),
                    size: Size.infinite,
                  ),
                ),
        ),
      ),
    );

    if (bytes == null) return page;

    return Stack(
      children: [
        page,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) => CnZoomablePage(
                    bytes: bytes,
                    label: pageNumber == null
                        ? (title ?? '')
                        : '${title ?? ''} — page $pageNumber',
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.82),
                shape: BoxShape.circle,
                border: Border.all(color: cs.outlineVariant, width: 0.5),
              ),
              child: Icon(
                Icons.zoom_in_rounded,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One page, full screen, pinch and drag to zoom — for reading handwriting on a
/// phone. Double-tap toggles between fit and 2.5×.
class CnZoomablePage extends StatefulWidget {
  const CnZoomablePage({super.key, required this.bytes, required this.label});

  final Uint8List bytes;
  final String label;

  @override
  State<CnZoomablePage> createState() => _CnZoomablePageState();
}

class _CnZoomablePageState extends State<CnZoomablePage> {
  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleZoom(TapDownDetails details) {
    final zoomed = _controller.value.getMaxScaleOnAxis() > 1.05;
    if (zoomed) {
      _controller.value = Matrix4.identity();
      return;
    }
    // Zoom about the point that was tapped, so the words under the finger stay
    // under the finger.
    const scale = 2.5;
    final position = details.localPosition;
    _controller.value = Matrix4.identity()
      ..translateByDouble(-position.dx * (scale - 1), -position.dy * (scale - 1), 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(
          widget.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        ),
      ),
      body: GestureDetector(
        onDoubleTapDown: _toggleZoom,
        onDoubleTap: () {},
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 1,
          maxScale: 6,
          child: Center(
            child: Image.memory(
              widget.bytes,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              // Full resolution matters here — this is the whole point of zooming.
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the paper template. Geometry is expressed in ClassNotes' 768-wide
/// logical page space and scaled to the rendered width, so line spacing matches
/// the native `PageTemplateView` proportionally.
class _PagePainter extends CustomPainter {
  _PagePainter({required this.template, required this.lineColor});

  final CnTemplate template;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 768.0;
    final stroke = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke;

    switch (template) {
      case CnTemplate.blank:
        break;
      case CnTemplate.ruled:
        stroke.strokeWidth = 1 * scale;
        final spacing = 32.0 * scale;
        final top = 64.0 * scale;
        for (double y = top; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), stroke);
        }
        // Default left margin — the soft-red rule ClassNotes draws at 72 pt.
        final margin = Paint()
          ..color = const Color(0xFFCC4747).withValues(alpha: 0.55)
          ..strokeWidth = 1 * scale;
        final mx = 72.0 * scale;
        canvas.drawLine(Offset(mx, 0), Offset(mx, size.height), margin);
      case CnTemplate.grid:
        stroke.strokeWidth = 0.75 * scale;
        final spacing = 32.0 * scale;
        for (double x = spacing; x < size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), stroke);
        }
        for (double y = spacing; y < size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), stroke);
        }
      case CnTemplate.dotGrid:
        final dot = Paint()
          ..color = lineColor
          ..style = PaintingStyle.fill;
        final spacing = 28.0 * scale;
        final r = 1.4 * scale;
        for (double x = spacing; x < size.width; x += spacing) {
          for (double y = spacing; y < size.height; y += spacing) {
            canvas.drawCircle(Offset(x, y), r, dot);
          }
        }
    }
  }

  @override
  bool shouldRepaint(_PagePainter old) =>
      old.template != template || old.lineColor != lineColor;
}
