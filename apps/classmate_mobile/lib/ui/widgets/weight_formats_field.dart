import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Reads a grade's weight formats from a server JSON map, preferring the
/// `weightPercents` list and falling back to the legacy single `weightPercent`.
List<int> readWeights(Map<String, dynamic> json) {
  final wp = json['weightPercents'];
  if (wp is List && wp.isNotEmpty) {
    return wp.map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList();
  }
  final single = json['weightPercent'];
  final s = single is int ? single : int.tryParse('$single');
  return s != null ? [s] : <int>[];
}

/// Editor for a grade's weight "formats" on the subject average.
/// One row per format (e.g. Format 1 = 50%, Format 2 = 60%); the certificate
/// computes the average under every format and keeps the best for each student.
/// Emits `[]` when every row is blank (= unweighted).
class WeightFormatsField extends StatefulWidget {
  const WeightFormatsField({super.key, required this.value, required this.onChanged});

  final List<int> value;
  final ValueChanged<List<int>> onChanged;

  @override
  State<WeightFormatsField> createState() => _WeightFormatsFieldState();
}

class _WeightFormatsFieldState extends State<WeightFormatsField> {
  late List<TextEditingController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = (widget.value.isEmpty ? <int>[] : widget.value)
        .map((w) => TextEditingController(text: w > 0 ? '$w' : ''))
        .toList();
    if (_ctrls.isEmpty) _ctrls.add(TextEditingController());
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _emit() {
    final vals = _ctrls.map((c) => int.tryParse(c.text.trim())).toList();
    if (vals.every((v) => v == null)) {
      widget.onChanged(const <int>[]);
    } else {
      widget.onChanged(vals.map((v) => (v ?? 0).clamp(0, 100)).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final multi = _ctrls.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.gradeWeightLabel, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(l.gradeWeightHint, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 8),
        for (int i = 0; i < _ctrls.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                if (multi) ...[
                  SizedBox(
                    width: 78,
                    child: Text(l.gradeFormatN('${i + 1}'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ],
                Expanded(
                  child: TextField(
                    controller: _ctrls[i],
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _emit(),
                    decoration: InputDecoration(
                      isDense: true,
                      // Single, clear '%' via the suffix — dropped the redundant
                      // leading % icon that made the form read "% everywhere".
                      suffixText: '%',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                if (multi)
                  IconButton(
                    tooltip: l.actionRemove,
                    icon: Icon(Icons.remove_circle_outline_rounded, color: cs.error, size: 20),
                    onPressed: () {
                      setState(() {
                        _ctrls.removeAt(i).dispose();
                      });
                      _emit();
                    },
                  ),
              ],
            ),
          ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => setState(() => _ctrls.add(TextEditingController())),
            icon: const Icon(Icons.add, size: 18),
            label: Text(l.gradeAddFormat),
          ),
        ),
      ],
    );
  }
}
