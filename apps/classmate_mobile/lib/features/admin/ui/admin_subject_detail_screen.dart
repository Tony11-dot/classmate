import 'package:flutter/material.dart';

import '../../../core/contracts/school_subject.dart';

/// Edits the 5-language names for a single school subject. Returns the
/// updated [SchoolSubject] via Navigator.pop when the user taps save.
class AdminSubjectDetailScreen extends StatefulWidget {
  const AdminSubjectDetailScreen({super.key, required this.initial});
  final SchoolSubject initial;

  @override
  State<AdminSubjectDetailScreen> createState() => _AdminSubjectDetailScreenState();
}

class _AdminSubjectDetailScreenState extends State<AdminSubjectDetailScreen> {
  late final TextEditingController _en;
  late final TextEditingController _ar;
  late final TextEditingController _he;
  late final TextEditingController _fr;
  late final TextEditingController _ru;

  @override
  void initState() {
    super.initState();
    _en = TextEditingController(text: widget.initial.nameEn);
    _ar = TextEditingController(text: widget.initial.nameAr ?? '');
    _he = TextEditingController(text: widget.initial.nameHe ?? '');
    _fr = TextEditingController(text: widget.initial.nameFr ?? '');
    _ru = TextEditingController(text: widget.initial.nameRu ?? '');
  }

  @override
  void dispose() {
    for (final c in [_en, _ar, _he, _fr, _ru]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final nameEn = _en.text.trim();
    if (nameEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('English name is required')),
      );
      return;
    }
    Navigator.pop(context, SchoolSubject(
      nameEn: nameEn,
      nameAr: _trimOrNull(_ar.text),
      nameHe: _trimOrNull(_he.text),
      nameFr: _trimOrNull(_fr.text),
      nameRu: _trimOrNull(_ru.text),
    ));
  }

  String? _trimOrNull(String v) {
    final t = v.trim();
    return t.isEmpty ? null : t;
  }

  Widget _field(TextEditingController c, String label, String langCode, {TextDirection? dir}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        textDirection: dir,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Name in $label',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixText: langCode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_subject_detail',
        onPressed: _save,
        icon: const Icon(Icons.check_rounded),
        label: const Text('Save'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text(
              widget.initial.nameEn.isEmpty ? 'New subject' : widget.initial.nameEn,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Fill in any languages your students need. English is required; others fall back to it.',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            _field(_en, 'English', 'EN'),
            _field(_ar, 'Arabic',  'AR', dir: TextDirection.rtl),
            _field(_he, 'Hebrew',  'HE', dir: TextDirection.rtl),
            _field(_fr, 'French',  'FR'),
            _field(_ru, 'Russian', 'RU'),
          ],
        ),
      ),
    );
  }
}
