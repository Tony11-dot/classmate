import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import '../../l10n/app_localizations.dart';

class CMCodeBlock extends StatelessWidget {
  final String code;

  /// The fence language string (e.g. 'python', 'js', 'dart'). May be empty.
  final String language;

  const CMCodeBlock(this.code, {super.key, this.language = ''});

  // Normalize common aliases to names highlight.js recognises.
  static const _aliases = <String, String>{
    'py': 'python',
    'js': 'javascript',
    'ts': 'typescript',
    'jsx': 'javascript',
    'tsx': 'typescript',
    'c++': 'cpp',
    'c#': 'cs',
    'csharp': 'cs',
    'sh': 'bash',
    'zsh': 'bash',
    'shell': 'bash',
    'rb': 'ruby',
    'rs': 'rust',
    'yml': 'yaml',
    'kt': 'kotlin',
  };

  // Languages actually bundled in the highlight package.
  static const _supported = {
    'python', 'javascript', 'typescript', 'dart', 'cpp', 'java', 'bash',
    'swift', 'kotlin', 'go', 'rust', 'sql', 'css', 'html', 'ruby', 'php',
    'c', 'cs', 'yaml', 'json', 'xml', 'markdown',
  };

  String get _normLang {
    final raw = language.trim().toLowerCase();
    final resolved = _aliases[raw] ?? raw;
    return _supported.contains(resolved) ? resolved : '';
  }

  String get _displayLang {
    final n = language.trim().toLowerCase();
    if (n.isEmpty) return 'code';
    final resolved = _aliases[n] ?? n;
    switch (resolved) {
      case 'cs':
        return 'C#';
      case 'javascript':
        return 'JavaScript';
      case 'typescript':
        return 'TypeScript';
      case 'json':
        return 'JSON';
      case 'yaml':
        return 'YAML';
      case 'html':
        return 'HTML';
      case 'css':
        return 'CSS';
      case 'sql':
        return 'SQL';
      default:
        return resolved;
    }
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

