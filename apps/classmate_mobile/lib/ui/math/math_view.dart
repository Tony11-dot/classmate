import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathView extends StatelessWidget {
  final String latex;
  final TextStyle? textStyle;

  const MathView(
    this.latex, {
    super.key,
    this.textStyle,
  });

  bool get _looksLikeMath {
    final x = latex;
    return x.contains(r'\frac') ||
        x.contains(r'\sqrt') ||
        x.contains('^') ||
        x.contains(r'\text') ||
        x.contains(r'\Omega') ||
        x.contains(r'\Rightarrow');
  }

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? Theme.of(context).textTheme.titleMedium;

    if (!_looksLikeMath) {
      return SelectableText(latex, style: style);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Math.tex(
        latex,
        textStyle: style,
        mathStyle: MathStyle.text,
        onErrorFallback: (err) => SelectableText(latex, style: style),
      ),
    );
  }
}
