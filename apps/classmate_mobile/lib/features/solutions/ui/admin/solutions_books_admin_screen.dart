import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/config/env.dart';
import '../../../../core/http/cm_api.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/solutions_api.dart';
import '../../domain/solution_subjects.dart';
import '../../providers/solutions_flow_provider.dart';

/// Opens the add/edit book sheet (title + pages + cover). Returns true if a
/// book was saved. Reusable so the per-subject books screen can host the same
/// editor via a FAB (teachers/admins) without a separate management tab.
Future<bool?> showSolutionBookEditor(
  BuildContext context, {
  required String subjectKey,
  Map<String, dynamic>? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _BookEditorSheet(subjectKey: subjectKey, existing: existing),
  );
}

String _resolveCover(String? raw) {
  final s = (raw ?? '').trim();
  if (s.isEmpty || s.startsWith('http')) return s;
  final base = Env.apiBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
  return '$base${s.startsWith('/') ? s : '/$s'}';
}

/// Teacher/admin screen to manage the global Solutions books per subject:
/// add / edit / delete a book (title + page count + cover image).
class SolutionsBooksAdminScreen extends ConsumerStatefulWidget {
  const SolutionsBooksAdminScreen({super.key});

  @override
  ConsumerState<SolutionsBooksAdminScreen> createState() => _SolutionsBooksAdminScreenState();
}

class _SolutionsBooksAdminScreenState extends ConsumerState<SolutionsBooksAdminScreen> {
  String _subjectKey = kSolutionSubjectKeys.first;
  bool _loading = false;
  List<Map<String, dynamic>> _books = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ref.read(solutionsApiProvider).fetchBooks(subject: _subjectKey);
      final list = res['books'];
      _books = list is List
          ? list.whereType<Map>().map((e) => e.map((k, v) => MapEntry('$k', v))).toList()
          : const [];
    } catch (_) {
      _books = const [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEditor({Map<String, dynamic>? existing}) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _BookEditorSheet(subjectKey: _subjectKey, existing: existing),
    );
    if (saved == true) {
      await _load();
      // Keep the student-facing flow in sync too.
      ref.read(solutionsFlowProvider.notifier).reloadBooks();
    }
  }

  Future<void> _delete(Map<String, dynamic> book) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.solutionsDeleteBookTitle),
        content: Text(l.solutionsDeleteBookBody('${book['title'] ?? ''}')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.tutorCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(solutionsApiProvider).deleteBook('${book['id']}');
      await _load();
      ref.read(solutionsFlowProvider.notifier).reloadBooks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.solutionsBookSaveFailed('$e'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.solutionsManageBooksTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.solutionsAddBookAction),
      ),
      body: Column(
        children: [
          // Subject selector.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: DropdownButtonFormField<String>(
              initialValue: _subjectKey,
              decoration: InputDecoration(
                labelText: l.assignmentsSubjectLabel,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final k in kSolutionSubjectKeys)
                  DropdownMenuItem(value: k, child: Text(solutionSubjectTitle(l, k))),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() => _subjectKey = v);
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _books.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Text(
                            l.solutionsNoBooksManageHint,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                        itemCount: _books.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          final b = _books[i];
                          final cover = _resolveCover(b['coverUrl'] as String?);
                          final pages = b['pages'] is int
                              ? b['pages'] as int
                              : int.tryParse('${b['pages'] ?? ''}') ?? 0;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: SizedBox(
                                    width: 44,
                                    height: 58,
                                    child: cover.isEmpty
                                        ? Container(
                                            color: cs.secondaryContainer,
                                            child: Icon(Icons.menu_book_rounded,
                                                color: cs.onSecondaryContainer, size: 20),
                                          )
                                        : CachedNetworkImage(imageUrl: cover, fit: BoxFit.cover),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${b['title'] ?? ''}',
                                          style: const TextStyle(fontWeight: FontWeight.w800)),
                                      const SizedBox(height: 3),
                                      Text(l.solutionsBookPagesCount(pages),
                                          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12.5)),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_rounded),
                                  onPressed: () => _openEditor(existing: b),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline_rounded, color: cs.error),
                                  onPressed: () => _delete(b),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _BookEditorSheet extends ConsumerStatefulWidget {
  const _BookEditorSheet({required this.subjectKey, this.existing});

  final String subjectKey;
  final Map<String, dynamic>? existing;

  @override
  ConsumerState<_BookEditorSheet> createState() => _BookEditorSheetState();
}

