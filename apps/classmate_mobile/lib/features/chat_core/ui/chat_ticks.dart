import 'package:flutter/material.dart';

/// WhatsApp-style delivery ticks, shared by every own-message bubble.
///
/// This exists because the ticks were drawn twice, differently: text/media
/// bubbles stacked two single `done_rounded` glyphs by hand while voice bubbles
/// used the real `done_all_rounded`, so the same message state looked like two
/// different states depending on what kind of message it was.
///
/// The three states map to the server's `delivered` / `seen` flags:
///   ✓        sent      — the server has it, nobody's device has confirmed
///   ✓✓ grey  delivered — it reached every recipient's device
///   ✓✓ blue  seen      — every recipient opened the thread after it arrived
enum ChatTickState { sent, delivered, seen }

class ChatTicks extends StatelessWidget {
  const ChatTicks({
    super.key,
    required this.state,
    required this.onAccentSurface,
    this.size = 15,
  });

  /// Which tick to draw.
  final ChatTickState state;

  /// True when the ticks sit on the coloured own-message bubble (or on a media
  /// overlay), where they must be light. False on a plain surface, where they
  /// take the theme's muted foreground instead of hardcoded white — the old
  /// code assumed a dark own-bubble, which the lighter themes broke.
  final bool onAccentSurface;

  final double size;

  /// WhatsApp's read-receipt blue. Deliberately constant across themes: it is
  /// a status signal people recognise, not a brand accent.
  static const Color seenBlue = Color(0xFF53BDEB);

  @override
  Widget build(BuildContext context) {
    final muted = onAccentSurface
        ? Colors.white.withValues(alpha: 0.82)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    final (icon, color) = switch (state) {
      ChatTickState.seen => (Icons.done_all_rounded, seenBlue),
      ChatTickState.delivered => (Icons.done_all_rounded, muted),
      ChatTickState.sent => (Icons.done_rounded, muted),
    };

    return Icon(
      icon,
      size: size,
      color: color,
      // Read out as words rather than as an unlabelled glyph.
      semanticLabel: switch (state) {
        ChatTickState.seen => 'Read',
        ChatTickState.delivered => 'Delivered',
        ChatTickState.sent => 'Sent',
      },
    );
  }

  /// Convenience for the common `delivered`/`seen` boolean pair.
  static ChatTickState stateOf({required bool delivered, required bool seen}) =>
      seen
          ? ChatTickState.seen
          : delivered
              ? ChatTickState.delivered
              : ChatTickState.sent;
}
