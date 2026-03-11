import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathView extends StatelessWidget {
  final String expression;

  const MathView(this.expression, {super.key});

  bool _hasRtl(String s) {
    return RegExp(r'[\u0590-\u05FF\u0600-\u06FF]').hasMatch(s);
  }

  bool _looksLikeMath(String s) {
    return s.contains(r'\') ||
        s.contains('=') ||
        s.contains('^') ||
        s.contains('_') ||
        s.contains('{') ||
        s.contains('}') ||
        s.contains(r'$') ||
        s.contains('frac') ||
        s.contains('sqrt');
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final value = expression.trim();

    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_hasRtl(value) && !_looksLikeMath(value)) {
      return SelectableText(
        value,
        style: textStyle,
        textDirection: TextDirection.rtl,
      );
    }

    return Math.tex(
      value,
      mathStyle: MathStyle.text,
      textStyle: textStyle,
      onErrorFallback: (_) => SelectableText(value, style: textStyle),
    );
  }
}
