import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown/markdown.dart' as md;

import '../../core/text/normalize_question.dart';
import '../../features/practice/domain/practice_models.dart';
import '../../features/practice/providers/practice_providers.dart';
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
        // Fenced code block — `practice-cta` is a custom tag Nova emits
        // to launch a practice session; route it to its own block type
        // so we render a button instead of a code preview.
        final lang = (m.group(2) ?? '').trim();
        final body = (m.group(3) ?? '').trimRight();
        if (body.isNotEmpty) {
          if (lang == 'practice-cta') {
            out.add(_Block.practiceCta(body));
          } else {
            out.add(_Block.code(body, lang));
          }
        }
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
      case _BlockType.practiceCta:
        return PracticeCtaButton(jsonText: block.value);
    }
  }

  static double _blockGap(List<_Block> blocks, int i, bool compact) {
    if (compact) return 2;
    final a = blocks[i].type;
    final b = blocks[i + 1].type;
    // Display math must read as part of the surrounding paragraph — no
    // visible gap on either side. The math widget's own internal padding
    // is 0, so the total prose↔math gap is literally a single line of
    // text-space here.
    if ((a == _BlockType.prose && b == _BlockType.blockMath) ||
        (a == _BlockType.blockMath && b == _BlockType.prose)) {
      return 2;
    }
    // Adjacent display-math blocks: tight stack.
    if (a == _BlockType.blockMath && b == _BlockType.blockMath) return 4;
    // Generous gap between code and anything else (code blocks are heavy).
    if (a == _BlockType.code || b == _BlockType.code) return 10;
    return 8;
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
    // No internal vertical padding — the parent column's _blockGap is the
    // only source of spacing around display math now. Eliminates the
    // "blank line right before/after a formula" effect the user reported.
    return Align(
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
        color: cs.onSurface,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: cs.primary, width: 3)),
        color: cs.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      blockquotePadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: cs.onSurface,
        backgroundColor: cs.onSurface,
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xFF282C34),
        borderRadius: BorderRadius.circular(10),
      ),
      codeblockPadding: const EdgeInsets.all(14),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: cs.onSurface,
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
      // Tighter paragraph spacing — prevents NOVA responses feeling too spaced out.
      blockSpacing: compact ? 4.0 : 8.0,
      // Tables: distribute column widths proportionally so text never gets
      // squeezed into a single-character column.
      tableColumnWidth: const FlexColumnWidth(),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      tableBorder: TableBorder.all(
        color: cs.outlineVariant,
        width: 0.5,
      ),
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
    // FittedBox.scaleDown: renders at natural size when space allows;
    // shrinks proportionally when the parent is too narrow (e.g. table cells).
    // This prevents RenderLine overflow errors from flutter_math_fork while
    // keeping math legible — never clips or causes overflow assertions.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
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
        .replaceAll('×', r'\times ')
        .replaceAll('÷', r'\div ')
        .replaceAll('≤', r'\leq ')
        .replaceAll('≥', r'\geq ')
        .replaceAll('≠', r'\neq ')
        .replaceAll('≈', r'\approx ')
        .replaceAll('→', r'\to ')
        .replaceAll('↔', r'\leftrightarrow ')
        .replaceAll('⇒', r'\Rightarrow ')
        .replaceAll('⇔', r'\Leftrightarrow ')
        .replaceAll('∞', r'\infty ')
        .replaceAll('π', r'\pi ')
        .replaceAll('α', r'\alpha ')
        .replaceAll('β', r'\beta ')
        .replaceAll('γ', r'\gamma ')
        .replaceAll('θ', r'\theta ')
        .replaceAll('λ', r'\lambda ')
        .replaceAll('μ', r'\mu ')
        .replaceAll('σ', r'\sigma ')
        .replaceAll('φ', r'\phi ')
        .replaceAll('ω', r'\omega ')
        .replaceAll('Δ', r'\Delta ')
        .replaceAll('Σ', r'\Sigma ')
        .replaceAll('Ω', r'\Omega ')
        .replaceAll('∫', r'\int ')
        .replaceAll('∑', r'\sum ')
        .replaceAll('∏', r'\prod ')
        // Strip any remaining non-ASCII chars that would trip the
        // flutter_math_fork tokenizer.
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '');
    // Drop dangling ^ or _ at end (causes parse error).
    s = s.replaceAll(RegExp(r'[_^]\s*$'), '');
    // Close unbalanced braces — common when an LLM truncates mid-formula.
    final opens = '{'.allMatches(s).length;
    final closes = '}'.allMatches(s).length;
    if (opens > closes) s = s + '}' * (opens - closes);
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
        color: cs.onSurface,
      ),
    );
  }
}

