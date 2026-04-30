import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

import '../../core/text/normalize_question.dart';
import 'cm_code_block.dart';

/// Full AI-response renderer.
///
/// Handles:
///  • Markdown: headers, bold, italic, lists, tables, blockquotes, hr
///  • Code blocks with syntax highlighting + copy button
///  • Block math: $$...$$  and  \[...\]  (normalised to $$)
///  • Inline math: $...$  and  \(...\)  (normalised to $)
class CMAiMessage extends StatelessWidget {
  const CMAiMessage(
    this.text, {
    super.key,
    this.compact = false,
    this.textStyle,
  });

  final String text;
  final bool compact;
  final TextStyle? textStyle;

  /// Parse the AI reply into [_Block]s.
  static List<_Block> _parse(String raw) {
    final src = prepareRenderableText(raw);
    final out = <_Block>[];

    // One-pass extraction: fenced code blocks and $$...$$ block math.
    // Code fences: (```|~~~) lang \n body \1  — groups 2 (lang) + 3 (body)
    // Block math:  $$...$$                    — group 4
    final re = RegExp(
      r'(```|~~~)([\w+\-]*)[ \t]*\n([\s\S]*?)\1'
      r'|\$\$([\s\S]+?)\$\$',
      multiLine: true,
    );

    var cursor = 0;
    for (final m in re.allMatches(src)) {
      if (m.start > cursor) {
        final prose = src.substring(cursor, m.start).trim();
        if (prose.isNotEmpty) out.add(_Block.prose(prose));
      }

      if (m.group(3) != null) {
        // Fenced code block
        final lang = (m.group(2) ?? '').trim();
        final body = (m.group(3) ?? '').trimRight();
        if (body.isNotEmpty) out.add(_Block.code(body, lang));
      } else {
        // Block math $$...$$
        // sanitizeMathLatex already applied by prepareRenderableText, but
        // apply again here as a safety net for any math that slips through.
        final math = sanitizeMathLatex((m.group(4) ?? '').trim());
        if (math.isNotEmpty) out.add(_Block.blockMath(math));
      }

      cursor = m.end;
    }

    if (cursor < src.length) {
      final prose = src.substring(cursor).trim();
      if (prose.isNotEmpty) out.add(_Block.prose(prose));
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
        return _BlockMathWidget(block.value, style: base, compact: compact);
      case _BlockType.prose:
        return _ProseWidget(block.value, baseStyle: base, compact: compact);
    }
  }

  static double _blockGap(List<_Block> blocks, int i, bool compact) {
    if (compact) return 4;
    final a = blocks[i].type;
    final b = blocks[i + 1].type;
    // Tight gap between prose and display math — they belong together visually.
    if ((a == _BlockType.prose && b == _BlockType.blockMath) ||
        (a == _BlockType.blockMath && b == _BlockType.prose)) {
      return 6;
    }
    // Generous gap between code and anything else.
    if (a == _BlockType.code || b == _BlockType.code) return 12;
    // Between two display math blocks.
    if (a == _BlockType.blockMath && b == _BlockType.blockMath) return 8;
    return 12;
  }
}

// ── Block math ────────────────────────────────────────────────────────────────

class _BlockMathWidget extends StatelessWidget {
  const _BlockMathWidget(this.math, {this.style, this.compact = false});
  final String math;
  final TextStyle? style;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fontSize = (style?.fontSize ?? 15) + (compact ? 0 : 2);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 3 : 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.hardEdge,
          child: Math.tex(
            math,
            mathStyle: MathStyle.display,
            textStyle: style?.copyWith(fontSize: fontSize),
            onErrorFallback: (_) => _MathFallback(math, style: style),
          ),
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
    if (RegExp(r'[֐-׿؀-ۿ]').hasMatch(value)) return TextDirection.rtl;
    return TextDirection.ltr;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textDirection = _inferTextDirection(text);

