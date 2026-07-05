import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'chat_emoji_picker_sheet.dart';

/// TikTok-style message context overlay.
///
/// Layout (top → bottom, centered on screen):
///   1. Emoji reaction strip (pill)
///   2. Message bubble preview (aligned left/right per [isMine])
///   3. Action panel (full width, rounded rectangle)
///
/// Tapping the blurred background dismisses with `null`.
/// Selecting an action or emoji dismisses with the action key.
class ChatContextOverlay extends StatelessWidget {
  const ChatContextOverlay({
    super.key,
    required this.messageBubble,
    required this.isMine,
    this.canReply = true,
    this.canEdit = false,
    this.canDelete = false,
    this.canCopy = false,
    this.canForward = true,
    this.canPin = false,
    this.canViewInfo = false,
    this.canReport = false,
    this.pinLabel,
    this.pickerAllowedEmojis,
  });

  final Widget messageBubble;
  final bool isMine;
  final bool canReply;
  final bool canEdit;
  final bool canDelete;
  final bool canCopy;
  final bool canForward;
  final bool canPin;
  final bool canViewInfo;
  final bool canReport;
  final String? pinLabel;
  final List<String>? pickerAllowedEmojis;

  // ─── Static show helper ──────────────────────────────────────────────────
  static Future<String?> show(
    BuildContext context, {
    required Widget messageBubble,
    required bool isMine,
    bool canReply = true,
    bool canEdit = false,
    bool canDelete = false,
    bool canCopy = false,
    bool canForward = true,
    bool canPin = false,
    bool canViewInfo = false,
    bool canReport = false,
    String? pinLabel,
    List<String>? pickerAllowedEmojis,
  }) {
    final l = AppLocalizations.of(context)!;
    return showGeneralDialog<String>(
      context: context,
      barrierDismissible: false, // handled inside widget
      barrierLabel: l.chatContextDismiss,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 210),
      transitionBuilder: (ctx, anim, secAnim, child) => FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: child,
      ),
      pageBuilder: (ctx, anim, secAnim) => ChatContextOverlay(
        messageBubble: messageBubble,
        isMine: isMine,
        canReply: canReply,
        canEdit: canEdit,
        canDelete: canDelete,
        canCopy: canCopy,
        canForward: canForward,
        canPin: canPin,
        canViewInfo: canViewInfo,
        canReport: canReport,
        pinLabel: pinLabel,
        pickerAllowedEmojis: pickerAllowedEmojis,
      ),
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        // Tap empty background → dismiss
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(null),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.black.withValues(alpha: 0.55),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 32,
                  ),
                  child: GestureDetector(
                    // Absorb taps within content area so they don't
                    // propagate to the dismiss handler above.
                    onTap: () {},
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── 1. Emoji reaction strip ───────────────
                          Center(
                            child: _ReactionStrip(
                              onReact: (emoji) =>
                                  Navigator.of(context).pop('react:$emoji'),
                              onOpenPicker: () async {
                                // No filter — full picker shows all emojis.
                                final picked = await ChatEmojiPickerSheet.show(context);
                                if (!context.mounted) return;
                                if ((picked ?? '').trim().isEmpty) return;
                                Navigator.of(context)
                                    .pop('react:${picked!.trim()}');
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          // ── 2. Message bubble preview ─────────────
                          Align(
                            alignment: isMine
                                ? AlignmentDirectional.centerEnd
                                : AlignmentDirectional.centerStart,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 270),
                              // IgnorePointer: bubble is visual-only in overlay
                              child: IgnorePointer(child: messageBubble),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // ── 3. Action panel ───────────────────────
                          _ActionPanel(
                            canReply: canReply,
                            canCopy: canCopy,
                            canForward: canForward,
                            canPin: canPin,
                            pinLabel: pinLabel,
                            canViewInfo: canViewInfo,
                            canEdit: canEdit,
                            canDelete: canDelete,
                            canReport: canReport,
                            onAction: (key) =>
                                Navigator.of(context).pop(key),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Emoji reaction strip ────────────────────────────────────────────────────

class _ReactionStrip extends StatelessWidget {
  const _ReactionStrip({
    required this.onReact,
    required this.onOpenPicker,
  });

  final ValueChanged<String> onReact;
  final VoidCallback onOpenPicker;

  static const _reactions = ['❤️', '👍', '😂', '😮', '😢', '🙏', '🔥', '🎉'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in _reactions)
              GestureDetector(
                onTap: () => onReact(r),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(r, style: const TextStyle(fontSize: 26)),
                ),
              ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onOpenPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action panel ────────────────────────────────────────────────────────────

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.canReply,
    required this.canCopy,
    required this.canForward,
    required this.canPin,
    required this.pinLabel,
    required this.canViewInfo,
    required this.canEdit,
    required this.canDelete,
    required this.canReport,
    required this.onAction,
  });

  final bool canReply;
  final bool canCopy;
  final bool canForward;
  final bool canPin;
  final String? pinLabel;
  final bool canViewInfo;
  final bool canEdit;
  final bool canDelete;
  final bool canReport;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final items = <({IconData icon, String label, String key, bool isDanger})>[
      if (canReply)
        (
          icon: Icons.reply_rounded,
          label: l.chatComposerReplyFallback,
          key: 'reply',
          isDanger: false,
        ),
      if (canCopy)
        (
          icon: Icons.copy_rounded,
          label: l.chatContextCopyText,
          key: 'copy',
          isDanger: false,
        ),
      if (canForward)
        (
          icon: Icons.forward_rounded,
          label: l.classroomsForwardAction,
          key: 'forward',
          isDanger: false,
        ),
      if (canPin)
        (
          icon: Icons.push_pin_outlined,
          label: pinLabel ?? l.classroomDetailPinAction,
          key: 'pin',
          isDanger: false,
        ),
      if (canViewInfo)
        (
          icon: Icons.info_outline_rounded,
          label: l.classroomDetailMessageInfoTitle,
          key: 'info',
          isDanger: false,
        ),
      if (canEdit)
        (
          icon: Icons.edit_rounded,
          label: l.classroomDetailEditMessageTitle,
          key: 'edit',
          isDanger: false,
        ),
      if (canDelete)
        (
          icon: Icons.delete_outline_rounded,
          label: l.chatContextDelete,
          key: 'delete',
          isDanger: true,
        ),
      if (canReport)
        (
          icon: Icons.flag_outlined,
          label: l.chatReportButton,
          key: 'report',
          isDanger: true,
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: cs.outlineVariant,
                  indent: 20,
                  endIndent: 20,
                ),
              _ActionTile(
                icon: items[i].icon,
                label: items[i].label,
                isDanger: items[i].isDanger,
                onTap: () => onAction(items[i].key),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = isDanger
        ? cs.error
        : cs.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 21, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
