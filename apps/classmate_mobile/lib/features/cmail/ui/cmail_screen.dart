// ignore_for_file: use_build_context_synchronously
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/cmail_api.dart';
import 'cmail_compose_screen.dart';
import 'cmail_detail_screen.dart';

String cmailAudienceLabel(AppLocalizations l, String? audience) {
  return switch (audience) {
    'SCHOOL' => l.cmailAudienceSchool,
    'STUDENTS' => l.cmailAudienceStudents,
    'TEACHERS' => l.cmailAudienceTeachers,
    'PARENTS' => l.cmailAudienceParents,
    'STAFF' => l.cmailAudienceStaff,
    'GRADES' => l.cmailAudienceGrades,
    'COHORTS' => l.cmailAudienceCohorts,
    'USERS' => l.cmailAudienceUsers,
    _ => '',
  };
}

/// CMail home. Everyone gets an Inbox; staff (admin/teacher/secretary) also
/// get a Sent tab and the compose button.
class CMailScreen extends ConsumerStatefulWidget {
  const CMailScreen({super.key});

  @override
  ConsumerState<CMailScreen> createState() => _CMailScreenState();
}

class _CMailScreenState extends ConsumerState<CMailScreen> {
  int _tab = 0;

  bool get _isStaff {
    final roles = ref.read(authSessionProvider).roles;
    return roles.contains('ADMIN') ||
        roles.contains('TEACHER') ||
        roles.contains('SECRETARY');
  }

  Future<void> _refresh() async {
    if (_tab == 0) {
      ref.invalidate(cmailInboxProvider);
      await ref.read(cmailInboxProvider.future);
    } else {
      ref.invalidate(cmailSentProvider);
      await ref.read(cmailSentProvider.future);
    }
  }

  Future<void> _compose() async {
    final sent = await Navigator.of(context, rootNavigator: true).push<bool>(
      CupertinoPageRoute(builder: (_) => const CMailComposeScreen()),
    );
    if (sent == true) {
      ref.invalidate(cmailSentProvider);
      ref.invalidate(cmailInboxProvider);
    }
  }

  Future<void> _open(CMailSummary mail) async {
    await Navigator.of(context, rootNavigator: true).push(
      CupertinoPageRoute(builder: (_) => CMailDetailScreen(mailId: mail.id)),
    );
    ref.invalidate(cmailInboxProvider);
    ref.invalidate(cmailSentProvider);
  }

  // ── Long-press actions (Gmail-style) ──────────────────────────────────────

