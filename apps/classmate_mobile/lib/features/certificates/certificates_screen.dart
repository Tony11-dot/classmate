// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import 'certificate_pdf.dart';
import 'data/certificates_repository.dart';

/// Supported certificate languages — every locale the app actually ships.
const _certLanguages = <(String, String)>[
  ('en', 'English'),
  ('ar', 'العربية'),
  ('he', 'עברית'),
  ('fr', 'Français'),
  ('ru', 'Русский'),
  ('ps', 'پښتو'),
];

class CertificatesScreen extends ConsumerStatefulWidget {
  const CertificatesScreen({super.key});

  @override
  ConsumerState<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends ConsumerState<CertificatesScreen> {
  final _displayNameCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _principalCtrl = TextEditingController();
  final _homeroomCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final List<TextEditingController> _weightCtrls = [];

  List<CertCohort> _cohorts = [];
  List<CertStudent> _students = [];
  CertPrefill? _prefill;

  String? _cohortId;
  String? _studentId;
  String _language = 'en';

  bool _loading = true;
  bool _loadingStudents = false;
  bool _loadingPrefill = false;
  bool _generating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_loadCohorts);
  }

  @override
  void dispose() {
    _displayNameCtrl.dispose();
    _nationalIdCtrl.dispose();
    _principalCtrl.dispose();
    _homeroomCtrl.dispose();
    _noteCtrl.dispose();
    for (final c in _weightCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  CertificatesRepository get _repo => ref.read(certificatesRepositoryProvider);

  Future<void> _loadCohorts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cohorts = await _repo.cohorts();
      setState(() {
        _cohorts = cohorts;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _onCohortChanged(String? id) async {
    setState(() {
      _cohortId = id;
      _studentId = null;
      _students = [];
      _prefill = null;
    });
    if (id == null) return;
    setState(() => _loadingStudents = true);
    try {
      final students = await _repo.students(id);
      setState(() {
        _students = students;
        _loadingStudents = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loadingStudents = false;
      });
    }
  }

  Future<void> _onStudentChanged(String? id) async {
    setState(() => _studentId = id);
    if (id == null || _cohortId == null) return;
    await _loadPrefill();
  }

  Future<void> _loadPrefill({List<int>? weights}) async {
    if (_cohortId == null || _studentId == null) return;
    setState(() => _loadingPrefill = true);
    try {
      final p = await _repo.prefill(_cohortId!, studentId: _studentId, semesterWeights: weights);
      setState(() {
        _prefill = p;
        _displayNameCtrl.text = p.student?.name ?? '';
        _nationalIdCtrl.text = p.studentNationalId ?? '';
        if (_homeroomCtrl.text.trim().isEmpty && p.defaultHomeroomTeacher.isNotEmpty) {
          _homeroomCtrl.text = p.defaultHomeroomTeacher;
        }
        if (_principalCtrl.text.trim().isEmpty && p.defaultPrincipalName.isNotEmpty) {
          _principalCtrl.text = p.defaultPrincipalName;
        }
        _syncWeightControllers(p.semesterWeights.isNotEmpty
            ? p.semesterWeights
            : List.filled(p.semesterCount, (100 / p.semesterCount).round()));
        _loadingPrefill = false;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loadingPrefill = false;
      });
    }
  }

  void _syncWeightControllers(List<int> weights) {
    for (final c in _weightCtrls) {
      c.dispose();
    }
    _weightCtrls
      ..clear()
      ..addAll(weights.map((w) => TextEditingController(text: '$w')));
  }

  List<int> get _weights => _weightCtrls.map((c) => int.tryParse(c.text.trim()) ?? 0).toList();

  Future<void> _generate() async {
    final l = AppLocalizations.of(context)!;
    final p = _prefill;
    if (p == null || _studentId == null) {
      setState(() => _error = l.certSelectStudentFirst);
      return;
    }
    final weights = _weights;
    if (weights.fold(0, (a, b) => a + b) != 100) {
      setState(() => _error = l.certWeightsMustBe100);
      return;
    }
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      // Recompute with the chosen weights so finals/overall are exact.
      final fresh = await _repo.prefill(_cohortId!, studentId: _studentId, semesterWeights: weights);
      final displayName = _displayNameCtrl.text.trim().isEmpty ? (fresh.student?.name ?? '') : _displayNameCtrl.text.trim();
      final now = DateTime.now();
      final dateLabel = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      final pdfData = CertificatePdfData(
        language: _language,
        schoolName: fresh.schoolName,
        schoolLogoUrl: fresh.schoolLogoUrl,
        schoolYear: fresh.schoolYear,
        studentName: displayName,
        nationalId: _nationalIdCtrl.text.trim(),
        cohortName: _cohorts.firstWhere((c) => c.id == _cohortId, orElse: () => const CertCohort(id: '', name: '')).name,
        homeroomTeacher: _homeroomCtrl.text.trim().isEmpty ? fresh.defaultHomeroomTeacher : _homeroomCtrl.text.trim(),
        principalName: _principalCtrl.text.trim(),
        publisherNote: _noteCtrl.text.trim(),
        subjects: fresh.subjects,
        overall: fresh.overall,
        absences: fresh.absences,
        lates: fresh.lates,
        semesterCount: fresh.semesterCount,
        dateLabel: dateLabel,
      );

      final bytes = await buildCertificatePdf(pdfData);

      // Persist the certificate (snapshot frozen server-side).
      try {
        await _repo.create({
          'studentId': _studentId,
          'studentDisplayName': displayName,
          if (_nationalIdCtrl.text.trim().isNotEmpty) 'nationalId': _nationalIdCtrl.text.trim(),
          'cohortId': _cohortId,
          'homeroomTeacher': _homeroomCtrl.text.trim().isEmpty ? fresh.defaultHomeroomTeacher : _homeroomCtrl.text.trim(),
          'principalName': _principalCtrl.text.trim(),
          'language': _language,
          if (_noteCtrl.text.trim().isNotEmpty) 'publisherNote': _noteCtrl.text.trim(),
          'schoolYear': fresh.schoolYear,
          'semesterWeights': weights,
        });
      } catch (_) {
        // Persistence failure shouldn't block sharing the generated PDF.
      }

      await shareCertificatePdf(bytes, 'certificate_${displayName.replaceAll(' ', '_')}.pdf');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.certSaved)));
      }
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final p = _prefill;

    // Body-only: the app shell supplies the top bar / section pill.
    if (_loading) return const Center(child: CircularProgressIndicator());

    return AbsorbPointer(
      absorbing: _generating,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: TextStyle(color: cs.error)),
            ),
          // Homeroom (cohort)
          LiquidGlassSelectField<String>(
            label: l.certHomeroom,
            hint: l.certHomeroom,
            value: _cohortId,
            items: _cohorts.map((c) => LiquidGlassDropdownItem(value: c.id, label: c.name)).toList(),
            onChanged: _onCohortChanged,
          ),
          const SizedBox(height: 14),
          // Student
          LiquidGlassSelectField<String>(
            label: l.certStudent,
            hint: l.certStudent,
            value: _studentId,
            enabled: _cohortId != null && !_loadingStudents,
            items: _students.map((s) => LiquidGlassDropdownItem(value: s.id, label: s.name)).toList(),
            onChanged: _onStudentChanged,
          ),
          if (_loadingPrefill)
            const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
          if (p != null && _studentId != null) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _displayNameCtrl,
              decoration: InputDecoration(labelText: l.certDisplayName, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nationalIdCtrl,
              decoration: InputDecoration(labelText: l.certNationalId, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            LiquidGlassNameField(
              controller: _homeroomCtrl,
              label: l.certHomeroomTeacher,
              options: p.teacherNames,
            ),
            const SizedBox(height: 14),
            LiquidGlassNameField(
              controller: _principalCtrl,
              label: l.certPrincipal,
              options: p.principalNames,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: InputDecoration(labelText: l.certPublisherNote, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 14),
            // Semester weights
            Text(l.certSemesterWeights, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                for (int i = 0; i < _weightCtrls.length; i++) ...[
                  Expanded(
                    child: TextField(
                      controller: _weightCtrls[i],
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: l.adminSchoolSemesterN('${i + 1}'),
                        suffixText: '%',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                  if (i < _weightCtrls.length - 1) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 14),
            // Language
            LiquidGlassSelectField<String>(
              label: l.certLanguage,
              value: _language,
              items: _certLanguages
                  .map((lang) => LiquidGlassDropdownItem(value: lang.$1, label: lang.$2))
                  .toList(),
              onChanged: (v) => setState(() => _language = v),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _generating ? null : _generate,
              icon: _generating
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.picture_as_pdf_rounded),
              label: Text(l.certGenerate),
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
}
