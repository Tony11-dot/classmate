import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

class CMCodeBlock extends StatelessWidget {
  final String code;

  const CMCodeBlock(this.code, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withValues(alpha: 0.05),
      ),
      child: HighlightView(
        code,
        language: 'cpp',
        theme: githubTheme,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
