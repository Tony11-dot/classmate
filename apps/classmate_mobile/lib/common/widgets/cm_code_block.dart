import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:highlight/languages/all.dart' show allLanguages;

import '../../l10n/app_localizations.dart';

class CMCodeBlock extends StatelessWidget {
  final String code;

  /// The fence language string (e.g. 'python', 'js', 'dart'). May be empty.
  final String language;

  const CMCodeBlock(this.code, {super.key, this.language = ''});

  // Map fence language strings to the grammar names the `highlight` package
  // actually registers. Most fence names pass through unchanged (validated
  // against allLanguages below); these are the ones that differ or are common
  // aliases. IMPORTANT: highlight.js has NO `html` grammar — HTML/SVG/XHTML are
  // all the `xml` grammar, which is why HTML used to render unhighlighted.
  static const _aliases = <String, String>{
    'py': 'python',
    'js': 'javascript',
    'jsx': 'javascript',
    'ts': 'typescript',
    'tsx': 'typescript',
    'c++': 'cpp',
    'cc': 'cpp',
    'h': 'cpp',
    'hpp': 'cpp',
    'c#': 'cs',
    'csharp': 'cs',
    'sh': 'bash',
    'zsh': 'bash',
    'shell': 'bash',
    'console': 'bash',
    'rb': 'ruby',
    'rs': 'rust',
    'yml': 'yaml',
    'kt': 'kotlin',
    'golang': 'go',
    'objc': 'objectivec',
    'objective-c': 'objectivec',
    'jsonc': 'json',
    'json5': 'json',
    // HTML and its relatives are the `xml` grammar in highlight.js.
    'html': 'xml',
    'htm': 'xml',
    'xhtml': 'xml',
    'svg': 'xml',
    'rss': 'xml',
    'plist': 'xml',
    'vue': 'xml',
    'ps1': 'powershell',
    'bat': 'dos',
    'cmd': 'dos',
    'make': 'makefile',
    'docker': 'dockerfile',
  };

  /// Resolve the fence language to a grammar the highlight package knows.
  /// Returns '' only when there's genuinely no matching grammar (then we render
  /// plain text). The package registers all ~190 highlight.js languages, so any
  /// fence whose name matches a grammar (python, rust, go, sql, css, swift, …)
  /// highlights automatically — no per-language whitelist to maintain.
  String get _normLang {
    final raw = language.trim().toLowerCase();
    if (raw.isEmpty) return '';
    final resolved = _aliases[raw] ?? raw;
    return allLanguages.containsKey(resolved) ? resolved : '';
  }

  /// Pretty header label, derived from the original fence so HTML shows "HTML"
  /// (not "xml") and JS shows "JavaScript".
  String get _displayLang {
    final raw = language.trim().toLowerCase();
    if (raw.isEmpty) return 'code';
    const labels = <String, String>{
      'py': 'Python', 'python': 'Python',
      'js': 'JavaScript', 'javascript': 'JavaScript',
      'ts': 'TypeScript', 'typescript': 'TypeScript',
      'jsx': 'JSX', 'tsx': 'TSX',
      'html': 'HTML', 'htm': 'HTML', 'xhtml': 'HTML', 'xml': 'XML', 'svg': 'SVG',
      'css': 'CSS', 'scss': 'SCSS', 'sql': 'SQL',
      'json': 'JSON', 'jsonc': 'JSON', 'yaml': 'YAML', 'yml': 'YAML',
      'cpp': 'C++', 'c++': 'C++', 'c': 'C',
      'cs': 'C#', 'csharp': 'C#', 'c#': 'C#',
      'php': 'PHP', 'go': 'Go', 'golang': 'Go',
      'objectivec': 'Objective-C', 'objc': 'Objective-C',
      'bash': 'Bash', 'sh': 'Bash', 'shell': 'Bash', 'zsh': 'Bash',
      'dart': 'Dart', 'java': 'Java', 'kotlin': 'Kotlin', 'kt': 'Kotlin',
      'swift': 'Swift', 'rust': 'Rust', 'rs': 'Rust',
      'ruby': 'Ruby', 'rb': 'Ruby', 'powershell': 'PowerShell',
    };
    final mapped = labels[raw];
    if (mapped != null) return mapped;
    // Fallback: capitalize the raw fence (e.g. "scala" -> "Scala").
    return raw[0].toUpperCase() + raw.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final normLang = _normLang;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF282C34),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF3E4451)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          // ── Header: language label + copy button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Row(
                children: [
                  Text(
                    _displayLang,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Color(0xFFABB2BF),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  _CopyButton(code: code),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFF3E4451)),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(14),
              child: normLang.isNotEmpty
                  ? HighlightView(
                      code,
                      language: normLang,
                      theme: atomOneDarkTheme,
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.55,
                      ),
                    )
                  : SelectableText(
                      code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.55,
                        color: Color(0xFFABB2BF),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.code});
  final String code;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: _copied ? null : _copy,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _copied
            ? Row(
                key: const ValueKey('copied'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_rounded,
                      size: 13, color: Color(0xFF98C379)),
                  const SizedBox(width: 4),
                  Text(
                    l.cmCodeBlockCopied,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF98C379),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              )
            : Row(
                key: const ValueKey('copy'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.content_copy_rounded,
                      size: 13, color: Color(0xFFABB2BF)),
                  const SizedBox(width: 4),
                  Text(
                    l.cmCodeBlockCopy,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFABB2BF),
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

