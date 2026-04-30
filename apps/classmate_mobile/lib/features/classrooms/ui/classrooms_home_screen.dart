// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import '../data/classrooms_repository.dart';
import '../providers/classrooms_providers.dart';
import '../../chat_core/controllers/classroom_chat_thread_controller.dart';
import 'classroom_order_screen.dart';
import 'classroom_detail_screen.dart';
import '../../chat_core/utils/chat_time.dart';

class ClassroomsHomeScreen extends ConsumerStatefulWidget {
  const ClassroomsHomeScreen({super.key});

  @override
  ConsumerState<ClassroomsHomeScreen> createState() =>
      _ClassroomsHomeScreenState();
}

class _ClassroomsHomeScreenState extends ConsumerState<ClassroomsHomeScreen> {
  final TextEditingController _searchCtl = TextEditingController();

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _showJoinSheet(BuildContext context) async {
    final codeCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return StatefulBuilder(
          builder: (ctx, setS) {
            bool joining = false;
            String? errorMsg;

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: LiquidGlassCard(
                    borderRadius: BorderRadius.circular(24),
                    blurSigma: 18,
                    color: cs.surface.withValues(alpha: 0.97),
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.22)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outlineVariant.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(color: cs.primaryContainer.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
                                    child: Icon(Icons.class_rounded, color: cs.primary, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Join a Classroom', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                      Text('Enter the code your teacher gave you', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: codeCtrl,
                                autofocus: true,
                                textCapitalization: TextCapitalization.characters,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 6),
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: '• • • • • •',
                                  hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.4), letterSpacing: 6),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                  filled: true,
                                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                                  errorText: errorMsg,
                                ),
                                onSubmitted: (_) async {
                                  final code = codeCtrl.text.trim();
                                  if (code.isEmpty) return;
                                  setS(() { joining = true; errorMsg = null; });
                                  try {
                                    await ClassroomsRepository().joinByCode(code);
                                    if (!mounted) return;
                                    ref.invalidate(orderedStudentClassroomsProvider);
                                    ref.invalidate(studentClassroomsProvider);
                                    Navigator.of(ctx).pop();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('You joined the classroom!')),
                                    );
                                  } catch (e) {
                                    setS(() { joining = false; errorMsg = e.toString().replaceFirst('Exception: ', ''); });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: joining ? null : () async {
                                    final code = codeCtrl.text.trim();
                                    if (code.isEmpty) return;
                                    setS(() { joining = true; errorMsg = null; });
                                    try {
                                      await ClassroomsRepository().joinByCode(code);
                                      if (!mounted) return;
                                      ref.invalidate(orderedStudentClassroomsProvider);
                                      ref.invalidate(studentClassroomsProvider);
                                      Navigator.of(ctx).pop();
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('You joined the classroom!')),
                                      );
                                    } catch (e) {
                                      setS(() { joining = false; errorMsg = e.toString().replaceFirst('Exception: ', ''); });
                                    }
                                  },
                                  icon: joining
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                      : const Icon(Icons.login_rounded),
                                  label: Text(joining ? 'Joining…' : 'Join Classroom'),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(orderedStudentClassroomsProvider);
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final query = _searchCtl.text.trim().toLowerCase();

    return Scaffold(
backgroundColor: cs.surface,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        onVerticalDragStart: (_) => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: async.when(
            loading: () => const _LoadingView(),
            error: (e, _) => _ErrorView(error: '$e'),
            data: (items) {
              final filtered = query.isEmpty
                  ? items
                  : items.where((item) {
                      final hay = [
                        _s(item, 'id'),
                        _s(item, 'name'),
                        _s(item, 'title'),
                        _s(item, 'subject'),
                        _s(item, 'teacher'),
                        _s(item, 'teacherName'),
                        _s(item, 'subtitle'),
                      ].join(' ').toLowerCase();
                      return hay.contains(query);
                    }).toList();

              return ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,

                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                itemCount: filtered.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: LiquidGlassCard(
                        borderRadius: BorderRadius.circular(28),
                        blurSigma: 18,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.surface.withValues(alpha: 0.98),
                            cs.primary.withValues(alpha: 0.06),
                          ],
                        ),
                        border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                            color: cs.primary.withValues(alpha: 0.10),
                          ),
                        ],
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Row(
                            children: [
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  color: cs.primary.withValues(alpha: 0.14),
                                ),
                                child: Icon(
                                  Icons.forum_rounded,
                                  size: 30,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            l.classroomsYourClassrooms,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                ),
                                          ),
                                        ),
                                        IconButton(
                                          tooltip: 'Join a classroom',
                                          onPressed: () => _showJoinSheet(context),
                                          icon: const Icon(Icons.add_rounded),
                                        ),
                                        IconButton(
                                          tooltip: l.classroomsReorder,
                                          onPressed: () async {
                                            await Navigator.of(context, rootNavigator: true).push(
                                              CupertinoPageRoute<void>(
                                                builder: (_) => const ClassroomOrderScreen(),
                                              ),
                                            );
                                            if (!mounted) return;
                                            ref.invalidate(orderedStudentClassroomsProvider);
                                          },
                                          icon: const Icon(Icons.reorder_rounded),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      l.classroomsCount(items.length),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant
                                                .withValues(alpha: 0.84),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        controller: _searchCtl,
                        onChanged: (_) => setState(() {}),
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        decoration: InputDecoration(
                          hintText: l.classroomsSearchHint,
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchCtl.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () {
                                    _searchCtl.clear();
                                    setState(() {});
                                    FocusScope.of(context).unfocus();
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest.withValues(
                            alpha: 0.40,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.55),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: cs.outlineVariant.withValues(alpha: 0.55),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: cs.primary.withValues(alpha: 0.85),
                              width: 1.25,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  if (filtered.isEmpty) {
                    return LiquidGlassCard(
                      borderRadius: BorderRadius.circular(28),
                      blurSigma: 18,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.surface.withValues(alpha: 0.98),
                          cs.primary.withValues(alpha: 0.06),
                        ],
                      ),
                      border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                          color: cs.primary.withValues(alpha: 0.10),
                        ),
                      ],
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 30,
                            color: cs.primary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.classroomsNoSearchMatches,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    );
                  }

                  final item = filtered[index - 2];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ClassroomAppleCard(
                      item: item,
                      onTap: () {
                        final id = _s(item, 'id').trim();
                        if (id.isEmpty) {
                          return;
                        }
                        Navigator.of(context, rootNavigator: true).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ClassroomDetailScreen(courseId: id),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}




class _ClassroomAppleCard extends ConsumerWidget {
  const _ClassroomAppleCard({required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final subject = _s(item, 'subject', fallback: l.classroomsClassroomLabel);
    final title = _s(
      item,
      'name',
      fallback: _s(item, 'title', fallback: subject),
    );
    final courseId = _s(item, 'id').trim();
    final accent = cs.primary;

    final chatAsync = ref.watch(
      classroomChatProvider((id: courseId, limit: 20, cursor: null)),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: LiquidGlassCard(
        borderRadius: BorderRadius.circular(28),
        blurSigma: 18,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface.withValues(alpha: 0.98),
            accent.withValues(alpha: 0.06),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 12),
            color: accent.withValues(alpha: 0.10),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: accent.withValues(alpha: 0.14),
                ),
                child: Icon(_subjectIcon(subject), color: accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: FutureBuilder<String?>(
                  future: _readSeenAt(courseId),
                  builder: (context, seenSnap) {
                    final seenAt = DateTime.tryParse(
                      (seenSnap.data ?? '').trim(),
                    )?.toUtc();

                    return chatAsync.when(
                      loading: () => _CardTextBlock(
                        title: title,
                        subject: subject,
                        accent: accent,
                        preview: l.classroomsLoadingLatestMessage,
                        timeText: '',
                        isUnread: false,
                      ),
                      error: (err, stack) => _CardTextBlock(
                        title: title,
                        subject: subject,
                        accent: accent,
                        preview: l.classroomsTapToOpen,
                        timeText: '',
                        isUnread: false,
                      ),
                      data: (raw) {
                        final sortedMessages = _normalizeChatList(raw)
                          ..sort((a, b) {
                            final ad = parseFirstChatTimestamp([
                                  _s(a, 'createdAt'),
                                  _s(a, 'sentAt'),
                                  _s(a, 'updatedAt'),
                                ]) ??
                                DateTime.fromMillisecondsSinceEpoch(0);
                            final bd = parseFirstChatTimestamp([
                                  _s(b, 'createdAt'),
                                  _s(b, 'sentAt'),
                                  _s(b, 'updatedAt'),
                                ]) ??
                                DateTime.fromMillisecondsSinceEpoch(0);
                            final byDate = bd.compareTo(ad);
                            if (byDate != 0) return byDate;
                            return _s(b, 'id').compareTo(_s(a, 'id'));
                          });

                        // Server GET always returns items:[]. Fall back to the
                        // last locally-sent message tracked by the controller.
                        final serverLatest = sortedMessages.isNotEmpty
                            ? Map<String, dynamic>.from(sortedMessages.first)
                            : null;
                        final localLatest =
                            ClassroomChatThreadController.lastMessage(courseId);

                        // Pick whichever is more recent.
                        Map<String, dynamic>? latest;
                        if (serverLatest != null && localLatest != null) {
                          final st = parseFirstChatTimestamp([_s(serverLatest, 'createdAt')]);
                          final lt = parseFirstChatTimestamp([_s(localLatest, 'createdAt')]);
                          latest = (lt != null && st != null && lt.isAfter(st))
                              ? localLatest
                              : serverLatest;
                        } else {
                          latest = serverLatest ?? localLatest;
                        }

                        final preview = latest == null
                          ? l.classroomsNoMessagesYet
                          : _previewText(context, latest);

                        final createdAtRaw = latest == null
                            ? ''
                            : _s(latest, 'createdAt');
                        final createdAt = parseFirstChatTimestamp([
                          createdAtRaw,
                          latest == null ? '' : _s(latest, 'sentAt'),
                          latest == null ? '' : _s(latest, 'updatedAt'),
                        ])?.toUtc();

                        final isUnread =
                            latest != null &&
                            createdAt != null &&
                            (seenAt == null || createdAt.isAfter(seenAt));

                        final timeText = _previewTime(createdAtRaw);

                        return _CardTextBlock(
                          title: title,
                          subject: subject,
                          accent: accent,
                          preview: preview,
                          timeText: timeText,
                          isUnread: isUnread,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardTextBlock extends StatelessWidget {
  const _CardTextBlock({
    required this.title,
    required this.subject,
    required this.accent,
    required this.preview,
    required this.timeText,
    required this.isUnread,
  });

  final String title;
  final String subject;
  final Color accent;
  final String preview;
  final String timeText;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        _pill(subject, accent, accent.withValues(alpha: 0.14)),
        const SizedBox(height: 8),
        Row(
          children: [
            if (isUnread) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
                  color: cs.onSurfaceVariant.withValues(
                    alpha: isUnread ? 0.96 : 0.82,
                  ),
                ),
              ),
            ),
            if (timeText.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(
                timeText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                  color: isUnread
                      ? accent
                      : cs.onSurfaceVariant.withValues(alpha: 0.72),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(error, textAlign: TextAlign.center),
      ),
    );
  }
}

Widget _pill(String text, Color fg, Color bg) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          bg.withValues(alpha: 0.94),
          Colors.white.withValues(alpha: 0.24),
        ],
      ),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: fg.withValues(alpha: 0.10)),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12.5),
    ),
  );
}

String _classroomSeenKey(String courseId) => 'classroom_last_seen_$courseId';

Future<String?> _readSeenAt(String courseId) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_classroomSeenKey(courseId));
}