    final styleSheet = MarkdownStyleSheet(
      p: baseStyle,
      h1: theme.textTheme.headlineMedium
          ?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
      h2: theme.textTheme.headlineSmall
          ?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
      h3: theme.textTheme.titleLarge
          ?.copyWith(fontWeight: FontWeight.w700, height: 1.3),
      h4: theme.textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.w600, height: 1.3),
      h5: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      h6: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      strong: baseStyle?.copyWith(fontWeight: FontWeight.w700),
      em: baseStyle?.copyWith(fontStyle: FontStyle.italic),
      listBullet: baseStyle,
      tableBody: baseStyle?.copyWith(fontSize: 13),
      tableHead:
          baseStyle?.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
      blockquote: baseStyle?.copyWith(
        color: cs.onSurface.withValues(alpha: 0.65),
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: cs.primary, width: 3)),
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

    // Pre-extract every $...$ span into [mathExprs] and replace each with a
    // control-char placeholder \x02M{index}\x02. This prevents MarkdownBody's
    // emphasis parser from mangling underscore-heavy subscripts like
    // \lim_{x \to 0} before the math builder can consume them.
    //
    // The regex matches inline math: $ not preceded or followed by $,
    // content may span multiple tokens but NOT multiple lines.
    final mathExprs = <String>[];
    final safeText = text.replaceAllMapped(
      RegExp(r'(?<!\$)\$(?!\$)((?:[^$\n\\]|\\.)+?)(?<!\$)\$(?!\$)'),
      (m) {
        final raw = (m.group(1) ?? '').trim();
        if (raw.isEmpty) return m.group(0)!;
        final expr = sanitizeMathLatex(raw);
        final idx = mathExprs.length;
        mathExprs.add(expr);
        return '\x02M$idx\x02';
      },
    );

    return Directionality(
      textDirection: textDirection,
      child: MarkdownBody(
        data: safeText,
        selectable: false,
        softLineBreak: false,
        extensionSet: md.ExtensionSet(
          md.ExtensionSet.gitHubFlavored.blockSyntaxes,
          [
            _MathPlaceholderSyntax(),
            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
          ],
        ),
        builders: {
          'mathph': _MathPlaceholderBuilder(mathExprs, compact: compact),
        },
        styleSheet: styleSheet,
      ),
    );
  }
}

// ── Inline math placeholder ────────────────────────────────────────────────────

class _MathPlaceholderSyntax extends md.InlineSyntax {
  _MathPlaceholderSyntax() : super('\x02M(\\d+)\x02');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final el = md.Element.text('mathph', match.group(1)!);
    parser.addNode(el);
    return true;
  }
}

class _MathPlaceholderBuilder extends MarkdownElementBuilder {
  _MathPlaceholderBuilder(this.exprs, {this.compact = false});
  final List<String> exprs;
  final bool compact;

  @override
  bool isBlockElement() => false;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final idx = int.tryParse(element.textContent) ?? -1;
    if (idx < 0 || idx >= exprs.length) return null;
    final mathText = exprs[idx];
    final style = preferredStyle ?? parentStyle;

    return _InlineMathWidget(mathText, style: style);
  }
}

class _InlineMathWidget extends StatelessWidget {
  const _InlineMathWidget(this.math, {this.style});
  final String math;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    // Render inline math at text style. Clip horizontally if it overflows —
    // never use a scroll view here since that breaks baseline alignment.
    return ClipRect(
      child: Math.tex(
        math,
        mathStyle: MathStyle.text,
        textStyle: style,
        onErrorFallback: (_) => _MathFallback(math, style: style, inline: true),
      ),
    );
  }
}

// ── Error fallback ────────────────────────────────────────────────────────────

/// Shown when flutter_math_fork fails to parse the LaTeX.
/// Attempts a few recovery heuristics before giving up and showing monospace.
class _MathFallback extends StatelessWidget {
  const _MathFallback(this.math, {this.style, this.inline = false});
  final String math;
  final TextStyle? style;
  final bool inline;

  String _tryRepair(String src) {
    var s = src
        .replaceAll('​', '')  // zero-width space
        .replaceAll(' ', ' ') // non-breaking space
        .replaceAll(RegExp(r'[^\x00-\x7Fα-ωΑ-Ω∀-⋿]'), '');
    // Drop dangling ^ or _ at end (causes parse error)
    s = s.replaceAll(RegExp(r'[_^]\s*$'), '');
    return s.trim();
  }

  @override
  Widget build(BuildContext context) {
    final repaired = _tryRepair(math);
    final style2 = style;

    // Try rendering the repaired string; if still fails, show monospace text.
    if (repaired.isNotEmpty && repaired != math) {
      return Math.tex(
        repaired,
        mathStyle: inline ? MathStyle.text : MathStyle.display,
        textStyle: style2,
        onErrorFallback: (_) => _monospace(context),
      );
    }
    return _monospace(context);
  }

  Widget _monospace(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      math,
      style: style?.copyWith(
        fontFamily: 'monospace',
        fontStyle: FontStyle.italic,
        color: cs.onSurface.withValues(alpha: 0.75),
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
  factory _Block.blockMath(String math) => _Block._(_BlockType.blockMath, math);
  factory _Block.prose(String text) => _Block._(_BlockType.prose, text);

  final _BlockType type;
  final String value;
  final String? lang;
}
