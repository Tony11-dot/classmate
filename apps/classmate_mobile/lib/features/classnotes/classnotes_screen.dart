import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/auth_session.dart';
import 'classnotes_manage.dart';
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
  AuthSession? _session;
  bool _hadToken = false;
  /// Arrange mode: covers become a draggable list.
  bool _arranging = false;
  /// The order shown while a drag is being saved, so covers don't snap back to
  /// the server's order mid-gesture.
  List<CnNotebook>? _pendingOrder;

  @override
  void initState() {
    super.initState();
    // `authSessionProvider` is a plain Provider, so it never notifies Riverpod
    // when the token hydrates on launch. Listen directly and refetch the moment
    // we go from "no token" to "signed in", so the tab never sticks on a blank
    // loading screen.
    _session = ref.read(authSessionProvider);
    _hadToken = (_session?.token ?? '').isNotEmpty;
    _session?.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _session?.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final hasToken = (_session?.token ?? '').isNotEmpty;
    if (hasToken != _hadToken) {
      _hadToken = hasToken;
      ref.invalidate(classNotesLibraryProvider);
    }
    setState(() {});
  }

  Future<void> _refresh() async {
    // A refresh is the user asking for the server's truth — drop any local order
    // we were showing over it.
    setState(() => _pendingOrder = null);
    ref.invalidate(classNotesLibraryProvider);
    await ref.read(classNotesLibraryProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final session = _session;

    Widget child;
    if (session != null && !session.ready) {
      // Auth still restoring — show a branded loader, never a blank surface.
      child = const _LoadingState();
    } else if (session != null && (session.token ?? '').isEmpty) {
      child = const _SignedOutState();
    } else {
      child = ref.watch(classNotesLibraryProvider).when(
            loading: () => const _LoadingState(),
            error: (_, __) => _ErrorState(onRetry: _refresh),
            data: _libraryView,
          );
    }

    return ColoredBox(color: cs.surface, child: child);
  }

  Widget _libraryView(CnLibrary library) {
    // If the previously-selected shelf vanished on a refetch, fall back to All.
    final filter = (_shelfFilter != null &&
            !library.shelves.any((s) => s.id == _shelfFilter))
        ? null
        : _shelfFilter;
    // While reordering, show the local order — the server round-trip would
    // otherwise snap the covers back under the finger.
    final visible = _pendingOrder ?? library.inShelf(filter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (library.shelves.isNotEmpty)
          _ShelfBar(
            shelves: library.shelves,
            selected: filter,
            onSelect: (id) => setState(() {
              _shelfFilter = id;
              _pendingOrder = null;
            }),
            onEditShelf: (shelf) =>
                CnManage.showShelfActions(context, ref, shelf),
          ),
        _ManageHint(
          arranging: _arranging,
          onToggle: () => setState(() {
            _arranging = !_arranging;
            _pendingOrder = null;
          }),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: visible.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 100),
                      _EmptyState(),
                    ],
                  )
                : _arranging
                    ? _arrangeList(library, visible)
                    : _coverGrid(library, visible),
          ),
        ),
      ],
    );
  }

  Widget _coverGrid(CnLibrary library, List<CnNotebook> visible) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 28,
        crossAxisSpacing: 28,
        childAspectRatio: 0.64,
      ),
      itemCount: visible.length,
      itemBuilder: (context, i) => _CoverCell(
        notebook: visible[i],
        onTap: () => _openNotebook(visible[i]),
        onManage: () => _manage(visible[i], library),
      ),
    );
  }

  /// Arrange mode: the covers become a list you can drag. A grid has no
  /// reorderable equivalent in Flutter, and a list makes the drag target obvious
  /// — one row, one handle, no guessing which gap you're dropping into.
  Widget _arrangeList(CnLibrary library, List<CnNotebook> visible) {
    return ReorderableListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      itemCount: visible.length,
      onReorder: (oldIndex, newIndex) {
        if (newIndex > oldIndex) newIndex -= 1;
        final next = List<CnNotebook>.from(visible);
        next.insert(newIndex, next.removeAt(oldIndex));
        setState(() => _pendingOrder = next);
        // The order is saved for the WHOLE library, not just the filtered shelf:
        // the dragged books keep their new positions and everything else follows.
        final ids = <String>[
          for (final n in next) n.id,
          for (final n in library.notebooks)
            if (!next.any((v) => v.id == n.id)) n.id,
        ];
        CnManage.saveOrder(context, ref, ids);
      },
      itemBuilder: (context, i) => _ArrangeRow(
        key: ValueKey(visible[i].id),
        index: i,
        notebook: visible[i],
        onManage: () => _manage(visible[i], library),
      ),
    );
  }

  void _manage(CnNotebook notebook, CnLibrary library) {
    CnManage.showNotebookActions(
      context,
      ref,
      notebook: notebook,
      shelves: library.shelves,
      onOpen: () => _openNotebook(notebook),
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
    required this.onEditShelf,
  });

  final List<CnShelf> shelves;
  final String? selected;
  final ValueChanged<String?> onSelect;

  /// Long-press a shelf chip to rename or delete it.
  final ValueChanged<CnShelf> onEditShelf;

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
              onLongPress: () => onEditShelf(s),
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
    this.onLongPress,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

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
        onLongPress: onLongPress,
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