String _s(Map<String, dynamic> m, String key, {String fallback = ''}) {
  final value = (m[key] ?? '').toString().trim();
  return value.isEmpty ? fallback : value;
}

List<Map<String, dynamic>> _normalizeChatList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  if (raw is Map<String, dynamic>) {
    final items = raw['items'];
    if (items is List) {
      return items
          .whereType<Map>()
          .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
          .toList();
    }
  }

  return const <Map<String, dynamic>>[];
}

String _previewText(BuildContext context, Map<String, dynamic> m) {
  final sender = _s(m, 'senderName', fallback: _s(m, 'sender', fallback: ''));
  final text = _s(
    m,
    'text',
    fallback: _s(
      m,
      'content',
      fallback: AppLocalizations.of(context)!.classroomsMessageFallback,
    ),
  );
  if (sender.isEmpty) {
    return text;
  }
  return '$sender: $text';
}

String _previewTime(String raw) {
  final dt = parseChatTimestamp(raw);
  return formatChatInboxTrailingLabel(dt, fallback: '');
}

IconData _subjectIcon(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('math')) return Icons.functions_rounded;
  if (s.contains('physics')) return Icons.bolt_rounded;
  if (s.contains('chem')) return Icons.science_rounded;
  if (s.contains('bio')) return Icons.biotech_rounded;
  if (s.contains('arab')) return Icons.translate_rounded;
  if (s.contains('hebrew')) return Icons.menu_book_rounded;
  if (s.contains('english')) return Icons.language_rounded;
  if (s.contains('computer') || s.contains('cs')) return Icons.memory_rounded;
  return Icons.forum_rounded;
}

