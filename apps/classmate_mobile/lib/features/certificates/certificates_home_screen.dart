// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../ui/widgets/cm_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/config/env.dart';
import '../../core/util/friendly_date.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/liquid_glass_dropdown.dart';
import 'certificate_pdf.dart';
import 'certificates_screen.dart';
import 'data/certificates_repository.dart';
import '../../ui/widgets/cm_refresh_indicator.dart';

/// Staff-facing certificates hub. It is **student-first**: pick a class, see
/// its students, tap a student to see (and create) all of THEIR certificates.
/// Teachers (their homeroom) + admins can create/edit; secretaries stay
/// read-only and print by cohort. Body-only: the app shell supplies the top bar.
class CertificatesHomeScreen extends ConsumerStatefulWidget {
  const CertificatesHomeScreen({super.key});

  @override
  ConsumerState<CertificatesHomeScreen> createState() => _CertificatesHomeScreenState();
}

class _CertificatesHomeScreenState extends ConsumerState<CertificatesHomeScreen> {
  List<Map<String, dynamic>> _items = []; // certs in the selected cohort
  List<CertCohort> _cohorts = [];
  List<CertStudent> _students = []; // students in the selected cohort
  final _searchCtrl = TextEditingController();
  String? _cohortFilter;
  bool _loading = true;
  String? _error;

  CertificatesRepository get _repo => ref.read(certificatesRepositoryProvider);

  bool get _isSecretary => ref.read(authSessionProvider).primaryRole == 'SECRETARY';
  bool get _canCreate => !_isSecretary; // admin + teacher

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
    Future<void>.microtask(_load);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cohorts = await _repo.cohorts();
      // Default to the first class (homeroom teachers usually have one).
      _cohortFilter ??= cohorts.isNotEmpty ? cohorts.first.id : null;
      final items = _cohortFilter != null ? await _repo.list(cohortId: _cohortFilter) : <Map<String, dynamic>>[];
      final students = (_canCreate && _cohortFilter != null)
          ? await _repo.students(_cohortFilter!)
          : <CertStudent>[];
      if (!mounted) return;
      setState(() {
        _cohorts = cohorts;
        _items = items;
        _students = students;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  int _certCountFor(String studentId) =>
      _items.where((c) => (c['studentId'] ?? '').toString() == studentId).length;

  Future<void> _openStudent(CertStudent student) async {
    final cohortName = _cohorts
        .firstWhere((c) => c.id == _cohortFilter, orElse: () => const CertCohort(id: '', name: ''))
        .name;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => StudentCertificatesStaffPage(
          cohortId: _cohortFilter!,
          cohortName: cohortName,
          student: student,
        ),
      ),
    );
    // Always refresh counts on return (a cert may have been created/edited).
    if (mounted) _load();
  }

