import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/classrooms_providers.dart';
import 'classroom_detail_screen.dart';

class ClassroomsHomeScreen extends ConsumerWidget {
  const ClassroomsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studentClassroomsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: async.when(
                loading: () => const _LoadingView(),
                error: (e, _) => _ErrorView(error: '$e'),
                data: (items) => _LoadedView(items: items),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.items});

  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    final accent = items.isNotEmpty
        ? _subjectColor(context, _s(items.first, 'subject'))
        : Theme.of(context).colorScheme.primary;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              decoration: _glassCard(context, accent: accent),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: accent.withValues(alpha: 0.16),
                      ),
                      child: Icon(Icons.forum_rounded, size: 34, color: accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your classrooms',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${items.length} classrooms',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
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

        final item = items[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _ClassroomAppleCard(
            item: item,
            onTap: () {
              final id = _s(item, 'id').trim();
              if (id.isEmpty) {
                return;
              }
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ClassroomDetailScreen(courseId: id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ClassroomAppleCard extends ConsumerWidget {
  const _ClassroomAppleCard({required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subject = _s(item, 'subject', fallback: 'Classroom');
    final title = _s(item, 'name', fallback: subject);
    final courseId = _s(item, 'id').trim();
    final accent = _subjectColor(context, subject);

    final chatAsync = ref.watch(
      classroomChatProvider((id: courseId, limit: 20, cursor: null)),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: _glassCard(context, accent: accent),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: accent.withValues(alpha: 0.16),
                ),
                child: Icon(_subjectIcon(subject), color: accent, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FutureBuilder<String?>(
                  future: _readSeenAt(courseId),
                  builder: (context, seenSnap) {
                    final seenAt = DateTime.tryParse(
                      (seenSnap.data ?? '').trim(),
                    )?.toUtc();

                    return chatAsync.when(
                      loading: () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          _pill(
                            subject,
                            accent,
                            accent.withValues(alpha: 0.14),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Loading latest message…',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.72),
                                ),
                          ),
                        ],
                      ),
                      error: (_, stackTrace) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 10),
                          _pill(
                            subject,
                            accent,
                            accent.withValues(alpha: 0.14),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tap to open classroom',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.82),
                                ),
                          ),
                        ],
                      ),
                      data: (raw) {
                        final items = _normalizeChatList(raw);
                        final latest = items.isNotEmpty
                            ? Map<String, dynamic>.from(items.first)
                            : null;

                        final preview = latest == null
                            ? 'No messages yet'
                            : _previewText(latest);

                        final createdAtRaw = latest == null
                            ? ''
                            : _s(latest, 'createdAt');
                        final createdAt = DateTime.tryParse(
                          createdAtRaw,
                        )?.toUtc();
                        final isUnread =
                            latest != null &&
                            createdAt != null &&
                            (seenAt == null || createdAt.isAfter(seenAt));
                        final timeText = _previewTime(createdAtRaw);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 10),
                            _pill(
                              subject,
                              accent,
                              accent.withValues(alpha: 0.14),
                            ),
                            const SizedBox(height: 10),
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontWeight: isUnread
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant
                                              .withValues(
                                                alpha: isUnread ? 0.96 : 0.82,
                                              ),
                                        ),
                                  ),
                                ),
                                if (timeText.isNotEmpty) ...[
                                  const SizedBox(width: 10),
                                  Text(
                                    timeText,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontWeight: isUnread
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isUnread
                                              ? accent
                                              : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant
                                                    .withValues(alpha: 0.72),
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ],
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

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            height: index == 0 ? 112 : 128,
            decoration: _glassCard(context),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          decoration: _glassCard(context, accent: cs.error),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 40, color: cs.error),
                const SizedBox(height: 14),
                Text(
                  'Could not load classrooms',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _pill(String text, Color fg, Color bg) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      text,
      style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 12),
    ),
  );
}

List<Map<String, dynamic>> _normalizeChatList(dynamic raw) {
  if (raw is Map && raw['items'] is List) {
    return (raw['items'] as List)
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
  return <Map<String, dynamic>>[];
}

String _previewText(Map<String, dynamic> item) {
  final text = _s(item, 'text').trim();
  if (text.isNotEmpty) {
    return text;
  }
  final kind = _s(item, 'kind').trim().toUpperCase();
  if (kind == 'IMAGE') {
    return 'Photo';
  }
  if (kind == 'VOICE') {
    return 'Voice message';
  }
  if (kind == 'FILE') {
    return 'File';
  }
  return 'New message';
}

String _s(dynamic item, String key, {String fallback = ''}) {
  if (item is Map) {
    return (item[key] ?? fallback).toString();
  }
  return fallback;
}

IconData _subjectIcon(String subject) {
  final s = subject.toLowerCase();
  if (s.contains('math')) return Icons.calculate_rounded;
  if (s.contains('physics')) return Icons.science_rounded;
  if (s.contains('chem')) return Icons.biotech_rounded;
  if (s.contains('bio')) return Icons.eco_rounded;
  if (s.contains('history')) return Icons.history_edu_rounded;
  if (s.contains('cs')) return Icons.memory_rounded;
  return Icons.book_rounded;
}

Color _subjectColor(BuildContext context, String subject) {
  final s = subject.toLowerCase();
  if (s.contains('math')) return const Color(0xFF5C8DFF);
  if (s.contains('physics')) return const Color(0xFF00A896);
  if (s.contains('chem')) return const Color(0xFFFF8A65);
  if (s.contains('bio')) return const Color(0xFF66BB6A);
  if (s.contains('cs')) return const Color(0xFF42A5F5);
  return Theme.of(context).colorScheme.primary;
}

String _classroomSeenKey(String courseId) => 'classroom_last_seen_$courseId';

String _previewTime(String raw) {
  final v = raw.trim();
  if (v.isEmpty) return '';
  final dt = DateTime.tryParse(v)?.toLocal();
  if (dt == null) return '';
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

Future<String?> _readSeenAt(String courseId) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_classroomSeenKey(courseId));
}

BoxDecoration _glassCard(BuildContext context, {Color? accent}) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(28),
    gradient: LinearGradient(
      colors: [
        cs.surface.withValues(alpha: 0.98),
        cs.surfaceContainerLow.withValues(alpha: 0.92),
      ],
    ),
    border: Border.all(
      color: (accent ?? cs.outlineVariant).withValues(alpha: 0.20),
    ),
    boxShadow: [
      BoxShadow(
        blurRadius: 30,
        offset: const Offset(0, 12),
        color: Colors.black.withValues(alpha: 0.10),
      ),
    ],
  );
}
