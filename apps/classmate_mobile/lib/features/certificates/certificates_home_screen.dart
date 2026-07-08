// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
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

/// Staff-facing certificates hub. Teachers (their homeroom) + admins can create
/// and edit; secretaries are read-only and can open/print PDFs by cohort.
/// Body-only: the app shell supplies the top bar.
class CertificatesHomeScreen extends ConsumerStatefulWidget {
  const CertificatesHomeScreen({super.key});

  @override
  ConsumerState<CertificatesHomeScreen> createState() => _CertificatesHomeScreenState();
}

class _CertificatesHomeScreenState extends ConsumerState<CertificatesHomeScreen> {
  List<Map<String, dynamic>> _items = [];
  List<CertCohort> _cohorts = [];
  String? _cohortFilter;
  bool _loading = true;
  String? _error;

  CertificatesRepository get _repo => ref.read(certificatesRepositoryProvider);

  bool get _isSecretary => ref.read(authSessionProvider).primaryRole == 'SECRETARY';
  bool get _canCreate => !_isSecretary; // admin + teacher

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
      final cohorts = await _repo.cohorts();
      final items = await _repo.list(cohortId: _cohortFilter);
      if (!mounted) return;
      setState(() {
        _cohorts = cohorts;
        _items = items;
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
      MaterialPageRoute(builder: (_) => CertificatesFormPage(certId: certId)),
    );
    if (changed == true) _load();
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

  /// Build ONE combined PDF of every published certificate in the cohort (each
  /// as its own page, in color) from their frozen snapshots, and open the print
  /// dialog.
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

    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          if (_error != null)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(_error!, style: TextStyle(color: cs.error))),
          if (_canCreate)
            FilledButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.navCertificates),
            ),
          if (_isSecretary) ...[
            LiquidGlassSelectField<String>(
              label: l.certPrintAll,
              hint: l.certSelectCohortToPrint,
              value: _cohortFilter,
              items: _cohorts.map((c) => LiquidGlassDropdownItem(value: c.id, label: c.name)).toList(),
              onChanged: (v) {
                setState(() => _cohortFilter = v);
                _load();
              },
            ),
            if (_cohortFilter != null) ...[
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _printAll,
                icon: const Icon(Icons.print_rounded),
                label: Text(l.certPrintAll),
              ),
            ],
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
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    final id = (c['id'] ?? '').toString();
                    final pdfUrl = (c['pdfUrl'] ?? '').toString();
                    if (_canCreate) {
                      _openForm(certId: id);
                    } else if (pdfUrl.isNotEmpty) {
                      _openPdf(pdfUrl);
                    }
                  },
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
                              Text((c['studentDisplayName'] ?? '').toString(),
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                              Text(
                                [
                                  (c['schoolYear'] ?? '').toString(),
                                  if ((c['issuedAt'] ?? '').toString().isNotEmpty)
                                    FriendlyDate.date(c['issuedAt'].toString()),
                                ].where((s) => s.isNotEmpty).join(' · '),
                                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                        _Badge(published: c['published'] == true),
                        const SizedBox(width: 6),
                        Icon(_canCreate ? Icons.edit_rounded : Icons.open_in_new_rounded,
                            size: 18, color: cs.onSurfaceVariant),
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
