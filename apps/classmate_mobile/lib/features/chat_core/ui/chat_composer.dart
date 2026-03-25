import 'package:flutter/material.dart';
import '../utils/chat_reply_codec.dart';

class ChatComposer extends StatelessWidget {
  final dynamic replyingTo;
  final VoidCallback? onCancelReply;

  const ChatComposer({
    this.replyingTo,
    this.onCancelReply,
    super.key,
    required this.controller,
    required this.onSend,
    required this.onCamera,
    required this.onAttach,
    required this.onMic,
    this.onStop,
    this.onMicHoldStart,
    this.onMicHoldMove,
    this.onMicHoldEnd,
    this.onMicHoldCancel,
    this.onTrashRecording,
    this.onPauseRecording,
    this.onResumeRecording,
    this.enabled = true,
    this.isStreaming = false,
    this.isRecording = false,
    this.isVoiceLocked = false,
    this.isVoicePaused = false,
    this.hint,
    this.hintText,
    this.forceMicOnlyTap = false,
  });

  final TextEditingController controller;

  final VoidCallback onSend;
  final VoidCallback onCamera;
  final VoidCallback onAttach;
  final VoidCallback onMic;
  final VoidCallback? onStop;

  final GestureLongPressStartCallback? onMicHoldStart;
  final GestureLongPressMoveUpdateCallback? onMicHoldMove;
  final GestureLongPressEndCallback? onMicHoldEnd;
  final VoidCallback? onMicHoldCancel;

  final VoidCallback? onTrashRecording;
  final VoidCallback? onPauseRecording;
  final VoidCallback? onResumeRecording;

  final bool enabled;
  final bool isStreaming;
  final bool isRecording;
  final bool isVoiceLocked;
  final bool isVoicePaused;
  final bool forceMicOnlyTap;

  final String? hint;
  final String? hintText;

  String get _resolvedHint {
    final v = (hintText ?? hint ?? 'Message').trim();
    return v.isEmpty ? 'Message' : v;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (replyingTo != null) _replyPreview(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final hasText = value.text.trim().isNotEmpty;

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: isRecording && !isVoiceLocked
                      ? _holding(context)
                      : isRecording && isVoiceLocked
                      ? _locked(context)
                      : _idle(context, hasText),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _replyPreview(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dynamic rawReplyingTo = replyingTo;
    final String sender = ((rawReplyingTo?.senderName ?? '') as String).trim();
    final String raw = ((rawReplyingTo?.text ?? '') as String).trim();
    final String preview = raw.isEmpty
        ? 'Replying to message'
        : replyPreviewText(raw);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 34,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sender.isEmpty ? 'Reply' : sender,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onCancelReply,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close_rounded, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _idle(BuildContext context, bool hasText) {
    final scheme = Theme.of(context).colorScheme;
    final canSend = enabled && hasText && !isStreaming && !isRecording;
    final showLeftTools = !hasText && !isStreaming && !isRecording;

    return _shell(
      context,
      key: const ValueKey('idle'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: showLeftTools ? 92 : 0,
            child: ClipRect(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 120),
                opacity: showLeftTools ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !showLeftTools,
                  child: showLeftTools
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _circleBtn(
                              context,
                              icon: Icons.camera_alt_rounded,
                              onTap: enabled ? onCamera : null,
                            ),
                            const SizedBox(width: 4),
                            _circleBtn(
                              context,
                              icon: Icons.attach_file_rounded,
                              onTap: enabled ? onAttach : null,
                            ),
                            const SizedBox(width: 4),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.16),
                ),
              ),
              child: TextField(
                key: const ValueKey('chat_input'),
                controller: controller,
                enabled: enabled && !isStreaming,
                minLines: 1,
                maxLines: 2,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: _resolvedHint,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 40,
            height: 40,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 120),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              child: isStreaming
                  ? _sendBtn(
                      context,
                      key: const ValueKey('stop_btn'),
                      icon: Icons.stop_rounded,
                      active: true,
                      onTap: enabled ? (onStop ?? onSend) : null,
                    )
                  : canSend
                  ? _sendBtn(
                      context,
                      key: const ValueKey('send_btn'),
                      icon: Icons.send_rounded,
                      active: true,
                      onTap: onSend,
                    )
                  : GestureDetector(
                      key: const ValueKey('mic_btn'),
                      behavior: HitTestBehavior.opaque,
                      onLongPressStart: enabled && !forceMicOnlyTap
                          ? onMicHoldStart
                          : null,
                      onLongPressMoveUpdate: enabled && !forceMicOnlyTap
                          ? onMicHoldMove
                          : null,
                      onLongPressEnd: enabled && !forceMicOnlyTap
                          ? onMicHoldEnd
                          : null,
                      onLongPressCancel: enabled && !forceMicOnlyTap
                          ? onMicHoldCancel
                          : null,
                      child: _circleBtn(
                        context,
                        icon: Icons.mic_none_rounded,
                        onTap: forceMicOnlyTap && enabled ? onMic : null,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _holding(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      key: const ValueKey('holding'),
      clipBehavior: Clip.none,
      children: [
        _shell(
          context,
          child: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.72,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: scheme.outlineVariant.withValues(alpha: 0.16),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: -3, end: 3),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeInOut,
                    builder: (context, dx, child) {
                      return Transform.translate(
                        offset: Offset(dx, 0),
                        child: child,
                      );
                    },
                    onEnd: () {},
                    child: Text(
                      '< Slide left to cancel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 54),
            ],
          ),
        ),
        Positioned(right: 8, bottom: 10, child: _holdingLockRail(context)),
      ],
    );
  }

  Widget _locked(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _shell(
      context,
      key: const ValueKey('locked'),
      child: Row(
        children: [
          _circleBtn(
            context,
            icon: Icons.delete_outline_rounded,
            onTap: enabled ? (onTrashRecording ?? onMic) : null,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isVoicePaused ? 'Paused' : 'Recording locked',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _circleBtn(
                    context,
                    icon: isVoicePaused
                        ? Icons.mic_none_rounded
                        : Icons.pause_rounded,
                    compact: true,
                    onTap: enabled
                        ? (isVoicePaused
                              ? (onResumeRecording ?? onMic)
                              : (onPauseRecording ?? onMic))
                        : null,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          _sendBtn(
            context,
            icon: Icons.send_rounded,
            active: true,
            onTap: enabled ? onMic : null,
          ),
        ],
      ),
    );
  }

  Widget _shell(BuildContext context, {required Widget child, Key? key}) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      key: key,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.14),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: -8,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.22),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _holdingLockRail(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 44,
      height: 82,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: scheme.surface.withValues(alpha: 0.96),
            shape: BoxShape.circle,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.18),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 16,
                spreadRadius: -6,
                offset: const Offset(0, 8),
                color: Colors.black.withValues(alpha: 0.22),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.lock_rounded, size: 22),
        ),
      ),
    );
  }

  Widget _circleBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
    bool compact = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 30.0 : 40.0;
    return AnimatedScale(
      duration: const Duration(milliseconds: 160),
      scale: onTap == null ? 0.98 : 1,
      child: Material(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: compact ? 18 : 20),
          ),
        ),
      ),
    );
  }

  Widget _sendBtn(
    BuildContext context, {
    Key? key,
    required IconData icon,
    required bool active,
    required VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      key: key,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      scale: active ? 1 : 0.98,
      child: Material(
        color: active
            ? scheme.primary
            : scheme.surfaceContainerHighest.withValues(alpha: 0.72),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: active ? onTap : null,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 20,
              color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
