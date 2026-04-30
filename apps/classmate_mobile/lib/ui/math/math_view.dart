import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../common/widgets/cm_code_block.dart';
import '../../core/text/normalize_question.dart';

class MathView extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final int? maxLines;
  final bool compact;

  const MathView(
    this.data, {
    super.key,
    this.style,
    this.maxLines,
    this.compact = false,
  });

  // Matches $$...$$, $...$, \[...\], \(...\) (priority order).
  // After prepareRenderableText, \[...\] → $$/$ and \(...\) → $.
  static final RegExp _tokenRe = RegExp(
    r'(\$\$[\s\S]+?\$\$)|(\$[^$\n]+?\$)',
    multiLine: true,
  );
  static final RegExp _codeFenceRe = RegExp(
    r'```([a-zA-Z0-9_+#.-]*)\n?([\s\S]*?)```',
    multiLine: true,
  );

  bool _hasRtl(String s) => RegExp(r'[֐-׿؀-ۿ]').hasMatch(s);

  ({String content, bool isBlock}) _unwrap(String raw) {
    if (raw.startsWith(r'$$') && raw.endsWith(r'$$')) {
      return (
        content: sanitizeMathLatex(raw.substring(2, raw.length - 2).trim()),
        isBlock: true,
      );
    }
    return (
      content: sanitizeMathLatex(raw.substring(1, raw.length - 1).trim()),
      isBlock: false,
    );
  }

  List<_Chunk> _chunks(String input) {
    final out = <_Chunk>[];
    var last = 0;

    for (final m in _tokenRe.allMatches(input)) {
      if (m.start > last) {
        final plain = input.substring(last, m.start);
        if (plain.isNotEmpty) out.add(_Chunk.text(plain));
      }
      final raw = m.group(0)!;
      final r = _unwrap(raw);
      out.add(_Chunk.math(r.content, r.isBlock));
      last = m.end;
    }

    if (last < input.length) {
      final plain = input.substring(last);
      if (plain.isNotEmpty) out.add(_Chunk.text(plain));
    }

    if (out.isEmpty) out.add(_Chunk.text(input));
    return out;
  }

  Widget _plainText(String value, TextStyle? ts) => SelectableText(
        value,
        style: ts,
        maxLines: maxLines,
        textDirection: _hasRtl(value) ? TextDirection.rtl : TextDirection.ltr,
      );

  Widget _inlineMath(String value, TextStyle? ts) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Math.tex(
          value,
          mathStyle: MathStyle.text,
          textStyle: ts,
          onErrorFallback: (_) => Text(
            value,
            style: ts?.copyWith(
                fontFamily: 'monospace', fontStyle: FontStyle.italic),
          ),
        ),
      );

  Widget _inlineMathSpan(String value, TextStyle? ts) => Math.tex(
        value,
        mathStyle: MathStyle.text,
        textStyle: ts,
        onErrorFallback: (_) => Text(
          value,
          style: ts?.copyWith(
              fontFamily: 'monospace', fontStyle: FontStyle.italic),
        ),
      );

  Widget _blockMath(String value, TextStyle? ts) => Padding(
        padding: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.hardEdge,
          child: Math.tex(
            value,
            mathStyle: MathStyle.display,
            textStyle: ts,
            onErrorFallback: (_) => SelectableText(
              value,
              style: ts?.copyWith(fontFamily: 'monospace'),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final value = prepareRenderableText(data).trim();
    if (value.isEmpty) return const SizedBox.shrink();

    final ts = style ?? Theme.of(context).textTheme.bodyMedium;
    if (_codeFenceRe.hasMatch(value)) {
      return _buildWithCodeFences(value, ts);
    }
    return _buildMathText(value, ts);
  }

  Widget _buildWithCodeFences(String value, TextStyle? ts) {
    final widgets = <Widget>[];
    var last = 0;

    for (final match in _codeFenceRe.allMatches(value)) {
      if (match.start > last) {
        final plain = value.substring(last, match.start).trim();
        if (plain.isNotEmpty) widgets.add(_buildMathText(plain, ts));
      }

      final language = (match.group(1) ?? '').trim();
      final code = (match.group(2) ?? '').trimRight();
      if (code.isNotEmpty) {
        if (widgets.isNotEmpty) widgets.add(SizedBox(height: compact ? 6 : 10));
        widgets.add(CMCodeBlock(code, language: language));
      }

      last = match.end;
    }

    if (last < value.length) {
      final tail = value.substring(last).trim();
      if (tail.isNotEmpty) {
        if (widgets.isNotEmpty) widgets.add(SizedBox(height: compact ? 6 : 10));
        widgets.add(_buildMathText(tail, ts));
      }
    }

    return widgets.isEmpty
        ? _buildMathText(value, ts)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widgets,
          );
  }

  Widget _buildMathText(String value, TextStyle? ts) {
    if (!_tokenRe.hasMatch(value)) {
      return _plainText(normalizeQuestionText(value), ts);
    }

    final chunks = _chunks(value);
    final hasBlock = chunks.any((c) => !c.isText && c.isBlock);

    if (!hasBlock) {
      return Text.rich(
        TextSpan(
          style: ts,
          children: [
            for (final chunk in chunks)
              if (chunk.isText)
                TextSpan(text: chunk.value)
              else
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: _inlineMathSpan(chunk.value, ts),
                ),
          ],
        ),
        textDirection:
            _hasRtl(value) ? TextDirection.rtl : TextDirection.ltr,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final chunk in chunks)
          if (chunk.isText)
            Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 1 : 2),
              child: _plainText(normalizeQuestionText(chunk.value), ts),
            )
          else if (chunk.isBlock)
            _blockMath(chunk.value, ts)
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 1 : 2),
              child: _inlineMath(chunk.value, ts),
            ),
      ],
    );
  }
}

class _Chunk {
  final String value;
  final bool isText;
  final bool isBlock;

  const _Chunk._(this.value, this.isText, this.isBlock);
  factory _Chunk.text(String value) => _Chunk._(value, true, false);
  factory _Chunk.math(String value, bool isBlock) =>
      _Chunk._(value, false, isBlock);
}
