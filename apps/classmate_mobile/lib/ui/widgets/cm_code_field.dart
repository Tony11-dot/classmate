import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/cm_tokens.dart';

/// Visual state of a [CmCodeField], driven by the host's async check.
enum CmCodeStatus { idle, checking, success, error }

/// One-box-per-character code entry (2FA / SMS codes, classroom & group join
/// codes). The user sees exactly how many characters are expected.
///
/// A single invisible [TextField] owns the keyboard, paste and autofill; the
/// boxes only *render* its value, so system behaviours (paste a whole code,
/// SMS one-time-code autofill, backspace) work for free.
///
/// The host flips [status] while it validates:
/// * [CmCodeStatus.checking] — a wave pulses across the boxes.
/// * [CmCodeStatus.success]  — boxes turn green one after another and pop.
/// * [CmCodeStatus.error]    — the row shakes and turns red; typing again
///   resets it.
class CmCodeField extends StatefulWidget {
  const CmCodeField({
    super.key,
    required this.length,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.status = CmCodeStatus.idle,
    this.errorText,
    this.digitsOnly = false,
    this.upperCase = false,
    this.autofocus = true,
    this.enabled = true,
  });

  final int length;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  /// Fired once every box is filled.
  final ValueChanged<String>? onCompleted;
  final CmCodeStatus status;
  final String? errorText;
  final bool digitsOnly;

  /// Force upper-case (for case-insensitive codes). Leave false for codes that
  /// are case-sensitive, e.g. group invite codes.
  final bool upperCase;
  final bool autofocus;
  final bool enabled;

  @override
  State<CmCodeField> createState() => _CmCodeFieldState();
}

