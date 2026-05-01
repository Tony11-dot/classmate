import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../ui/chat_composer.dart';

typedef ClassroomRow = Map<String, dynamic>;

class ClassroomChatSurface extends StatelessWidget {
  const ClassroomChatSurface({
    super.key,
    required this.rows,
    required this.scrollController,
    required this.showScrollToBottom,
    required this.onScrollNotification,
    required this.onScrollToBottomTap,
    required this.onPinnedChipTap,
    required this.onBubbleLongPress,
    required this.onBubbleReplySwipe,
    required this.onBubbleInfoSwipe,
    required this.onReplyPreviewTap,
    required this.onSend,
    required this.onCamera,
    required this.onAttach,
    required this.onMic,
    required this.onMicHoldStart,
    required this.onMicHoldMove,
    required this.onMicHoldEnd,
    required this.onMicHoldCancel,
    required this.onActiveHoldMove,
    required this.onActiveHoldRelease,
    required this.onActiveHoldCancel,
    required this.onTrashRecording,
    required this.onPauseRecording,
    required this.onResumeRecording,
    required this.controller,
    required this.replyingTo,
    required this.onCancelReply,
    required this.topContent,
    required this.isSending,
    required this.isRecording,
    required this.isVoiceLocked,
    required this.isVoicePaused,
    required this.recordingElapsed,
    required this.activeHoldDx,
    required this.activeHoldDy,
    required this.renderBubble,
    required this.renderPinnedChipLabel,
    this.bottomPadding = 24,
  });

  final List<ClassroomRow> rows;
  final ScrollController scrollController;
  final bool showScrollToBottom;
  final bool Function(ScrollNotification notification) onScrollNotification;
  final VoidCallback onScrollToBottomTap;
  final void Function(String messageId) onPinnedChipTap;
  final void Function(ClassroomRow row, Offset globalPosition)
  onBubbleLongPress;
  final void Function(ClassroomRow row) onBubbleReplySwipe;
  final void Function(ClassroomRow row) onBubbleInfoSwipe;
  final VoidCallback? onReplyPreviewTap;
  final Future<void> Function() onSend;
  final Future<void> Function() onCamera;
  final Future<void> Function() onAttach;
  final Future<void> Function() onMic;
  final Future<void> Function(LongPressStartDetails d) onMicHoldStart;
  final void Function(LongPressMoveUpdateDetails d) onMicHoldMove;
  final Future<void> Function(LongPressEndDetails d) onMicHoldEnd;
  final Future<void> Function() onMicHoldCancel;
  final void Function(Offset globalPosition) onActiveHoldMove;
  final Future<void> Function() onActiveHoldRelease;
  final Future<void> Function() onActiveHoldCancel;
  final Future<void> Function() onTrashRecording;
  final Future<void> Function() onPauseRecording;
  final Future<void> Function() onResumeRecording;
  final TextEditingController controller;
  final ({String senderName, String text})? replyingTo;
  final VoidCallback onCancelReply;
  final Widget topContent;
  final bool isSending;
  final bool isRecording;
  final bool isVoiceLocked;
  final bool isVoicePaused;
  final Duration recordingElapsed;
  final double activeHoldDx;
  final double activeHoldDy;
  final Widget Function(BuildContext context, ClassroomRow row) renderBubble;
  final String Function(ClassroomRow row) renderPinnedChipLabel;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pinnedRows = rows.where((row) {
      final pinned = row['isPinned'] == true;
      return pinned;
    }).toList();

    return Column(
      children: [
        if (pinnedRows.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pinnedRows.map((row) {
                  final id = (row['id'] ?? '').toString().trim();
                  return InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: id.isEmpty ? null : () => onPinnedChipTap(id),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.push_pin_rounded,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              renderPinnedChipLabel(row),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: onScrollNotification,
                child: ListView.builder(
                  controller: scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    bottomPadding + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  itemCount: rows.length,
                  itemBuilder: (context, index) =>
                      renderBubble(context, rows[index]),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: showScrollToBottom
                    ? FloatingActionButton.small(
                        heroTag: 'classroom-scroll-bottom',
                        backgroundColor: const Color(0xFF0A84FF),
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        onPressed: onScrollToBottomTap,
                        child: const Icon(Icons.keyboard_arrow_down_rounded),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
        ChatComposer(
          controller: controller,
          topContent: topContent,
          enabled: !isSending,
          isStreaming: false,
          isRecording: isRecording,
          isVoiceLocked: isVoiceLocked,
          isVoicePaused: isVoicePaused,
          recordingElapsed: recordingElapsed,
          hintText: l.chatMessageHint,
          onSend: isSending || isRecording ? () async {} : onSend,
          onCamera: isSending || isRecording ? () async {} : onCamera,
          onAttach: isSending || isRecording ? () async {} : onAttach,
          onMic: onMic,
          onMicHoldStart: onMicHoldStart,
          onMicHoldMove: onMicHoldMove,
          onMicHoldEnd: onMicHoldEnd,
          onMicHoldCancel: onMicHoldCancel,
          onActiveHoldMove: onActiveHoldMove,
          onActiveHoldRelease: onActiveHoldRelease,
          onActiveHoldCancel: onActiveHoldCancel,
          activeHoldDx: activeHoldDx,
          activeHoldDy: activeHoldDy,
          onTrashRecording: onTrashRecording,
          onPauseRecording: onPauseRecording,
          onResumeRecording: onResumeRecording,
          showCamera: true,
          showAttach: true,
          showMic: true,
          forceMicOnlyTap: false,
          hasDraft: false,
          replyingTo: replyingTo,
          onCancelReply: onCancelReply,
          onTapReplyPreview: onReplyPreviewTap,
        ),
      ],
    );
  }
}
