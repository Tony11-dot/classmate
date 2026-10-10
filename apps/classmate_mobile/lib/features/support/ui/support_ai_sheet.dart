import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/theme/cm_tokens.dart';
import '../../../ui/widgets/cm_press.dart';
import '../../../ui/widgets/nova_avatar.dart';
import '../../chat_core/ui/chat_bubble_tail.dart';
import '../../chat_core/ui/chat_composer.dart';
import '../data/support_ai_repository.dart';

/// Opens the support assistant as a tall, rounded modal sheet. Self-contained:
/// no router wiring, keeps the FAQ screen beneath it.
Future<void> showSupportAiSheet(BuildContext context) {
  return showModalBottomSheet<void>(
      useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SupportAiSheet(),
  );
}

class _SupportAiSheet extends ConsumerStatefulWidget {
  const _SupportAiSheet();

  @override
  ConsumerState<_SupportAiSheet> createState() => _SupportAiSheetState();
}

class _SupportAiSheetState extends ConsumerState<_SupportAiSheet> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<SupportTurn> _turns = <SupportTurn>[];
  bool _sending = false;
  bool _errored = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    // History is every turn BEFORE this new question (bounded server-side too).
    final history = List<SupportTurn>.from(_turns);

    setState(() {
      _turns.add(SupportTurn(role: 'user', content: text));
      _controller.clear();
      _sending = true;
      _errored = false;
    });
    _scrollToEnd();

    try {
      final answer =
          await ref.read(supportAiRepositoryProvider).ask(text, history: history);
      if (!mounted) return;
      final clean = _plainText(answer);
      setState(() {
        _turns.add(SupportTurn(
          role: 'assistant',
          content: clean.isEmpty
              ? AppLocalizations.of(context)!.supportAiError
              : clean,
        ));
        _sending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _errored = true;
      });
    }
    _scrollToEnd();
  }

  /// The support bubble renders as plain [SelectableText], so any HTML tags or
  /// markdown the model emits show up as literal characters (web QA #90). Strip
  /// tags, decode the common entities, and flatten markdown emphasis/headers/
  /// bullets to clean prose.
  String _plainText(String raw) {
    var s = raw;
    // Fenced/inline code fences → drop the backticks, keep the content.
    s = s.replaceAll(RegExp(r'```[a-zA-Z]*\n?'), '').replaceAll('`', '');
    // HTML tags.
    s = s.replaceAll(RegExp(r'<[^>]+>'), '');
    // Common HTML entities.
    const entities = {
      '&amp;': '&', '&lt;': '<', '&gt;': '>', '&quot;': '"',
      '&#39;': "'", '&apos;': "'", '&nbsp;': ' ',
    };
    entities.forEach((k, v) => s = s.replaceAll(k, v));
    // Markdown headers (### Title) → plain line.
    s = s.replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '');
    // Bold/italic markers (**x**, __x__, *x*, _x_) → bare text.
    s = s.replaceAllMapped(
        RegExp(r'(\*\*|__|\*|_)(.+?)\1'), (m) => m.group(2) ?? '');
    // Markdown links [label](url) → "label (url)".
    s = s.replaceAllMapped(
        RegExp(r'\[([^\]]+)\]\(([^)]+)\)'), (m) => '${m[1]} (${m[2]})');
    // List bullets (- / * at line start) → •.
    s = s.replaceAll(RegExp(r'^\s*[-*]\s+', multiLine: true), '• ');
    // Collapse 3+ blank lines to a single blank line.
    s = s.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return s.trim();
  }

  /// Re-asks the last question after a failure (the user turn is already in
  /// the list, so only the answer is retried).
  Future<void> _retry() async {
    if (_sending || _turns.isEmpty || !_turns.last.isUser) return;
    final question = _turns.last.content;
    final history = _turns.sublist(0, _turns.length - 1);
    setState(() {
      _sending = true;
      _errored = false;
    });
    _scrollToEnd();
    try {
      final answer = await ref
          .read(supportAiRepositoryProvider)
          .ask(question, history: history);
      if (!mounted) return;
      final clean = _plainText(answer);
      setState(() {
        _turns.add(SupportTurn(
          role: 'assistant',
          content: clean.isEmpty
              ? AppLocalizations.of(context)!.supportAiError
              : clean,
        ));
        _sending = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _errored = true;
      });
    }
    _scrollToEnd();
  }

  void _ask(String q) {
    _controller.text = q;
    _send();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;

    final suggestions = <(IconData, String)>[
      (Icons.lock_reset_rounded, l.supportAiSuggestPassword),
      (Icons.vpn_key_rounded, l.supportAiSuggestJoin),
      (Icons.palette_rounded, l.supportAiSuggestTheme),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Grab handle + header ─────────────────────────────────────────
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 8, 10),
            child: Row(
              children: [
                // NOVA's actual face + name — the support assistant IS NOVA.
                const NovaAvatar(size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.supportAiSheetTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: CmTokens.of(context).good,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l.supportAiSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l.commonClose,
                  style: IconButton.styleFrom(
                    backgroundColor: cs.surfaceContainerHigh,
                  ),
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          // ── Messages ─────────────────────────────────────────────────────
          Expanded(
            child: ListView(
              controller: _scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              children: [
                _Bubble(text: l.supportAiGreeting, fromUser: false, tail: true),
                if (_turns.isEmpty) ...[
                  const SizedBox(height: 6),
                  for (final (icon, q) in suggestions)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8, bottom: 8),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: CmPress(
                          onTap: () => _ask(q),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(icon, size: 17, color: cs.primary),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    q,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
                for (var i = 0; i < _turns.length; i++)
                  _Bubble(
                    text: _turns[i].content,
                    fromUser: _turns[i].isUser,
                    tail: i == 0 || _turns[i - 1].isUser != _turns[i].isUser,
                  ),
                if (_sending) const _TypingBubble(),
                if (_errored)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8, top: 4, bottom: 8),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 8, 10),
                        decoration: BoxDecoration(
                          color: cs.errorContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline_rounded, size: 18, color: cs.onErrorContainer),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l.supportAiError,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: cs.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            TextButton.icon(
                              onPressed: _retry,
                              style: TextButton.styleFrom(
                                foregroundColor: cs.onErrorContainer,
                              ),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: Text(l.retry),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // ── Disclaimer + composer ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
            child: Text(
              l.supportAiDisclaimer,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          // Same pill composer as every chat in the app — text only here.
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ChatComposer(
            controller: _controller,
            onSend: _send,
            onCamera: () {},
            onAttach: () {},
            onMic: () {},
            showCamera: false,
            showAttach: false,
            showMic: false,
            enabled: !_sending,
            hintText: l.supportAiInputHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.fromUser, this.tail = false});
  final String text;
  final bool fromUser;
  final bool tail;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final pointRight = fromUser != rtl;
    final color = fromUser ? cs.primary : cs.surfaceContainerHigh;
    const r = Radius.circular(18);
    final radius = !tail
        ? const BorderRadius.all(r)
        : BorderRadius.only(
            topLeft: pointRight ? r : Radius.zero,
            topRight: pointRight ? Radius.zero : r,
            bottomLeft: r,
            bottomRight: r,
          );
    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: color, borderRadius: radius),
      child: SelectableText(
        text,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: fromUser ? cs.onPrimary : cs.onSurface,
          height: 1.4,
          fontSize: 15,
        ),
      ),
    );
    final pointer = tail
        ? ChatBubbleTail(color: color, pointRight: pointRight)
        : const SizedBox(width: 8);
    return Padding(
      padding: EdgeInsets.only(bottom: 6, top: tail ? 4 : 0),
      child: Align(
        alignment: fromUser ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.ltr,
          children: pointRight
              ? [Flexible(child: bubble), pointer]
              : [pointer, Flexible(child: bubble)],
        ),
      ),
    );
  }
}

/// Three bouncing dots while NOVA is answering.
class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8, top: 2, bottom: 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++)
                  Builder(builder: (_) {
                    final t = (_c.value - i * 0.18) % 1.0;
                    final up = t < 0.5 ? math.sin(t * 2 * math.pi) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Transform.translate(
                        offset: Offset(0, -4 * up.clamp(0.0, 1.0)),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: cs.onSurfaceVariant
                                .withValues(alpha: 0.45 + 0.5 * up.clamp(0.0, 1.0)),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