class _BookEditorSheetState extends ConsumerState<_BookEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _pagesCtrl;
  String? _existingCoverUrl;
  File? _pickedCover;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?['title']?.toString() ?? '');
    _pagesCtrl = TextEditingController(
        text: e?['pages'] != null ? '${e!['pages']}' : '');
    _existingCoverUrl = _resolveCover(e?['coverUrl'] as String?);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _pagesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picker = ImagePicker();
    final x = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
    if (x == null) return;
    setState(() => _pickedCover = File(x.path));
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final title = _titleCtrl.text.trim();
    final pages = int.tryParse(_pagesCtrl.text.trim()) ?? 0;
    if (title.isEmpty || pages <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.solutionsBookNeedTitlePages)),
      );
      return;
    }
    setState(() => _saving = true);
    final api = ref.read(solutionsApiProvider);
    try {
      // Upload the new cover first (if the user picked one).
      String? coverUrl;
      if (_pickedCover != null) {
        final uploaded = await api.uploadFilesMultipart([_pickedCover!.path]);
        if (uploaded.isNotEmpty) coverUrl = '${uploaded.first['url'] ?? ''}';
      }

      final existing = widget.existing;
      if (existing != null) {
        // Edit by id — supports renaming + new cover.
        await api.updateBook(
          id: '${existing['id']}',
          title: title,
          pages: pages,
          coverUrl: coverUrl,
        );
      } else {
        // Create (upsert by subject+title), passing the cover in one shot.
        // The API flags a SIMILAR existing title (e.g. "archimidis" vs
        // "Archimedes") with a 409 — we warn the teacher and only force it
        // through if they confirm it's a different book.
        final created = await _createGuarded(api, title: title, pages: pages, coverUrl: coverUrl);
        if (!created) {
          if (mounted) setState(() => _saving = false);
          return;
        }
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.solutionsBookSaveFailed('$e'))),
      );
    }
  }

  /// Creates the book, but if the API replies 409 with a fuzzy-duplicate
  /// warning, asks the teacher to confirm before forcing it through.
  /// Returns false only when the teacher cancels at the warning.
  Future<bool> _createGuarded(
    SolutionsApi api, {
    required String title,
    required int pages,
    String? coverUrl,
  }) async {
    try {
      await api.createBook(
        subject: widget.subjectKey,
        title: title,
        pages: pages,
        coverUrl: coverUrl,
      );
      return true;
    } on CMApiException catch (e) {
      if (e.statusCode != 409) rethrow;
      String existingTitle = '';
      try {
        final decoded = jsonDecode(e.body);
        if (decoded is Map && decoded['duplicateWarning'] == true) {
          existingTitle = '${decoded['existingTitle'] ?? ''}'.trim();
        }
      } catch (_) {}
      if (existingTitle.isEmpty) rethrow; // not our duplicate signal
      if (!mounted) return false;
      final proceed = await _confirmDuplicate(existingTitle);
      if (proceed != true) return false;
      // Teacher confirmed it's a different book — force it through.
      await api.createBook(
        subject: widget.subjectKey,
        title: title,
        pages: pages,
        coverUrl: coverUrl,
        confirmDuplicate: true,
      );
      return true;
    }
  }

  Future<bool?> _confirmDuplicate(String existingTitle) {
    final l = AppLocalizations.of(context)!;
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: cs.tertiary),
          title: Text(l.solutionsBookDuplicateTitle),
          content: Text(l.solutionsBookDuplicateBody(existingTitle)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.tutorCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.solutionsBookAddAnyway),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEdit ? l.solutionsEditBookTitle : l.solutionsAddBookTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickCover,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 70,
                    height: 92,
                    child: _pickedCover != null
                        ? Image.file(_pickedCover!, fit: BoxFit.cover)
                        : (_existingCoverUrl ?? '').isNotEmpty
                            ? CachedNetworkImage(imageUrl: _existingCoverUrl!, fit: BoxFit.cover)
                            : Container(
                                color: cs.secondaryContainer,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo_rounded, color: cs.onSecondaryContainer, size: 22),
                                    const SizedBox(height: 4),
                                    Text(l.solutionsBookCoverLabel,
                                        style: TextStyle(fontSize: 10, color: cs.onSecondaryContainer)),
                                  ],
                                ),
                              ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l.solutionsBookTitleHint,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _pagesCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l.commonNumberOfPages,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.format_list_numbered_rounded),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isEdit) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.solutionsBookDuplicateHint,
                      style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEdit ? l.commonSave : l.solutionsAddBookAction),
            ),
          ),
        ],
      ),
    );
  }
}
