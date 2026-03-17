import 'package:flutter/material.dart';
import 'package:classmate_mobile/common/widgets/cm_code_block.dart';
import 'package:classmate_mobile/common/widgets/cm_math_text.dart';

class CMRichContent extends StatelessWidget {
  final String data;

  const CMRichContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final trimmed = data.trim();

    if (trimmed.startsWith('```') && trimmed.endsWith('```')) {
      final lines = trimmed.split('\n');
      final codeLines = lines.length >= 3
          ? lines.sublist(1, lines.length - 1)
          : <String>[];
      return CMCodeBlock(codeLines.join('\n'));
    }

    return CMMathText(trimmed);
  }
}