class _CmCodeFieldState extends State<CmCodeField>
    with TickerProviderStateMixin {
  late final TextEditingController _ctrl =
      widget.controller ?? TextEditingController();
  final FocusNode _focus = FocusNode();

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onText);
    _focus.addListener(() => setState(() {}));
    _syncStatus(null);
  }

  @override
  void didUpdateWidget(covariant CmCodeField old) {
    super.didUpdateWidget(old);
    if (old.status != widget.status) _syncStatus(old.status);
  }

  void _syncStatus(CmCodeStatus? previous) {
    switch (widget.status) {
      case CmCodeStatus.checking:
        _wave.repeat();
      case CmCodeStatus.success:
        _wave.stop();
        _reveal.forward(from: 0);
        HapticFeedback.mediumImpact();
      case CmCodeStatus.error:
        _wave.stop();
        _shake.forward(from: 0);
        HapticFeedback.heavyImpact();
      case CmCodeStatus.idle:
        _wave.stop();
        _reveal.value = 0;
    }
  }

  String _last = '';
  void _onText() {
    final v = _ctrl.text;
    if (v == _last) return;
    _last = v;
    setState(() {});
    widget.onChanged?.call(v);
    if (v.length == widget.length) widget.onCompleted?.call(v);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onText);
    if (widget.controller == null) _ctrl.dispose();
    _focus.dispose();
    _shake.dispose();
    _wave.dispose();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = CmTokens.of(context);
    final text = _ctrl.text;
    final status = widget.status;
    final disableMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;

    final field = SizedBox(
      // The real input: invisible, but sized so long-press → Paste works.
      height: 1,
      child: Opacity(
        opacity: 0,
        child: TextField(
          controller: _ctrl,
          focusNode: _focus,
          autofocus: widget.autofocus,
          enabled: widget.enabled && status != CmCodeStatus.checking,
          maxLength: widget.length,
          showCursor: false,
          enableInteractiveSelection: false,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.oneTimeCode],
          keyboardType:
              widget.digitsOnly ? TextInputType.number : TextInputType.visiblePassword,
          textCapitalization: widget.upperCase
              ? TextCapitalization.characters
              : TextCapitalization.none,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
            const _AsciiDigitsFormatter(),
            if (widget.digitsOnly) FilteringTextInputFormatter.digitsOnly,
            if (widget.upperCase) _UpperCaseFormatter(),
            LengthLimitingTextInputFormatter(widget.length),
          ],
          decoration: const InputDecoration(
            counterText: '',
            filled: false,
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ),
    );

    final boxes = LayoutBuilder(builder: (context, c) {
      const gap = 8.0;
      final w = math.min(
        52.0,
        (c.maxWidth - gap * (widget.length - 1)) / widget.length,
      );
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) const SizedBox(width: gap),
            _box(context, i, w, text, cs, t, disableMotion),
          ],
        ],
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!widget.enabled) return;
            if (_focus.hasFocus) {
              SystemChannels.textInput.invokeMethod('TextInput.show');
            } else {
              _focus.requestFocus();
            }
          },
          child: AnimatedBuilder(
            animation: _shake,
            builder: (context, child) {
              // Damped sine: a quick "no" shake.
              final p = _shake.value;
              final dx = disableMotion
                  ? 0.0
                  : math.sin(p * math.pi * 6) * 10 * (1 - p);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: boxes,
          ),
        )),
        field,
        AnimatedSwitcher(
          duration: CmTokens.medium,
          child: status == CmCodeStatus.error &&
                  (widget.errorText ?? '').trim().isNotEmpty
              ? Padding(
                  key: const ValueKey('err'),
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline_rounded, size: 16, color: cs.error),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          widget.errorText!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: cs.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox(key: ValueKey('none'), height: 0),
        ),
      ],
    );
  }

  Widget _box(
    BuildContext context,
    int i,
    double w,
    String text,
    ColorScheme cs,
    CmTokens t,
    bool disableMotion,
  ) {
    final status = widget.status;
    final char = i < text.length ? text[i] : '';
    final filled = char.isNotEmpty;
    final isCursor = _focus.hasFocus &&
        status != CmCodeStatus.checking &&
        status != CmCodeStatus.success &&
        (i == text.length || (i == widget.length - 1 && text.length == widget.length));

    return AnimatedBuilder(
      animation: Listenable.merge([_wave, _reveal]),
      builder: (context, _) {
        Color bg;
        Color border;
        Color fg = cs.onSurface;
        double scale = 1;
        double lift = 0;

        switch (status) {
          case CmCodeStatus.success:
            // Staggered: each box flips to green slightly after the last.
            final start = i / (widget.length + 2);
            final local = ((_reveal.value - start) / 0.35).clamp(0.0, 1.0);
            bg = Color.lerp(cs.surfaceContainerHigh, t.goodContainer, local)!;
            border = Color.lerp(cs.outlineVariant, t.good, local)!;
            fg = Color.lerp(cs.onSurface, t.onGoodContainer, local)!;
            scale = disableMotion ? 1 : 1 + 0.12 * math.sin(local * math.pi);
          case CmCodeStatus.error:
            bg = cs.errorContainer;
            border = cs.error;
            fg = cs.onErrorContainer;
          case CmCodeStatus.checking:
            // A soft wave travelling left → right.
            final phase = (_wave.value * (widget.length + 2) - i) / 2;
            final wave = (phase >= 0 && phase <= 1)
                ? math.sin(phase * math.pi)
                : 0.0;
            bg = Color.lerp(cs.surfaceContainerHigh,
                cs.primaryContainer, wave)!;
            border = Color.lerp(cs.outlineVariant, cs.primary, wave)!;
            lift = disableMotion ? 0 : -5 * wave;
          case CmCodeStatus.idle:
            bg = filled ? cs.surfaceContainerHighest : cs.surfaceContainerHigh;
            border = isCursor
                ? cs.primary
                : filled
                    ? cs.outline
                    : cs.outlineVariant.withValues(alpha: 0.6);
        }

        return Transform.translate(
          offset: Offset(0, lift),
          child: Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              width: w,
              height: w * 1.2,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: border,
                  width: isCursor || status != CmCodeStatus.idle ? 2 : 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 120),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: filled
                    ? Text(
                        char,
                        key: ValueKey('$i$char'),
                        style: TextStyle(
                          fontSize: w * 0.46,
                          fontWeight: FontWeight.w800,
                          color: fg,
                        ),
                      )
                    : isCursor
                        ? _Caret(color: cs.primary, height: w * 0.5)
                        : const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Arabic keyboards type Arabic-Indic (٠١٢) or Persian (۰۱۲) digits; the
/// digits-only filter would silently drop them. Map them to ASCII first.
class _AsciiDigitsFormatter extends TextInputFormatter {
  const _AsciiDigitsFormatter();

  static String _map(String s) => String.fromCharCodes(s.runes.map((r) {
        if (r >= 0x0660 && r <= 0x0669) return 0x30 + r - 0x0660;
        if (r >= 0x06F0 && r <= 0x06F9) return 0x30 + r - 0x06F0;
        return r;
      }));

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final mapped = _map(newValue.text);
    return mapped == newValue.text ? newValue : newValue.copyWith(text: mapped);
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
          TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

/// Blinking caret shown in the next empty box.
class _Caret extends StatefulWidget {
  const _Caret({required this.color, required this.height});
  final Color color;
  final double height;

  @override
  State<_Caret> createState() => _CaretState();
}

class _CaretState extends State<_Caret> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(
        width: 2,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
