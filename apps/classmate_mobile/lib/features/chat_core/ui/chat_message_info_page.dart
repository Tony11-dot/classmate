import 'package:flutter/material.dart';

import '../models/chat_message_info.dart';

class ChatMessageInfoPage extends StatelessWidget {
  const ChatMessageInfoPage({
    super.key,
    required this.info,
    this.previewTitle = '',
    this.previewBody = '',
    this.previewMeta = '',
    this.previewBubble,
    this.previewBubbleBuilder,
    this.seenByNames = const <String>[],
    this.deliveredToNames = const <String>[],
  });

  final ChatMessageInfo info;
  final String previewTitle;
  final String previewBody;
  final String previewMeta;
  final Widget? previewBubble;
  final WidgetBuilder? previewBubbleBuilder;
  final List<String> seenByNames;
  final List<String> deliveredToNames;

  String _statusLabel() {
    final deleteState = info.deleteState.trim().toUpperCase();
    if (deleteState.isNotEmpty && deleteState != 'VISIBLE') {
      return info.deleteState.trim();
    }
    if (info.seen) return 'Seen';
    if (info.delivered) return 'Delivered';
    return 'Not delivered';
  }

  String _statusTime() {
    if (info.seen && info.seenAt.trim().isNotEmpty) return info.seenAt.trim();
    if (info.delivered && info.deliveredAt.trim().isNotEmpty) {
      return info.deliveredAt.trim();
    }
    return info.sentAt.trim();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

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

    final fallbackPreview = _ThreadPreviewBubble(
      isMine: info.isMine,
      senderLabel: previewTitle.trim(),
      body: previewBody.trim(),
      meta: previewMeta.trim(),
    );
    final resolvedPreview =
        previewBubbleBuilder?.call(context) ?? previewBubble ?? fallbackPreview;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: scheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.22),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      'Info',
                      textAlign: TextAlign.center,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxPreviewHeight = constraints.maxHeight * 0.48;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: maxPreviewHeight,
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Align(
                              alignment: info.isMine
                                  ? Alignment.topRight
                                  : Alignment.topLeft,
                              child: resolvedPreview,
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
                                color: scheme.surfaceContainerHighest.withValues(
                                  alpha: 0.42,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: scheme.outlineVariant.withValues(
                                    alpha: 0.22,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: [
                                  factRow(
                                    Icons.schedule_rounded,
                                    'Status',
                                    _statusLabel(),
                                  ),
                                  const SizedBox(height: 14),
                                  factRow(
                                    Icons.access_time_rounded,
                                    'Status time',
                                    _statusTime(),
                                  ),
                                  const SizedBox(height: 14),
                                  factRow(
                                    Icons.send_rounded,
                                    'Sent at',
                                    info.sentAt.trim(),
                                  ),
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
          ],
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
  static const int _truncateAt = 420;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final body = widget.body.trim().isEmpty ? '(empty)' : widget.body.trim();
    final shouldTruncate = body.length > _truncateAt;
    final visibleText = shouldTruncate && !_expanded
        ? '${body.substring(0, _truncateAt).trimRight()}…'
        : body;

    final bubbleColor = widget.isMine
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final bodyColor = widget.isMine
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    final metaColor = (widget.isMine
            ? scheme.onPrimaryContainer
            : scheme.onSurfaceVariant)
        .withValues(alpha: 0.82);

    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(widget.isMine ? 18 : 6),
          bottomRight: Radius.circular(widget.isMine ? 6 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.senderLabel.isNotEmpty && !widget.isMine) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.senderLabel,
                style: text.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Align(
            alignment:
                widget.isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(
              visibleText,
              style: text.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: bodyColor,
              ),
            ),
          ),
          if (shouldTruncate) ...[
            const SizedBox(height: 8),
            Align(
              alignment:
                  widget.isMine ? Alignment.centerRight : Alignment.centerLeft,
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 2,
                  ),
                  child: Text(
                    _expanded ? 'Read less' : 'Read more',
                    style: text.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
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
                style: text.bodySmall?.copyWith(color: metaColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
