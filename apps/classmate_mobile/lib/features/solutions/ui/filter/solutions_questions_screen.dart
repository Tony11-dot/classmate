import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/solutions_api.dart';
import '../../data/solutions_live_mapper.dart';
import '../../domain/solutions_models.dart';
import '../../providers/solutions_flow_provider.dart';

final liveExactSolutionsPageProvider =
    FutureProvider.family<LiveSolutionsPage, int>((ref, page) async {
      final state = ref.watch(solutionsFlowProvider);
      final api = ref.watch(solutionsApiProvider);

      final subject = state.selectedSubject?.title;
      final bookTitle = state.selectedBook?.title;
      final pageNumber = int.tryParse(state.pageNumber.trim());
      final questionNumber = state.questionNumber.trim();

      if ((subject ?? '').trim().isEmpty ||
          (bookTitle ?? '').trim().isEmpty ||
          pageNumber == null ||
          questionNumber.isEmpty) {
        return const LiveSolutionsPage(
          items: <QuestionSolutionCard>[],
          hasMore: false,
          page: 1,
        );
      }

      final raw = await api.fetchSolutions(
        subject: subject,
        bookTitle: bookTitle,
        pageNumber: pageNumber,
        questionNumber: questionNumber,
        page: page,
        limit: 10,
      );

      return SolutionsLiveMapper.mapPage(raw);
    });

final liveSamePageSolutionsPageProvider =
    FutureProvider.family<LiveSolutionsPage, int>((ref, page) async {
      final state = ref.watch(solutionsFlowProvider);
      final api = ref.watch(solutionsApiProvider);

      final subject = state.selectedSubject?.title;
      final bookTitle = state.selectedBook?.title;
      final pageNumber = int.tryParse(state.pageNumber.trim());

      if ((subject ?? '').trim().isEmpty ||
          (bookTitle ?? '').trim().isEmpty ||
          pageNumber == null) {
        return const LiveSolutionsPage(
          items: <QuestionSolutionCard>[],
          hasMore: false,
          page: 1,
        );
      }

      final raw = await api.fetchSolutions(
        subject: subject,
        bookTitle: bookTitle,
        pageNumber: pageNumber,
        page: page,
        limit: 10,
      );

      final mapped = SolutionsLiveMapper.mapPage(raw);
      final filtered = mapped.items
          .where((e) => e.questionNumber != state.questionNumber.trim())
          .toList(growable: false);

      return LiveSolutionsPage(
        items: filtered,
        hasMore: mapped.hasMore,
        page: mapped.page,
      );
    });

class SolutionsQuestionsScreen extends ConsumerStatefulWidget {
  const SolutionsQuestionsScreen({super.key});

  @override
  ConsumerState<SolutionsQuestionsScreen> createState() =>
      _SolutionsQuestionsScreenState();
}

