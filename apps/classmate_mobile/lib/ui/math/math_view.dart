import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class _Piece {
  final String text;
  final bool isMath;

  const _Piece.text(this.text) : isMath = false;
  const _Piece.math(this.text) : isMath = true;
}

class MathView extends StatelessWidget {
  final String latex;
  final TextStyle? textStyle;
  final bool centered;
  final EdgeInsetsGeometry padding;

  const MathView(
    this.latex, {
    super.key,
    this.textStyle,
    this.centered = false,
    this.padding = const EdgeInsets.symmetric(vertical: 4),
  });

  String _clean(String s) {
    var x = s.trim();

    if (x.startsWith(r'$$') && x.endsWith(r'$$') && x.length >= 4) {
      x = x.substring(2, x.length - 2);
    } else if (x.startsWith(r'$') && x.endsWith(r'$') && x.length >= 2) {
      x = x.substring(1, x.length - 1);
    }

    x = x.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

    while (x.contains('\\\\')) {
      x = x.replaceAll('\\\\', '\\');
    }

    x = x.replaceAll(r'\(', '');
    x = x.replaceAll(r'\)', '');
    x = x.replaceAll(r'\[', '');
    x = x.replaceAll(r'\]', '');

    return x.trim();
  }

  String _normalizeText(String s) {
    var x = _clean(s);

    final phraseFixes = <String, String>{
      'solvefor': 'solve for ',
      'findx': 'find x ',
      'findy': 'find y ',
      'showthat': 'show that ',
      'provethat': 'prove that ',
      'therefore': 'therefore ',
      'hence': 'hence ',
      'letx': 'let x ',
      'lety': 'let y ',
      'giventhat': 'given that ',
      'computevalue': 'compute value ',
      'simplifyexpression': 'simplify expression ',
    };

    phraseFixes.forEach((k, v) {
      x = x.replaceAllMapped(RegExp(k, caseSensitive: false), (_) => v);
    });

    x = x.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)!} ${m.group(2)!}',
    );

    x = x.replaceAllMapped(
      RegExp(r'([A-Za-z])(\d)'),
      (m) => '${m.group(1)!} ${m.group(2)!}',
    );

    x = x.replaceAllMapped(
      RegExp(r'(\d)([A-Za-z])'),
      (m) => '${m.group(1)!} ${m.group(2)!}',
    );

    x = x.replaceAllMapped(
      RegExp(r'([.!?,:;])([A-Za-z])'),
      (m) => '${m.group(1)!} ${m.group(2)!}',
    );

    x = x.replaceAllMapped(RegExp(r'\s+'), (_) => ' ');

    return x.trim();
  }

  String _latexifyLooseMath(String s) {
    var x = s;

    x = x.replaceAll('±', r'\pm ');
    x = x.replaceAll('Ω', r'\Omega ');
    x = x.replaceAll('°', r'^\circ ');
    x = x.replaceAll('>=', r'\ge ');
    x = x.replaceAll('<=', r'\le ');
    x = x.replaceAll('!=', r'\ne ');
    x = x.replaceAll('=>', r'\Rightarrow ');
    x = x.replaceAll('->', r'\to ');

    x = x.replaceAllMapped(
      RegExp(r'(?<!\\)sqrt\s*\(\s*([^)]+?)\s*\)'),
      (m) => '\\sqrt{${m.group(1)!.trim()}}',
    );

    x = x.replaceAllMapped(
      RegExp(r'(?<!\\)sqrt\s*([A-Za-z0-9]+)'),
      (m) => '\\sqrt{${m.group(1)!.trim()}}',
    );

    x = x.replaceAllMapped(
      RegExp(r'(?<!\\)\b([A-Za-z0-9]+)\s*/\s*([A-Za-z0-9]+)\b'),
      (m) => '\\frac{${m.group(1)!.trim()}}{${m.group(2)!.trim()}}',
    );

    x = x.replaceAllMapped(
      RegExp(r'(?<!\\)\b([A-Za-z0-9]+)\^([A-Za-z0-9]+)\b'),
      (m) => '${m.group(1)!}^{${m.group(2)!}}',
    );

    x = x.replaceAllMapped(
      RegExp(r'(?<!\\)\b(sin|cos|tan|log|ln)([A-Za-z0-9])'),
      (m) => '${m.group(1)!} ${m.group(2)!}',
    );

    x = x.replaceAllMapped(
      RegExp(r'(\S)([+\-*=])(\S)'),
      (m) => '${m.group(1)!} ${m.group(2)!} ${m.group(3)!}',
    );

    x = x.replaceAllMapped(RegExp(r'\s+'), (_) => ' ');
    return x.trim();
  }

  String _normalizeMath(String s) {
    return _latexifyLooseMath(_clean(s));
  }

  bool _looksLikeMath(String s) {
    return s.contains(r'\sqrt') ||
        s.contains(r'\frac') ||
        s.contains(r'\pm') ||
        s.contains(r'\Omega') ||
        s.contains(r'\Rightarrow') ||
        s.contains(r'\to') ||
        s.contains(r'\ge') ||
        s.contains(r'\le') ||
        s.contains(r'\ne') ||
        s.contains(r'$') ||
        s.contains('^') ||
        s.contains('=') ||
        s.contains('+') ||
        s.contains('-') ||
        s.contains('/');
  }

  String _escapeTextForLatex(String s) {
    s = s.replaceAll(' ', r'\ ');
    return s
        .replaceAll(r'\', r'\\')
        .replaceAll('{', r'\{')
        .replaceAll('}', r'\}')
        .replaceAll('%', r'\%')
        .replaceAll('&', r'\&')
        .replaceAll('#', r'\#')
        .replaceAll('_', r'\_')
        .replaceAll(r'$', r'\$');
  }

  List<_Piece> _splitLine(String raw) {
    final line = _clean(raw);
    if (line.isEmpty) return const <_Piece>[];

    final dollar = RegExp(r'\$[^$]+\$');
    final matches = dollar.allMatches(line).toList();

    if (matches.isNotEmpty) {
      final out = <_Piece>[];
      var cursor = 0;

      for (final m in matches) {
        if (m.start > cursor) {
          final txt = _normalizeText(line.substring(cursor, m.start));
          if (txt.isNotEmpty) {
            out.add(_Piece.text(txt));
          }
        }

        final math = _normalizeMath(m.group(0)!);
        if (math.isNotEmpty) {
          out.add(_Piece.math(math));
        }

        cursor = m.end;
      }

      if (cursor < line.length) {
        final txt = _normalizeText(line.substring(cursor));
        if (txt.isNotEmpty) {
          out.add(_Piece.text(txt));
        }
      }

      return out;
    }

    if (_looksLikeMath(line)) {
      return <_Piece>[_Piece.math(_normalizeMath(line))];
    }

    return <_Piece>[_Piece.text(_normalizeText(line))];
  }

  Widget _pieceWidget(BuildContext context, _Piece piece, TextStyle? style) {
    final expr = piece.isMath
        ? piece.text
        : '\\text{${_escapeTextForLatex(piece.text)}}';

    return Math.tex(
      expr,
      mathStyle: MathStyle.text,
      textStyle: style,
      onErrorFallback: (_) => Text(
        piece.text,
        style: style,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        softWrap: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = textStyle ?? Theme.of(context).textTheme.titleMedium;
    final lines = _clean(
      latex,
    ).split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: centered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Wrap(
                alignment: centered
                    ? WrapAlignment.center
                    : WrapAlignment.start,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final piece in _splitLine(line))
                    piece.isMath
                        ? ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: _pieceWidget(context, piece, style),
                            ),
                          )
                        : _pieceWidget(context, piece, style),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
