import 'package:flutter/material.dart';

import '../utils/chat_reply_codec.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onCamera,
    required this.onAttach,
    required this.onMic,
    this.replyingTo,
    this.onCancelReply,
    this.onTapReplyPreview,
    this.onStop,
    this.onMicHoldStart,
    this.onMicHoldMove,
    this.onMicHoldEnd,
    this.onMicHoldCancel,
    this.onActiveHoldMove,
    this.onActiveHoldRelease,
    this.onActiveHoldCancel,
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
    this.showCamera = true,
    this.showAttach = true,
    this.showMic = true,
    this.hasDraft = false,
    this.recordingElapsed = Duration.zero,
    this.activeHoldDx = 0,
    this.activeHoldDy = 0,
    this.topContent,
  });

  final TextEditingController controller;
  final dynamic replyingTo;
  final VoidCallback? onCancelReply;
  final VoidCallback? onTapReplyPreview;

  final VoidCallback onSend;
  final VoidCallback onCamera;
  final VoidCallback onAttach;
  final VoidCallback onMic;
  final VoidCallback? onStop;

  final GestureLongPressStartCallback? onMicHoldStart;
  final GestureLongPressMoveUpdateCallback? onMicHoldMove;
  final GestureLongPressEndCallback? onMicHoldEnd;
  final VoidCallback? onMicHoldCancel;

  final ValueChanged<Offset>? onActiveHoldMove;
  final VoidCallback? onActiveHoldRelease;
  final VoidCallback? onActiveHoldCancel;

  final VoidCallback? onTrashRecording;
  final VoidCallback? onPauseRecording;
  final VoidCallback? onResumeRecording;

  final bool enabled;
  final bool isStreaming;
  final bool isRecording;
  final bool isVoiceLocked;
  final bool isVoicePaused;
  final bool forceMicOnlyTap;
  final bool showCamera;
  final bool showAttach;
  final bool showMic;
  final bool hasDraft;
  final Duration recordingElapsed;
  final double activeHoldDx;
  final double activeHoldDy;
  final Widget? topContent;

  final String? hint;
  final String? hintText;

  String _fmtElapsed(Duration d) {
    final total = d.inSeconds < 0 ? 0 : d.inSeconds;
    final mm = (total ~/ 60).toString().padLeft(2, '0');
    final ss = (total % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  String get _resolvedHint {
    final v = (hintText ?? hint ?? 'Message').trim();
    return v.isEmpty ? 'Message' : v;
  }

  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...?(topContent != null ? <Widget>[topContent!] : null),
          if (replyingTo != null) _replyPreview(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerMove: enabled && isRecording && !isVoiceLocked
                  ? (e) => onActiveHoldMove?.call(e.position)
                  : null,
              onPointerUp: enabled && isRecording && !isVoiceLocked
                  ? (_) => onActiveHoldRelease?.call()
                  : null,
              onPointerCancel: enabled && isRecording && !isVoiceLocked
                  ? (_) => onActiveHoldCancel?.call()
                  : null,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.18),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTapReplyPreview,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
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
    final canSend =
        enabled && (hasText || hasDraft) && !isStreaming && !isRecording;
    final showLeftTools =
        !hasText &&
        !hasDraft &&
        !isStreaming &&
        !isRecording &&
        (showCamera || showAttach);

    return _shell(
      context,
      key: const ValueKey('idle'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: showLeftTools
                ? Padding(
                    key: const ValueKey('left_tools'),
                    padding: const EdgeInsets.only(right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showCamera)
                          _circleBtn(
                            context,
                            icon: Icons.camera_alt_rounded,
                            onTap: enabled ? onCamera : null,
                          ),
                        if (showCamera && showAttach) const SizedBox(width: 4),
                        if (showAttach)
                          _circleBtn(
                            context,
                            icon: Icons.attach_file_rounded,
                            onTap: enabled ? onAttach : null,
                          ),
                      ],
                    ),
                  )
                : const SizedBox(key: ValueKey('left_tools_empty')),
          ),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 46),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: enabled
                    ? scheme.surfaceContainerHighest.withValues(alpha: 0.78)
                    : scheme.surfaceContainerHighest.withValues(alpha: 0.50),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.16),
                ),
              ),
              child: TextField(
                key: const ValueKey('chat_input'),
                controller: controller,
                enabled: enabled && !isStreaming,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
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
              duration: const Duration(milliseconds: 140),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              child: isStreaming
                  ? _sendBtn(
                      context,
                      key: const ValueKey('stop_btn'),
                      icon: Icons.stop_rounded,
                      active: enabled,
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
                  : showMic
                  ? SizedBox(
                      width: 56,
                      height: 56,
                      child: GestureDetector(
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
                        child: Center(
                          child: _circleBtn(
                            context,
                            icon: Icons.mic_none_rounded,
                            onTap: enabled ? onMic : null,
                          ),
                        ),
                      ),
                    )
                  : _sendBtn(
                      context,
                      key: const ValueKey('disabled_send_btn'),
                      icon: Icons.send_rounded,
                      active: false,
                      onTap: null,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _holding(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cancelProgress = _clamp01((-activeHoldDx) / 56);
    final lockProgress = _clamp01((-activeHoldDy) / 44);
    final cancelActive = cancelProgress >= 1;
    final lockActive = lockProgress >= 1;

    final cancelAccent =
        Color.lerp(scheme.onSurfaceVariant, scheme.error, cancelProgress) ??
        scheme.error;
    final lockAccent =
        Color.lerp(scheme.onSurfaceVariant, scheme.primary, lockProgress) ??
        scheme.primary;

    return Stack(
      key: const ValueKey('holding_pan_surface'),
      clipBehavior: Clip.none,
      children: [
        _shell(
          context,
          key: const ValueKey('holding'),
          child: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 110),
                  curve: Curves.easeOutCubic,
                  constraints: const BoxConstraints(minHeight: 46),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest.withValues(
                      alpha: 0.78,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color:
                          Color.lerp(
                            scheme.outlineVariant.withValues(alpha: 0.18),
                            scheme.error.withValues(alpha: 0.42),
                            cancelProgress,
                          ) ??
                          scheme.outlineVariant.withValues(alpha: 0.18),
                    ),
                    boxShadow: cancelProgress > 0
                        ? [
                            BoxShadow(
                              color: scheme.error.withValues(
                                alpha: 0.14 * cancelProgress,
                              ),
                              blurRadius: 16,
                              spreadRadius: -6,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      AnimatedScale(
                        scale: 1 + (cancelProgress * 0.08),
                        duration: const Duration(milliseconds: 110),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          cancelActive
                              ? Icons.delete_outline_rounded
                              : Icons.mic_rounded,
                          size: 18 + (cancelProgress * 1.5),
                          color: cancelAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 110),
                        curve: Curves.easeOutCubic,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w800,
                          color: cancelAccent,
                        ),
                        child: Text(_fmtElapsed(recordingElapsed)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            AnimatedOpacity(
                              opacity: 1 - cancelProgress.clamp(0, 0.92),
                              duration: const Duration(milliseconds: 110),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.translate(
                                    offset: Offset(-10 * cancelProgress, 0),
                                    child: Icon(
                                      Icons.chevron_left_rounded,
                                      size: 18,
                                      color: scheme.onSurfaceVariant.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Expanded(
                                    child: Text(
                                      lockProgress > 0.15
                                          ? 'Slide up to lock'
                                          : 'Slide left to cancel',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: cancelProgress,
                              duration: const Duration(milliseconds: 110),
                              child: Text(
                                cancelActive
                                    ? 'Release to cancel'
                                    : 'Keep sliding to cancel',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cancelAccent,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 56),
            ],
          ),
        ),
        Positioned(
          right: 8,
          bottom: 8,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOutCubic,
            offset: Offset(0, -0.08 * lockProgress),
            child: AnimatedScale(
              scale: 1 + (lockProgress * 0.10),
              duration: const Duration(milliseconds: 110),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 110),
                curve: Curves.easeOutCubic,
                width: 46,
                height: 96,
                decoration: BoxDecoration(
                  color: scheme.surface.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color:
                        Color.lerp(
                          scheme.outlineVariant.withValues(alpha: 0.20),
                          scheme.primary.withValues(alpha: 0.42),
                          lockProgress,
                        ) ??
                        scheme.outlineVariant.withValues(alpha: 0.20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 16,
                      spreadRadius: -6,
                      offset: const Offset(0, 8),
                      color: Colors.black.withValues(alpha: 0.22),
                    ),
                    if (lockProgress > 0)
                      BoxShadow(
                        blurRadius: 18,
                        spreadRadius: -8,
                        offset: const Offset(0, 8),
                        color: scheme.primary.withValues(
                          alpha: 0.18 * lockProgress,
                        ),
                      ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Transform.translate(
                      offset: Offset(0, -4 * lockProgress),
                      child: Icon(
                        lockActive
                            ? Icons.lock_rounded
                            : Icons.lock_open_rounded,
                        size: 20,
                        color: lockAccent,
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: 1 - (lockProgress * 0.55),
                      duration: const Duration(milliseconds: 110),
                      child: Icon(
                        Icons.keyboard_arrow_up_rounded,
                        size: 16,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.72),
                      ),
                    ),
                    Container(
                      width: 16,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          scheme.outlineVariant,
                          scheme.primary,
                          lockProgress,
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    Text(
                      lockActive ? 'Release' : 'Lock',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: lockAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              constraints: const BoxConstraints(minHeight: 46),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.10),
                    blurRadius: 14,
                    spreadRadius: -8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    child: Icon(
                      isVoicePaused
                          ? Icons.pause_circle_outline_rounded
                          : Icons.lock_rounded,
                      key: ValueKey(isVoicePaused ? 'paused' : 'locked'),
                      size: 18,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isVoicePaused
                              ? 'Recording paused'
                              : 'Recording locked',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _fmtElapsed(recordingElapsed),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
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
            active: enabled,
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
        borderRadius: BorderRadius.circular(22),
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

  Widget _circleBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
    bool compact = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 34.0 : 40.0;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: onTap == null ? 0.04 : 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.14),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: compact ? 18 : 20),
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
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active
              ? scheme.primary.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? scheme.primary.withValues(alpha: 0.28)
                : scheme.outlineVariant.withValues(alpha: 0.14),
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.14),
                    blurRadius: 12,
                    spreadRadius: -6,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: active ? scheme.primary : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
