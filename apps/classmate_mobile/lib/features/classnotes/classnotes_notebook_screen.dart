import 'package:flutter/material.dart';

import 'classnotes_models.dart';

/// Full-screen read-only notebook viewer — a vertical scroll of pages rendered
/// with the notebook's paper template (blank/ruled/grid/dot), mirroring the
/// native ClassNotes `NotebookViewerScreen`. Opened when a cover is tapped in
/// the library; there is no ink to show (no synced page content yet), so pages
/// render as faithful blank paper in the notebook's style.
class ClassNotesNotebookScreen extends StatelessWidget {
  const ClassNotesNotebookScreen({super.key, required this.notebook});

  final CnNotebook notebook;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Cap the rendered pages — with no ink, a handful conveys the paper style
    // without an endless empty scroll; the true count still shows in the meta.
    final rendered = notebook.pageCount.clamp(1, 12);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailHeader(notebook: notebook),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                itemCount: rendered,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (_, i) => _NotebookPage(template: notebook.template),
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

/// A single blank page in the notebook's paper style: 3:4, rounded, hairline
/// border + soft shadow, with the template lines painted on paper.
class _NotebookPage extends StatelessWidget {
  const _NotebookPage({required this.template});

  final CnTemplate template;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    // Warm off-white / near-black paper, following the theme's mode.
    final paper = isDark ? const Color(0xFF17191C) : const Color(0xFFFCFBF7);
    final lines = cs.outlineVariant.withValues(alpha: isDark ? 0.6 : 0.9);

    return AspectRatio(
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
          child: CustomPaint(
            painter: _PagePainter(template: template, lineColor: lines),
            size: Size.infinite,
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
