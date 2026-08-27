import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';
import 'chat_live_waveform.dart';
import 'chat_recording_tokens.dart';
import '../utils/chat_reply_codec.dart';

class ChatComposer extends StatelessWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    this.focusNode,
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
    this.onMicPressStart,
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
    this.voiceLevels = const <double>[],
    this.activeHoldDx = 0,
    this.activeHoldDy = 0,
    this.topContent,
    this.backgroundColor,
  });

  final TextEditingController controller;
  /// Focus node for the text input. Owned by the host so it can re-establish
  /// the platform keyboard connection after returning from an external picker
  /// (image_picker / file_picker leave the field in a state where a plain tap
  /// won't reopen the keyboard on Android — QA #7/#9).
  final FocusNode? focusNode;
  /// Optional override for the composer bar's fill. Defaults to the theme
  /// surface; NOVA passes a translucent color so the full-screen background
  /// shows through the bottom of the screen.
  final Color? backgroundColor;
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
  /// Finger down on the mic — recording starts immediately. The global
  /// position seeds the slide-to-cancel / slide-to-lock origin.
  final ValueChanged<Offset>? onMicPressStart;
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

  /// Live mic input levels, newest last, each 0..1. Empty when the recorder
  /// hasn't reported any yet (or the platform doesn't support amplitude), in
  /// which case the waveform falls back to a calm idle pattern.
  final List<double> voiceLevels;
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
        label: l.commonFiles,
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
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 180),
      // NO SafeArea around this Stack. A BackdropFilter blurs exactly its own
      // layout bounds, so wrapping it in a SafeArea inset the backdrop by
      // MediaQuery.padding and left the status-bar strip and the home-indicator
      // strip sharp AND untinted — the screen looked blocky, blurred in the
      // middle with two crisp bands. The popover doesn't need the SafeArea
      // either: minTop/maxTop above already clamp against padding.top/.bottom,
      // so the outer inset was only double-counting them.
      pageBuilder: (dialogContext, animation, secondaryAnimation) => Stack(
        children: [
          // Blurred backdrop instead of solid black — edge to edge.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: animation,
              builder: (_, __) => BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 6 * animation.value,
                  sigmaY: 6 * animation.value,
                ),
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.28 * animation.value),
                ),
              ),
            ),
          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Listener(
              behavior: HitTestBehavior.translucent,
              // Deliberately NOT gated on isRecording: pointer routing is
              // frozen at pointer-down, and at that instant recording hasn't
              // started yet. If these were null until the post-setState
              // rebuild, a release landing before that frame (fast tap, or a
              // janky frame during recorder bring-up) would go unhandled and
              // strand the HUD with the mic open. The handlers no-op while
              // not recording, so pre-recording taps cost nothing. Locked
              // mode stays gated out — there, pointer-ups belong to the HUD's
              // own buttons, and treating one as a hold-release would send.
              onPointerMove: enabled && !isVoiceLocked
                  ? (e) => onActiveHoldMove?.call(e.position)
                  : null,
              onPointerUp: enabled && !isVoiceLocked
                  ? (_) => onActiveHoldRelease?.call()
                  : null,
              onPointerCancel: enabled && !isVoiceLocked
                  ? (_) => onActiveHoldCancel?.call()
                  : null,
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, _) {
                  final hasText = value.text.trim().isNotEmpty;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    // Fade THROUGH, not across. A plain cross-fade paints the
                    // outgoing and incoming rows on top of each other for the
                    // whole transition, which reads as "the composer and the
                    // recording HUD are both on screen at once" — especially
                    // on cancel, where the eye is already looking for a change.
                    // These intervals make the old row finish leaving (35%)
                    // before the new one starts arriving (50%), so exactly one
                    // is ever visible.
                    switchInCurve: const Interval(0.5, 1, curve: Curves.easeOutCubic),
                    switchOutCurve: const Interval(0.65, 1, curve: Curves.easeIn),
                    // Size to the incoming child only, so the bar doesn't jump
                    // to the taller of the two mid-transition.
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        ...previous.map(
                          (c) => Positioned.fill(child: IgnorePointer(child: c)),
                        ),
                        if (current != null) current,
                      ],
                    ),
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
                    // Floating lock bubble — Instagram's model: it is not part
                    // of the pill, it hovers ABOVE the finger and follows it,
                    // so the gesture reads as "carry the recording up into the
                    // lock" rather than "hit an anchored button".
                    if (isRecording && !isVoiceLocked)
                      _lockBubble(context, constraints.maxWidth),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The hover circle that tracks the finger while a hold-recording is live.
  /// Rises with the drag; fills red and swaps to a closed padlock once the
  /// finger is high enough — a "release to lock" affordance. Nothing latches
  /// while the finger is down; the thread view resolves lock/cancel/send only
  /// on release (lock = released high enough, at ANY horizontal position).
  Widget _lockBubble(BuildContext context, double width) {
    final scheme = Theme.of(context).colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final toCancel = isRtl ? activeHoldDx : -activeHoldDx;
    final cancelProgress = _clamp01(toCancel / chatRecordingCancelThreshold);
    final lockProgress = _clamp01((-activeHoldDy) / chatRecordingLockThreshold);
    final locking = lockProgress >= 0.99;

    // The finger lands on the mic, which sits at the trailing edge.
    const bubbleSize = 46.0;
    final startX = isRtl ? 28.0 : width - 28.0;
    final x = (startX + activeHoldDx).clamp(26.0, width - 26.0);
    // Hovers ~64 px above the finger and rides up with it.
    final lift = 64.0 - activeHoldDy.clamp(-120.0, 16.0);

    return Positioned(
      left: x - bubbleSize / 2,
      top: -lift,
      child: IgnorePointer(
        child: AnimatedOpacity(
          // Dragging toward the trash means "cancel" — the lock affordance
          // bows out instead of competing for attention.
          opacity: (1.0 - cancelProgress * 0.9).clamp(0.0, 1.0),
          duration: const Duration(milliseconds: 90),
          child: AnimatedScale(
            scale: locking ? 1.14 : 1.0 + 0.08 * lockProgress,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOutCubic,
              width: bubbleSize,
              height: bubbleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: locking
                    ? scheme.error
                    : Color.lerp(scheme.surfaceContainerHigh, scheme.error,
                        0.25 * lockProgress),
                border: Border.all(
                  color: locking
                      ? scheme.error
                      : scheme.outlineVariant.withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(
                locking ? Icons.lock_rounded : Icons.lock_open_rounded,
                size: 20,
                color: locking ? Colors.white : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
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
        color: backgroundColor ?? scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: scheme.outlineVariant,
        ),
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
                      padding: const EdgeInsetsDirectional.only(end: 6),
                      child: SizedBox(
                        width: 40,
                        height: 40,
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
              constraints: const BoxConstraints(minHeight: 36),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                child: TextField(
                  key: const ValueKey('chat_input'),
                  controller: controller,
                  focusNode: focusNode,
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
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
                  ? _MicPressDetector(
                      key: const ValueKey('mic_btn'),
                      enabled: enabled && !forceMicOnlyTap,
                      onPressStart: onMicPressStart,
                      child: Center(
                        child: _circleBtn(
                          context,
                          icon: Icons.mic_none_rounded,
                          // Tap-only fallback surfaces (no press-to-record)
                          // still get a plain tap to open a locked take.
                          onTap: enabled && forceMicOnlyTap ? onMic : null,
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
    // Instagram-style hold HUD. The pill is STATIC — the finger moves, not
    // the bar:
    //   🗑 (grows red as you drag toward it)  ──live waveform──  ● 0:05
    // The lock affordance is the floating bubble above the finger (see
    // _lockBubble), not part of this row.
    final scheme = Theme.of(context).colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final toCancel = isRtl ? activeHoldDx : -activeHoldDx;
    final cancelProgress = _clamp01(toCancel / chatRecordingCancelThreshold);
    final cancelActive = cancelProgress >= 1;
    final accent = cancelActive ? scheme.error : scheme.primary;

    return _shell(
      context,
      key: const ValueKey('holding'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Color.lerp(
                scheme.outlineVariant, scheme.error, 0.6 * cancelProgress)!,
          ),
        ),
        child: Row(
          children: [
            // Trash target at the start edge (the cancel direction). Swells
            // and tints red as the drag approaches so the finger has
            // something concrete to aim at — release over it cancels.
            AnimatedScale(
              scale: 1.0 + 0.3 * cancelProgress,
              duration: const Duration(milliseconds: 110),
              curve: Curves.easeOutCubic,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.error
                      .withValues(alpha: 0.16 * cancelProgress),
                ),
                alignment: Alignment.center,
                child: Icon(
                  cancelActive
                      ? Icons.delete_rounded
                      : Icons.delete_outline_rounded,
                  size: 19,
                  color: Color.lerp(
                      scheme.onSurfaceVariant, scheme.error, cancelProgress),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ChatLiveWaveform(levels: voiceLevels, color: accent),
            ),
            const SizedBox(width: 10),
            _recordingPulseDot(context, accent: scheme.error),
            const SizedBox(width: 7),
            Text(
              _fmtElapsed(recordingElapsed),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locked(BuildContext context) {
    // Locked (hands-free) HUD — the timer's spot at the trailing edge becomes
    // the send button, exactly the swap Instagram makes:
    //   🗑    ● 0:12   ──live waveform──   ➤(send)
    final scheme = Theme.of(context).colorScheme;

    return _shell(
      context,
      key: const ValueKey('locked'),
      // Claim horizontal drags that start on the pill so a host TabBarView
      // (classroom tabs) can't turn a stray swipe into a page change while a
      // take is open.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (_) {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            children: [
              _miniIconButton(
                context,
                icon: Icons.delete_outline_rounded,
                color: scheme.error,
                onTap: enabled ? (onTrashRecording ?? onMic) : null,
              ),
              const SizedBox(width: 4),
              _recordingPulseDot(context, accent: scheme.error),
              const SizedBox(width: 7),
              Text(
                _fmtElapsed(recordingElapsed),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChatLiveWaveform(
                    levels: voiceLevels, color: scheme.primary),
              ),
              const SizedBox(width: 10),
              _sendBtn(
                context,
                key: const ValueKey('voice_send_btn'),
                icon: Icons.send_rounded,
                active: enabled,
                onTap: enabled ? onMic : null,
                large: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pulsing red dot — the universal "recording" indicator.
  Widget _recordingPulseDot(BuildContext context, {required Color accent, bool dim = false}) {
    final phase = recordingElapsed.inMilliseconds ~/ 500 % 2;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.65, end: phase == 0 ? 1.0 : 0.7),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeInOutCubic,
      builder: (context, alpha, _) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (dim ? Theme.of(context).colorScheme.tertiary : Colors.red)
              .withValues(alpha: alpha),
        ),
      ),
    );
  }

  Widget _miniIconButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    Color? fill,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill ?? Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _shell(BuildContext context, {required Widget child, Key? key}) {
    return KeyedSubtree(
      key: key ?? const ValueKey('_shell'),
      child: child,
    );
  }

  // ── Removed: the old multi-pill recording HUD's helpers
  // (_recordingBar / _recordingEdgeIcon / _recordingCore /
  // _recordingPulseOrb / _recordingWaveform / _recordingGestureMeter /
  // _recordingActionButton). The new _holding/_locked widgets above use a
  // single minimal pill (red dot · elapsed · slide-to-cancel · lock-or-
  // actions) modelled on Instagram's recorder, replacing all of them.

  Widget _circleBtn(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onTap,
    bool compact = false,
    bool prominent = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final size = compact ? 24.0 : (prominent ? 36.0 : 30.0);
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: prominent
              ? scheme.surfaceContainerHigh
              : scheme.surfaceContainerLow,
          shape: BoxShape.circle,
          border: Border.all(color: scheme.outlineVariant),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: compact ? 14 : (prominent ? 18 : 16),
          color: prominent ? scheme.onSurface : scheme.onSurfaceVariant,
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
    final size = large ? 40.0 : 32.0;
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
          color: active ? scheme.primary : scheme.surfaceContainerLow,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? scheme.primary : scheme.outlineVariant,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: large ? 18 : 15,
          color: active ? scheme.onPrimary : scheme.onSurfaceVariant,
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
        color: scheme.surface,
        border: Border.all(
          color: scheme.outlineVariant,
        ),
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
                              color: scheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: scheme.primary.withValues(alpha: 0.30),
                              ),
                            ),
                            child: Icon(
                              action.icon,
                              size: 18,
                              color: scheme.onPrimaryContainer,
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

/// Mic button press detector: recording starts on *contact*, with no
/// recognition delay at all.
///
/// This deliberately uses a raw [Listener] rather than any gesture recognizer.
/// Every recognizer has to wait before it can claim the pointer — the stock
/// long-press waits [kLongPressTimeout] (500 ms), and even a shortened one
/// waits its own duration — during which nothing happens on screen. Stacked on
/// top of the platform work the recorder still does (permission, temp dir,
/// audio-session activation), that read as a mic button that ignored you.
///
/// There is nothing to disambiguate here anyway: the mic button does exactly
/// one thing on press, and *what kind* of press it was (quick tap → hands-free
/// lock, hold → send on release, slide left → cancel, slide up → lock) is
/// decided later from the same pointer stream, by the composer-level [Listener]
/// that takes over once this button unmounts and the recording HUD replaces it.
class _MicPressDetector extends StatelessWidget {
  const _MicPressDetector({
    super.key,
    required this.enabled,
    required this.child,
    this.onPressStart,
  });

  final bool enabled;
  final Widget child;
  final ValueChanged<Offset>? onPressStart;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return SizedBox(key: key, child: child);
    }
    // The eager recognizer claims the pointer in the gesture arena the moment
    // it lands on the mic. Without it, the raw Listener below gets the events
    // but never *competes* for them — so a host TabBarView (classroom tabs)
    // would win the horizontal drag and slide-to-cancel doubled as a page
    // swipe. With the claim, the whole hold-drag stream belongs to the
    // recorder and the page never moves.
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        EagerGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
          () => EagerGestureRecognizer(),
          (EagerGestureRecognizer instance) {},
        ),
      },
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (e) => onPressStart?.call(e.position),
        child: child,
      ),
    );
  }
}
