import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../../ui/widgets/cm_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/auth/auth_controller.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/solutions_api.dart';
import '../../data/solutions_live_mapper.dart';
import '../../domain/solutions_models.dart';
import '../../domain/solution_subjects.dart';
import '../../providers/solutions_flow_provider.dart';
import '../../../solutions/ui/widgets/solution_asset_preview_sheet.dart';
import '../filter/solutions_pages_screen.dart' show SolutionsDrumPicker;
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
    // Cap the height a touch below full-screen so the rounded top + drag
    // handle peek above the sheet — making it obvious it's a draggable sheet
    // and not a full page.
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.9,
    ),
    // A non-transparent, fixed-height container prevents taps on the empty
    // space below the list from falling through to the barrier (which would
    // close the sheet and lose TextField focus).
    builder: (sheetCtx) => _SolutionUploadSheetBody(
      key: const ValueKey('upload_sheet'),
      onSuccess: onSuccess,
    ),
  );
}

class _SolutionUploadSheetBody extends ConsumerStatefulWidget {
  const _SolutionUploadSheetBody({super.key, this.onSuccess});

  final VoidCallback? onSuccess;

  @override
  ConsumerState<_SolutionUploadSheetBody> createState() =>
      _SolutionUploadSheetBodyState();
}

class _SolutionUploadSheetBodyState
    extends ConsumerState<_SolutionUploadSheetBody> {
  bool _submitting = false;

  // Controllers that persist across Riverpod rebuilds.
  // TextFormField(initialValue:) loses focus every rebuild — use controllers instead.
  late final TextEditingController _captionCtrl;
  late FixedExtentScrollController _pageCtrl;
  late FixedExtentScrollController _questionCtrl;

  int _selectedPage = 1;
  int _selectedQuestion = 0; // 0 = All, 1..N

  static const int _maxQuestions = 99;

  int get _pageCount =>
      (ref.read(solutionsFlowProvider).uploadSelectedBook ??
              ref.read(solutionsFlowProvider).selectedBook)
          ?.pageCount ??
      500;

  @override
  void initState() {
    super.initState();
    final s = ref.read(solutionsFlowProvider);
    _captionCtrl = TextEditingController(text: s.uploadCaption);

    _selectedPage = int.tryParse(s.uploadPageNumber.trim()) ?? 1;
    final qStr = s.uploadQuestionNumber.trim();
    _selectedQuestion =
        (qStr == 'all' || qStr.isEmpty) ? 0 : (int.tryParse(qStr) ?? 0);

    _pageCtrl = FixedExtentScrollController(
        initialItem: (_selectedPage - 1).clamp(0, _pageCount - 1));
    _questionCtrl =
        FixedExtentScrollController(initialItem: _selectedQuestion);
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    _pageCtrl.dispose();
    _questionCtrl.dispose();
    super.dispose();
  }

  void _onBookChanged(SolutionBook? book) {
    // When the book changes, re-create the page controller so the picker
    // starts at 1 and respects the new pageCount.
    setState(() {
      _selectedPage = 1;
      _selectedQuestion = 0;
      _pageCtrl.dispose();
      _questionCtrl.dispose();
      _pageCtrl = FixedExtentScrollController(initialItem: 0);
      _questionCtrl = FixedExtentScrollController(initialItem: 0);
    });
  }

  // ── file helpers ──────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty || !mounted) return;
    // Web has no filesystem path — read the bytes so the upload has something
    // to send (web QA #77).
    final assets = <SolutionUploadAsset>[];
    for (final xf in picked) {
      assets.add(
        SolutionUploadAsset(
          id: 'img-${DateTime.now().microsecondsSinceEpoch}-${xf.name}',
          name: xf.name,
          kind: SolutionAssetKind.image,
          filePath: kIsWeb ? null : xf.path,
          bytes: kIsWeb ? await xf.readAsBytes() : null,
        ),
      );
    }
    _addFiles(assets);
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      // Pull bytes on web (no path there); mobile keeps using the path.
      withData: kIsWeb,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    _addFiles(
      result.files
          .where((f) => (f.path ?? '').trim().isNotEmpty || f.bytes != null)
          .map(
            (f) => SolutionUploadAsset(
              id: 'pdf-${DateTime.now().microsecondsSinceEpoch}-${f.name}',
              name: f.name,
              kind: SolutionAssetKind.pdf,
              filePath: f.path,
              bytes: f.bytes,
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
    final page = _selectedPage;
    final question =
        _selectedQuestion == 0 ? 'all' : '$_selectedQuestion';

    // Sync drum values to provider so the questions screen sees them.
    final n = ref.read(solutionsFlowProvider.notifier);
    n.setUploadPageNumber('$page');
    n.setUploadQuestionNumber(question);

    if (subject == null || book == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.solutionsUploadCompleteFields)),
      );
      return;
    }

    // Web assets carry bytes (no path); mobile assets carry a path. Keep
    // either so the upload works on both (web QA #77).
    final assets = state.uploadFiles
        .where((e) => e.bytes != null || (e.filePath ?? '').trim().isNotEmpty)
        .map((e) => (name: e.name, path: e.filePath, bytes: e.bytes))
        .toList(growable: false);

    if (assets.isEmpty) {
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
      files = await api.uploadFilesMultipart(assets);
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
        subject: subject.id,
        bookTitle: book.title,
        pageNumber: page,
        questionNumber: question,
        caption: _captionCtrl.text.trim(),
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
            label: solutionSubjectTitle(l, s.id),
            icon: Icons.menu_book_rounded,
          ),
        )
        .toList(growable: false);

    // Books are admin/teacher-managed — students pick from the existing list
    // only. No "add new book" option here anymore.
    final booksForSubject = uploadSubject?.books ?? const <SolutionBook>[];
    final bookItems = <LiquidGlassDropdownItem<String>>[
      ...booksForSubject.map(
        (b) => LiquidGlassDropdownItem<String>(
          value: b.id,
          label: b.title,
          icon: Icons.auto_stories_rounded,
        ),
      ),
    ];

    Future<void> handleBookChanged(String bookId) async {
      final book = (uploadSubject?.books ?? <SolutionBook>[]).firstWhere(
        (b) => b.id == bookId,
        orElse: () => SolutionBook(
          id: bookId,
          title: bookId,
          subjectId: uploadSubject?.id ?? '',
        ),
      );
      notifier.setUploadSelectedBook(book);
      _onBookChanged(book);
    }

    final fileCount = uploadState.uploadFiles.length;
    final hasFailed = uploadState.uploadFiles.any(
      (e) => e.uploadState == UploadState.failed,
    );

    // Keyboard padding lives here (inside the State) so the stateful widget
    // survives the ModalRoute rebuild that happens when the keyboard opens.
    // Keeping it in the builder lambda meant the builder could remount the
    // widget, destroying the TextEditingController and closing the sheet.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      // Absorb all taps within the sheet so they never reach the barrier.
      behavior: HitTestBehavior.opaque,
      onTap: () {},  // swallow stray taps
      child: Padding(
        padding: EdgeInsetsDirectional.only(
          start: 16, end: 16, top: 8,
          bottom: bottomInset + 20,
        ),
        child: ListView(
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

        // Page + Question drum pickers — side by side.
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(l.solutionsPageNumberLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  SolutionsDrumPicker(
                    controller: _pageCtrl,
                    itemCount: uploadBook?.pageCount ?? 500,
                    looping: true,
                    labelBuilder: (i) => '${i + 1}',
                    onChanged: (i) => setState(() => _selectedPage = i + 1),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('/',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: cs.onSurfaceVariant)),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(l.solutionsQuestionNumberLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  SolutionsDrumPicker(
                    controller: _questionCtrl,
                    itemCount: _maxQuestions + 1,
                    looping: false,
                    labelBuilder: (i) => i == 0 ? 'All' : '$i',
                    onChanged: (i) => setState(() => _selectedQuestion = i),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Caption — uses a persistent controller so focus survives rebuilds.
        TextField(
          controller: _captionCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l.solutionsUploadCaptionOptional,
            prefixIcon: const Icon(Icons.notes_rounded),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
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
              color: cs.errorContainer,
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
              alignment: AlignmentDirectional.centerStart,
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
              ? const CmLoading(size: 18)
              : const Icon(Icons.cloud_upload_outlined),
          label: Text(
            _submitting
                ? l.solutionsUploadSubmittingAction
                : l.solutionsUploadSubmitAction,
          ),
        ),
        const SizedBox(height: 8),
      ],
        ), // ListView
      ), // Padding
    ); // GestureDetector
  }
}
