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

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isStaff = _isStaff;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 136),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.cmailTitle,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (isStaff)
                      FilledButton.icon(
                        onPressed: _compose,
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: Text(l.cmailCompose),
                      ),
                  ],
                ),
              ),
              if (isStaff)
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
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
                _InboxList(onOpen: _open, colorScheme: cs)
              else
                _SentList(onOpen: _open, colorScheme: cs),
            ],
          ),
        ),
      ),
    );
  }
}

class _InboxList extends ConsumerWidget {
  const _InboxList({required this.onOpen, required this.colorScheme});

  final void Function(CMailSummary) onOpen;
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
  const _SentList({required this.onOpen, required this.colorScheme});

  final void Function(CMailSummary) onOpen;
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
    this.stats,
  });

  final CMailSummary mail;
  final ColorScheme colorScheme;
  final ThemeData theme;
  final VoidCallback onTap;
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
