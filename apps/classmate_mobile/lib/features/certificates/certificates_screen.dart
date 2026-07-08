// ignore_for_file: use_build_context_synchronously
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../ui/widgets/cm_loading.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import 'certificate_pdf.dart';
import 'data/certificates_repository.dart';

/// Full-screen wrapper (Scaffold + app bar) for pushing the create/edit form
/// as its own route from the certificates list.
class CertificatesFormPage extends StatelessWidget {
  const CertificatesFormPage({super.key, this.certId});
  final String? certId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(certId == null ? l.navCertificates : l.certEditTitle)),
      body: SafeArea(child: CertificatesScreen(certId: certId)),
    );
  }
}

/// Supported certificate languages — every locale the app actually ships.
const _certLanguages = <(String, String)>[
  ('en', 'English'),
  ('ar', 'العربية'),
  ('he', 'עברית'),
  ('fr', 'Français'),
  ('ru', 'Русский'),
  ('ps', 'پښتو'),
];

/// One editable grades row: the subject + a per-semester grade box + an editable
/// teacher field (comma/،-separated for multi-teacher subjects).
class _EditableSubject {
  _EditableSubject({required this.base, required this.semCtrls, required this.teacherCtrl});
  final CertSubjectRow base;
  final List<TextEditingController> semCtrls;
  final TextEditingController teacherCtrl;
  void dispose() {
    for (final c in semCtrls) {
      c.dispose();
    }
    teacherCtrl.dispose();
  }
}

class CertificatesScreen extends ConsumerStatefulWidget {
  const CertificatesScreen({super.key, this.certId});

  /// When set, the screen opens an EXISTING certificate to edit (admin, or the
  /// homeroom teacher who owns it). Otherwise it's a fresh create.
  final String? certId;

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
  List<_EditableSubject> _subjects = [];

  String? _cohortId;
  String? _studentId;
  String _language = 'en';
  int _semesterOnly = 0; // 0 = annual (all semesters); 1..N = semester diploma
  bool _roundWhole = true; // true = round-half-up to whole; false = 2 decimals
  String? _editId; // set when editing an existing certificate

