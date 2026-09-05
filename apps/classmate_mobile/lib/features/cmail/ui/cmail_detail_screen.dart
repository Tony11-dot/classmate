// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/attachment_pill.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../data/cmail_api.dart';
import 'cmail_screen.dart' show cmailAudienceLabel;

/// Full mail view: subject, sender, audience, body, attachments. Opening it
/// marks the recipient's copy as read (server-side). Delete removes the mail
/// for everyone when the viewer is the sender, otherwise just their copy.
class CMailDetailScreen extends ConsumerWidget {
  const CMailDetailScreen({super.key, required this.mailId});

  final String mailId;

  Future<void> _delete(
      BuildContext context, WidgetRef ref, CMailDetail mail) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.cmailDeleteTitle),
        content:
            Text(mail.isSender ? l.cmailDeleteForAll : l.cmailDeleteForMe),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.commonCancel),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(cmailApiProvider).delete(mail.id);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  /// Sender taps the "N recipients" chip to see exactly who received the mail
  /// and who has read it (QA #44).
  Future<void> _showRecipients(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (ctx, scroll) => FutureBuilder<List<CMailRecipient>>(
            future: ref.read(cmailApiProvider).fetchRecipients(mailId),
            builder: (ctx, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CmLoading());
              }
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(snap.error.toString(),
                        textAlign: TextAlign.center),
                  ),
                );
              }
              final people = snap.data ?? const <CMailRecipient>[];
              return ListView.separated(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                itemCount: people.length + 1,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        l.cmailRecipients(people.length),
                        style: Theme.of(ctx)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    );
                  }
                  final p = people[i - 1];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: cs.primaryContainer,
                      child: Text(
                        p.name.isNotEmpty
                            ? p.name.characters.first.toUpperCase()
                            : '?',
                        style: TextStyle(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    title: Text(p.name),
                    subtitle: p.role != null ? Text(p.role!) : null,
                    trailing: Icon(
                      p.read
                          ? Icons.mark_email_read_rounded
                          : Icons.mark_email_unread_outlined,
                      size: 18,
                      color: p.read ? cs.primary : cs.outline,
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  static String _attachmentType(CMailAttachment a) {
    final mime = (a.mimeType ?? '').toLowerCase();
    final name = (a.fileName ?? a.url).toLowerCase();
    if (mime == 'application/pdf' || name.endsWith('.pdf')) return 'pdf';
    if (mime.startsWith('image/') ||
        name.endsWith('.png') ||
        name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.webp')) {
      return 'image';
    }
    return 'file';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final detail = ref.watch(cmailDetailProvider(mailId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.cmailTitle,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          detail.maybeWhen(
            data: (mail) => IconButton(
              tooltip: l.commonDelete,
              onPressed: () => _delete(context, ref, mail),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: detail.when(
          loading: () => const Center(child: CmLoading()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(e.toString(), textAlign: TextAlign.center),
            ),
          ),
          data: (mail) {
            final date =
                DateFormat.yMMMd().add_jm().format(mail.createdAt);
            final initial = mail.senderName.isNotEmpty
                ? mail.senderName.characters.first.toUpperCase()
                : '?';
            final audience = cmailAudienceLabel(l, mail.audience);
            final meta = mail.audienceMeta ?? const {};
            final metaBits = <String>[
              if ((meta['grades'] as List?)?.isNotEmpty ?? false)
                (meta['grades'] as List).join(', '),
              if ((meta['cohortNames'] as List?)?.isNotEmpty ?? false)
                (meta['cohortNames'] as List).join(', '),
            ];

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                Text(
                  mail.subject,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: cs.primaryContainer,
                      child: Text(
                        initial,
                        style: TextStyle(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mail.senderName,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            date,
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _Chip(
                      icon: Icons.people_alt_rounded,
                      label: metaBits.isNotEmpty
                          ? '$audience · ${metaBits.join(' · ')}'
                          : audience,
                      colorScheme: cs,
                    ),
                    // Sender can open the roster; recipients just see the count.
                    mail.isSender
                        ? InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => _showRecipients(context, ref),
                            child: _Chip(
                              icon: Icons.mark_email_read_rounded,
                              label:
                                  l.cmailRecipients(mail.recipientCount),
                              colorScheme: cs,
                              trailing: Icons.chevron_right_rounded,
                            ),
                          )
                        : _Chip(
                            icon: Icons.mark_email_read_rounded,
                            label: l.cmailRecipients(mail.recipientCount),
                            colorScheme: cs,
                          ),
                  ],
                ),
                const SizedBox(height: 18),
                if (mail.body.trim().isNotEmpty)
                  SelectableText(
                    mail.body,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                if (mail.attachments.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l.cmailAttachments,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final a in mail.attachments)
                        AttachmentPill(
                          url: a.url,
                          name: a.fileName?.isNotEmpty == true
                              ? a.fileName!
                              : l.cmailAttachments,
                          type: _attachmentType(a),
                        ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 2),
            Icon(trailing, size: 14, color: cs.onSurfaceVariant),
          ],
        ],
      ),
    );
  }
}