  Future<void> _runMailAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        ref.invalidate(cmailInboxProvider);
        ref.invalidate(cmailSentProvider);
      }
    }
  }

  Future<void> _showMailActions(CMailSummary mail, {required bool inInbox}) async {
    final l = AppLocalizations.of(context)!;
    final api = ref.read(cmailApiProvider);
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    mail.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(ctx)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              if (inInbox)
                ListTile(
                  leading: Icon(mail.read
                      ? Icons.mark_email_unread_rounded
                      : Icons.mark_email_read_rounded),
                  title: Text(
                    mail.read ? l.cmailActionMarkUnread : l.cmailActionMarkRead,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _runMailAction(() =>
                        mail.read ? api.markUnread(mail.id) : api.markRead(mail.id));
                  },
                ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: cs.error),
                title: Text(
                  l.commonDelete,
                  style: TextStyle(fontWeight: FontWeight.w600, color: cs.error),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (dctx) => AlertDialog(
                      title: Text(l.commonDelete),
                      content: Text(l.cmailDeleteConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dctx).pop(false),
                          child: Text(l.commonCancel),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(dctx).colorScheme.error,
                            foregroundColor: Theme.of(dctx).colorScheme.onError,
                          ),
                          onPressed: () => Navigator.of(dctx).pop(true),
                          child: Text(l.commonDelete),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await _runMailAction(() => api.delete(mail.id));
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isStaff = _isStaff;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // Compose lives at the bottom as a FAB — the top-bar pill already names
      // the screen, so no in-page "CMail" header.
      floatingActionButton: isStaff
          ? FloatingActionButton.extended(
              heroTag: 'fab_cmail_compose',
              backgroundColor: cs.primaryContainer,
              foregroundColor: cs.onPrimaryContainer,
              onPressed: _compose,
              icon: const Icon(Icons.edit_rounded),
              label: Text(l.cmailCompose),
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 136),
            children: [
              if (isStaff)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
                  child: SegmentedButton<int>(
                    segments: [
                      ButtonSegment(
                        value: 0,
                        label: Text(l.cmailInbox),
                        icon: const Icon(Icons.inbox_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: 1,
                        label: Text(l.cmailSentTab),
                        icon: const Icon(Icons.send_rounded, size: 18),
                      ),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (s) =>
                        setState(() => _tab = s.first),
                    showSelectedIcon: false,
                  ),
                ),
              if (_tab == 0)
                _InboxList(
                  onOpen: _open,
                  onLongPress: (m) => _showMailActions(m, inInbox: true),
                  colorScheme: cs,
                )
              else
                _SentList(
                  onOpen: _open,
                  onLongPress: (m) => _showMailActions(m, inInbox: false),
                  colorScheme: cs,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InboxList extends ConsumerWidget {
  const _InboxList({
    required this.onOpen,
    required this.onLongPress,
    required this.colorScheme,
  });

  final void Function(CMailSummary) onOpen;
  final void Function(CMailSummary) onLongPress;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final inbox = ref.watch(cmailInboxProvider);
    return inbox.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(child: CmLoading()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Center(child: Text(e.toString())),
      ),
      data: (data) {
        if (data.mails.isEmpty) {
          return _Empty(
            icon: Icons.mark_email_unread_outlined,
            title: l.cmailEmptyInbox,
            hint: l.cmailEmptyInboxHint,
          );
        }
        return Column(
          children: [
            for (final m in data.mails)
              _MailRow(
                mail: m,
                colorScheme: colorScheme,
                theme: theme,
                onTap: () => onOpen(m),
                onLongPress: () => onLongPress(m),
                leadingName: m.senderName,
                unread: !m.read,
              ),
          ],
        );
      },
    );
  }
}

class _SentList extends ConsumerWidget {
  const _SentList({
    required this.onOpen,
    required this.onLongPress,
    required this.colorScheme,
  });

  final void Function(CMailSummary) onOpen;
  final void Function(CMailSummary) onLongPress;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final sent = ref.watch(cmailSentProvider);
    return sent.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: 120),
        child: Center(child: CmLoading()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.only(top: 120),
        child: Center(child: Text(e.toString())),
      ),
      data: (mails) {
        if (mails.isEmpty) {
          return _Empty(
            icon: Icons.send_outlined,
            title: l.cmailEmptySent,
            hint: l.cmailEmptyInboxHint,
          );
        }
        return Column(
          children: [
            for (final m in mails)
              _MailRow(
                mail: m,
                colorScheme: colorScheme,
                theme: theme,
                onTap: () => onOpen(m),
                onLongPress: () => onLongPress(m),
                leadingName: cmailAudienceLabel(l, m.audience),
                unread: false,
                stats: (m.recipientCount != null)
                    ? l.cmailReadStats(m.readCount ?? 0, m.recipientCount!)
                    : null,
              ),
          ],
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.icon, required this.title, required this.hint});

  final IconData icon;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 110),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 56, color: cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(hint,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _MailRow extends StatelessWidget {
  const _MailRow({
    required this.mail,
    required this.colorScheme,
    required this.theme,
    required this.onTap,
    required this.leadingName,
    required this.unread,
    this.onLongPress,
    this.stats,
  });

  final CMailSummary mail;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String leadingName;
  final bool unread;
  final String? stats;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    final now = DateTime.now();
    final sameDay = mail.createdAt.year == now.year &&
        mail.createdAt.month == now.month &&
        mail.createdAt.day == now.day;
    final time = sameDay
        ? DateFormat.jm().format(mail.createdAt)
        : DateFormat.MMMd().format(mail.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      child: Material(
        color: unread ? cs.surfaceContainer : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 6, end: 8),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unread ? cs.primary : Colors.transparent,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              leadingName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight:
                                    unread ? FontWeight.w900 : FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (mail.attachmentCount > 0)
                            Icon(Icons.attach_file_rounded,
                                size: 15, color: cs.onSurfaceVariant),
                          Text(
                            time,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mail.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              unread ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      if (mail.preview.isNotEmpty)
                        Text(
                          mail.preview.replaceAll('\n', ' '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      if (stats != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          stats!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
