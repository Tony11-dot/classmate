import 'package:flutter/material.dart';

import '../../ui/glass/native_glass_view.dart';
import 'classnotes_models.dart';

/// The **ClassNotes** tab — a faithful Flutter mirror of the native ClassNotes
/// library: a horizontal shelf-chip bar, an adaptive grid of notebook covers
/// (portrait book, spine, gradient cover, contrast title), and a floating
/// liquid-glass toolbar. Colours/paper come from the current ClassMate theme;
/// cover colours use ClassNotes' own palette. Data is sample for now — it
/// swaps for the real synced library later.
class ClassNotesScreen extends StatefulWidget {
  const ClassNotesScreen({super.key});

  @override
  State<ClassNotesScreen> createState() => _ClassNotesScreenState();
}

class _ClassNotesScreenState extends State<ClassNotesScreen> {
  String? _shelfFilter; // null = "All"
  late final List<CnNotebook> _all = CnSampleData.notebooks();
  final List<CnShelf> _shelves = CnSampleData.shelves;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final visible = _shelfFilter == null
        ? _all
        : _all.where((n) => n.shelfId == _shelfFilter).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return ColoredBox(
      color: cs.surface,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ShelfBar(
                shelves: _shelves,
                selected: _shelfFilter,
                onSelect: (id) => setState(() => _shelfFilter = id),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const _EmptyState()
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 150),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 190,
                          mainAxisSpacing: 26,
                          crossAxisSpacing: 26,
                          childAspectRatio: 0.63,
                        ),
                        itemCount: visible.length,
                        itemBuilder: (context, i) =>
                            _CoverCell(notebook: visible[i]),
                      ),
              ),
            ],
          ),
          // Floating glass toolbar, raised to clear the ClassMate nav pill.
          Positioned(
            left: 0,
            right: 0,
            bottom: 96,
            child: Center(child: _GlassToolbar(onAction: _notImplemented)),
          ),
        ],
      ),
    );
  }

  void _notImplemented() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Your ClassNotes library syncs here soon.'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shelf bar
// ─────────────────────────────────────────────────────────────────────────────

class _ShelfBar extends StatelessWidget {
  const _ShelfBar({
    required this.shelves,
    required this.selected,
    required this.onSelect,
  });

  final List<CnShelf> shelves;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          _ShelfChip(
            label: 'All',
            icon: Icons.grid_view_rounded,
            color: cs.primary,
            selected: selected == null,
            onTap: () => onSelect(null),
          ),
          for (final s in shelves) ...[
            const SizedBox(width: 8),
            _ShelfChip(
              label: s.name,
              icon: s.icon,
              color: s.color,
              selected: selected == s.id,
              onTap: () => onSelect(s.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShelfChip extends StatelessWidget {
  const _ShelfChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cnContrastingInk(color) : cs.onSurface;
    return Material(
      color: selected ? color : cs.surfaceContainerHighest,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cover cell
// ─────────────────────────────────────────────────────────────────────────────

class _CoverCell extends StatelessWidget {
  const _CoverCell({required this.notebook});

  final CnNotebook notebook;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: _NotebookCover(notebook: notebook)),
        const SizedBox(height: 8),
        Text(
          _formatDate(notebook.updatedAt),
          style: TextStyle(
            fontSize: 11.5,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

/// The book itself — 3:4 portrait, gradient cover, translucent left spine,
/// contrast title bottom-left. Mirrors ClassNotes' `NotebookCoverView`.
class _NotebookCover extends StatelessWidget {
  const _NotebookCover({required this.notebook});

  final CnNotebook notebook;

  @override
  Widget build(BuildContext context) {
    final color = notebook.coverColor;
    final ink = cnContrastingInk(color);
    final darker = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.08).clamp(0.0, 1.0),
        )
        .toColor();

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, darker],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Spine
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 10,
                  color: Colors.black.withValues(alpha: 0.14),
                ),
              ),
              // Title
              Positioned(
                left: 20,
                right: 12,
                bottom: 12,
                child: Text(
                  notebook.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating glass toolbar
// ─────────────────────────────────────────────────────────────────────────────

class _GlassToolbar extends StatelessWidget {
  const _GlassToolbar({required this.onAction});

  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return NativeGlassView(
      borderRadius: 30,
      style: NativeGlassStyle.regular,
      fallbackColor: cs.surface.withValues(alpha: isDark ? 0.5 : 0.56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _GlassIconButton(icon: Icons.add_rounded, onTap: onAction),
            _GlassIconButton(icon: Icons.folder_outlined, onTap: onAction),
            _GlassIconButton(icon: Icons.settings_outlined, onTap: onAction),
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 20, color: cs.onSurface),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 44, color: cs.primary),
          const SizedBox(height: 12),
          Text(
            'No notebooks here yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Covers, paper and ink all follow your theme.',
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

