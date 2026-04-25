import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

import '../../core/text/normalize_question.dart';
import 'cm_code_block.dart';

/// Full ChatGPT-style renderer for AI-generated text.
///
/// Handles:
///  • Markdown: headers, bold, italic, lists, tables, blockquotes, hr
///  • Code blocks with syntax highlighting + copy button
///  • Block math: $$...$$  and  \[...\]
///  • Inline math: $...$  and  \(...\)
class CMAiMessage extends StatelessWidget {
  const CMAiMessage(
    this.text, {
    super.key,
    this.compact = false,
    this.textStyle,
  });

  final String text;
  final bool compact;

  /// Override the base prose text style.
  final TextStyle? textStyle;

  /// Split the raw AI reply into a list of [_Block]s.
  /// Order of extraction matters: code fences first, then block math.
  static List<_Block> _parse(String raw) {
    var src = prepareRenderableText(raw).replaceAll('\r\n', '\n');
    // Convert simple single-line $$...$$ that appear mid-sentence to $...$
    // so they render inline (avoids block spacing around short expressions).
    // Complex formulas (fractions, roots, sums, etc.) stay as block math.
    src = _inlineifySimpleBlockMath(src);
    final out = <_Block>[];

    // Combined regex: fenced code block OR block math (\[...\] or $$...$$)
    final re = RegExp(
      r'(```|~~~)([\w+\-]*)[ \t]*\n([\s\S]*?)\1'  // fenced code: group 2=lang, 3=body
      r'|\$\$([\s\S]+?)\$\$',                        // $$...$$        group 4
      multiLine: true,
    );

    var cursor = 0;
    for (final m in re.allMatches(src)) {
      if (m.start > cursor) {
        final prose = src.substring(cursor, m.start).trim();
        if (prose.isNotEmpty) _addProseOrMath(out, prose);
      }

      if (m.group(3) != null) {
        // Fenced code block
        final lang = (m.group(2) ?? '').trim();
        final body = (m.group(3) ?? '').trimRight();
        out.add(_Block.code(body, lang));
      } else {
        final math = (m.group(4) ?? '').trim();
        if (math.isNotEmpty) out.add(_Block.blockMath(math));
      }

      cursor = m.end;
    }

    if (cursor < src.length) {
      final prose = src.substring(cursor).trim();
      if (prose.isNotEmpty) _addProseOrMath(out, prose);
    }

    if (out.isEmpty && src.trim().isNotEmpty) {
      out.add(_Block.prose(src.trim()));
    }

    return out;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = textStyle ??
        theme.textTheme.bodyLarge?.copyWith(
          height: compact ? 1.4 : 1.6,
          fontSize: compact ? 14 : 15,
        );

    final blocks = _parse(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          _buildBlock(context, blocks[i], baseStyle),
          if (i < blocks.length - 1)
            SizedBox(height: _blockGap(blocks, i, compact)),
        ],
      ],
    );
  }

  Widget _buildBlock(BuildContext context, _Block block, TextStyle? base) {
    switch (block.type) {
      case _BlockType.code:
        return CMCodeBlock(block.value, language: block.lang ?? '');

      case _BlockType.blockMath:
        return _BlockMathWidget(block.value, style: base);

      case _BlockType.prose:
        return _ProseWidget(block.value, baseStyle: base, compact: compact);
    }
  }

  // If the entire prose string is a single $...$ expression, render it as a
  // horizontally-scrollable block-math widget instead of inline text. This
  // prevents RenderLine overflow when an answer option is purely a math tuple.
  static final _soleInlineMathRe = RegExp(r'^\$([^\$]+)\$$');

  static void _addProseOrMath(List<_Block> out, String prose) {
    final trimmed = prose.trim();
    final m = _soleInlineMathRe.firstMatch(trimmed);
    if (m != null) {
      out.add(_Block.blockMath(m.group(1)!.trim()));
    } else {
      out.add(_Block.prose(prose));
    }
  }

  // Spacing between adjacent blocks. Prose↔blockMath uses a tight gap so that
  // a formula displayed below a sentence doesn't look like a blank paragraph.
  static double _blockGap(List<_Block> blocks, int i, bool compact) {
    if (compact) return 3;
    final a = blocks[i].type;
    final b = blocks[i + 1].type;
    if ((a == _BlockType.prose && b == _BlockType.blockMath) ||
        (a == _BlockType.blockMath && b == _BlockType.prose)) {
      return 2;
    }
    return 8;
  }

  // Complex LaTeX commands that produce wide output — keep as block math.
  static final _complexMathRe = RegExp(
    r'\\(?:frac|sqrt|sum|int|oint|prod|binom|matrix|bmatrix|pmatrix|vmatrix|cases|begin|over)',
  );

  /// Converts $$...$$ to inline $...$, absorbing any surrounding newlines so
  /// they don't become paragraph breaks. Always inlines when there are no
  /// paragraph breaks (double newlines) around the math — which covers the
  /// common case where NOVA writes \[complex_math\] mid-sentence. Complex
  /// formulas surrounded by blank lines (paragraph breaks) stay as block math.
  static String _inlineifySimpleBlockMath(String src) {
    // [\s\S]*? allows newlines inside $$...$$ (e.g. from \[...\] conversion).
    // Leading/trailing \n* are captured so they can be absorbed on inline.
    final re = RegExp(r'\n*\$\$([\s\S]*?)\$\$\n*');
    final out = StringBuffer();
    var cursor = 0;

    for (final m in re.allMatches(src)) {
      final before = src.substring(cursor, m.start);
      // Normalize multi-line math to a single line for the simplicity check.
      final math = (m.group(1) ?? '').replaceAll('\n', ' ').trim();
      final isSimple = math.isNotEmpty &&
          math.length <= 40 &&
          !_complexMathRe.hasMatch(math);

      // Inline if: simple, OR if no paragraph break (double newline) on either
      // side. A paragraph break on both sides signals intentional block display.
      final matchText = m.group(0)!;
      final hasParagraphBreakBefore = matchText.startsWith('\n\n');
      final hasParagraphBreakAfter = matchText.endsWith('\n\n');
      final inline = isSimple || (!hasParagraphBreakBefore && !hasParagraphBreakAfter);

      if (inline) {
        // Discard surrounding newlines so no paragraph break forms.
        out.write(before);
        out.write(' \$$math\$ ');
      } else {
        // Complex math surrounded by paragraph breaks: keep as block.
        out.write(before);
        out.write(matchText);
      }
      cursor = m.end;
    }
    out.write(src.substring(cursor));
    return out.toString();
  }
}