class _SolutionsQuestionsScreenState
    extends ConsumerState<SolutionsQuestionsScreen> {
  int _exactPage = 1;
  int _samePagePage = 1;

  final List<QuestionSolutionCard> _exactItems = <QuestionSolutionCard>[];
  final List<QuestionSolutionCard> _samePageItems = <QuestionSolutionCard>[];

  void _resetAndRefresh() {
    setState(() {
      _exactPage = 1;
      _samePagePage = 1;
      _exactItems.clear();
      _samePageItems.clear();
    });
    ref.invalidate(liveExactSolutionsPageProvider(1));
    ref.invalidate(liveSamePageSolutionsPageProvider(1));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isEmpty || !mounted) return;

    final current = List<SolutionUploadAsset>.from(
      ref.read(solutionsFlowProvider).uploadFiles,
    );

    current.addAll(
      picked.map(
        (file) => SolutionUploadAsset(
          id: 'img-${DateTime.now().microsecondsSinceEpoch}-${file.name}',
          name: file.name,
          kind: SolutionAssetKind.image,
          filePath: file.path,
        ),
      ),
    );

    ref.read(solutionsFlowProvider.notifier).setUploadFiles(current);
  }

  Future<void> _pickPdf() async {
    final picked = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );

    if (picked == null || picked.files.isEmpty || !mounted) return;

    final current = List<SolutionUploadAsset>.from(
      ref.read(solutionsFlowProvider).uploadFiles,
    );

    current.addAll(
      picked.files
          .where((f) => (f.path ?? '').trim().isNotEmpty)
          .map(
            (file) => SolutionUploadAsset(
              id: 'pdf-${DateTime.now().microsecondsSinceEpoch}-${file.name}',
              name: file.name,
              kind: SolutionAssetKind.pdf,
              filePath: file.path,
            ),
          ),
    );

    ref.read(solutionsFlowProvider.notifier).setUploadFiles(current);
  }

  Future<void> _submitUpload(BuildContext context) async {
    final state = ref.read(solutionsFlowProvider);
    final api = ref.read(solutionsApiProvider);

    final subject = state.uploadSelectedSubject ?? state.selectedSubject;
    final book = state.uploadSelectedBook ?? state.selectedBook;
    final page = int.tryParse(state.uploadPageNumber.trim());
    final question = state.uploadQuestionNumber.trim();

    if (subject == null || book == null || page == null || question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete subject, book, page, and question'),
        ),
      );
      return;
    }

    final filePaths = state.uploadFiles
        .map((e) => e.filePath)
        .whereType<String>()
        .toList(growable: false);

    if (filePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one image or PDF')),
      );
      return;
    }

    final files = await api.uploadFilesMultipart(filePaths);

    final raw = await api.createSolution(
      subject: subject.title,
      bookTitle: book.title,
      pageNumber: page,
      questionNumber: question,
      caption: state.uploadCaption.trim(),
      uploaderName: 'You',
      uploaderInitials: 'YO',
      files: files,
    );

    final uploadRaw = raw['upload'];
    if (uploadRaw is Map) {
      final mapped = SolutionsLiveMapper.mapUpload(
        uploadRaw.map((k, v) => MapEntry(k.toString(), v)),
      );
      ref.read(solutionsFlowProvider.notifier).addUploadLocally(mapped);
    }

    ref.invalidate(liveExactSolutionsPageProvider(1));
    ref.invalidate(liveSamePageSolutionsPageProvider(1));

    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Solution uploaded')));

    _resetAndRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(solutionsFlowProvider);
    final exactAsync = ref.watch(liveExactSolutionsPageProvider(_exactPage));
    final samePageAsync = ref.watch(
      liveSamePageSolutionsPageProvider(_samePagePage),
    );
    final cs = Theme.of(context).colorScheme;
    final exactPage = exactAsync.maybeWhen(data: (v) => v, orElse: () => null);
    final samePagePage = samePageAsync.maybeWhen(
      data: (v) => v,
      orElse: () => null,
    );

    ref.listen<AsyncValue<LiveSolutionsPage>>(
      liveExactSolutionsPageProvider(_exactPage),
      (_, next) {
        next.whenData((page) {
          if (!mounted) return;
          setState(() {
            if (_exactPage == 1) {
              _exactItems
                ..clear()
                ..addAll(page.items);
            } else {
              final ids = _exactItems.map((e) => e.id).toSet();
              _exactItems.addAll(page.items.where((e) => !ids.contains(e.id)));
            }
          });
        });
      },
    );

    ref.listen<AsyncValue<LiveSolutionsPage>>(
      liveSamePageSolutionsPageProvider(_samePagePage),
      (_, next) {
        next.whenData((page) {
          if (!mounted) return;
          setState(() {
            if (_samePagePage == 1) {
              _samePageItems
                ..clear()
                ..addAll(page.items);
            } else {
              final ids = _samePageItems.map((e) => e.id).toSet();
              _samePageItems.addAll(
                page.items.where((e) => !ids.contains(e.id)),
              );
            }
          });
        });
      },
    );

    Future<void> openUploadSheet() async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Consumer(
              builder: (context, ref, child) {
                final uploadState = ref.watch(solutionsFlowProvider);
                final uploadSubject =
                    uploadState.uploadSelectedSubject ??
                    uploadState.selectedSubject;
                final uploadBook =
                    uploadState.uploadSelectedBook ?? uploadState.selectedBook;

                return ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      'Upload a solution',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Upload real images/PDFs. Moderation and NOVA verification come next.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SolutionSubject>(
                      initialValue: uploadSubject,
                      items: uploadState.subjects
                          .map(
                            (subject) => DropdownMenuItem<SolutionSubject>(
                              value: subject,
                              child: Text(subject.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(solutionsFlowProvider.notifier)
                              .setUploadSelectedSubject(value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Subject'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<SolutionBook>(
                      initialValue: uploadBook,
                      items: (uploadSubject?.books ?? const <SolutionBook>[])
                          .map(
                            (book) => DropdownMenuItem<SolutionBook>(
                              value: book,
                              child: Text(book.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref
                              .read(solutionsFlowProvider.notifier)
                              .setUploadSelectedBook(value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Book'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: uploadState.uploadPageNumber.isEmpty
                          ? state.pageNumber
                          : uploadState.uploadPageNumber,
                      onChanged: ref
                          .read(solutionsFlowProvider.notifier)
                          .setUploadPageNumber,
                      decoration: const InputDecoration(
                        labelText: 'Page number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: uploadState.uploadQuestionNumber.isEmpty
                          ? state.questionNumber
                          : uploadState.uploadQuestionNumber,
                      onChanged: ref
                          .read(solutionsFlowProvider.notifier)
                          .setUploadQuestionNumber,
                      decoration: const InputDecoration(
                        labelText: 'Question number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: uploadState.uploadCaption,
                      onChanged: ref
                          .read(solutionsFlowProvider.notifier)
                          .setUploadCaption,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Caption'),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_outlined),
                          label: const Text('Pick images'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _pickPdf,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Pick PDF'),
                        ),
                      ],
                    ),
                    if (uploadState.uploadFiles.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: uploadState.uploadFiles
                            .map(
                              (file) => InputChip(
                                label: Text(file.name),
                                avatar: Icon(
                                  file.kind == SolutionAssetKind.pdf
                                      ? Icons.picture_as_pdf_outlined
                                      : Icons.photo_outlined,
                                ),
                                onDeleted: () => ref
                                    .read(solutionsFlowProvider.notifier)
                                    .removeUploadAsset(file.id),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () => _submitUpload(context),
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text('Upload solution'),
                    ),
                  ],
                );
              },
            ),
          );
        },
      );
    }

    final exactHasMore = exactPage?.hasMore ?? false;
    final samePageHasMore = samePagePage?.hasMore ?? false;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: openUploadSheet,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Upload'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Text(
              '${state.selectedSubject?.title ?? 'Subject'} • ${state.selectedBook?.title ?? 'Book'}',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              'Page ${state.pageNumber.isEmpty ? '—' : state.pageNumber} • Question ${state.questionNumber.isEmpty ? '—' : state.questionNumber}',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            _SectionTitle(
              title: 'Solutions for this exact question',
              subtitle: _exactItems.isEmpty
                  ? 'Nothing has been uploaded for this exact question yet. Be the first to help your classmates.'
                  : '${_exactItems.length} upload${_exactItems.length == 1 ? '' : 's'} found',
            ),
            const SizedBox(height: 10),
            if (exactAsync.isLoading && _exactItems.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_exactItems.isEmpty)
              const _EmptyCard(
                text:
                    'No exact match yet. You can upload one now, or check what classmates solved on this same page.',
              )
            else ...[
              ..._exactItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SolutionCard(item: item),
                ),
              ),
              if (exactHasMore)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _exactPage += 1),
                    icon: const Icon(Icons.expand_more_rounded),
                    label: const Text('Load more'),
                  ),
                ),
            ],
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'Other questions solved on this page',
              subtitle: _samePageItems.isEmpty
                  ? 'No neighboring questions were uploaded from this page yet.'
                  : 'Useful fallback when your exact question has no upload yet.',
            ),
            const SizedBox(height: 10),
            if (samePageAsync.isLoading && _samePageItems.isEmpty)
              const Center(child: CircularProgressIndicator())
            else if (_samePageItems.isEmpty)
              const _EmptyCard(
                text:
                    'No nearby uploads on this page yet. A fresh upload here would really help.',
              )
            else ...[
              ..._samePageItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SolutionCard(item: item),
                ),
              ),
              if (samePageHasMore)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _samePagePage += 1),
                    icon: const Icon(Icons.expand_more_rounded),
                    label: const Text('Load more'),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: cs.onSurfaceVariant)),
    );
  }
}

class _SolutionCard extends StatelessWidget {
  const _SolutionCard({required this.item});

  final QuestionSolutionCard item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(item.uploaderInitials)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.uploaderName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Page ${item.pageNumber} • Question ${item.questionNumber}',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (item.verifiedByNova)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Verified by NOVA'),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(item.caption),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.assets
                .map(
                  (asset) => ActionChip(
                    label: Text(asset.name),
                    avatar: Icon(
                      asset.kind == SolutionAssetKind.pdf
                          ? Icons.picture_as_pdf_outlined
                          : Icons.photo_outlined,
                      size: 18,
                    ),
                    onPressed: () {},
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
