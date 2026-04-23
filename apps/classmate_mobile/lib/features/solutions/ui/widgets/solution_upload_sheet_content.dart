import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/solutions_api.dart';
import '../../data/solutions_live_mapper.dart';
import '../../domain/solutions_models.dart';
import '../../providers/solutions_flow_provider.dart';
import '../../../solutions/ui/widgets/solution_asset_preview_sheet.dart';
import '../../../../ui/widgets/liquid_glass_dropdown.dart';

/// Shows the upload bottom sheet.  Call from any screen via
/// [showSolutionUploadSheet].  Pass [initialPageNumber] /
/// [initialQuestionNumber] when the caller already knows the context.
Future<void> showSolutionUploadSheet(
  BuildContext context, {
  String initialPageNumber = '',
  String initialQuestionNumber = '',
  VoidCallback? onSuccess,
}) {
  final ref = ProviderScope.containerOf(context);
  final notifier = ref.read(solutionsFlowProvider.notifier);

  if (initialPageNumber.isNotEmpty) {
    notifier.setUploadPageNumber(initialPageNumber);
  }
  if (initialQuestionNumber.isNotEmpty) {
    notifier.setUploadQuestionNumber(initialQuestionNumber);
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetCtx) => Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
      ),
      child: _SolutionUploadSheetBody(onSuccess: onSuccess),
    ),
  );
}

class _SolutionUploadSheetBody extends ConsumerStatefulWidget {
  const _SolutionUploadSheetBody({this.onSuccess});

  final VoidCallback? onSuccess;

  @override
  ConsumerState<_SolutionUploadSheetBody> createState() =>
      _SolutionUploadSheetBodyState();
}

