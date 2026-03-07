import 'dart:async';
import '../../core/auth/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'solutions_controller.dart';
import 'solutions_filters.dart';
import 'solution_model.dart';

class SolutionsScreen extends ConsumerStatefulWidget {
  const SolutionsScreen({super.key});

  @override
  ConsumerState<SolutionsScreen> createState() => _SolutionsScreenState();
}

bool _isStaffToken(String token) {
  final t = token.trim().toLowerCase();
  return t == 'dev-token-admin@classmate.local' || t == 'admin@classmate.local';
}

class _SolutionsScreenState extends ConsumerState<SolutionsScreen> {
  final _scroll = ScrollController();
  final _pageCtl = PageController();
  bool _filtersOpen = false;

  Future<void> _openSolutionComposer(
    BuildContext context, {
    Solution? repostFrom,
  }) async {
    final subjectCtl = TextEditingController(text: repostFrom?.subject ?? '');
    final sourceTypeCtl = TextEditingController(
      text: repostFrom?.sourceType.isNotEmpty == true
          ? repostFrom!.sourceType
          : 'other',
    );
    final sourceNameCtl = TextEditingController(
      text: repostFrom?.sourceName ?? '',
    );
    final pageCtl = TextEditingController(
      text: repostFrom?.page?.toString() ?? '',
    );
    final qCtl = TextEditingController(text: repostFrom?.questionNumber ?? '');
    final titleCtl = TextEditingController(text: repostFrom?.title ?? '');
    final bodyCtl = TextEditingController();
    final notesCtl = TextEditingController(
      text: repostFrom == null
          ? ''
          : 'Repost / alternate solution for ${repostFrom.sourceName}'
                '${repostFrom.page != null ? " p.${repostFrom.page}" : ""}'
                '${(repostFrom.questionNumber ?? "").trim().isNotEmpty ? " q.${repostFrom.questionNumber}" : ""}',
    );

    final c = ref.read(solutionsControllerProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    bool submitting = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            Future<void> submit() async {
              if (submitting) return;

              final subject = subjectCtl.text.trim();
              final sourceType = sourceTypeCtl.text.trim();
              final sourceName = sourceNameCtl.text.trim();
              final page = int.tryParse(pageCtl.text.trim());
              final qn = qCtl.text.trim();
              final title = titleCtl.text.trim();
              final body = bodyCtl.text.trim();
              final notes = notesCtl.text.trim();

              if (subject.isEmpty || sourceType.isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Subject and source type are required'),
                  ),
                );
                return;
              }

              setSheetState(() => submitting = true);

              try {
                await c.createSolutionWithImages(
                  subject: subject,
                  sourceType: sourceType,
                  sourceName: sourceName.isEmpty ? null : sourceName,
                  page: page,
                  questionNumber: qn.isEmpty ? null : qn,
                  title: title.isEmpty ? null : title,
                  notes: notes.isEmpty ? null : notes,
                  body: body.isEmpty ? null : body,
                  imagePaths: const <String>[],
                );
                if (nav.canPop()) nav.pop();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      repostFrom == null
                          ? 'Solution created'
                          : 'Reposted as a new solution',
                    ),
                  ),
                );
              } catch (e) {
                setSheetState(() => submitting = false);
                messenger.showSnackBar(
                  SnackBar(content: Text('Create failed: $e')),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 16 + MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repostFrom == null
                          ? 'Create solution'
                          : 'Post alternate solution',
                      style: Theme.of(sheetContext).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      repostFrom == null
                          ? 'Share a clear, useful solution for other students.'
                          : 'Create a cleaner or better version of this solution.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectCtl,
                      decoration: const InputDecoration(labelText: 'Subject *'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sourceTypeCtl,
                      decoration: const InputDecoration(
                        labelText: 'Source type *',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: sourceNameCtl,
                      decoration: const InputDecoration(
                        labelText: 'Book / source name',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: pageCtl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Page',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: qCtl,
                            decoration: const InputDecoration(
                              labelText: 'Question #',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: titleCtl,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: notesCtl,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: bodyCtl,
                      minLines: 5,
                      maxLines: 9,
                      decoration: const InputDecoration(
                        labelText: 'Your explanation / answer',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: submitting ? null : submit,
                        icon: submitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                repostFrom == null
                                    ? Icons.upload_rounded
                                    : Icons.repeat_rounded,
                              ),
                        label: Text(
                          submitting
                              ? 'Saving...'
                              : (repostFrom == null
                                    ? 'Create solution'
                                    : 'Post repost'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final pos = _scroll.position;
      if (pos.pixels >= pos.maxScrollExtent - 400) {
        ref.read(solutionsControllerProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _pageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(solutionsControllerProvider);
    final c = ref.read(solutionsControllerProvider.notifier);
    final session = ref.watch(authSessionProvider);
    final token = (session.token ?? '').trim();
    final canCreate = _isStaffToken(token);

    return Scaffold(
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () async {
                await _openSolutionComposer(context);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Upload'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Solutions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                if (s.filters.isActive)
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Active',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                FilledButton.tonalIcon(
                  onPressed: () {
                    setState(() => _filtersOpen = !_filtersOpen);
                  },
                  icon: Icon(
                    _filtersOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.tune_rounded,
                  ),
                  label: Text(_filtersOpen ? 'Hide filters' : 'Show filters'),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _FiltersBar(
              filters: s.filters,
              onChanged: c.setFilters,
            ),
            crossFadeState: _filtersOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 160),
          ),
          Expanded(
            child: RefreshIndicator(
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
                      padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                      children: [
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.filters.isActive
                              ? 'No solutions match these filters'
                              : 'No solutions yet',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.filters.isActive
                              ? 'Try clearing one or two filters and check again.'
                              : (canCreate
                                    ? 'Upload the first solution for your school.'
                                    : 'Solutions will show up here once teachers or admins upload them.'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        if (s.filters.isActive)
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: c.clearFilters,
                              icon: const Icon(Icons.filter_alt_off_rounded),
                              label: const Text('Clear filters'),
                            ),
                          ),
                      ],
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification &&
                          _pageCtl.hasClients) {
                        final page = _pageCtl.page?.round() ?? 0;
                        if (page >= s.items.length - 3) {
                          c.loadMore();
                        }
                      }
                      return false;
                    },
                    child: PageView.builder(
                      padEnds: false,
                      controller: _pageCtl,
                      scrollDirection: Axis.vertical,
                      itemCount: s.items.length + (s.loadingMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i >= s.items.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return _FullscreenSolutionPost(item: s.items[i]);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenSolutionPost extends ConsumerWidget {
  const _FullscreenSolutionPost({required this.item});

  final Solution item;

  String get _title {
    final v = item.title?.trim() ?? '';
    return v.isNotEmpty ? v : 'Solution';
  }

  String get _caption {
    final v = item.body?.trim() ?? '';
    return v.isNotEmpty ? v : 'No caption yet.';
  }

  String get _subject {
    final v = item.subject.trim();
    return v.isNotEmpty ? v : 'Subject';
  }

  String get _sourceType {
    final v = item.sourceType.trim();
    return v.isNotEmpty ? v : 'other';
  }

  String get _sourceName {
    final v = item.sourceName.trim();
    return v.isNotEmpty ? v : 'Unknown source';
  }

  String get _pageText => item.page == null ? '—' : '${item.page}';

  String get _questionText {
    final v = item.questionNumber?.trim() ?? '';
    return v.isNotEmpty ? v : '—';
  }

  String get _repostCount => '${item.repostCount}';

  String get _createdText {
    final raw = item.createdAt?.trim() ?? '';
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw)?.toLocal();
    if (dt == null) return raw;
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d  $hh:$mm';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(solutionsControllerProvider.notifier);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _FullscreenSolutionMedia(images: item.images),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.22),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.84),
                  ],
                  stops: const [0.0, 0.25, 0.58, 1.0],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                child: Column(
                  children: [
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.34),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _OverlayPill(text: _subject),
                                    _OverlayPill(text: _sourceType),
                                    _OverlayPill(text: 'Book: $_sourceName'),
                                    _OverlayPill(text: 'Page: $_pageText'),
                                    _OverlayPill(text: 'Q: $_questionText'),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.4,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _caption,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withValues(
                                          alpha: 0.96,
                                        ),
                                        height: 1.3,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 6,
                                  children: [
                                    if ((item.authorName ?? '')
                                        .trim()
                                        .isNotEmpty)
                                      Text(
                                        'By ${item.authorName!.trim()}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.86,
                                              ),
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    if (_createdText.isNotEmpty)
                                      Text(
                                        _createdText,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.72,
                                              ),
                                            ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SideAction(
                              icon: item.likedByMe
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              label: '${item.likeCount}',
                              color: item.likedByMe
                                  ? const Color(0xFFFF6B81)
                                  : Colors.white,
                              onTap: () async {
                                await controller.toggleLike(item.id);
                              },
                            ),
                            const SizedBox(height: 12),
                            _SideAction(
                              icon: Icons.chat_bubble_outline_rounded,
                              label: item.commentCount == 0
                                  ? ''
                                  : '${item.commentCount}',
                              color: Colors.white,
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  showDragHandle: true,
                                  builder: (_) =>
                                      _CommentsSheet(solution: item),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _SideAction(
                              icon: Icons.repeat_rounded,
                              label: _repostCount,
                              color: Colors.white,
                              onTap: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                try {
                                  await controller.registerRepost(item);
                                  if (context.mounted) {
                                    messenger.showSnackBar(
                                      const SnackBar(content: Text('Reposted')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text('Repost failed: $e'),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenSolutionMedia extends StatefulWidget {
  const _FullscreenSolutionMedia({required this.images});

  final List<Map<String, dynamic>> images;

  @override
  State<_FullscreenSolutionMedia> createState() =>
      _FullscreenSolutionMediaState();
}

class _FullscreenSolutionMediaState extends State<_FullscreenSolutionMedia> {
  late final PageController _mediaCtl;

  @override
  void initState() {
    super.initState();
    _mediaCtl = PageController();
  }

  @override
  void dispose() {
    _mediaCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usable = widget.images
        .where((e) => (e['url'] ?? '').toString().trim().isNotEmpty)
        .toList(growable: false);

    if (usable.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: 72,
          color: Colors.white.withValues(alpha: 0.72),
        ),
      );
    }

    if (usable.length == 1) {
      final images = usable
          .map((e) => (e['url'] ?? '').toString())
          .where((e) => e.trim().isNotEmpty)
          .toList(growable: false);
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => _ImageViewerPage(images: images, initialIndex: 0),
            ),
          );
        },
        child: _FullscreenNetworkImage(
          url: (usable.first['url'] ?? '').toString(),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _mediaCtl,
          itemCount: usable.length,
          itemBuilder: (context, index) {
            final url = (usable[index]['url'] ?? '').toString();
            final images = usable
                .map((e) => (e['url'] ?? '').toString())
                .where((e) => e.trim().isNotEmpty)
                .toList(growable: false);
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        _ImageViewerPage(images: images, initialIndex: index),
                  ),
                );
              },
              child: _FullscreenNetworkImage(url: url),
            );
          },
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${usable.length} media',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FullscreenNetworkImage extends StatelessWidget {
  const _FullscreenNetworkImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, _) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        errorWidget: (context, imageUrl, error) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: const Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _OverlayPill extends StatelessWidget {
  const _OverlayPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.30),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}

String _relativeTime(String raw) {
  final dt = DateTime.tryParse(raw)?.toLocal();
  if (dt == null) {
    return raw;
  }

  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
  return '${(diff.inDays / 365).floor()}y';
}

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({required this.solution});

  final Solution solution;

  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final TextEditingController _ctl = TextEditingController();
  final ScrollController _scrollCtl = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(solutionsControllerProvider.notifier)
          .loadComments(widget.solution.id);
    });
    _scrollCtl.addListener(() async {
      if (!_scrollCtl.hasClients) {
        return;
      }
      if (_scrollCtl.position.pixels >=
          _scrollCtl.position.maxScrollExtent - 220) {
        await ref
            .read(solutionsControllerProvider.notifier)
            .loadMoreComments(widget.solution.id);
      }
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    _scrollCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(solutionsControllerProvider.notifier);
    final comments = controller.commentsStateFor(widget.solution.id);
    final cs = Theme.of(context).colorScheme;
    final loadedCount = comments.items.length;
    final count = loadedCount > widget.solution.commentCount
        ? loadedCount
        : widget.solution.commentCount;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.82,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () async {
                    await controller.loadComments(widget.solution.id);
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: 'Refresh comments',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: comments.loading
                  ? const Center(child: CircularProgressIndicator())
                  : comments.error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 42,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Could not load comments',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            comments.error!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () async {
                              await controller.loadComments(widget.solution.id);
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : comments.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.forum_outlined,
                            size: 48,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No comments yet',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Be the first one to reply.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      controller: _scrollCtl,
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount:
                          comments.items.length +
                          (comments.loadingMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index >= comments.items.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final item = comments.items[index];
                        final author = item.author.name.trim().isEmpty
                            ? 'User'
                            : item.author.name.trim();
                        final initial = author[0].toUpperCase();

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: cs.outlineVariant.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.14),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: cs.primary,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            author,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                        ),
                                        Text(
                                          _relativeTime(item.createdAt),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: cs.onSurfaceVariant,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.body,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(height: 1.25),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 10),
            Material(
              elevation: 0,
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctl,
                        minLines: 1,
                        maxLines: 5,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) async {
                          final text = _ctl.text.trim();
                          if (text.isEmpty) {
                            return;
                          }
                          await controller.addComment(widget.solution.id, text);
                          if (!mounted) {
                            return;
                          }
                          _ctl.clear();
                        },
                        decoration: const InputDecoration(
                          hintText: 'Add a helpful comment…',
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: comments.posting
                          ? null
                          : () async {
                              final text = _ctl.text.trim();
                              if (text.isEmpty) {
                                return;
                              }
                              await controller.addComment(
                                widget.solution.id,
                                text,
                              );
                              if (!mounted) {
                                return;
                              }
                              _ctl.clear();
                            },
                      style: FilledButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(14),
                      ),
                      child: comments.posting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageViewerPage extends StatefulWidget {
  const _ImageViewerPage({required this.images, required this.initialIndex});

  final List<String> images;
  final int initialIndex;

  @override
  State<_ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<_ImageViewerPage> {
  late final PageController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: PageView.builder(
        controller: _ctl,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final url = widget.images[index];
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (context, progress) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, imageUrl, error) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white70,
                  size: 48,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChipField extends StatelessWidget {
  const _ChipField({
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.width,
    this.keyboardType,
  });

  final String hint;
  final TextEditingController controller;
  final double? width;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final field = SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.22),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outlineVariant.withValues(alpha: 0.22),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
        ),
      ),
    );

    return width == null ? field : field;
  }
}

class _FiltersBar extends StatefulWidget {
  const _FiltersBar({required this.filters, required this.onChanged});
  final SolutionsFilters filters;
  final Future<void> Function(SolutionsFilters) onChanged;

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
  void didUpdateWidget(covariant _FiltersBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      _subject.text = widget.filters.subject ?? '';
      _sourceType.text = widget.filters.sourceType ?? '';
      _sourceName.text = widget.filters.sourceName ?? '';
      _page.text = widget.filters.page?.toString() ?? '';
      _q.text = widget.filters.questionNumber ?? '';
    }
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

  SolutionsFilters _draftFilters() {
    final page = int.tryParse(_page.text.trim());
    return SolutionsFilters(
      subject: _subject.text.trim().isEmpty ? null : _subject.text.trim(),
      sourceType: _sourceType.text.trim().isEmpty
          ? null
          : _sourceType.text.trim(),
      sourceName: _sourceName.text.trim().isEmpty
          ? null
          : _sourceName.text.trim(),
      page: page,
      questionNumber: _q.text.trim().isEmpty ? null : _q.text.trim(),
    );
  }

  Future<void> _apply() async {
    await widget.onChanged(_draftFilters());
    if (mounted) FocusScope.of(context).unfocus();
  }

  Future<void> _clear() async {
    _subject.clear();
    _sourceType.clear();
    _sourceName.clear();
    _page.clear();
    _q.clear();
    setState(() {});
    await widget.onChanged(const SolutionsFilters());
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final chipW = (w - 16 * 2 - 10 * 2) / 3;
    final hasDraft = _draftFilters().isActive;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Column(
        children: [
          Row(
            children: [
              _ChipField(
                hint: 'Subject',
                controller: _subject,
                width: chipW,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(width: 10),
              _ChipField(
                hint: 'Type',
                controller: _sourceType,
                width: chipW,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(width: 10),
              _ChipField(
                hint: 'Book',
                controller: _sourceName,
                width: chipW,
                onChanged: (_) => setState(() {}),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ChipField(
                  hint: 'Page',
                  controller: _page,
                  width: null,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ChipField(
                  hint: 'Question #',
                  controller: _q,
                  width: null,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: hasDraft || widget.filters.isActive
                      ? _clear
                      : null,
                  icon: const Icon(Icons.filter_alt_off_rounded),
                  label: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _apply,
                  icon: const Icon(Icons.tune_rounded),
                  label: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
