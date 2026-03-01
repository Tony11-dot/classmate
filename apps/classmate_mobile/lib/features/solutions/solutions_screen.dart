import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'solution_model.dart';
import 'solutions_controller.dart';
import 'solutions_filters.dart';

class SolutionsScreen extends ConsumerStatefulWidget {
  const SolutionsScreen({super.key});

  @override
  ConsumerState<SolutionsScreen> createState() => _SolutionsScreenState();
}

class _SolutionsScreenState extends ConsumerState<SolutionsScreen> {
  bool _showFilters = false;

  void _openComments(BuildContext context, Solution item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          builder: (context, sc) {
            return StatefulBuilder(
              builder: (context, setState) {
                final ctrl = TextEditingController();
                final comments = <String>[];

                void addComment() {
                  final t = ctrl.text.trim();
                  if (t.isEmpty) return;
                  setState(() {
                    comments.insert(0, t);
                    ctrl.clear();
                  });
                }

                return ListView(
                  controller: sc,
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  children: [
                    Text(
                      'Comments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (comments.isEmpty)
                      Text(
                        'No comments yet. Be the first 👇',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                    if (comments.isNotEmpty) ...[
                      for (final c in comments)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              c,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                    ],

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ctrl,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => addComment(),
                            decoration: const InputDecoration(
                              hintText: 'Write a comment…',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton.icon(
                          onPressed: addComment,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Send'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(solutionsControllerProvider);
    final c = ref.read(solutionsControllerProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
          child: Row(
            children: [
              Text(
                'Solutions',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(
                  _showFilters ? Icons.close_rounded : Icons.tune_rounded,
                ),
                label: Text(_showFilters ? 'Close' : 'Filters'),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: _FiltersBar(filters: s.filters, onChanged: c.setFilters),
          crossFadeState: _showFilters
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
        ),
        Expanded(
          child: Stack(
            children: [
              RefreshIndicator(
                onRefresh: c.refresh,
                child: Builder(
                  builder: (context) {
                    if (s.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (s.error != null) {
                      return ListView(
                        children: [
                          const SizedBox(height: 24),
                          Center(child: Text('Error: ${s.error}')),
                          const SizedBox(height: 12),
                          Center(
                            child: FilledButton(
                              onPressed: c.refresh,
                              child: const Text('Retry'),
                            ),
                          ),
                        ],
                      );
                    }

                    if (s.items.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 24),
                          Center(child: Text('No solutions yet')),
                        ],
                      );
                    }

                    return PageView.builder(
                      scrollDirection: Axis.vertical,
                      onPageChanged: (i) {
                        if (i >= s.items.length - 3) {
                          ref
                              .read(solutionsControllerProvider.notifier)
                              .loadMore();
                        }
                      },
                      itemCount: s.items.length + (s.loadingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i >= s.items.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return _FeedPage(
                          item: s.items[i],
                          onLike: () {},
                          onComment: () => _openComments(context, s.items[i]),
                          onRepost: () {},
                          onSave: () {},
                        );
                      },
                    );
                  },
                ),
              ),
              Positioned(
                right: 14,
                bottom: 14,
                child: FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      showDragHandle: true,
                      builder: (context) {
                        return DraggableScrollableSheet(
                          expand: false,
                          initialChildSize: 0.55,
                          minChildSize: 0.25,
                          maxChildSize: 0.92,
                          builder: (context, sc) {
                            return SingleChildScrollView(
                              controller: sc,
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 8,
                                bottom:
                                    16 +
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upload solution',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'TODO: wire upload flow',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 14),
                                  FilledButton.icon(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: const Icon(Icons.upload_rounded),
                                    label: const Text(
                                      'Choose files / write solution',
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeedPage extends StatelessWidget {
  const _FeedPage({
    required this.item,
    required this.onLike,
    required this.onComment,
    required this.onRepost,
    required this.onSave,
  });

  final Solution item;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onRepost;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final sub = item.subject.isEmpty ? '—' : item.subject;
    final meta =
        '${item.sourceType} • ${item.sourceName}'
        '${item.page != null ? ' • p.${item.page}' : ''}'
        '${(item.questionNumber != null && item.questionNumber!.isNotEmpty) ? ' • q.${item.questionNumber}' : ''}';

    final title = (item.title != null && item.title!.trim().isNotEmpty)
        ? item.title!.trim()
        : 'Solution';
    final body = (item.body != null && item.body!.trim().isNotEmpty)
        ? item.body!.trim()
        : '—';
    final created = item.createdAt ?? '';

    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            color: t.colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  child: Row(
                    children: [
                      _Pill(sub),
                      const Spacer(),
                      Text(created, style: t.textTheme.bodySmall),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      meta,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: t.colorScheme.onSurface.withValues(alpha: 0.70),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        body,
                        style: t.textTheme.bodyLarge?.copyWith(height: 1.35),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: onLike,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.favorite_border),
                              if (item.likeCount > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '${item.likeCount}',
                                  style: t.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onComment,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat_bubble_outline),
                              if (item.commentCount > 0) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '${item.commentCount}',
                                  style: t.textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: onRepost,
                        icon: const Icon(Icons.repeat_rounded),
                        tooltip: 'Repost',
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onSave,
                        icon: const Icon(Icons.bookmark_outline),
                        tooltip: 'Save',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: t.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FiltersBar extends StatefulWidget {
  const _FiltersBar({required this.filters, required this.onChanged});
  final SolutionsFilters filters;
  final ValueChanged<SolutionsFilters> onChanged;

  @override
  State<_FiltersBar> createState() => _FiltersBarState();
}

class _FiltersBarState extends State<_FiltersBar> {
  late final TextEditingController _subject;
  late final TextEditingController _sourceType;
  late final TextEditingController _sourceName;
  late final TextEditingController _page;
  late final TextEditingController _q;

  @override
  void initState() {
    super.initState();
    _subject = TextEditingController(text: widget.filters.subject ?? '');
    _sourceType = TextEditingController(text: widget.filters.sourceType ?? '');
    _sourceName = TextEditingController(text: widget.filters.sourceName ?? '');
    _page = TextEditingController(text: widget.filters.page?.toString() ?? '');
    _q = TextEditingController(text: widget.filters.questionNumber ?? '');
  }

  @override
  void dispose() {
    _subject.dispose();
    _sourceType.dispose();
    _sourceName.dispose();
    _page.dispose();
    _q.dispose();
    super.dispose();
  }

  void _emit() {
    final page = int.tryParse(_page.text.trim());
    widget.onChanged(
      SolutionsFilters(
        subject: _subject.text.trim().isEmpty ? null : _subject.text.trim(),
        sourceType: _sourceType.text.trim().isEmpty
            ? null
            : _sourceType.text.trim(),
        sourceName: _sourceName.text.trim().isEmpty
            ? null
            : _sourceName.text.trim(),
        page: page,
        questionNumber: _q.text.trim().isEmpty ? null : _q.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final chipW = (w - 16 * 2 - 10 * 2) / 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Column(
        children: [
          Row(
            children: [
              _ChipField(
                hint: 'Subject',
                controller: _subject,
                width: chipW,
                onChanged: (_) => _emit(),
              ),
              const SizedBox(width: 10),
              _ChipField(
                hint: 'Type',
                controller: _sourceType,
                width: chipW,
                onChanged: (_) => _emit(),
              ),
              const SizedBox(width: 10),
              _ChipField(
                hint: 'Name',
                controller: _sourceName,
                width: chipW,
                onChanged: (_) => _emit(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ChipField(
                hint: 'Page',
                controller: _page,
                width: chipW,
                keyboard: TextInputType.number,
                onChanged: (_) => _emit(),
              ),
              const SizedBox(width: 10),
              _ChipField(
                hint: 'Q#',
                controller: _q,
                width: chipW,
                onChanged: (_) => _emit(),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  _subject.clear();
                  _sourceType.clear();
                  _sourceName.clear();
                  _page.clear();
                  _q.clear();
                  widget.onChanged(const SolutionsFilters());
                },
                icon: const Icon(Icons.clear),
                tooltip: 'Clear filters',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipField extends StatelessWidget {
  const _ChipField({
    required this.hint,
    required this.controller,
    required this.width,
    required this.onChanged,
    this.keyboard,
  });

  final String hint;
  final TextEditingController controller;
  final double width;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: t.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: keyboard,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}