// ── Internal block model ──────────────────────────────────────────────────────

enum _BlockType { code, blockMath, prose, practiceCta }

class _Block {
  const _Block._(this.type, this.value, {this.lang});
  factory _Block.code(String body, String lang) =>
      _Block._(_BlockType.code, body, lang: lang);
  factory _Block.blockMath(String math) => _Block._(_BlockType.blockMath, math);
  factory _Block.prose(String text) => _Block._(_BlockType.prose, text);
  /// A `practice-cta` fenced JSON block emitted by Nova when the user
  /// asks for a quiz. Renders as a "Start practice session" button that
  /// patches the practice filter and navigates to /practice.
  factory _Block.practiceCta(String jsonBody) =>
      _Block._(_BlockType.practiceCta, jsonBody);

  final _BlockType type;
  final String value;
  final String? lang;
}

// ── Practice-session CTA button ──────────────────────────────────────────────

/// Rendered in place of a ```practice-cta``` fenced code block in
/// Nova's response. Parses the JSON payload, prefills the practice
/// filter with the inferred subject/topic/difficulty/count, and
/// launches the practice setup screen so the user can start a real
/// graded session instead of an inline quiz.
class PracticeCtaButton extends ConsumerWidget {
  const PracticeCtaButton({super.key, required this.jsonText});
  final String jsonText;

  Map<String, dynamic>? _parse() {
    try {
      final decoded = jsonDecode(jsonText);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  PracticeDifficulty _difficultyOf(String? raw) {
    switch ((raw ?? '').toLowerCase().trim()) {
      case 'easy':
        return PracticeDifficulty.easy;
      case 'hard':
        return PracticeDifficulty.hard;
      case 'olympiad':
        return PracticeDifficulty.olympiad;
      case 'adaptive':
        return PracticeDifficulty.adaptive;
      default:
        return PracticeDifficulty.medium;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final data = _parse();
    // Malformed JSON — silently render nothing rather than show broken
    // text. Nova will usually self-correct on retry.
    if (data == null) return const SizedBox.shrink();

    final subject = (data['subject'] ?? '').toString().trim();
    final topicRaw = data['topic'];
    final topicPath = topicRaw is String && topicRaw.trim().isNotEmpty
        ? <String>[topicRaw.trim()]
        : (topicRaw is List
            ? topicRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
            : <String>[]);
    final difficulty = _difficultyOf(data['difficulty']?.toString());
    final questionCount = (data['questionCount'] is num)
        ? (data['questionCount'] as num).toInt().clamp(3, 20)
        : 10;

    final summaryBits = <String>[
      if (subject.isNotEmpty) subject,
      if (topicPath.isNotEmpty) topicPath.join(' › '),
      '$questionCount questions',
      _difficultyLabel(difficulty),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Patch the practice filter so the setup screen opens with
            // Nova's inferred settings already selected. The user can
            // still tweak before tapping Start.
            ref.read(practiceFilterProvider.notifier).patch(
                  subject: subject.isNotEmpty ? subject : null,
                  topicPath: topicPath.isNotEmpty ? topicPath : null,
                  difficulty: difficulty,
                  questionCount: questionCount,
                );
            context.push('/practice');
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: cs.onPrimary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start practice session',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: cs.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        summaryBits.join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onPrimaryContainer.withValues(alpha: 0.78),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.onPrimaryContainer),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _difficultyLabel(PracticeDifficulty d) {
    switch (d) {
      case PracticeDifficulty.easy:
        return 'Easy';
      case PracticeDifficulty.hard:
        return 'Hard';
      case PracticeDifficulty.olympiad:
        return 'Olympiad';
      case PracticeDifficulty.adaptive:
        return 'Adaptive';
      case PracticeDifficulty.medium:
        return 'Medium';
    }
  }
}
