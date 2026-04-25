import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import 'chat_recording_tokens.dart';
import '../utils/chat_reply_codec.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onCamera,
    required this.onAttach,
    this.onVideo,
    this.onGallery,
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
  final VoidCallback? onVideo;
  final VoidCallback? onGallery;
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

  String _resolvedHint(BuildContext context) {
    final fallback = AppLocalizations.of(context)!.chatComposerDefaultHint;
    if (hintText != null) return hintText!;
    if (hint != null) return hint!;
    return fallback;
  }

  double _clamp01(double v) => v < 0 ? 0 : (v > 1 ? 1 : v);

  Future<void> _showComposerActions(BuildContext context, Rect anchor) async {
    final l = AppLocalizations.of(context)!;
    final actions = <({IconData icon, String label, VoidCallback onTap})>[
      (
        icon: Icons.photo_camera_back_rounded,
        label: l.tutorTakePhoto,
        onTap: onCamera,
      ),
      if (onVideo != null)
        (
          icon: Icons.videocam_rounded,
          label: l.tutorRecordVideo,
          onTap: onVideo!,
        ),
      if (onGallery != null)
        (
          icon: Icons.photo_library_rounded,
          label: l.tutorChooseFromGallery,
          onTap: onGallery!,
        ),
      (
        icon: Icons.attach_file_rounded,
        label: 'Files',
        onTap: onAttach,
      ),
    ];

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
    final overlaySize = overlay?.size ?? MediaQuery.sizeOf(context);
    final mediaQuery = MediaQuery.of(context);
    final popoverWidth = (overlaySize.width - 24).clamp(196.0, 224.0);
    final popoverHeight = (actions.length * 54.0) + 22.0;
    final left = (anchor.left - 4).clamp(
      12.0,
      overlaySize.width - popoverWidth - 12.0,
    );
    final minTop = mediaQuery.padding.top + 10.0;
    final maxTop = overlaySize.height - popoverHeight - mediaQuery.padding.bottom - 10.0;
    final spaceAbove = anchor.top - minTop;
    final spaceBelow = maxTop - anchor.bottom;
    final showAbove = spaceAbove >= popoverHeight || spaceAbove >= spaceBelow;
    final top = showAbove
        ? (anchor.top - popoverHeight - 12).clamp(minTop, maxTop)
        : (anchor.bottom + 12).clamp(minTop, maxTop);
    final scaleAlignment = showAbove ? Alignment.bottomLeft : Alignment.topLeft;

    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.10),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, animation, secondaryAnimation) => SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(dialogContext).pop(),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: popoverWidth,
              child: _ComposerActionPopover(
                actions: actions,
                onSelect: (action) {
                  Navigator.of(dialogContext).pop();
                  action.onTap();
                },
              ),
            ),
          ],
        ),
      ),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1).animate(curved),
            alignment: scaleAlignment,
            child: child,
          ),
        );
      },
    );
  }

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
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
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
                    transitionBuilder: (child, animation) {
                      final fade = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.08),
                        end: Offset.zero,
                      ).animate(fade);
                      final scale = Tween<double>(
                        begin: 0.985,
                        end: 1,
                      ).animate(fade);
                      return FadeTransition(
                        opacity: fade,
                        child: SlideTransition(
                          position: slide,
                          child: ScaleTransition(scale: scale, child: child),
                        ),
                      );
                    },
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
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final dynamic rawReplyingTo = replyingTo;
    final sender = ((rawReplyingTo?.senderName ?? '') as String).trim();
    final raw = ((rawReplyingTo?.text ?? '') as String).trim();
    final preview = raw.isEmpty
        ? l.chatComposerReplyingToMessage
        : replyPreviewText(raw);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            spreadRadius: -10,
            offset: const Offset(0, 10),
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: 3,
            height: 30,
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
          const SizedBox(width: 8),
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
                      sender.isEmpty ? l.chatComposerReplyFallback : sender,
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
              padding: EdgeInsets.all(3),
              child: Icon(Icons.close_rounded, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _idle(BuildContext context, bool hasText) {
    final canSend =
        enabled && (hasText || hasDraft) && !isStreaming && !isRecording;
    final showAddButton =
        !hasText &&
        !hasDraft &&
        !isStreaming &&
        !isRecording &&
      (showCamera || showAttach || onVideo != null || onGallery != null);

    return _shell(
      context,
      key: const ValueKey('idle'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: showAddButton
                ? Builder(
                    key: const ValueKey('left_add_button'),
                    builder: (buttonContext) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: _circleBtn(
                            context,
                            icon: Icons.add_rounded,
                            onTap: enabled
                                ? () {
                                    final box = buttonContext.findRenderObject()
                                        as RenderBox?;
                                    final overlay = Overlay.of(context)
                                        .context
                                        .findRenderObject() as RenderBox?;
                                    if (box == null || overlay == null) {
                                      _showComposerActions(
                                        context,
                                        const Rect.fromLTWH(16, 0, 44, 44),
                                      );
                                      return;
                                    }
                                    final offset = box.localToGlobal(
                                      Offset.zero,
                                      ancestor: overlay,
                                    );
                                    _showComposerActions(
                                      context,
                                      offset & box.size,
                                    );
                                  }
                                : null,
                            compact: true,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('left_add_button_empty')),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 42),
              child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    key: const ValueKey('chat_input'),
                    controller: controller,
                    enabled: enabled && !isStreaming,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      isDense: true,
                      border: InputBorder.none,
                      hintText: _resolvedHint(context),
                    ),
                  ),
                ],
              ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 44,
            height: 44,
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
                      large: true,
                    )
                  : canSend
                  ? _sendBtn(
                      context,
                      key: const ValueKey('send_btn'),
                      icon: Icons.send_rounded,
                      active: true,
                      onTap: onSend,
                      large: true,
                    )
                  : showMic
                  ? GestureDetector(
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
                          prominent: true,
                        ),
                      ),
                    )
                  : _sendBtn(
                      context,
                      key: const ValueKey('disabled_send_btn'),
                      icon: Icons.send_rounded,
                      active: false,
                      onTap: null,
                      large: true,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _holding(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final cancelProgress = _clamp01(
      (-activeHoldDx) / chatRecordingCancelThreshold,
    );
    final lockProgress = _clamp01(
      (-activeHoldDy) / chatRecordingLockThreshold,
    );
    final cancelActive = cancelProgress >= 1;
    final lockActive = lockProgress >= 1;

    final cancelAccent =
        Color.lerp(scheme.onSurfaceVariant, scheme.error, cancelProgress) ??
        scheme.error;
    final lockAccent =
        Color.lerp(scheme.onSurfaceVariant, scheme.primary, lockProgress) ??
        scheme.primary;

    return _shell(
      context,
      key: const ValueKey('holding'),
      child: _recordingBar(
        context,
        leading: _recordingEdgeIcon(
          context,
          color: cancelAccent,
          icon: cancelActive
              ? Icons.delete_forever_rounded
              : Icons.swipe_left_rounded,
          active: cancelProgress > 0.18,
        ),
        center: _recordingCore(
          context,
          elapsed: recordingElapsed,
          accent: cancelActive
              ? cancelAccent
              : (lockActive ? lockAccent : scheme.primary),
          leadingIcon: cancelActive
              ? Icons.delete_outline_rounded
              : (lockActive ? Icons.lock_rounded : Icons.mic_rounded),
          trailing: _recordingGestureMeter(
            context,
            leftProgress: cancelProgress,
            rightProgress: lockProgress,
            leftColor: cancelAccent,
            rightColor: lockAccent,
          ),
        ),
        trailing: _recordingEdgeIcon(
          context,
          color: lockAccent,
          icon: lockActive
              ? Icons.lock_rounded
              : Icons.keyboard_double_arrow_up_rounded,
          active: lockProgress > 0.18,
        ),
        borderColor: Color.alphaBlend(
          cancelAccent.withValues(alpha: 0.10 * cancelProgress),
          scheme.outlineVariant.withValues(alpha: 0.14),
        ),
        glowColor: Color.alphaBlend(
          lockAccent.withValues(alpha: 0.16 * lockProgress),
          cancelAccent.withValues(alpha: 0.08 * cancelProgress),
        ),
      ),
    );
  }

  Widget _locked(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _shell(
      context,
      key: const ValueKey('locked'),
      child: _recordingBar(
        context,
        leading: _recordingActionButton(
          context,
          icon: Icons.delete_outline_rounded,
          accent: scheme.error,
          onTap: enabled ? (onTrashRecording ?? onMic) : null,
        ),
        center: _recordingCore(
          context,
          elapsed: recordingElapsed,
          accent: isVoicePaused ? scheme.tertiary : scheme.primary,
          leadingIcon: isVoicePaused
              ? Icons.pause_circle_filled_rounded
              : Icons.lock_rounded,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _recordingActionButton(
                context,
                icon: isVoicePaused
                    ? Icons.mic_rounded
                    : Icons.pause_rounded,
                accent: isVoicePaused ? scheme.tertiary : scheme.primary,
                small: true,
                onTap: enabled
                    ? (isVoicePaused
                          ? (onResumeRecording ?? onMic)
                          : (onPauseRecording ?? onMic))
                    : null,
              ),
              const SizedBox(width: 6),
              _recordingActionButton(
                context,
                icon: Icons.send_rounded,
                accent: scheme.primary,
                onTap: enabled ? onMic : null,
                filled: true,
              ),
            ],
          ),
        ),
        borderColor: scheme.primary.withValues(alpha: 0.16),
        glowColor: (isVoicePaused ? scheme.tertiary : scheme.primary)
            .withValues(alpha: 0.16),
      ),
    );
  }

  Widget _shell(BuildContext context, {required Widget child, Key? key}) {
    // Fully transparent passthrough — NativeGlassView handles all visual styling.
    return KeyedSubtree(
      key: key ?? const ValueKey('_shell'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: child,
      ),
    );
  }

  Widget _recordingBar(
    BuildContext context, {
    required Widget leading,
    required Widget center,
    Widget? trailing,
    required Color borderColor,
    required Color glowColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      constraints: const BoxConstraints(minHeight: 48),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.surfaceContainerHighest.withValues(alpha: 0.88),
            scheme.surface.withValues(alpha: 0.82),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor,
            blurRadius: 18,
            spreadRadius: -12,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 8),
          Expanded(child: center),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _recordingEdgeIcon(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required bool active,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: chatRecordingHudMotionDuration,
      curve: Curves.easeOutCubic,
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.14)
            : scheme.surface.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? color.withValues(alpha: 0.24)
              : scheme.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: 18,
        color: active ? color : scheme.onSurfaceVariant,
      ),
    );
  }

  Widget _recordingCore(
    BuildContext context, {
    required Duration elapsed,
    required Color accent,
    required IconData leadingIcon,
    Widget? trailing,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          _recordingPulseOrb(context, accent: accent, icon: leadingIcon),
          const SizedBox(width: 10),
          Text(
            _fmtElapsed(elapsed),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: _recordingWaveform(context, accent: accent, elapsed: elapsed)),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _recordingPulseOrb(
    BuildContext context, {
    required Color accent,
    required IconData icon,
  }) {
    final phase = recordingElapsed.inSeconds % 2 == 0 ? 1.0 : 0.0;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.9, end: phase == 1.0 ? 1.06 : 0.94),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.26),
                accent.withValues(alpha: 0.12),
              ],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.22)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.18),
                blurRadius: 12,
                spreadRadius: -8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 15, color: accent),
        ),
      ),
    );
  }

  Widget _recordingWaveform(
    BuildContext context, {
    required Color accent,
    required Duration elapsed,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final phase = elapsed.inSeconds % 4;
    final baseHeights = <double>[8, 13, 18, 12, 16, 10, 14];
    return Container(
      height: 20,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          for (var index = 0; index < baseHeights.length; index++) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeInOutCubic,
              width: 4,
              height: baseHeights[(index + phase) % baseHeights.length],
              decoration: BoxDecoration(
                color: index.isEven
                    ? accent.withValues(alpha: 0.86)
                    : accent.withValues(alpha: 0.46),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            if (index != baseHeights.length - 1) const SizedBox(width: 3),
          ],
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: ((elapsed.inSeconds % 12) + 1) / 12,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha: 0.28),
                        accent.withValues(alpha: 0.74),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _recordingGestureMeter(
    BuildContext context, {
    required double leftProgress,
    required double rightProgress,
    required Color leftColor,
    required Color rightColor,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: scheme.outlineVariant.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: leftProgress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: leftColor.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: rightProgress,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: rightColor.withValues(alpha: 0.82),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
    bool compact = false,
    bool prominent = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 28.0 : (prominent ? 40.0 : 34.0);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: prominent
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: onTap == null ? 0.10 : 0.22),
                    scheme.primaryContainer.withValues(
                      alpha: onTap == null ? 0.14 : 0.44,
                    ),
                  ],
                )
              : null,
          color: prominent
              ? null
              : Colors.white.withValues(alpha: onTap == null ? 0.04 : 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: prominent
                ? scheme.primary.withValues(alpha: 0.28)
              : scheme.outlineVariant.withValues(alpha: 0.10),
          ),
          boxShadow: prominent && onTap != null
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.18),
                    blurRadius: 14,
                    spreadRadius: -6,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: compact ? 16 : (prominent ? 21 : 18),
          color: prominent ? scheme.onPrimaryContainer : null,
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
    bool large = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final size = large ? 44.0 : 36.0;
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.22),
                    scheme.primaryContainer.withValues(alpha: 0.55),
                  ],
                )
              : null,
          color: active
              ? null
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
          size: large ? 21 : 18,
          color: active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _recordingActionButton(
    BuildContext context, {
    required IconData icon,
    required Color accent,
    required VoidCallback? onTap,
    bool small = false,
    bool filled = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final size = small ? 30.0 : 34.0;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: filled
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: onTap == null ? 0.10 : 0.20),
                    accent.withValues(alpha: onTap == null ? 0.18 : 0.42),
                  ],
                )
              : null,
          color: filled
              ? null
              : accent.withValues(alpha: onTap == null ? 0.06 : 0.10),
          border: Border.all(color: accent.withValues(alpha: 0.18)),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: small ? 16 : 18,
          color: filled ? scheme.onPrimaryContainer : accent,
        ),
      ),
    );
  }

}

class _ComposerActionPopover extends StatelessWidget {
  const _ComposerActionPopover({
    required this.actions,
    required this.onSelect,
  });

  final List<({IconData icon, String label, VoidCallback onTap})> actions;
  final ValueChanged<({IconData icon, String label, VoidCallback onTap})> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: LiquidGlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        borderRadius: BorderRadius.circular(24),
        blurSigma: 18,
        color: scheme.surface.withValues(alpha: 0.72),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 28,
            spreadRadius: -14,
            offset: const Offset(0, 16),
          ),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final action in actions)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onSelect(action),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: scheme.primary.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Icon(
                              action.icon,
                              size: 18,
                              color: scheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            action.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