  bool _loading = true;
  bool _loadingStudents = false;
  bool _loadingPrefill = false;
  bool _generating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _editId = widget.certId;
    Future<void>.microtask(_editId != null ? () => _loadForEdit(_editId!) : _loadCohorts);
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
    for (final s in _subjects) {
      s.dispose();
    }
    super.dispose();
  }

  String _trimNum(double v) {
    final s = v.toStringAsFixed(2);
    return s.replaceAll(RegExp(r'\.?0+$'), '');
  }

  /// Weighted final for a subject from its per-semester values + weights.
  double? _weightedFinal(List<double?> sems, List<int> weights) {
    double num = 0, den = 0;
    for (int i = 0; i < sems.length; i++) {
      final v = sems[i];
      if (v == null) continue;
      final w = (i < weights.length ? weights[i] : 0).toDouble();
      if (w <= 0) continue;
      num += v * w;
      den += w;
    }
    if (den == 0) {
      final vals = sems.whereType<double>().toList();
      return vals.isEmpty ? null : vals.reduce((a, b) => a + b) / vals.length;
    }
    return num / den;
  }

  /// The edited subjects → CertSubjectRow list used for the PDF + snapshot.
  List<CertSubjectRow> _editedSubjects() {
    final weights = _weights;
    return _subjects.map((es) {
      final sems = es.semCtrls.map((c) {
        final t = c.text.trim();
        return t.isEmpty ? null : double.tryParse(t);
      }).toList();
      final teachers = es.teacherCtrl.text
          .split(RegExp(r'[،,]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      return CertSubjectRow(
        subject: es.base.subject,
        i18n: es.base.i18n,
        units: es.base.units,
        semesters: sems,
        finalAvg: _weightedFinal(sems, weights),
        teachers: teachers,
      );
    }).toList();
  }

  double? _overallOf(List<CertSubjectRow> subs) {
    final finals = subs.map((s) => s.finalAvg).whereType<double>().toList();
    return finals.isEmpty ? null : finals.reduce((a, b) => a + b) / finals.length;
  }

  List<Map<String, dynamic>> _subjectsJson(List<CertSubjectRow> subs) => subs
      .map((s) => <String, dynamic>{
            'subject': s.subject,
            'i18n': s.i18n,
            'units': s.units,
            'semesters': s.semesters,
            'final': s.finalAvg,
            'teachers': s.teachers,
          })
      .toList();

  CertificatesRepository get _repo => ref.read(certificatesRepositoryProvider);

  Future<void> _loadCohorts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cohorts = await _repo.cohorts();
      if (!mounted) return;
      setState(() {
        _cohorts = cohorts;
        _loading = false;
      });
      // Homeroom teachers usually own exactly one class — auto-select it.
      if (_cohortId == null && cohorts.length == 1) {
        await _onCohortChanged(cohorts.first.id);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  /// Load an existing certificate into the form for editing.
  Future<void> _loadForEdit(String id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final c = await _repo.getOne(id);
      _cohortId = (c['cohortId'] ?? '').toString();
      _studentId = (c['studentId'] ?? '').toString().isEmpty ? null : c['studentId'].toString();
      _displayNameCtrl.text = (c['studentDisplayName'] ?? '').toString();
      _nationalIdCtrl.text = (c['nationalId'] ?? '').toString();
      _homeroomCtrl.text = (c['homeroomTeacher'] ?? '').toString();
      _principalCtrl.text = (c['principalName'] ?? '').toString();
      _noteCtrl.text = (c['publisherNote'] ?? '').toString();
      _language = (c['language'] ?? 'en').toString();
      final w = (c['semesterWeights'] as List?)?.map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList();
      final cohorts = await _repo.cohorts();
      _cohorts = cohorts;
      if (_cohortId != null && _cohortId!.isNotEmpty) {
        _students = await _repo.students(_cohortId!);
      }
      if (!mounted) return;
      setState(() => _loading = false);
      if (_cohortId != null && _studentId != null) {
        await _loadPrefill(weights: w != null && w.isNotEmpty ? w : null);
      }
    } catch (e) {
      if (!mounted) return;
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
        // Only fill blanks so an edit-mode / hand-edited value isn't clobbered.
        if (_displayNameCtrl.text.trim().isEmpty) _displayNameCtrl.text = p.student?.name ?? '';
        if (_nationalIdCtrl.text.trim().isEmpty) _nationalIdCtrl.text = p.studentNationalId ?? '';
        if (_homeroomCtrl.text.trim().isEmpty && p.defaultHomeroomTeacher.isNotEmpty) {
          _homeroomCtrl.text = p.defaultHomeroomTeacher;
        }
        if (_principalCtrl.text.trim().isEmpty && p.defaultPrincipalName.isNotEmpty) {
          _principalCtrl.text = p.defaultPrincipalName;
        }
        _syncWeightControllers(p.semesterWeights.isNotEmpty
            ? p.semesterWeights
            : List.filled(p.semesterCount, (100 / p.semesterCount).round()));
        _syncSubjects(p);
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

  /// Build the editable grade rows from the prefill's computed subjects.
  void _syncSubjects(CertPrefill p) {
    for (final s in _subjects) {
      s.dispose();
    }
    _subjects = p.subjects.map((s) {
      final sem = List.generate(
        p.semesterCount,
        (i) => TextEditingController(
          text: i < s.semesters.length && s.semesters[i] != null ? _trimNum(s.semesters[i]!) : '',
        ),
      );
      return _EditableSubject(base: s, semCtrls: sem, teacherCtrl: TextEditingController(text: s.teachers.join('، ')));
    }).toList();
  }

  List<int> get _weights => _weightCtrls.map((c) => int.tryParse(c.text.trim()) ?? 0).toList();

  /// Render the certificate PDF from the (teacher-edited) grade rows.
  Future<({Uint8List bytes, String name, List<CertSubjectRow> subjects, double? overall})?> _buildBytes() async {
    final p = _prefill;
    if (p == null) return null;
    final subjects = _editedSubjects();
    final overall = _overallOf(subjects);
    final displayName = _displayNameCtrl.text.trim().isEmpty ? (p.student?.name ?? '') : _displayNameCtrl.text.trim();
    final now = DateTime.now();
    final dateLabel = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final pdfData = CertificatePdfData(
      language: _language,
      schoolName: p.schoolName,
      schoolLogoUrl: p.schoolLogoUrl,
      schoolYear: p.schoolYear,
      studentName: displayName,
      nationalId: _nationalIdCtrl.text.trim(),
      cohortName: _cohorts.firstWhere((c) => c.id == _cohortId, orElse: () => const CertCohort(id: '', name: '')).name,
      homeroomTeacher: _homeroomCtrl.text.trim().isEmpty ? p.defaultHomeroomTeacher : _homeroomCtrl.text.trim(),
      principalName: _principalCtrl.text.trim(),
      publisherNote: _noteCtrl.text.trim(),
      subjects: subjects,
      overall: overall,
      absences: p.absences,
      lates: p.lates,
      semesterCount: p.semesterCount,
      semesterOnly: _semesterOnly,
      roundWhole: _roundWhole,
      dateLabel: dateLabel,
    );
    final bytes = await buildCertificatePdf(pdfData);
    return (bytes: bytes, name: displayName, subjects: subjects, overall: overall);
  }

  bool? _validateForSave() {
    final l = AppLocalizations.of(context)!;
    if (_prefill == null || _studentId == null) {
      setState(() => _error = l.certSelectStudentFirst);
      return null;
    }
    if (_weights.fold(0, (a, b) => a + b) != 100) {
      setState(() => _error = l.certWeightsMustBe100);
      return null;
    }
    return true;
  }

  /// Save (draft or published). When published, the PDF is uploaded so the
  /// student can download it in their Certificates section.
  Future<void> _save({required bool publish}) async {
    if (_validateForSave() != true) return;
    final l = AppLocalizations.of(context)!;
    final weights = _weights;
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final built = await _buildBytes();
      if (built == null) return;
      final displayName = built.name;
      final p = _prefill!;
      String? pdfUrl;
      if (publish) {
        pdfUrl = await _repo.uploadPdf(built.bytes, 'certificate_${displayName.replaceAll(' ', '_')}.pdf');
      }
      final body = <String, dynamic>{
        'studentId': _studentId,
        'studentDisplayName': displayName,
        if (_nationalIdCtrl.text.trim().isNotEmpty) 'nationalId': _nationalIdCtrl.text.trim(),
        'cohortId': _cohortId,
        'homeroomTeacher': _homeroomCtrl.text.trim().isEmpty ? p.defaultHomeroomTeacher : _homeroomCtrl.text.trim(),
        'principalName': _principalCtrl.text.trim(),
        'language': _language,
        if (_noteCtrl.text.trim().isNotEmpty) 'publisherNote': _noteCtrl.text.trim(),
        'schoolYear': p.schoolYear,
        'semesterWeights': weights,
        // Freeze the teacher-edited grades so the stored snapshot matches the PDF.
        'snapshot': {
          'subjects': _subjectsJson(built.subjects),
          'overall': built.overall,
        },
        if (pdfUrl != null) 'pdfUrl': pdfUrl,
        'published': publish,
      };
      if (_editId != null) {
        await _repo.update(_editId!, body);
      } else {
        final created = await _repo.create(body);
        _editId = created['id']?.toString();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(publish ? l.certPublished : l.certDraftSaved)),
        );
        if (Navigator.of(context).canPop()) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  /// Render + share the PDF locally without publishing.
  Future<void> _preview() async {
    if (_validateForSave() != true) return;
    setState(() {
      _generating = true;
      _error = null;
    });
    try {
      final built = await _buildBytes();
      if (built != null) {
        await shareCertificatePdf(built.bytes, 'certificate_${built.name.replaceAll(' ', '_')}.pdf');
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
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
    if (_loading) return const Center(child: CmLoading());

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
            // Certificate type — Annual or an end-of-semester diploma.
            LiquidGlassSelectField<int>(
              label: l.certTypeLabel,
              value: _semesterOnly,
              items: [
                LiquidGlassDropdownItem(value: 0, label: l.certTypeAnnual),
                for (int i = 1; i <= p.semesterCount; i++)
                  LiquidGlassDropdownItem(value: i, label: l.certTypeSemester(l.adminSchoolSemesterN('$i'))),
              ],
              onChanged: (v) => setState(() => _semesterOnly = v),
            ),
            const SizedBox(height: 14),
            // Rounding — whole (round-half-up) or two decimals.
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _roundWhole,
              title: Text(l.certRoundWhole),
              subtitle: Text(l.certRoundWholeHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              onChanged: (v) => setState(() => _roundWhole = v),
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
            const SizedBox(height: 18),
            // Editable grades — per-semester grade boxes + teacher field per
            // subject (comma/،-separated for multi-teacher). The final column
            // recomputes live from the boxes × the semester weights.
            if (_subjects.isNotEmpty) ...[
              Text(l.certGrin, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              for (int i = 0; i < _subjects.length; i++)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(_subjects[i].base.display(_language),
                                style: const TextStyle(fontWeight: FontWeight.w800)),
                          ),
                          Builder(builder: (_) {
                            final sems = _subjects[i]
                                .semCtrls
                                .map((c) => c.text.trim().isEmpty ? null : double.tryParse(c.text.trim()))
                                .toList();
                            final f = _weightedFinal(sems, _weights);
                            return Text(
                              f == null ? '—' : (_roundWhole ? (f + 0.5).floor().toString() : f.toStringAsFixed(2)),
                              style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary, fontSize: 16),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (int s = 0; s < _subjects[i].semCtrls.length; s++) ...[
                            Expanded(
                              child: TextField(
                                controller: _subjects[i].semCtrls[s],
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                textAlign: TextAlign.center,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  labelText: l.adminSchoolSemesterN('${s + 1}'),
                                  isDense: true,
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            if (s < _subjects[i].semCtrls.length - 1) const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      LiquidGlassNameField(
                        controller: _subjects[i].teacherCtrl,
                        label: l.certPdfTeacher,
                        options: p.teacherNames,
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: 20),
            // Save & publish (uploads the PDF → student can download it).
            FilledButton.icon(
              onPressed: _generating ? null : () => _save(publish: true),
              icon: _generating
                  ? const CmLoading(size: 18)
                  : const Icon(Icons.publish_rounded),
              label: Text(l.certSaveAndPublish),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generating ? null : () => _save(publish: false),
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: Text(l.certSaveDraft),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _generating ? null : _preview,
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: Text(l.certPreview),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ],
      ),
    );
  }
}
