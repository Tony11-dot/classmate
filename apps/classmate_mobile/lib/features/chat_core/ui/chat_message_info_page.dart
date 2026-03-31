import 'package:flutter/material.dart';

import '../models/chat_message_info.dart';

class ChatMessageInfoPage extends StatelessWidget {
  const ChatMessageInfoPage({
    super.key,
    required this.info,
    this.previewTitle = '',
    this.previewBody = '',
    this.previewMeta = '',
    this.seenByNames = const <String>[],
    this.deliveredToNames = const <String>[],
  });

  final ChatMessageInfo info;
  final String previewTitle;
  final String previewBody;
  final String previewMeta;
  final List<String> seenByNames;
  final List<String> deliveredToNames;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    String statusLabel() {
      final deleteState = info.deleteState.trim().toUpperCase();
      if (deleteState.isNotEmpty && deleteState != 'VISIBLE') {
        return info.deleteState.trim();
      }
      if (info.seen) return 'Seen';
      if (info.delivered) return 'Delivered';
      return 'Not delivered';
    }

    String statusTime() {
      if (info.seen && info.seenAt.trim().isNotEmpty) return info.seenAt.trim();
      if (info.delivered && info.deliveredAt.trim().isNotEmpty) {
        return info.deliveredAt.trim();
      }
      return info.sentAt.trim();
    }

    Widget factRow(IconData icon, String label, String value) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: text.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.trim().isEmpty ? '—' : value.trim(),
                  style: text.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    Widget peopleCard(
      String title,
      List<String> names, {
      required IconData icon,
    }) {
      if (names.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...names.map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    name,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message info'),
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxPreviewHeight = constraints.maxHeight * 0.48;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(alpha: 0.18),
                    border: Border(
                      bottom: BorderSide(
                        color: scheme.outlineVariant.withValues(alpha: 0.22),
                      ),
                    ),
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: maxPreviewHeight,
                    ),
                    child: Align(
                      alignment: info.isMine
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: _ThreadPreviewBubble(
                        isMine: info.isMine,
                        senderLabel: previewTitle.trim(),
                        body: previewBody.trim(),
                        meta: previewMeta.trim(),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: scheme.outlineVariant.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Column(
                          children: [
                            factRow(Icons.schedule_rounded, 'Status', statusLabel()),
                            const SizedBox(height: 14),
                            factRow(Icons.access_time_rounded, 'Status time', statusTime()),
                            const SizedBox(height: 14),
                            factRow(Icons.send_rounded, 'Sent at', info.sentAt.trim()),
                            if (info.deliveredAt.trim().isNotEmpty) ...[
                              const SizedBox(height: 14),
                              factRow(
                                Icons.done_rounded,
                                'Delivered at',
                                info.deliveredAt.trim(),
                              ),
                            ],
                            if (info.seenAt.trim().isNotEmpty) ...[
                              const SizedBox(height: 14),
                              factRow(
                                Icons.done_all_rounded,
                                'Seen at',
                                info.seenAt.trim(),
                              ),
                            ],
                            const SizedBox(height: 14),
                            factRow(
                              Icons.category_rounded,
                              'Message type',
                              info.messageType.trim().isEmpty
                                  ? 'Text'
                                  : info.messageType.trim(),
                            ),
                            const SizedBox(height: 14),
                            factRow(
                              Icons.edit_rounded,
                              'Edited',
                              info.edited ? 'Yes' : 'No',
                            ),
                            const SizedBox(height: 14),
                            factRow(
                              Icons.forward_rounded,
                              'Forwarded',
                              info.forwarded ? 'Yes' : 'No',
                            ),
                            if (info.voiceDuration.trim().isNotEmpty) ...[
                              const SizedBox(height: 14),
                              factRow(
                                Icons.mic_rounded,
                                'Voice duration',
                                info.voiceDuration.trim(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (seenByNames.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        peopleCard(
                          'Seen by',
                          seenByNames,
                          icon: Icons.visibility_rounded,
                        ),
                      ],
                      if (deliveredToNames.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        peopleCard(
                          'Delivered to',
                          deliveredToNames,
                          icon: Icons.mark_email_read_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThreadPreviewBubble extends StatefulWidget {
  const _ThreadPreviewBubble({
    required this.isMine,
    required this.senderLabel,
    required this.body,
    required this.meta,
  });

  final bool isMine;
  final String senderLabel;
  final String body;
  final String meta;

  @override
  State<_ThreadPreviewBubble> createState() => _ThreadPreviewBubbleState();
}

class _ThreadPreviewBubbleState extends State<_ThreadPreviewBubble> {
  bool _expanded = false;

  bool get _shouldOfferExpand {
    final text = widget.body.trim();
    if (text.isEmpty) return false;
    if (text.length > 220) return true;
    if ('\n'.allMatches(text).length >= 5) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final bodyText = widget.body.trim().isEmpty ? '(empty)' : widget.body.trim();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 280),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: widget.isMine ? scheme.primaryContainer : scheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: Radius.circular(widget.isMine ? 15 : 5),
            bottomRight: Radius.circular(widget.isMine ? 5 : 15),
          ),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.senderLabel.isNotEmpty && !widget.isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  widget.senderLabel,
                  style: text.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              ),
            Text(
              bodyText,
              maxLines: _expanded ? null : 7,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.fade,
              style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: widget.isMine
                    ? scheme.onPrimaryContainer
                    : scheme.onSurface,
                height: 1.25,
              ),
            ),
            if (_shouldOfferExpand) ...[
              const SizedBox(height: 6),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Text(
                    _expanded ? 'Read less' : 'Read more',
                    style: text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
            if (widget.meta.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  widget.meta,
                  style: text.bodySmall?.copyWith(
                    color: (widget.isMine
                            ? scheme.onPrimaryContainer
                            : scheme.onSurfaceVariant)
                        .withValues(alpha: 0.82),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
