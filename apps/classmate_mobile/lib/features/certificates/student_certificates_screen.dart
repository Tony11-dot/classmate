import 'package:flutter/material.dart';
import '../../ui/widgets/cm_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/env.dart';
import '../../core/util/friendly_date.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/cm_tokens.dart';
import '../../ui/widgets/cm_surfaces.dart';
import 'data/certificates_repository.dart';
import '../parent/data/viewed_student_context.dart';
import '../../ui/widgets/cm_refresh_indicator.dart';

/// The student's own PUBLISHED certificates — a simple list they can download.
/// Body-only: the app shell supplies the top bar / section pill.
class StudentCertificatesScreen extends ConsumerStatefulWidget {
  const StudentCertificatesScreen({super.key});

  @override
  ConsumerState<StudentCertificatesScreen> createState() => _StudentCertificatesScreenState();
}

class _StudentCertificatesScreenState extends ConsumerState<StudentCertificatesScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  String? _error;

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
      // Parent viewing a child → child endpoint; student → own.
      final childId = ref.read(viewedStudentIdProvider);
      final items = await ref
          .read(certificatesRepositoryProvider)
          .mine(childId: childId);
      if (!mounted) return;
      setState(() {
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

  Future<void> _open(String rawUrl) async {
    var url = rawUrl.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) {
      final base = Env.stripApiSuffix(Env.apiBaseUrl).trim().replaceAll(RegExp(r'/+$'), '');
      url = '$base${url.startsWith('/') ? url : '/$url'}';
    }
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CmLoading());
    if (_error != null) {
      return Center(child: CmEmptyState(icon: Icons.error_outline_rounded, title: l.commonError, message: _error));
    }
    if (_items.isEmpty) {
      return CmRefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.only(top: 40),
          children: [
            CmEmptyState(icon: Icons.workspace_premium_outlined, title: l.certNoneYet),
          ],
        ),
      );
    }

    return CmRefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final c = _items[i];
          final title = (c['studentDisplayName'] ?? '').toString();
          final year = (c['schoolYear'] ?? '').toString();
          final issued = (c['issuedAt'] ?? '').toString();
          final pdfUrl = (c['pdfUrl'] ?? '').toString();
          final gold = CmTokens.of(context).warn;
          return CmCard(
            tint: gold,
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              children: [
                CmIconTile(icon: Icons.workspace_premium_rounded, color: gold, size: 48, filled: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(year.isEmpty ? l.navCertificates : year,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, fontFeatures: const [FontFeature.tabularFigures()])),
                      if (title.isNotEmpty || issued.isNotEmpty)
                        Text([if (title.isNotEmpty) title, if (issued.isNotEmpty) FriendlyDate.date(issued)].join(' · '),
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (pdfUrl.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14)),
                    onPressed: () => _open(pdfUrl),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: Text(l.certDownload),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
