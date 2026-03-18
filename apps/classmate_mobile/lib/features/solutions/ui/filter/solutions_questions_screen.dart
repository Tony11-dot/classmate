import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/solutions_models.dart';
import '../../providers/solutions_flow_provider.dart';

class SolutionsQuestionsScreen extends ConsumerWidget {
  const SolutionsQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(solutionsFlowProvider);
    final notifier = ref.read(solutionsFlowProvider.notifier);
    final exact = notifier.currentQuestionSolutions();
    final samePage = notifier.samePageSolutions();
    final cs = Theme.of(context).colorScheme;

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
              builder: (context, ref, _) {
                final uploadState = ref.watch(solutionsFlowProvider);
                final uploadNotifier = ref.read(solutionsFlowProvider.notifier);
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
                      'NOVA can mark strong solutions as verified. Inappropriate media should be moderated server-side later.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<SolutionSubject>(
                      initialValue: uploadSubject,
                      items: uploadState.subjects
                          .map(
                            (subject) => DropdownMenuItem<SolutionSubject>(
                              initialValue: subject,
                              child: Text(subject.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          uploadNotifier.setUploadSelectedSubject(value);
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
                              initialValue: book,
                              child: Text(book.title),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          uploadNotifier.setUploadSelectedBook(value);
                        }
                      },
                      decoration: const InputDecoration(labelText: 'Book'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: uploadState.uploadPageNumber.isEmpty
                          ? state.pageNumber
                          : uploadState.uploadPageNumber,
                      onChanged: uploadNotifier.setUploadPageNumber,
                      decoration: const InputDecoration(
                        labelText: 'Page number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: uploadState.uploadQuestionNumber.isEmpty
                          ? state.questionNumber
                          : uploadState.uploadQuestionNumber,
                      onChanged: uploadNotifier.setUploadQuestionNumber,
                      decoration: const InputDecoration(
                        labelText: 'Question number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: uploadState.uploadCaption,
                      onChanged: uploadNotifier.setUploadCaption,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Caption'),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: uploadNotifier.addMockImageUpload,
                          icon: const Icon(Icons.photo_outlined),
                          label: const Text('Add photo'),
                        ),
                        OutlinedButton.icon(
                          onPressed: uploadNotifier.addMockPdfUpload,
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Add PDF'),
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
                                onDeleted: () =>
                                    uploadNotifier.removeUploadAsset(file.id),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        uploadNotifier.addUpload();
                        Navigator.of(context).pop();
                      },
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
              subtitle: exact.isEmpty
                  ? 'Nothing has been uploaded for this exact question yet. Be the first to help your classmates.'
                  : '${exact.length} upload${exact.length == 1 ? '' : 's'} found',
            ),
            const SizedBox(height: 10),
            if (exact.isEmpty)
              _EmptyCard(
                text:
                    'No exact match yet. You can upload one now, or check what classmates solved on this same page.',
              )
            else
              ...exact.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SolutionCard(item: item),
                ),
              ),
            const SizedBox(height: 20),
            _SectionTitle(
              title: 'Other questions solved on this page',
              subtitle: samePage.isEmpty
                  ? 'No neighboring questions were uploaded from this page yet.'
                  : 'Useful fallback when your exact question has no upload yet.',
            ),
            const SizedBox(height: 10),
            if (samePage.isEmpty)
              _EmptyCard(
                text:
                    'No nearby uploads on this page yet. A fresh upload here would really help.',
              )
            else
              ...samePage.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SolutionCard(item: item),
                ),
              ),
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
                  (asset) => Chip(
                    label: Text(asset.name),
                    avatar: Icon(
                      asset.kind == SolutionAssetKind.pdf
                          ? Icons.picture_as_pdf_outlined
                          : Icons.photo_outlined,
                      size: 18,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
