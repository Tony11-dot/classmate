import 'package:flutter/material.dart';

import '../../../chat_core/ui/chat_composer.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onPickImage,
    required this.onRecord,
    this.onPickFile,
    this.replyingTo,
    this.onCancelReply,
    this.enabled = true,
    this.isRecording = false,
    this.isVoiceLocked = false,
    this.isVoicePaused = false,
    this.onStop,
    this.onMicHoldStart,
    this.onMicHoldMove,
    this.onMicHoldEnd,
    this.onMicHoldCancel,
    this.onTrashRecording,
    this.onPauseRecording,
    this.onResumeRecording,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onPickImage;
  final VoidCallback onRecord;
  final VoidCallback? onPickFile;
  final dynamic replyingTo;
  final VoidCallback? onCancelReply;
  final bool enabled;
  final bool isRecording;
  final bool isVoiceLocked;
  final bool isVoicePaused;
  final VoidCallback? onStop;
  final GestureLongPressStartCallback? onMicHoldStart;
  final GestureLongPressMoveUpdateCallback? onMicHoldMove;
  final GestureLongPressEndCallback? onMicHoldEnd;
  final VoidCallback? onMicHoldCancel;
  final VoidCallback? onTrashRecording;
  final VoidCallback? onPauseRecording;
  final VoidCallback? onResumeRecording;

  @override
  Widget build(BuildContext context) {
    return ChatComposer(
      controller: controller,
      replyingTo: replyingTo,
      onCancelReply: onCancelReply,
      onSend: onSend,
      onCamera: onPickImage,
      onAttach: onPickFile ?? onPickImage,
      onMic: onRecord,
      onStop: onStop,
      onMicHoldStart: onMicHoldStart,
      onMicHoldMove: onMicHoldMove,
      onMicHoldEnd: onMicHoldEnd,
      onMicHoldCancel: onMicHoldCancel,
      onTrashRecording: onTrashRecording,
      onPauseRecording: onPauseRecording,
      onResumeRecording: onResumeRecording,
      enabled: enabled,
      isRecording: isRecording,
      isVoiceLocked: isVoiceLocked,
      isVoicePaused: isVoicePaused,
      hintText: 'Message',
    );
  }
}
