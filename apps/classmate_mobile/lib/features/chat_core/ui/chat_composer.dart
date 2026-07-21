import 'dart:ui';

import 'package:flutter/foundation.dart' show ValueListenable;
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
    this.recordingAmplitudes,
    this.activeHoldDx = 0,
    this.activeHoldDy = 0,
    this.topContent,
    this.backgroundColor,
  });

  final TextEditingController controller;
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
  /// Live, normalised (0..1) mic-amplitude samples, oldest first, exposed as a
  /// listenable so the high-frequency stream repaints ONLY the waveform bars
  /// (not the whole composer/thread). Null/empty → the waveform falls back to
  /// its built-in idle animation.
  final ValueListenable<List<double>>? recordingAmplitudes;
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
      pageBuilder: (dialogContext, animation, secondaryAnimation) => SafeArea(
        child: Stack(
          children: [
            // Blurred backdrop instead of solid black
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
    // Minimal Instagram-style hold HUD:
    //   ●  0:05   ← Slide to cancel              ↑
    // Replaces the prior dual-edge-icons + gesture meter clutter. The hint
    // text fades to red as the cancel swipe approaches threshold, and the
    // trailing chevron firms into a lock icon as the lock swipe approaches.
    final scheme = Theme.of(context).colorScheme;
    final cancelProgress = _clamp01(
      (-activeHoldDx) / chatRecordingCancelThreshold,
    );
    final lockProgress = _clamp01(
      (-activeHoldDy) / chatRecordingLockThreshold,
    );
    final cancelActive = cancelProgress >= 1;
    final lockActive = lockProgress >= 1;

    final cancelTint = Color.lerp(
          scheme.onSurfaceVariant.withValues(alpha: 0.7),
          scheme.error,
          cancelProgress,
        ) ??
        scheme.error;
    final lockTint = Color.lerp(
          scheme.onSurfaceVariant.withValues(alpha: 0.7),
          scheme.primary,
          lockProgress,
        ) ??
        scheme.primary;
    final accent =
        cancelActive ? scheme.error : (lockActive ? scheme.primary : scheme.primary);

    // Instagram-style: the pill stays put. Only the chevron + "Slide
    // to cancel" group slides left as the user drags, and it fades out
    // the further it goes, so the affordance feels like a button being
    // pulled off-screen rather than the whole HUD shifting.
    final cancelDrag = _clamp01(cancelProgress);
    final cancelInsetOffset = Offset(-cancelDrag * 64, 0);
    final cancelOpacity = (1.0 - cancelDrag * 0.85).clamp(0.0, 1.0);

    return _shell(
      context,
      key: const ValueKey('holding'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Color.lerp(scheme.outlineVariant, accent, 0.4 * (cancelProgress + lockProgress))!,
          ),
        ),
        child: Row(
          children: [
            _recordingPulseDot(context, accent: accent),
            const SizedBox(width: 10),
            Text(
              _fmtElapsed(recordingElapsed),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ClipRect(
                child: Transform.translate(
                  offset: cancelInsetOffset,
                  child: Opacity(
                    opacity: cancelOpacity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cancelActive
                              ? Icons.delete_forever_rounded
                              : Icons.chevron_left_rounded,
                          size: 18,
                          color: cancelTint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cancelActive ? AppLocalizations.of(context)!.chatComposerReleaseToCancel : AppLocalizations.of(context)!.chatComposerSlideToCancel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cancelTint,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 30 + 6 * lockProgress,
              height: 30 + 6 * lockProgress,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: lockActive ? scheme.primary : Colors.transparent,
                border: Border.all(
                  color: lockTint,
                  width: lockActive ? 0 : 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                lockActive
                    ? Icons.lock_rounded
                    : Icons.keyboard_arrow_up_rounded,
                size: 16 + 2 * lockProgress,
                color: lockActive ? scheme.onPrimary : lockTint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _locked(BuildContext context) {
    // Minimal locked HUD:
    //   🗑    ●  0:12  ──animated bar──   ⏸  ▶(send)
    final scheme = Theme.of(context).colorScheme;
    final accent = isVoicePaused ? scheme.tertiary : scheme.primary;

    return _shell(
      context,
      key: const ValueKey('locked'),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            const SizedBox(width: 6),
            _recordingPulseDot(context, accent: accent, dim: isVoicePaused),
            const SizedBox(width: 8),
            Text(
              _fmtElapsed(recordingElapsed),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _slimWaveform(context, accent: accent, elapsed: recordingElapsed, dim: isVoicePaused),
            ),
            const SizedBox(width: 8),
            _miniIconButton(
              context,
              icon: isVoicePaused ? Icons.mic_rounded : Icons.pause_rounded,
              color: accent,
              onTap: enabled
                  ? (isVoicePaused
                      ? (onResumeRecording ?? onMic)
                      : (onPauseRecording ?? onMic))
                  : null,
            ),
            const SizedBox(width: 6),
            _miniIconButton(
              context,
              icon: Icons.send_rounded,
              color: Colors.white,
              fill: scheme.primary,
              onTap: enabled ? onMic : null,
            ),
          ],
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

  /// Slimmer waveform than the prior bar+track variant — a single row of
  /// animated bars with no spacer rail, sized to fit between elapsed and
  /// the action buttons.
  Widget _slimWaveform(BuildContext context, {required Color accent, required Duration elapsed, bool dim = false}) {
    final tone = dim ? accent.withValues(alpha: 0.55) : accent;
    final listenable = recordingAmplitudes;
    if (listenable == null) return _idleWave(tone, elapsed);
    // Only these bars repaint at the ~10 Hz amplitude rate — nothing else.
    return ValueListenableBuilder<List<double>>(
      valueListenable: listenable,
      builder: (context, amps, _) =>
          amps.isEmpty ? _idleWave(tone, elapsed) : _liveWave(tone, amps),
    );
  }

  /// Real-voice waveform: scrolling bars whose heights come from live mic
  /// amplitude, newest on the right — flows like Instagram's recorder.
  Widget _liveWave(Color tone, List<double> amps) {
    const maxH = 18.0, minH = 3.0, barW = 2.5, gap = 1.5;
    return SizedBox(
      height: maxH,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final avail =
              constraints.maxWidth.isFinite ? constraints.maxWidth : 120.0;
          final int barCount =
              ((avail + gap) / (barW + gap)).floor().clamp(6, 40).toInt();
          final start = amps.length > barCount ? amps.length - barCount : 0;
          final recent = amps.sublist(start);
          final int pad = barCount - recent.length;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < barCount; i++) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  curve: Curves.easeOut,
                  width: barW,
                  height:
                      minH + (i < pad ? 0.0 : recent[i - pad]) * (maxH - minH),
                  decoration: BoxDecoration(
                    color: tone,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                if (i != barCount - 1) const SizedBox(width: gap),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Fallback idle animation (amplitude stream unsupported).
  Widget _idleWave(Color tone, Duration elapsed) {
    final phase = elapsed.inSeconds % 4;
    const baseHeights = <double>[6, 11, 16, 9, 13, 7, 12, 8, 14, 10];
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < baseHeights.length; i++) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              width: 2.5,
              height: baseHeights[(i + phase) % baseHeights.length],
              decoration: BoxDecoration(
                color: tone,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            if (i != baseHeights.length - 1) const SizedBox(width: 2),
          ],
        ],
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