class _SolutionUploadSheetBodyState
    extends ConsumerState<_SolutionUploadSheetBody> {
  bool _submitting = false;

  // ── file helpers ──────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty || !mounted) return;
    _addFiles(
      picked.map(
        (xf) => SolutionUploadAsset(
          id: 'img-${DateTime.now().microsecondsSinceEpoch}-${xf.name}',
          name: xf.name,
          kind: SolutionAssetKind.image,
          filePath: xf.path,
        ),
      ),
    );
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    _addFiles(
      result.files
          .where((f) => (f.path ?? '').trim().isNotEmpty)
          .map(
            (f) => SolutionUploadAsset(
              id: 'pdf-${DateTime.now().microsecondsSinceEpoch}-${f.name}',
              name: f.name,
              kind: SolutionAssetKind.pdf,
              filePath: f.path,
            ),
          ),
    );
  }

  void _addFiles(Iterable<SolutionUploadAsset> incoming) {
    final l = AppLocalizations.of(context)!;
    final current =
        List<SolutionUploadAsset>.from(ref.read(solutionsFlowProvider).uploadFiles);
    final remaining = 10 - current.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.solutionsUploadFileLimitReached)),
      );
      return;
    }
    final toAdd = incoming.take(remaining).toList();
    if (toAdd.length < incoming.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.solutionsUploadFilesAddedLimit(toAdd.length))),
      );
    }
    current.addAll(toAdd);
    ref.read(solutionsFlowProvider.notifier).setUploadFiles(current);
  }

  void _markUploadState(String id, UploadState next) {
    final items = ref
        .read(solutionsFlowProvider)
        .uploadFiles
        .map(
          (e) => e.id == id
              ? SolutionUploadAsset(
                  id: e.id,
                  name: e.name,
                  kind: e.kind,
                  filePath: e.filePath,
                  remoteUrl: e.remoteUrl,
                  uploadState: next,
                )
              : e,
        )
        .toList(growable: false);
    ref.read(solutionsFlowProvider.notifier).setUploadFiles(items);
  }

  Future<void> _retryFailed() async {
    final repaired = ref
        .read(solutionsFlowProvider)
        .uploadFiles
        .map(
          (e) => e.uploadState == UploadState.failed
              ? SolutionUploadAsset(
                  id: e.id,
                  name: e.name,
                  kind: e.kind,
                  filePath: e.filePath,
                  remoteUrl: e.remoteUrl,
                  uploadState: UploadState.queued,
                )
              : e,
        )
        .toList(growable: false);
    ref.read(solutionsFlowProvider.notifier).setUploadFiles(repaired);
  }

  // ── submit ────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_submitting) return;
    final l = AppLocalizations.of(context)!;
    final state = ref.read(solutionsFlowProvider);
    final api = ref.read(solutionsApiProvider);
    final session = ref.read(authSessionProvider);

    final subject = state.uploadSelectedSubject ?? state.selectedSubject;
    final book = state.uploadSelectedBook ?? state.selectedBook;
    final page = int.tryParse(state.uploadPageNumber.trim());
    final question = state.uploadQuestionNumber.trim();

    if (subject == null || book == null || page == null || question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.solutionsUploadCompleteFields)),
      );
      return;
    }

    final filePaths = state.uploadFiles
        .map((e) => e.filePath)
        .whereType<String>()
        .toList(growable: false);

    if (filePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.solutionsUploadAddOneFile)),
      );
      return;
    }

    setState(() => _submitting = true);

    // Mark all as uploading.
    for (final f in state.uploadFiles) {
      _markUploadState(f.id, UploadState.uploading);
    }

    List<Map<String, dynamic>> files;
    try {
      files = await api.uploadFilesMultipart(filePaths);
      final uploaded = ref
          .read(solutionsFlowProvider)
          .uploadFiles
          .map(
            (e) => SolutionUploadAsset(
              id: e.id,
              name: e.name,
              kind: e.kind,
              filePath: e.filePath,
              remoteUrl: e.remoteUrl,
              uploadState: UploadState.uploaded,
            ),
          )
          .toList(growable: false);
      ref.read(solutionsFlowProvider.notifier).setUploadFiles(uploaded);
    } catch (e) {
      final failed = ref
          .read(solutionsFlowProvider)
          .uploadFiles
          .map(
            (e2) => SolutionUploadAsset(
              id: e2.id,
              name: e2.name,
              kind: e2.kind,
              filePath: e2.filePath,
              remoteUrl: e2.remoteUrl,
              uploadState: UploadState.failed,
            ),
          )
          .toList(growable: false);
      ref.read(solutionsFlowProvider.notifier).setUploadFiles(failed);
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.solutionsUploadFileFailed('$e'))),
        );
      }
      return;
    }

    final displayName = session.displayName.trim();
    final nameParts = displayName.split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : 'ME';

    try {
      final raw = await api.createSolution(
        subject: subject.title,
        bookTitle: book.title,
        pageNumber: page,
        questionNumber: question,
        caption: state.uploadCaption.trim(),
        uploaderName: displayName.isNotEmpty ? displayName : 'Student',
        uploaderInitials: initials,
        files: files,
      );

      final uploadRaw = raw['upload'];
      if (uploadRaw is Map) {
        final mapped = SolutionsLiveMapper.mapUpload(
          uploadRaw.map((k, v) => MapEntry(k.toString(), v)),
        );
        ref.read(solutionsFlowProvider.notifier).addUploadLocally(mapped);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.solutionsUploadCreateFailed('$e'))),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.solutionsUploadSuccess)),
    );
    widget.onSuccess?.call();
  }

  // ── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final uploadState = ref.watch(solutionsFlowProvider);
    final notifier = ref.read(solutionsFlowProvider.notifier);

    final uploadSubject =
        uploadState.uploadSelectedSubject ?? uploadState.selectedSubject;
    final uploadBook =
        uploadState.uploadSelectedBook ?? uploadState.selectedBook;

    final subjectItems = uploadState.subjects
        .map(
          (s) => LiquidGlassDropdownItem<String>(
            value: s.id,
            label: s.title,
            icon: Icons.menu_book_rounded,
          ),
        )
        .toList(growable: false);

    final booksForSubject = uploadSubject?.books ?? const <SolutionBook>[];
    final bookItems = <LiquidGlassDropdownItem<String>>[
      ...booksForSubject.map(
        (b) => LiquidGlassDropdownItem<String>(
          value: b.id,
          label: b.title,
          icon: Icons.auto_stories_rounded,
        ),
      ),
      LiquidGlassDropdownItem<String>(
        value: '__add_new_book__',
        label: l.solutionsUploadAddNewBookOption,
        icon: Icons.add_rounded,
      ),
    ];

    Future<void> handleBookChanged(String bookId) async {
      if (bookId == '__add_new_book__') {
        String newTitle = '';
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: Text(l.solutionsAddBookTitle),
            content: TextField(
              autofocus: true,
              onChanged: (v) => newTitle = v,
              decoration: InputDecoration(
                hintText: l.solutionsBookTitleHint,
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx, false),
                child: Text(l.tutorCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogCtx, true),
                child: Text(l.solutionsUploadAddBookShortAction),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        final subjectId = uploadSubject?.id;
        if (subjectId == null) return;
        notifier.addBook(subjectId, newTitle);
        final updatedBooks = ref
            .read(solutionsFlowProvider)
            .subjects
            .firstWhere((s) => s.id == subjectId, orElse: () => uploadSubject!)
            .books;
        final newBook = updatedBooks.lastWhere(
          (b) => b.title.trim().toLowerCase() == newTitle.trim().toLowerCase(),
          orElse: () => updatedBooks.last,
        );
        notifier.setUploadSelectedBook(newBook);
        return;
      }
      final book = (uploadSubject?.books ?? <SolutionBook>[]).firstWhere(
        (b) => b.id == bookId,
        orElse: () => SolutionBook(
          id: bookId,
          title: bookId,
          subjectId: uploadSubject?.id ?? '',
        ),
      );
      notifier.setUploadSelectedBook(book);
    }

    final fileCount = uploadState.uploadFiles.length;
    final hasFailed = uploadState.uploadFiles.any(
      (e) => e.uploadState == UploadState.failed,
    );

    return ListView(
      shrinkWrap: true,
      children: [
        Text(
          l.solutionsUploadTitle,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 6),
        Text(
          l.solutionsUploadSubtitle,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 16),

        // Subject picker.
        LiquidGlassDropdown<String>(
          label: l.assignmentsSubjectLabel,
          value: uploadSubject?.id ?? '',
          items: subjectItems.isEmpty
              ? [
                  LiquidGlassDropdownItem<String>(
                    value: '',
                    label: l.solutionsNoSubjectsAvailable,
                  ),
                ]
              : subjectItems,
          searchHint: l.assignmentsSearchSubjects,
          onChanged: (subjectId) {
            final subject = uploadState.subjects.firstWhere(
              (s) => s.id == subjectId,
              orElse: () => uploadState.subjects.first,
            );
            notifier.setUploadSelectedSubject(subject);
          },
        ),
        const SizedBox(height: 12),

        // Book picker.
        LiquidGlassDropdown<String>(
          label: l.solutionsBookLabel,
          value: uploadBook?.id ?? '',
          items: bookItems.isEmpty
              ? [
                  LiquidGlassDropdownItem<String>(
                    value: '',
                    label: l.solutionsUploadNoBooksAbove,
                  ),
                ]
              : bookItems,
          searchHint: l.solutionsSearchBooks,
          onChanged: handleBookChanged,
        ),
        const SizedBox(height: 12),

        // Page number.
        TextFormField(
          initialValue: uploadState.uploadPageNumber,
          keyboardType: TextInputType.number,
          onChanged: notifier.setUploadPageNumber,
          decoration: InputDecoration(
            labelText: l.solutionsPageNumberLabel,
            prefixIcon: const Icon(Icons.menu_outlined),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Question number.
        TextFormField(
          initialValue: uploadState.uploadQuestionNumber,
          onChanged: notifier.setUploadQuestionNumber,
          decoration: InputDecoration(
            labelText: l.solutionsQuestionNumberLabel,
            prefixIcon: const Icon(Icons.help_outline_rounded),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Caption.
        TextFormField(
          initialValue: uploadState.uploadCaption,
          onChanged: notifier.setUploadCaption,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l.solutionsUploadCaptionOptional,
            prefixIcon: const Icon(Icons.notes_rounded),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // File picker row.
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: fileCount >= 10 ? null : _pickImage,
                icon: const Icon(Icons.photo_outlined),
                label: Text(l.solutionsUploadImagesAction),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: fileCount >= 10 ? null : _pickPdf,
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(l.solutionsUploadPdfAction),
              ),
            ),
          ],
        ),

        if (fileCount > 0) ...[
          const SizedBox(height: 8),
          Text(
            l.solutionsUploadFileCount(fileCount),
            style: TextStyle(
              color: fileCount >= 10 ? cs.error : cs.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        if (hasFailed) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded),
                const SizedBox(width: 10),
                Expanded(child: Text(l.solutionsUploadSomeFilesFailed)),
              ],
            ),
          ),
        ],

        if (uploadState.uploadFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: uploadState.uploadFiles
                .map(
                  (file) => InputChip(
                    label: Text(file.name, overflow: TextOverflow.ellipsis),
                    avatar: Icon(
                      file.kind == SolutionAssetKind.pdf
                          ? Icons.picture_as_pdf_outlined
                          : Icons.photo_outlined,
                    ),
                    onPressed: () => openSolutionGallery(
                        context,
                        assets: uploadState.uploadFiles,
                        initialIndex: uploadState.uploadFiles.indexOf(file),
                      ),
                    onDeleted: () => notifier.removeUploadAsset(file.id),
                  ),
                )
                .toList(),
          ),
          if (hasFailed) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _retryFailed,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l.solutionsUploadRetryFailedFiles),
              ),
            ),
          ],
        ],

        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(
            _submitting
                ? l.solutionsUploadSubmittingAction
                : l.solutionsUploadSubmitAction,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
