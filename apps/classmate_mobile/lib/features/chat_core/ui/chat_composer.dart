
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
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

  /// The attachment actions the ⊕ tray offers, in Instagram's order.
  List<({IconData icon, String label, VoidCallback onTap})> _trayActions(
      BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return [
      if (onGallery != null)
        (
          icon: Icons.photo_library_rounded,
          label: l.chatCameraGalleryAction,
          onTap: onGallery!,
        ),
      if (showCamera)
        (icon: Icons.photo_camera_rounded, label: l.a11yCamera, onTap: onCamera),
      if (onVideo != null)
        (icon: Icons.videocam_rounded, label: l.chatVideo, onTap: onVideo!),
      if (showAttach)
        (icon: Icons.attach_file_rounded, label: l.commonFiles, onTap: onAttach),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _TrayHost(
      builder: (context, trayOpen) => _build(context, trayOpen),
    );
  }

  Widget _build(BuildContext context, ValueNotifier<bool> trayOpen) {
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
                        : _idle(context, hasText, trayOpen),
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
          ValueListenableBuilder<bool>(
            valueListenable: trayOpen,
            builder: (context, open, _) => AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: open && !isRecording && enabled
                  ? _AttachTray(
                      actions: _trayActions(context),
                      background: backgroundColor,
                      onSelect: (action) {
                        trayOpen.value = false;
                        action.onTap();
                      },
                    )
                  : const SizedBox(width: double.infinity),
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
          Semantics(
            button: true,
            label: AppLocalizations.of(context)!.a11yCancelReply,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: onCancelReply,
              child: const Padding(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.close_rounded, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _idle(
      BuildContext context, bool hasText, ValueNotifier<bool> trayOpen) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final canSend =
        enabled && (hasText || hasDraft) && !isStreaming && !isRecording;
    // Nothing typed or staged and not busy — the state that shows the quick
    // actions on the right (mic · gallery · +). Same rule as before for +.
    final idleEmpty = !hasText && !hasDraft && !isStreaming && !isRecording;
    final showAddButton = idleEmpty &&
        (showCamera || showAttach || onVideo != null || onGallery != null);
    // Typing (or anything that hides ⊕) folds the tray away.
    if (!showAddButton && trayOpen.value) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => trayOpen.value = false);
    }

    // Instagram-DM layout:
    //   📷  ( Message…               🎙  ⊕ )   ← nothing typed
    //   📷  ( Hello there                  ➤ )   ← typing
    // Camera sits outside the pill (one tap). ⊕ opens an inline tray below
    // (gallery · camera · video · files) and turns into a keyboard key that
    // brings the keyboard back. The mic is the same _MicPressDetector as
    // before — press / hold / slide / lock plumbing is untouched (guarded by
    // chat_composer_gesture_test.dart).
    return _shell(
      context,
      key: const ValueKey('idle'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (showCamera && !isStreaming) _cameraBtn(context),
          Expanded(
            child: Container(
        constraints: const BoxConstraints(minHeight: 50),
        padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 5, 5),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          // Buttons hug the bottom edge as the text grows to several lines.
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: TextField(
                    key: const ValueKey('chat_input'),
                    controller: controller,
                    focusNode: focusNode,
                    enabled: enabled && !isStreaming,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.newline,
                    onTap: () => trayOpen.value = false,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(filled: false, 
                      isCollapsed: true,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: _resolvedHint(context),
                      hintStyle: TextStyle(
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedSwitcher(
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
                      : (showMic || showAddButton)
                          ? Row(
                              key: const ValueKey('idle_actions'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showMic)
                                  _MicPressDetector(
                                    key: const ValueKey('mic_btn'),
                                    enabled: enabled && !forceMicOnlyTap,
                                    onPressStart: onMicPressStart,
                                    child: _pillIcon(
                                      context,
                                      icon: Icons.mic_none_rounded,
                                      label: l.chatComposerMicHint,
                                      // Tap-only fallback surfaces (no
                                      // press-to-record) still get a plain tap
                                      // to open a locked take.
                                      onTap: enabled && forceMicOnlyTap
                                          ? onMic
                                          : null,
                                    ),
                                  ),
                                if (showAddButton)
                                  ValueListenableBuilder<bool>(
                                    valueListenable: trayOpen,
                                    builder: (context, open, _) => _plusBtn(
                                      context,
                                      open: open,
                                      onTap: enabled
                                          ? () {
                                              if (open) {
                                                trayOpen.value = false;
                                                focusNode?.requestFocus();
                                              } else {
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                trayOpen.value = true;
                                              }
                                            }
                                          : null,
                                    ),
                                  ),
                              ],
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
          ],
        ),
      ),
          ),
        ],
      ),
    );
  }

  /// Leading camera glyph, outside the pill like Instagram. One tap.
  Widget _cameraBtn(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.tutorTakePhoto,
      child: InkResponse(
        onTap: enabled ? onCamera : null,
        radius: 24,
        child: SizedBox(
          width: 46,
          height: 50,
          child: Icon(
            Icons.photo_camera_rounded,
            size: 28,
            color: enabled
                ? scheme.onSurface
                : scheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
      ),
    );
  }

  /// Filled ⊕ — becomes a keyboard key while the tray is open.
  Widget _plusBtn(BuildContext context,
      {required bool open, required VoidCallback? onTap}) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l.a11yMore,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: SizedBox(
          width: 44,
          height: 40,
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: enabled
                    ? scheme.onSurface
                    : scheme.onSurface.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: a, child: c),
                child: Icon(
                  open ? Icons.keyboard_rounded : Icons.add_rounded,
                  key: ValueKey(open),
                  size: open ? 18 : 22,
                  color: scheme.surface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Bare 40×40 icon inside the pill (mic / gallery / +). No outline or fill —
  /// the pill is the container, like Instagram's trailing icons.
  Widget _pillIcon(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 24,
            color: enabled
                ? scheme.onSurface
                : scheme.onSurface.withValues(alpha: 0.38),
          ),
        ),
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
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
          // Invisible at rest (same as the fill), turning red as the drag
          // approaches the cancel threshold.
          border: Border.all(
            color: Color.lerp(scheme.surfaceContainerHigh, scheme.error,
                0.6 * cancelProgress)!,
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
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.surfaceContainerHigh),
          ),
          child: Row(
            children: [
              _miniIconButton(
                context,
                icon: Icons.delete_outline_rounded,
                label: AppLocalizations.of(context)!.a11yDiscardRecording,
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
    required String label,
    required Color color,
    Color? fill,
    VoidCallback? onTap,
  }) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: GestureDetector(
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


/// Owns the ⊕ tray's open state so [ChatComposer] can stay stateless.
class _TrayHost extends StatefulWidget {
  const _TrayHost({required this.builder});

  final Widget Function(BuildContext context, ValueNotifier<bool> trayOpen)
      builder;

  @override
  State<_TrayHost> createState() => _TrayHostState();
}

class _TrayHostState extends State<_TrayHost> {
  final _open = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _open);
}

/// Instagram-style inline attachment tray: big round buttons with labels,
/// sitting where the keyboard was.
class _AttachTray extends StatelessWidget {
  const _AttachTray({
    required this.actions,
    required this.onSelect,
    this.background,
  });

  final List<({IconData icon, String label, VoidCallback onTap})> actions;
  final ValueChanged<({IconData icon, String label, VoidCallback onTap})>
      onSelect;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(8, 2, 8, 8),
      padding: const EdgeInsets.fromLTRB(8, 22, 8, 22),
      decoration: BoxDecoration(
        color: background ?? scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final a in actions)
            Expanded(
              child: Semantics(
                button: true,
                label: a.label,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onSelect(a),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(a.icon,
                            size: 28, color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        a.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
