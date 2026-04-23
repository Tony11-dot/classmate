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

  static final RegExp _tokenRe = RegExp(
    r'(\\\[[\s\S]+?\\\])|(\\\([\s\S]+?\\\))|(\$\$[\s\S]+?\$\$)|(\$[^$\n]+\$)',
    multiLine: true,
  );
  static final RegExp _codeFenceRe = RegExp(
    r'```([a-zA-Z0-9_+#.-]*)\n?([\s\S]*?)```',
    multiLine: true,
  );

  bool _hasRtl(String s) {
    return RegExp(r'[\u0590-\u05FF\u0600-\u06FF]').hasMatch(s);
  }

  String _unwrapMath(String raw) {
    if (raw.startsWith(r'\[') && raw.endsWith(r'\]')) {
      return raw.substring(2, raw.length - 2).trim();
    }
    if (raw.startsWith(r'\(') && raw.endsWith(r'\)')) {
      return raw.substring(2, raw.length - 2).trim();
    }
    if (raw.startsWith(r'$$') && raw.endsWith(r'$$')) {
      return raw.substring(2, raw.length - 2).trim();
    }
    if (raw.startsWith(r'$') && raw.endsWith(r'$')) {
      return raw.substring(1, raw.length - 1).trim();
    }
    return raw.trim();
  }

  bool _isBlock(String raw) {
    return (raw.startsWith(r'\[') && raw.endsWith(r'\]')) ||
        (raw.startsWith(r'$$') && raw.endsWith(r'$$'));
  }

  List<_MathChunk> _chunks(String input) {
    final out = <_MathChunk>[];
    var last = 0;

    for (final m in _tokenRe.allMatches(input)) {
      if (m.start > last) {
        final plain = normalizeQuestionText(input.substring(last, m.start));
        if (plain.isNotEmpty) out.add(_MathChunk.text(plain));
      }

      final raw = m.group(0)!;
      out.add(_MathChunk.math(_unwrapMath(raw), _isBlock(raw)));
      last = m.end;
    }

    if (last < input.length) {
      final plain = normalizeQuestionText(input.substring(last));
      if (plain.isNotEmpty) out.add(_MathChunk.text(plain));
    }

    if (out.isEmpty) {
      out.add(_MathChunk.text(normalizeQuestionText(input)));
    }

    return out;
  }

  Widget _plainText(String value, TextStyle? textStyle) {
    return SelectableText(
      value,
      style: textStyle,
      maxLines: maxLines,
      textDirection: _hasRtl(value) ? TextDirection.rtl : TextDirection.ltr,
    );
  }

  Widget _inlineMath(String value, TextStyle? textStyle) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 0, maxWidth: double.infinity),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Math.tex(
          value,
          mathStyle: MathStyle.text,
          textStyle: textStyle,
          onErrorFallback: (_) => SelectableText(value, style: textStyle),
        ),
      ),
    );
  }

  Widget _blockMath(String value, TextStyle? textStyle) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 4 : 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.hardEdge,
        child: Math.tex(
          value,
          mathStyle: MathStyle.display,
          textStyle: textStyle,
          onErrorFallback: (_) => SelectableText(value, style: textStyle),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final value = prepareRenderableText(data).trim();
    if (value.isEmpty) return const SizedBox.shrink();

    final textStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    if (_codeFenceRe.hasMatch(value)) {
      return _buildWithCodeFences(value, textStyle);
    }

    return _buildMathTextOnly(value, textStyle);
  }

  Widget _buildWithCodeFences(String value, TextStyle? textStyle) {
    final widgets = <Widget>[];
    var last = 0;

    for (final match in _codeFenceRe.allMatches(value)) {
      if (match.start > last) {
        final plain = value.substring(last, match.start).trim();
        if (plain.isNotEmpty) {
          widgets.add(_buildMathTextOnly(plain, textStyle));
        }
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
        widgets.add(_buildMathTextOnly(tail, textStyle));
      }
    }

    if (widgets.isEmpty) {
      return _buildMathTextOnly(value, textStyle);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildMathTextOnly(String value, TextStyle? textStyle) {
    final normalizedValue = normalizeQuestionText(value);

    if (!_tokenRe.hasMatch(value)) {
      return _plainText(normalizedValue, textStyle);
    }

    final chunks = _chunks(value);
    final hasBlock = chunks.any((c) => !c.isText && c.isBlock);

    if (!hasBlock) {
      return Wrap(
        spacing: compact ? 4 : 6,
        runSpacing: compact ? 2 : 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final chunk in chunks)
            if (chunk.isText)
              _plainText(chunk.value, textStyle)
            else
              _inlineMath(chunk.value, textStyle),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final chunk in chunks)
          if (chunk.isText)
            Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 1 : 2),
              child: _plainText(chunk.value, textStyle),
            )
          else if (chunk.isBlock)
            _blockMath(chunk.value, textStyle)
          else
            Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 1 : 2),
              child: _inlineMath(chunk.value, textStyle),
            ),
      ],
    );
  }
}

class _MathChunk {
  final String value;
  final bool isText;
  final bool isBlock;

  const _MathChunk._(this.value, this.isText, this.isBlock);

  factory _MathChunk.text(String value) => _MathChunk._(value, true, false);

  factory _MathChunk.math(String value, bool isBlock) =>
      _MathChunk._(value, false, isBlock);
}
