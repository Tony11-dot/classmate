// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_press.dart';
import '../../../ui/widgets/cm_code_field.dart';
import '../../../ui/widgets/cm_search_field.dart';
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
import '../../chat_core/utils/chat_reply_codec.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_refresh_indicator.dart';
import '../../../core/util/bidi.dart';

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
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        // State vars OUTSIDE the builder so they persist across setS() rebuilds
        var joining = false;
        String? errorMsg;
        var status = CmCodeStatus.idle;
        return StatefulBuilder(
          builder: (ctx, setS) {
            Future<void> submit() async {
              final code = codeCtrl.text.trim();
              if (code.isEmpty || joining) return;
              setS(() { joining = true; errorMsg = null; status = CmCodeStatus.checking; });
              try {
                await ClassroomsRepository().joinByCode(code);
                if (!mounted) return;
                setS(() => status = CmCodeStatus.success);
                // Let the green "valid" animation land before closing.
                await Future<void>.delayed(const Duration(milliseconds: 700));
                ref.invalidate(orderedStudentClassroomsProvider);
                ref.invalidate(studentClassroomsProvider);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.classroomsJoined)),
                );
              } catch (e) {
                setS(() {
                  joining = false;
                  status = CmCodeStatus.error;
                  errorMsg = e is ClassroomJoinRejected
                      ? AppLocalizations.of(context)!.classroomsJoinInvalidCode
                      : e.toString().replaceFirst('Exception: ', '');
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: LiquidGlassCard(
                    borderRadius: BorderRadius.circular(24),
                    color: cs.surfaceContainerLow,
                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
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
                                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
                                    child: Icon(Icons.class_rounded, color: cs.onPrimaryContainer, size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(AppLocalizations.of(ctx)!.classroomsJoinTitle, style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                                        Text(AppLocalizations.of(ctx)!.classroomsJoinSubtitle, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              CmCodeField(
                                length: 6,
                                controller: codeCtrl,
                                upperCase: true,
                                status: status,
                                errorText: errorMsg,
                                onChanged: (_) {
                                  if (status == CmCodeStatus.error) {
                                    setS(() { status = CmCodeStatus.idle; errorMsg = null; });
                                  }
                                },
                                onCompleted: (_) => submit(),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: joining ? null : submit,
                                  icon: joining
                                      ? const CmLoading(size: 18)
                                      : const Icon(Icons.login_rounded),
                                  label: Text(joining ? AppLocalizations.of(ctx)!.chatJoining : AppLocalizations.of(ctx)!.classroomsJoinAction),
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
          bottom: false,
          child: CmRefreshIndicator(
          onRefresh: () async {
            ref.invalidate(orderedStudentClassroomsProvider);
            ref.invalidate(studentClassroomsProvider);
            await ref.read(orderedStudentClassroomsProvider.future);
          },
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
                padding: EdgeInsets.fromLTRB(16, 0, 16, 130 + MediaQuery.paddingOf(context).bottom),
                // Header + search field + either the rows or a single
                // "no matches" card. With `filtered.length + 2` an empty search
                // only built the header + search (count 2), so the empty-state
                // row at index ≥ 2 never rendered — no "No data" message (#20).
                itemCount: filtered.isEmpty ? 3 : filtered.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ClassroomsHero(
                        title: l.classroomsYourClassrooms,
                        subtitle: l.classroomsCount(items.length),
                        joinTooltip: l.classroomsJoinTooltip,
                        reorderTooltip: l.classroomsReorder,
                        onJoin: () => _showJoinSheet(context),
                        onReorder: () async {
                          await Navigator.of(context, rootNavigator: true).push(
                            CupertinoPageRoute<void>(
                              builder: (_) => const ClassroomOrderScreen(),
                            ),
                          );
                          if (!mounted) return;
                          ref.invalidate(orderedStudentClassroomsProvider);
                        },
                      ),
                    );
                  }

                  if (index == 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CmSearchField(
                        controller: _searchCtl,
                        hint: l.classroomsSearchHint,
                        onChanged: (_) => setState(() {}),
                        onTapOutside: (_) => FocusScope.of(context).unfocus(),
                        onClear: () => FocusScope.of(context).unfocus(),
                      ),
                    );
                  }

                  if (filtered.isEmpty) {
                    return LiquidGlassCard(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
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
                        ).then((_) {
                          if (!mounted) return;
                          ref.invalidate(classroomChatProvider);
                          // Refresh list in case new classrooms were added during the visit
                          ref.invalidate(orderedStudentClassroomsProvider);
                          ref.invalidate(studentClassroomsProvider);
                        });
                      },
                    ),
                  );
                },
              );
            },
          ),
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

    final tokens = CmTokens.of(context);
    final initial = title.characters.isEmpty
        ? '?'
        : title.characters.first.toUpperCase();

    // One lifted card per class: a monogram tile, the class name, then the
    // subject · time row and the latest-message preview (unread = bold + dot).
    return CmPress(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 14, 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(CmTokens.radiusLg),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.35),
            width: 0.8,
          ),
          boxShadow: tokens.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(CmTokens.radiusMd),
              ),
              child: Text(
                initial,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: cs.onPrimaryContainer,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 3),
                  FutureBuilder<String?>(
                        future: _readSeenAt(courseId),
                        builder: (context, seenSnap) {
                          final seenAt = DateTime.tryParse(
                            (seenSnap.data ?? '').trim(),
                          )?.toUtc();
                          return chatAsync.when(
                            loading: () => _BottomBandContent(
                              subject: subject,
                              accent: accent,
                              preview: l.classroomsLoadingLatestMessage,
                              timeText: '',
                              isUnread: false,
                            ),
                            error: (_, __) => _BottomBandContent(
                              subject: subject,
                              accent: accent,
                              preview: l.classroomsTapToOpen,
                              timeText: '',
                              isUnread: false,
                            ),
                            data: (raw) {
                              final sorted = _normalizeChatList(raw)
                                ..sort((a, b) {
                                  final ad = parseFirstChatTimestamp([
                                        _s(a, 'createdAt'), _s(a, 'sentAt')]) ??
                                      DateTime.fromMillisecondsSinceEpoch(0);
                                  final bd = parseFirstChatTimestamp([
                                        _s(b, 'createdAt'), _s(b, 'sentAt')]) ??
                                      DateTime.fromMillisecondsSinceEpoch(0);
                                  final d = bd.compareTo(ad);
                                  return d != 0 ? d : _s(b, 'id').compareTo(_s(a, 'id'));
                                });
                              final serverLatest = sorted.isNotEmpty
                                  ? Map<String, dynamic>.from(sorted.first)
                                  : null;
                              final localLatest =
                                  ClassroomChatThreadController.lastMessage(courseId);
                              // The local cache only exists to cover the send→confirm
                              // gap, so it may beat the server ONLY while it is fresh
                              // (a just-sent message the poll hasn't returned yet).
                              // Unbounded trust left cards showing long-deleted
                              // messages — e.g. a raw mp4 path over an empty thread.
                              final lt = localLatest == null
                                  ? null
                                  : parseFirstChatTimestamp(
                                      [_s(localLatest, 'createdAt')]);
                              final localFresh = lt != null &&
                                  DateTime.now()
                                          .toUtc()
                                          .difference(lt.toUtc())
                                          .inMinutes <
                                      5;
                              Map<String, dynamic>? latest;
                              if (serverLatest != null && localLatest != null) {
                                final st = parseFirstChatTimestamp([_s(serverLatest, 'createdAt')]);
                                latest = (localFresh && st != null && lt.isAfter(st))
                                    ? localLatest : serverLatest;
                              } else {
                                latest =
                                    serverLatest ?? (localFresh ? localLatest : null);
                              }
                              final createdAtRaw = latest == null ? '' : _s(latest, 'createdAt');
                              final createdAt = parseFirstChatTimestamp([createdAtRaw])?.toUtc();
                              final isUnread = latest != null && createdAt != null &&
                                  (seenAt == null || createdAt.isAfter(seenAt));
                              return _BottomBandContent(
                                subject: subject,
                                accent: accent,
                                preview: latest == null
                                    ? l.classroomsNoMessagesYet
                                    : _previewText(context, latest),
                                timeText: _previewTime(context, createdAtRaw),
                                isUnread: isUnread,
                              );
                            },
                          );
                        },
                      ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _BottomBandContent extends StatelessWidget {
  const _BottomBandContent({
    required this.subject,
    required this.accent,
    required this.preview,
    required this.timeText,
    required this.isUnread,
  });

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
        // Subject row
        Row(
          children: [
            Expanded(
              child: Text(
                subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (timeText.isNotEmpty)
              Text(
                timeText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight:
                      isUnread ? FontWeight.w800 : FontWeight.w500,
                  color: isUnread ? accent : cs.onSurfaceVariant,
                ),
              ),
            if (isUnread) ...[
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
            ],
          ],
        ),
        const SizedBox(height: 3),
        // Last message preview
        Text(
          preview,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight:
                isUnread ? FontWeight.w600 : FontWeight.w400,
            color: isUnread ? cs.onSurface : cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ClassroomsHero extends StatelessWidget {
  const _ClassroomsHero({
    required this.title,
    required this.subtitle,
    required this.joinTooltip,
    required this.reorderTooltip,
    required this.onJoin,
    required this.onReorder,
  });

  final String title;
  final String subtitle;
  final String joinTooltip;
  final String reorderTooltip;
  final VoidCallback onJoin;
  final VoidCallback onReorder;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = CmTokens.of(context);
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 18, 12, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CmTokens.radiusXl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer,
            Color.alphaBlend(
              cs.primary.withValues(alpha: 0.14),
              cs.primaryContainer,
            ),
          ],
        ),
        boxShadow: tokens.shadowMd,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CmTokens.radiusLg - 4),
              color: cs.onPrimaryContainer.withValues(alpha: 0.10),
            ),
            child: Icon(Icons.forum_rounded,
                size: 28, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          _HeroAction(
              icon: Icons.add_rounded, tooltip: joinTooltip, onTap: onJoin),
          const SizedBox(width: 6),
          _HeroAction(
              icon: Icons.reorder_rounded,
              tooltip: reorderTooltip,
              onTap: onReorder),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onTap,
      style: IconButton.styleFrom(
        backgroundColor: cs.surface.withValues(alpha: 0.7),
        foregroundColor: cs.onSurface,
        minimumSize: const Size(44, 44),
      ),
      icon: Icon(icon),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CmLoading());
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
  // Route through the shared formatter so this card describes an attachment
  // the same way the DM inbox, the reply quote and the push notification do.
  // It used to print `text` raw, which for classroom media is the stored wire
  // marker — the card literally read "Tony: [IMAGE] IMG_2.jpg".
  // A delete-for-everyone tombstone has its content nulled server-side; the
  // deleteMode flag is what identifies it, so the card shows 🚫 rather than
  // an empty "💬 Message".
  final isTombstone =
      _s(m, 'deleteMode').toUpperCase() == 'DELETED_FOR_EVERYONE' ||
          _s(m, 'kind').toUpperCase() == 'DELETED';
  final text = messagePreviewText(
    kind: isTombstone ? 'DELETED' : _s(m, 'kind', fallback: 'TEXT'),
    rawText:
        isTombstone ? '' : _s(m, 'text', fallback: _s(m, 'content', fallback: '')),
    labels: ChatPreviewLabels.of(AppLocalizations.of(context)!),
  );
  if (sender.isEmpty) {
    return firstStrongIsolate(text);
  }
  return '${firstStrongIsolate(sender)}: ${firstStrongIsolate(text)}';
}

String _previewTime(BuildContext context, String raw) {
  final dt = parseChatTimestamp(raw);
  return formatChatInboxTrailingLabel(
    dt,
    fallback: '',
    yesterday: AppLocalizations.of(context)!.yesterday,
    locale: Localizations.localeOf(context).toString(),
  );
}

