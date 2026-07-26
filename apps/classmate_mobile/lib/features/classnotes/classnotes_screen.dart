import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'classnotes_models.dart';
import 'classnotes_notebook_screen.dart';
import 'classnotes_repository.dart';

/// The **ClassNotes** library — a faithful Flutter mirror of the native
/// ClassNotes `LibraryGridScreen`: a horizontal shelf-chip bar and an adaptive
/// grid of notebook covers, always most-recently-updated first. Rendered inside
/// the app shell (regular screen, with the top bar). Tapping a cover opens the
/// notebook full-screen. Cover colours use ClassNotes' own 19-accent palette;
/// data comes from [classNotesLibraryProvider] (sample today, real sync later).
class ClassNotesScreen extends ConsumerStatefulWidget {
  const ClassNotesScreen({super.key});

  @override
  ConsumerState<ClassNotesScreen> createState() => _ClassNotesScreenState();
}

class _ClassNotesScreenState extends ConsumerState<ClassNotesScreen> {
  String? _shelfFilter; // null = "All"

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final library = ref.watch(classNotesLibraryProvider);
    final visible = library.inShelf(_shelfFilter);

    return ColoredBox(
      color: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (library.shelves.isNotEmpty)
            _ShelfBar(
              shelves: library.shelves,
              selected: _shelfFilter,
              onSelect: (id) => setState(() => _shelfFilter = id),
            ),
          Expanded(
            child: visible.isEmpty
                ? const _EmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      mainAxisSpacing: 28,
                      crossAxisSpacing: 28,
                      childAspectRatio: 0.64,
                    ),
                    itemCount: visible.length,
                    itemBuilder: (context, i) => _CoverCell(
                      notebook: visible[i],
                      onTap: () => _openNotebook(visible[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _openNotebook(CnNotebook notebook) {
    // Full-screen ABOVE the shell (no logo/pill bar) with iOS edge-swipe back —
    // "enter a notebook → full screen", matching ClassNotes' push viewer.
    Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute<void>(
        builder: (_) => ClassNotesNotebookScreen(notebook: notebook),
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
  const _CoverCell({required this.notebook, required this.onTap});

  final CnNotebook notebook;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
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
// Empty state — matches ClassNotes' copy/feel.
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 44, color: cs.primary),
            const SizedBox(height: 12),
            Text(
              'No notebooks yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Notebooks you create in ClassNotes appear here — covers, paper '
              'and ink all follow your theme.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
