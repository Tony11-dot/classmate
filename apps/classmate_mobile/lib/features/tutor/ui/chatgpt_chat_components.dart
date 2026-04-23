import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/glass/liquid_glass_card.dart';

bool _isRtlText(String s) {
  // Arabic + Hebrew ranges (broad)
  final rtl = RegExp(r'[\u0590-\u08FF]');
  return rtl.hasMatch(s);
}

Widget _bidiText(BuildContext context, String text, TextStyle? style) {
  final isRtl = _isRtlText(text);
  return Directionality(
    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
    child: Text(
      text,
      textAlign: isRtl ? TextAlign.right : TextAlign.left,
      style: style,
    ),
  );
}

class ChatGptLayout extends StatelessWidget {
  const ChatGptLayout({
    super.key,
    required this.title,
    required this.body,
    required this.composer,
    this.trailing,
  });

  final String title;
  final Widget body;
  final Widget composer;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        // ignore: use_null_aware_elements
        actions: [if (trailing != null) trailing!, const SizedBox(width: 8)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: body),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: composer,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatGptMessageList extends StatelessWidget {
  const ChatGptMessageList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: itemBuilder(context, index),
            ),
          ),
        );
      },
    );
  }
}

class ChatGptBubble extends StatelessWidget {
  const ChatGptBubble({required this.isUser, required this.text, super.key});

  final bool isUser;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final maxW = MediaQuery.of(context).size.width * 0.72;

    final bg = isUser
        ? cs.primary.withValues(alpha: 0.18)
        : cs.surface.withValues(alpha: 0.10);
    final border = cs.onSurface.withValues(alpha: 0.08);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: LiquidGlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 6),
                bottomRight: Radius.circular(isUser ? 6 : 18),
              ),
              blurSigma: 10,
              color: bg,
              border: Border.all(color: border, width: 1),
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUser)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _bidiText(
                        context,
                        AppLocalizations.of(context)!.titleNova,
                        theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                  _bidiText(
                    context,
                    text,
                    theme.textTheme.bodyMedium?.copyWith(height: 1.25),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatGptComposer extends StatelessWidget {
  const ChatGptComposer({
    super.key,
    required this.controller,
    required this.onSend,
    this.enabled = true,
    this.hintText,
    this.isSending = false,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;
  final bool isSending;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveHint =
        hintText ?? AppLocalizations.of(context)!.tutorMessageNovaHint;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: LiquidGlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          borderRadius: BorderRadius.circular(18),
          blurSigma: 12,
          color: theme.colorScheme.surface.withValues(alpha: 0.55),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.35),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: enabled && !isSending,
                  minLines: 1,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: effectiveHint,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SendButton(
                onPressed: (enabled && !isSending) ? onSend : null,
                isSending: isSending,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onPressed, required this.isSending});
  final VoidCallback? onPressed;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 40,
      width: 40,
      child: Material(
        color: (onPressed == null)
            ? theme.disabledColor.withValues(alpha: 0.15)
            : theme.colorScheme.primary.withValues(alpha: 0.85),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Center(
            child: isSending
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Transform.rotate(
                    angle: -math.pi / 4,
                    child: Icon(
                      Icons.send_rounded,
                      size: 18,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
