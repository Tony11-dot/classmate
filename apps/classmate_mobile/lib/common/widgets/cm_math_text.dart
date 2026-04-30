import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../core/text/normalize_question.dart';

class CMMathText extends StatelessWidget {
  final String text;

  const CMMathText(this.text, {super.key});

  static final _inlineRe = RegExp(r'\\\((.+?)\\\)|\$([^$\n]+?)\$');

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(fontSize: 16);

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final m in _inlineRe.allMatches(text)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, m.start)));
      }
      final raw = m.group(1) ?? m.group(2) ?? '';
      final math = sanitizeMathLatex(raw.trim());
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Math.tex(
          math,
          mathStyle: MathStyle.text,
          textStyle: style,
          onErrorFallback: (_) => Text(
            math,
            style: style?.copyWith(
                fontFamily: 'monospace', fontStyle: FontStyle.italic),
          ),
        ),
      ));
      cursor = m.end;
    }

    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor)));
    }

    if (spans.isEmpty) return Text(text, style: style);

    return Text.rich(TextSpan(style: style, children: spans));
  }
}
