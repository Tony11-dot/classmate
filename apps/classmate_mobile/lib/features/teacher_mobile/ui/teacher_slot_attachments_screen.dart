import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/teacher_mobile_repository.dart';

/// Manages the materials attached to a single teacher schedule slot.
///
/// Tap any attachment to open it externally, swipe / X to detach, or
/// press the "Attach material" FAB to pick from the teacher's existing
/// library (with a "Create new material" entry that round-trips through
/// the existing add-material screen and auto-attaches on return).
class TeacherSlotAttachmentsScreen extends ConsumerStatefulWidget {
  const TeacherSlotAttachmentsScreen({
    super.key,
    required this.slotId,
    required this.title,
  });

  final String slotId;
  final String title;

  @override
  ConsumerState<TeacherSlotAttachmentsScreen> createState() =>
      _TeacherSlotAttachmentsScreenState();
}

class _TeacherSlotAttachmentsScreenState
    extends ConsumerState<TeacherSlotAttachmentsScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _attached = const [];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(teacherMobileRepositoryProvider);
      final list = await repo.listSlotMaterials(widget.slotId);
      if (!mounted) return;
      setState(() {
        _attached = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _detach(String materialId) async {
    try {
      await ref.read(teacherMobileRepositoryProvider).detachSlotMaterial(
            slotId: widget.slotId,
            teacherMaterialId: materialId,
          );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Detach failed: $e')));
    }
  }

  Future<void> _openAttachPicker() async {
    final cs = Theme.of(context).colorScheme;
    final attachedIds = _attached.map((m) => m['id']?.toString() ?? '').toSet();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _MaterialPickerSheet(alreadyAttachedIds: attachedIds),
    );
    if (picked == null || picked.isEmpty) return;
    try {
      await ref.read(teacherMobileRepositoryProvider).attachSlotMaterial(
            slotId: widget.slotId,
            teacherMaterialId: picked,
          );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Attach failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attachments'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(28),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.title,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAttachPicker,
        icon: const Icon(Icons.attach_file_rounded),
        label: const Text('Attach material'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: TextStyle(color: cs.error)),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _attached.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.attach_file_rounded, size: 44, color: cs.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(
                              'No attachments yet',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Attach materials so your students see them on this period\'s card.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: _attached.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final m = _attached[i];
                        return _AttachedMaterialTile(
                          material: m,
                          onOpen: () async {
                            final url = (m['url'] ?? '').toString().trim();
                            if (url.isEmpty) return;
                            final uri = Uri.tryParse(url);
                            if (uri == null) return;
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          },
                          onDetach: () => _detach((m['id'] ?? '').toString()),
                        );
                      },
                    ),
    );
  }
}

class _AttachedMaterialTile extends StatelessWidget {
  const _AttachedMaterialTile({
    required this.material,
    required this.onOpen,
    required this.onDetach,
  });

  final Map<String, dynamic> material;
  final VoidCallback onOpen;
  final VoidCallback onDetach;

  IconData _iconFor(String mime) {
    final m = mime.toLowerCase();
    if (m.contains('pdf')) return Icons.picture_as_pdf_rounded;
    if (m.contains('image')) return Icons.image_rounded;
    if (m.contains('powerpoint') || m.contains('presentation')) return Icons.slideshow_rounded;
    if (m.contains('word') || m.contains('document')) return Icons.article_rounded;
    return Icons.description_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final title = (material['title'] ?? 'Material').toString();
    final desc = (material['description'] ?? '').toString().trim();
    final mime = (material['mime'] ?? '').toString();
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Icon(_iconFor(mime), size: 28, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(desc,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Detach',
              icon: const Icon(Icons.close_rounded),
              onPressed: onDetach,
            ),
          ],
        ),
      ),
    );
  }
}

class _MaterialPickerSheet extends ConsumerStatefulWidget {
  const _MaterialPickerSheet({required this.alreadyAttachedIds});
  final Set<String> alreadyAttachedIds;

  @override
  ConsumerState<_MaterialPickerSheet> createState() => _MaterialPickerSheetState();
}

class _MaterialPickerSheetState extends ConsumerState<_MaterialPickerSheet> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _materials = const [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await ref.read(teacherMobileRepositoryProvider).listTeacherMaterials();
      if (!mounted) return;
      setState(() {
        _materials = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _createNew() async {
    // Push the existing add-material screen and await its pop value.
    // The screen now returns the new material's id (when creating) so we
    // can pop our picker with that id and the parent screen will attach
    // it on return — single round trip, no manual re-select.
    final result = await context.push('/teacher/materials/add');
    if (!mounted) return;
    if (result is String && result.isNotEmpty && result != 'true') {
      Navigator.of(context).pop(result);
      return;
    }
    // If add-material returned true/null (legacy), just refresh the list
    // so the new material shows up and the teacher can pick it.
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? _materials
        : _materials.where((m) {
            final t = (m['title'] ?? '').toString().toLowerCase();
            final s = (m['subject'] ?? '').toString().toLowerCase();
            return t.contains(q) || s.contains(q);
          }).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Attach material',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search materials…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(child: Text(_error!, style: TextStyle(color: cs.error))),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                          itemCount: filtered.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(height: 4),
                          itemBuilder: (_, i) {
                            // First item: Create new material shortcut.
                            if (i == 0) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _createNew,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_rounded, color: cs.onPrimaryContainer),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Create new material',
                                        style: theme.textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: cs.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            final m = filtered[i - 1];
                            final id = (m['id'] ?? '').toString();
                            final title = (m['title'] ?? 'Material').toString();
                            final subj = (m['subject'] ?? '').toString();
                            final attached = widget.alreadyAttachedIds.contains(id);
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: attached ? null : () => Navigator.pop(context, id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: attached
                                      ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
                                      : cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.description_rounded, color: cs.primary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: attached ? cs.onSurfaceVariant : cs.onSurface,
                                            ),
                                          ),
                                          if (subj.isNotEmpty)
                                            Text(subj,
                                                style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                    if (attached)
                                      Icon(Icons.check_circle_rounded, size: 18, color: cs.primary),
                                  ],
                                ),
                              ),
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