  Future<void> _openPdf(String rawUrl) async {
    var url = rawUrl.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) {
      final base = Env.stripApiSuffix(Env.apiBaseUrl).trim().replaceAll(RegExp(r'/+$'), '');
      url = '$base${url.startsWith('/') ? url : '/$url'}';
    }
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Build ONE combined PDF of every published certificate in the cohort.
  Future<void> _printAll() async {
    if (_cohortFilter == null) return;
    final l = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final certs = await _repo.printList(_cohortFilter!);
      if (certs.isEmpty) {
        if (mounted) {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.certNoneYet)));
        }
        return;
      }
      final session = ref.read(authSessionProvider);
      final cohortName = _cohorts.firstWhere((c) => c.id == _cohortFilter, orElse: () => const CertCohort(id: '', name: '')).name;
      final list = <CertificatePdfData>[];
      for (final c in certs) {
        final snap = c['snapshot'] is Map ? Map<String, dynamic>.from(c['snapshot'] as Map) : <String, dynamic>{};
        final subjects = (snap['subjects'] as List? ?? [])
            .map((e) => CertSubjectRow.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        final att = snap['attendance'] is Map ? Map<String, dynamic>.from(snap['attendance'] as Map) : const {};
        final weights = (c['semesterWeights'] as List? ?? []).map((e) => e is int ? e : int.tryParse('$e') ?? 0).toList();
        final semCount = subjects.isNotEmpty ? subjects.first.semesters.length : (weights.isNotEmpty ? weights.length : 2);
        final issued = DateTime.tryParse((c['issuedAt'] ?? '').toString());
        final dateLabel = issued != null
            ? '${issued.day.toString().padLeft(2, '0')}/${issued.month.toString().padLeft(2, '0')}/${issued.year}'
            : '';
        list.add(CertificatePdfData(
          language: (c['language'] ?? 'en').toString(),
          schoolName: (snap['schoolName'] ?? session.schoolName).toString(),
          schoolLogoUrl: session.schoolLogoUrl,
          schoolYear: (c['schoolYear'] ?? snap['schoolYear'] ?? '').toString(),
          studentName: (c['studentDisplayName'] ?? '').toString(),
          nationalId: (c['nationalId'] ?? '').toString(),
          cohortName: cohortName,
          homeroomTeacher: (c['homeroomTeacher'] ?? '').toString(),
          principalName: (c['principalName'] ?? '').toString(),
          publisherNote: (c['publisherNote'] ?? '').toString(),
          subjects: subjects,
          overall: snap['overall'] is num ? (snap['overall'] as num).toDouble() : null,
          absences: att['absences'] is num ? (att['absences'] as num).toInt() : 0,
          lates: att['lates'] is num ? (att['lates'] as num).toInt() : 0,
          semesterCount: semCount,
          dateLabel: dateLabel,
        ));
      }
      final bytes = await buildCertificatesBundlePdf(list);
      if (!mounted) return;
      setState(() => _loading = false);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (mounted) setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CmLoading());

    final cohortField = LiquidGlassSelectField<String>(
      label: l.certHomeroom,
      hint: l.certHomeroom,
      value: _cohortFilter,
      items: _cohorts.map((c) => LiquidGlassDropdownItem(value: c.id, label: c.name)).toList(),
      onChanged: (v) {
        setState(() => _cohortFilter = v);
        _load();
      },
    );

    // ── Secretary: read-only print-by-cohort + flat published list ──────────
    if (_isSecretary) {
      return CmRefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            if (_error != null)
              Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: TextStyle(color: cs.error))),
            cohortField,
            if (_cohortFilter != null) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _printAll,
                icon: const Icon(Icons.print_rounded),
                label: Text(l.certPrintAll),
              ),
            ],
            const SizedBox(height: 14),
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text(l.certNoneYet, style: TextStyle(color: cs.onSurfaceVariant))),
              )
            else
              for (final c in _items)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CertRow(
                    cert: c,
                    canEdit: false,
                    onTap: () => _openPdf((c['pdfUrl'] ?? '').toString()),
                  ),
                ),
          ],
        ),
      );
    }

    // ── Admin / Teacher: student-first browse ───────────────────────────────
    final q = _searchCtrl.text.trim().toLowerCase();
    final students = q.isEmpty
        ? _students
        : _students.where((s) => s.name.toLowerCase().contains(q)).toList();

    return CmRefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          if (_error != null)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: TextStyle(color: cs.error))),
          cohortField,
          const SizedBox(height: 12),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: l.certSearchStudent,
              prefixIcon: const Icon(Icons.search_rounded),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),
          if (students.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(child: Text(l.certNoneYet, style: TextStyle(color: cs.onSurfaceVariant))),
            )
          else
            for (final s in students)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openStudent(s),
                  child: LiquidGlassCard(
                    borderRadius: BorderRadius.circular(16),
                    color: cs.surfaceContainerLow,
                    border: Border.all(color: cs.outlineVariant),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: cs.primaryContainer,
                          child: Text(
                            _initials(s.name),
                            style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                l.certCertificateCount(_certCountFor(s.id)),
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Per-student certificate list (staff). Shows all of one student's
/// certificates with tap-to-edit, plus a "New certificate" button that opens
/// the editor preselected for this student. Full-screen (own Scaffold+AppBar).
class StudentCertificatesStaffPage extends ConsumerStatefulWidget {
  const StudentCertificatesStaffPage({
    super.key,
    required this.cohortId,
    required this.cohortName,
    required this.student,
  });

  final String cohortId;
  final String cohortName;
  final CertStudent student;

  @override
  ConsumerState<StudentCertificatesStaffPage> createState() => _StudentCertificatesStaffPageState();
}

class _StudentCertificatesStaffPageState extends ConsumerState<StudentCertificatesStaffPage> {
  List<Map<String, dynamic>> _certs = [];
  bool _loading = true;
  String? _error;

  CertificatesRepository get _repo => ref.read(certificatesRepositoryProvider);

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final all = await _repo.list(cohortId: widget.cohortId);
      if (!mounted) return;
      setState(() {
        _certs = all
            .where((c) => (c['studentId'] ?? '').toString() == widget.student.id)
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _openForm({String? certId}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CertificatesFormPage(
          certId: certId,
          initialCohortId: certId == null ? widget.cohortId : null,
          initialStudentId: certId == null ? widget.student.id : null,
        ),
      ),
    );
    if (changed == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
        appBar: AppBar(title: Text(widget.student.name)),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add_rounded),
          label: Text(l.certNewCertificate),
        ),
        body: SafeArea(
          child: _loading
              ? const Center(child: CmLoading())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(_error!, style: TextStyle(color: cs.error)),
                      ),
                    Text('${widget.cohortName} · ${widget.student.name}',
                        style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    if (_certs.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: Text(l.certNoneYet, style: TextStyle(color: cs.onSurfaceVariant))),
                      )
                    else
                      for (final c in _certs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _CertRow(
                            cert: c,
                            canEdit: true,
                            onTap: () => _openForm(certId: (c['id'] ?? '').toString()),
                          ),
                        ),
                  ],
                ),
        ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.take(1).toString().toUpperCase();
  return (parts.first.characters.take(1).toString() + parts.last.characters.take(1).toString()).toUpperCase();
}

/// A single certificate row (student name + year/date + published badge).
class _CertRow extends StatelessWidget {
  const _CertRow({required this.cert, required this.canEdit, required this.onTap});
  final Map<String, dynamic> cert;
  final bool canEdit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: LiquidGlassCard(
        borderRadius: BorderRadius.circular(16),
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text((cert['studentDisplayName'] ?? '').toString(),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    [
                      (cert['schoolYear'] ?? '').toString(),
                      if ((cert['issuedAt'] ?? '').toString().isNotEmpty)
                        FriendlyDate.date(cert['issuedAt'].toString()),
                    ].where((s) => s.isNotEmpty).join(' · '),
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            _Badge(published: cert['published'] == true),
            const SizedBox(width: 6),
            Icon(canEdit ? Icons.edit_rounded : Icons.open_in_new_rounded,
                size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.published});
  final bool published;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final bg = published ? cs.primaryContainer : cs.surfaceContainerHighest;
    final fg = published ? cs.onPrimaryContainer : cs.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(published ? l.certPublished.replaceAll('.', '') : l.certSaveDraft,
          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
