import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/chat_message_info.dart';

/// Per-participant read record for the info page.
class MessageReadParticipant {
  const MessageReadParticipant({required this.name, this.time = ''});
  final String name;
  final String time;
}

class ChatMessageInfoPage extends StatelessWidget {
  const ChatMessageInfoPage({
    super.key,
    required this.info,
    this.onBack,
    this.previewTitle = '',
    this.previewBody = '',
    this.previewMeta = '',
    this.previewBubble,
    this.previewBubbleBuilder,
    /// Legacy plain-name lists kept for callers that haven't migrated.
    this.seenByNames = const <String>[],
    this.deliveredToNames = const <String>[],
    /// Rich participant lists (used when available; takes priority over legacy).
    this.seenBy = const <MessageReadParticipant>[],
    this.deliveredTo = const <MessageReadParticipant>[],
    this.pendingFor = const <MessageReadParticipant>[],
  });

  final ChatMessageInfo info;
  final VoidCallback? onBack;
  final String previewTitle;
  final String previewBody;
  final String previewMeta;
  final Widget? previewBubble;
  final WidgetBuilder? previewBubbleBuilder;
  final List<String> seenByNames;
  final List<String> deliveredToNames;
  final List<MessageReadParticipant> seenBy;
  final List<MessageReadParticipant> deliveredTo;
  final List<MessageReadParticipant> pendingFor;

  String _statusLabel(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final deleteState = info.deleteState.trim().toUpperCase();
    if (deleteState.isNotEmpty && deleteState != 'VISIBLE') {
      return info.deleteState.trim();
    }
    if (info.seen) return l.chatMessageInfoSeen;
    if (info.delivered) return l.chatMessageInfoDelivered;
    return l.chatMessageInfoNotDelivered;
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
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Resolve which participant lists to use.
    final effectiveSeen = seenBy.isNotEmpty
        ? seenBy
        : seenByNames.map((n) => MessageReadParticipant(name: n)).toList();
    final effectiveDelivered = deliveredTo.isNotEmpty
        ? deliveredTo
        : deliveredToNames.map((n) => MessageReadParticipant(name: n)).toList();
    final effectivePending = pendingFor;

    final hasParticipants = effectiveSeen.isNotEmpty ||
        effectiveDelivered.isNotEmpty ||
        effectivePending.isNotEmpty;

    Widget factRow(IconData icon, String label, String value) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800, color: cs.onSurface)),
                  const SizedBox(height: 2),
                  Text(
                    value.trim().isEmpty ? l.profileEmptyValue : value.trim(),
                    style:
                        tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        );

    final fallbackPreview = _ThreadPreviewBubble(
      isMine: info.isMine,
      senderLabel: previewTitle.trim(),
      body: previewBody.trim(),
      meta: previewMeta.trim(),
    );
    final resolvedPreview =
        previewBubbleBuilder?.call(context) ?? previewBubble ?? fallbackPreview;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App bar ────────────────────────────────────────────────────
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(bottom: BorderSide(color: cs.outlineVariant)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      final cb = onBack;
                      if (cb != null) {
                        cb();
                        return;
                      }
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Expanded(
                    child: Text(
                      l.chatMessageInfoShortTitle,
                      textAlign: TextAlign.center,
                      style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // ── Scrollable body ────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 32),
                children: [
                  // ── Bubble preview ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                    child: Align(
                      alignment: info.isMine
                          ? Alignment.topRight
                          : Alignment.topLeft,
                      child: resolvedPreview,
                    ),
                  ),

                  // ── Metadata card ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.42),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.22)),
                    ),
                    child: Column(
                      children: [
                        factRow(Icons.schedule_rounded,
                            l.chatMessageInfoStatus, _statusLabel(context)),
                        const SizedBox(height: 14),
                        factRow(Icons.access_time_rounded,
                            l.chatMessageInfoStatusTime, _statusTime()),
                        const SizedBox(height: 14),
                        factRow(Icons.send_rounded, l.chatMessageInfoSentAt,
                            info.sentAt.trim()),
                        if (info.deliveredAt.trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          factRow(Icons.done_rounded,
                              l.chatMessageInfoDeliveredAt,
                              info.deliveredAt.trim()),
                        ],
                        if (info.seenAt.trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          factRow(Icons.done_all_rounded,
                              l.chatMessageInfoSeenAt, info.seenAt.trim()),
                        ],
                        const SizedBox(height: 14),
                        factRow(
                            Icons.category_rounded,
                            l.chatMessageInfoMessageType,
                            info.messageType.trim().isEmpty
                                ? l.chatMessageInfoTextType
                                : info.messageType.trim()),
                        const SizedBox(height: 14),
                        factRow(
                            Icons.edit_rounded,
                            l.chatMessageInfoEdited,
                            info.edited
                                ? l.chatMessageInfoYes
                                : l.chatMessageInfoNo),
                        const SizedBox(height: 14),
                        factRow(
                            Icons.forward_rounded,
                            l.chatMessageInfoForwarded,
                            info.forwarded
                                ? l.chatMessageInfoYes
                                : l.chatMessageInfoNo),
                        if (info.voiceDuration.trim().isNotEmpty) ...[
                          const SizedBox(height: 14),
                          factRow(Icons.mic_rounded,
                              l.chatMessageInfoVoiceDuration,
                              info.voiceDuration.trim()),
                        ],
                      ],
                    ),
                  ),

                  // ── Per-participant sections (WhatsApp style) ─────────────
                  if (hasParticipants) ...[
                    const SizedBox(height: 20),
                    _ParticipantSection(
                      icon: Icons.done_all_rounded,
                      iconColor: const Color(0xFF22C55E),
                      title: 'Read',
                      participants: effectiveSeen,
                      emptyMessage: 'No one has read this yet',
                    ),
                    if (effectiveDelivered.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _ParticipantSection(
                        icon: Icons.done_rounded,
                        iconColor: const Color(0xFF60A5FA),
                        title: 'Delivered',
                        participants: effectiveDelivered,
                      ),
                    ],
                    if (effectivePending.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _ParticipantSection(
                        icon: Icons.schedule_rounded,
                        iconColor: const Color(0xFFF59E0B),
                        title: 'Pending',
                        participants: effectivePending,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Per-participant section (WhatsApp-style) ──────────────────────────────────

class _ParticipantSection extends StatelessWidget {
  const _ParticipantSection({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.participants,
    this.emptyMessage,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final List<MessageReadParticipant> participants;
  final String? emptyMessage;

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].length >= 2
          ? parts[0].substring(0, 2).toUpperCase()
          : parts[0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                participants.isEmpty
                    ? title
                    : '$title  ${participants.length}',
                style: tt.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),

        // ── Participant rows ─────────────────────────────────────────────
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: participants.isEmpty && emptyMessage != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Text(emptyMessage!,
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant)),
                )
              : Column(
                  children: [
                    for (int i = 0; i < participants.length; i++) ...[
                      _ParticipantRow(
                        participant: participants[i],
                        initials: _initials(participants[i].name),
                        avatarSeed: participants[i].name,
                      ),
                      if (i < participants.length - 1)
                        Divider(
                          height: 1,
                          indent: 60,
                          endIndent: 0,
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.participant,
    required this.initials,
    required this.avatarSeed,
  });

  final MessageReadParticipant participant;
  final String initials;
  final String avatarSeed;

  static const _palette = <Color>[
    Color(0xFF9CCC65), Color(0xFF4FC3F7), Color(0xFFFFB74D),
    Color(0xFFBA68C8), Color(0xFFFF8A65), Color(0xFF4DB6AC),
    Color(0xFFA1887F), Color(0xFF7986CB),
  ];

  Color get _bg {
    final seed = avatarSeed.toLowerCase().runes.fold(0, (a, b) => a + b);
    return _palette[seed % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fg = ThemeData.estimateBrightnessForColor(_bg) == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _bg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800, color: fg),
            ),
          ),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              participant.name.isEmpty ? 'Unknown' : participant.name,
              style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Timestamp
          if (participant.time.isNotEmpty)
            Text(
              participant.time,
              style: tt.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 11),
            ),
        ],
      ),
    );
  }
}

