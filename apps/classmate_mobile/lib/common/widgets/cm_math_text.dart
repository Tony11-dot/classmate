import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class CMMathText extends StatelessWidget {
  final String text;

  const CMMathText(this.text, {super.key});

  bool _isMath(String t) => t.contains(r'\(') && t.contains(r'\)');

  @override
  Widget build(BuildContext context) {
    if (_isMath(text)) {
      return Math.tex(
        text.replaceAll(r'\(', '').replaceAll(r'\)', ''),
        textStyle: const TextStyle(fontSize: 16),
      );
    }

    return Text(text, style: const TextStyle(fontSize: 16));
  }
}