/// A one-line strip above the grid: what you can do here, and the switch into
/// arrange mode. Without it, drag-to-reorder and the ⋮ menu are invisible.
class _ManageHint extends StatelessWidget {
  const _ManageHint({required this.arranging, required this.onToggle});

  final bool arranging;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 2, 16, 2),
      child: Row(
        children: [
          Icon(
            arranging ? Icons.drag_indicator_rounded : Icons.more_vert_rounded,
            size: 15,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              arranging
                  ? 'Drag to reorder your notebooks'
                  : 'Tap ⋮ on a notebook to rename, download or delete it',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onToggle,
            icon: Icon(arranging ? Icons.check_rounded : Icons.swap_vert_rounded, size: 18),
            label: Text(arranging ? 'Done' : 'Arrange'),
          ),
        ],
      ),
    );
  }
}

/// One row in arrange mode: a small cover, the title, and the same ⋮ menu.
class _ArrangeRow extends StatelessWidget {
  const _ArrangeRow({
    super.key,
    required this.index,
    required this.notebook,
    required this.onManage,
  });

  final int index;
  final CnNotebook notebook;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: cs.surfaceContainerLow,
      child: ListTile(
        leading: SizedBox(
          width: 34,
          child: _NotebookCover(notebook: notebook),
        ),
        title: Text(
          notebook.title.isEmpty ? 'Untitled' : notebook.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${notebook.pageCount} page${notebook.pageCount == 1 ? '' : 's'}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              tooltip: 'Manage',
              onPressed: onManage,
            ),
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_handle_rounded, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverCell extends StatelessWidget {
  const _CoverCell({
    required this.notebook,
    required this.onTap,
    required this.onManage,
  });

  final CnNotebook notebook;
  final VoidCallback onTap;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      // Long-press anywhere on the cover is the same menu as the ⋮ button, for
      // anyone who reaches for that first.
      onLongPress: onManage,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Stack(
              children: [
                Positioned.fill(child: _NotebookCover(notebook: notebook)),
                Positioned(
                  top: 2,
                  right: 2,
                  child: _ManageButton(
                    key: ValueKey('cn-manage-${notebook.id}'),
                    onTap: onManage,
                    title: notebook.title,
                  ),
                ),
              ],
            ),
          ),
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

/// The ⋮ affordance on a cover. Dark scrim behind it so it reads on every cover
/// colour, light or dark.
class _ManageButton extends StatelessWidget {
  const _ManageButton({super.key, required this.onTap, required this.title});

  final VoidCallback onTap;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Manage ${title.isEmpty ? 'notebook' : title}',
      child: Material(
        color: Colors.black.withValues(alpha: 0.28),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const SizedBox(
            width: 30,
            height: 30,
            child: Icon(Icons.more_vert_rounded, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

/// The book itself — 3:4 portrait, gradient cover, translucent left spine,
/// contrast title bottom-left. Mirrors ClassNotes' `NotebookCoverView`.
///
/// When the notebook has been opened on an iPad running cover pages, it also
/// carries a render of its real cover — the chosen design plus anything the user
/// wrote on it. That render wins, because it IS the cover; the drawn version
/// stays as the fallback for everything synced before covers were pages, and for
/// a render that won't decode.
class _NotebookCover extends StatelessWidget {
  const _NotebookCover({required this.notebook});

  final CnNotebook notebook;

  @override
  Widget build(BuildContext context) {
    final color = notebook.coverColor;
    final darker = HSLColor.fromColor(color)
        .withLightness(
          (HSLColor.fromColor(color).lightness - 0.08).clamp(0.0, 1.0),
        )
        .toColor();
    final render = notebook.coverImageBytes;

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Kept under the render too: it's what shows in the corners of a cover
          // whose aspect ratio isn't quite 3:4, instead of a bare rectangle.
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
          child: render == null
              ? _drawnCover(context)
              : Image.memory(
                  render,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  // The title is inside the artwork now, so it needs saying out
                  // loud for anyone who isn't looking at it.
                  semanticLabel: notebook.title,
                  errorBuilder: (context, error, stack) => _drawnCover(context),
                ),
        ),
      ),
    );
  }

  Widget _drawnCover(BuildContext context) {
    final ink = cnContrastingInk(notebook.coverColor);
    return Stack(
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

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/cn_monogram.png',
            width: 46,
            height: 46,
            color: cs.primary,
            colorBlendMode: BlendMode.srcIn,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: cs.primary),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading your notebooks…',
            style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SignedOutState extends StatelessWidget {
  const _SignedOutState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded, size: 44, color: cs.primary),
            const SizedBox(height: 12),
            Text(
              'Sign in to see your notebooks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your ClassNotes library is tied to your ClassMate account.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 44, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              "Couldn't load your notebooks",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