// ── Fallback bubble preview ───────────────────────────────────────────────────

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
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final body = widget.body.trim().isEmpty
        ? l.chatMessageInfoEmptyBody
        : widget.body.trim();
    final shouldTruncate = body.length > _truncateAt;
    final visibleText = shouldTruncate && !_expanded
        ? '${body.substring(0, _truncateAt).trimRight()}…'
        : body;

    final bubbleColor =
        widget.isMine ? cs.primaryContainer : cs.surfaceContainerHighest;
    final bodyColor =
        widget.isMine ? cs.onPrimaryContainer : cs.onSurface;
    final metaColor =
        (widget.isMine ? cs.onPrimaryContainer : cs.onSurfaceVariant)
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
              child: Text(widget.senderLabel,
                  style: tt.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800, color: cs.primary)),
            ),
            const SizedBox(height: 6),
          ],
          Align(
            alignment:
                widget.isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Text(visibleText,
                style: tt.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600, color: bodyColor)),
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
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  child: Text(
                    _expanded ? l.chatMessageInfoReadLess : l.chatMessageInfoReadMore,
                    style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800, color: cs.primary),
                  ),
                ),
              ),
            ),
          ],
          if (widget.meta.isNotEmpty) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(widget.meta,
                  style: tt.bodySmall?.copyWith(color: metaColor)),
            ),
          ],
        ],
      ),
    );
  }
}
