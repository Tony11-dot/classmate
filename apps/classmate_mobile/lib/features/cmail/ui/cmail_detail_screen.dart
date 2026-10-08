// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/cm_tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/attachment_pill.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/cm_press.dart';
import '../../../ui/widgets/cm_surfaces.dart';
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
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
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
      useRootNavigator: true,
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
            child: CmEmptyState(
              icon: Icons.mark_email_unread_outlined,
              title: l.commonError,
              message: e.toString(),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              children: [
                // ── Header: subject, sender, audience ──
                CmCard(
                  tint: cs.primary,
                  radius: CmTokens.radiusXl,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mail.subject,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: cs.primary,
                            child: Text(
                              initial,
                              style: TextStyle(
                                color: cs.onPrimary,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mail.senderName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  date,
                                  style: theme.textTheme.labelMedium
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          CmPill(
                            icon: Icons.people_alt_rounded,
                            label: metaBits.isNotEmpty
                                ? '$audience · ${metaBits.join(' · ')}'
                                : audience,
                            color: cs.primary,
                          ),
                          // Sender can open the roster; recipients just see the count.
                          if (mail.isSender)
                            CmPress(
                              onTap: () => _showRecipients(context, ref),
                              child: _RecipientsPill(
                                label: l.cmailRecipients(mail.recipientCount),
                                tappable: true,
                              ),
                            )
                          else
                            _RecipientsPill(
                              label: l.cmailRecipients(mail.recipientCount),
                              tappable: false,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (mail.body.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  CmCard(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    child: SelectableText(
                      mail.body,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ),
                ],
                if (mail.attachments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  CmSectionHeader(
                    label: l.cmailAttachments,
                    icon: Icons.attach_file_rounded,
                    count: mail.attachments.length,
                  ),
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

/// Recipient-count pill; the sender's version shows a chevron and opens
/// the read-receipt roster.
class _RecipientsPill extends StatelessWidget {
  const _RecipientsPill({required this.label, required this.tappable});

  final String label;
  final bool tappable;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(9, 4, 5, 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: tappable
            ? Border.all(color: cs.outlineVariant.withValues(alpha: 0.6))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mark_email_read_rounded, size: 13, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (tappable)
            Icon(Icons.chevron_right_rounded, size: 15, color: cs.onSurfaceVariant)
          else
            const SizedBox(width: 4),
        ],
      ),
    );
  }
}