// ── Block math ────────────────────────────────────────────────────────────────

class _BlockMathWidget extends StatelessWidget {
  const _BlockMathWidget(this.math, {this.style});
  final String math;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Math.tex(
        math,
        mathStyle: MathStyle.display,
        textStyle: style?.copyWith(fontSize: (style?.fontSize ?? 15) + 1),
        onErrorFallback: (_) => SelectableText(
          '\\[$math\\]',
          style: style?.copyWith(fontFamily: 'monospace'),
        ),
      ),
    );
  }
}

// ── Prose (markdown + inline math) ───────────────────────────────────────────

class _ProseWidget extends StatelessWidget {
  const _ProseWidget(this.text, {this.baseStyle, this.compact = false});
  final String text;
  final TextStyle? baseStyle;
  final bool compact;

  TextDirection _inferTextDirection(String value) {
    if (RegExp(r'[\u0590-\u05FF]').hasMatch(value)) {
      return TextDirection.rtl;
    }
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(value)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textDirection = _inferTextDirection(text);

    final styleSheet = MarkdownStyleSheet(
      p: baseStyle,
      h1: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h3: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h4: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h5: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      h6: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      strong: baseStyle?.copyWith(fontWeight: FontWeight.w700),
      em: baseStyle?.copyWith(fontStyle: FontStyle.italic),
      listBullet: baseStyle,
      tableBody: baseStyle?.copyWith(fontSize: 13),
      tableHead: baseStyle?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      blockquote: baseStyle?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.65),
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: cs.primary, width: 3),
        ),
        color: cs.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(4),
      ),
      blockquotePadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: cs.onSurface,
        backgroundColor: cs.onSurface.withValues(alpha: 0.08),
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF282C34),
        borderRadius: BorderRadius.circular(10),
      ),
      codeblockPadding: const EdgeInsets.all(14),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: cs.onSurface.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
      ),
      h1Padding: EdgeInsets.only(top: compact ? 6 : 12, bottom: 4),
      h2Padding: EdgeInsets.only(top: compact ? 4 : 10, bottom: 4),
      h3Padding: EdgeInsets.only(top: compact ? 4 : 8, bottom: 2),
      pPadding: EdgeInsets.zero,
      listIndent: 20,
      listBulletPadding: const EdgeInsets.only(right: 6),
    );

    return Directionality(
      textDirection: textDirection,
      child: MarkdownBody(
        data: text,
        selectable: true,
        softLineBreak: false,
        extensionSet: md.ExtensionSet(
          md.ExtensionSet.gitHubFlavored.blockSyntaxes,
          [
            _InlineMathSyntax(),
            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
          ],
        ),
        builders: {
          'inlinemath': _InlineMathBuilder(),
        },
        styleSheet: styleSheet,
      ),
    );
  }
}

// ── Inline math markdown extension ───────────────────────────────────────────

/// Recognises $...$ and \(...\) as inline math.
class _InlineMathSyntax extends md.InlineSyntax {
  // Match $...$  OR  \(...\)
  _InlineMathSyntax()
      : super(r'\$([^\$\n]+?)\$|\\\((.+?)\\\)');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final content = match.group(1) ?? match.group(2) ?? '';
    final el = md.Element.text('inlinemath', content);
    parser.addNode(el);
    return true;
  }
}

class _InlineMathBuilder extends MarkdownElementBuilder {
  @override
  bool isBlockElement() => false;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final mathText = element.textContent;
    final style = preferredStyle ?? parentStyle;
    // Small downward offset aligns the math baseline with surrounding text.
    return Transform.translate(
      offset: const Offset(0, 1.5),
      child: Math.tex(
        mathText,
        mathStyle: MathStyle.text,
        textStyle: style,
        onErrorFallback: (_) => Text(mathText, style: style),
      ),
    );
  }
}

// ── Internal block model ──────────────────────────────────────────────────────

enum _BlockType { code, blockMath, prose }

class _Block {
  const _Block._(this.type, this.value, {this.lang});
  factory _Block.code(String body, String lang) =>
      _Block._(_BlockType.code, body, lang: lang);
  factory _Block.blockMath(String math) =>
      _Block._(_BlockType.blockMath, math);
  factory _Block.prose(String text) => _Block._(_BlockType.prose, text);

  final _BlockType type;
  final String value;
  final String? lang;
}
