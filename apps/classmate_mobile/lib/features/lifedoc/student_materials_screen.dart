// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ui/glass/liquid_glass_card.dart';
import '../classrooms/providers/classrooms_repo_provider.dart';
import '../../ui/widgets/cm_loading.dart';
import '../../ui/widgets/attachment_pill.dart';
import '../../core/config/env.dart';

final studentMaterialsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async {
    final repo = ref.read(classroomsRepoProvider);
    return repo.allStudentMaterials();
  },
);

class StudentMaterialsScreen extends ConsumerStatefulWidget {
  const StudentMaterialsScreen({super.key});

  @override
  ConsumerState<StudentMaterialsScreen> createState() => _StudentMaterialsScreenState();
}

class _StudentMaterialsScreenState extends ConsumerState<StudentMaterialsScreen> {
  Future<void> _openUrl(BuildContext context, String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.startsWith('/') || trimmed.startsWith('file:')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This file is not yet available.')),
      );
      return;
    }
    Uri? uri = Uri.tryParse(trimmed);
    if (uri != null && !uri.hasScheme && trimmed.contains('.')) {
      uri = Uri.tryParse('https://$trimmed');
    }
    if (uri == null || !uri.hasScheme) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final materialsAsync = ref.watch(studentMaterialsProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(studentMaterialsProvider),
      child: materialsAsync.when(
        loading: () => const Center(child: CmLoading()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: cs.onSurfaceVariant),
                const SizedBox(height: 16),
                Text('Could not load materials', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('$e', style: TextStyle(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              children: [
                // Hero banner
                LiquidGlassCard(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: cs.outlineVariant),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Materials', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                      const SizedBox(height: 4),
                      Text('No materials yet', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ])),
                    Container(width: 46, height: 46,
                      decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
                      child: Icon(Icons.folder_open_rounded, size: 24, color: cs.onPrimaryContainer)),
                  ]),
                ),
                const SizedBox(height: 60),
                Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.folder_open_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  Text('No materials shared yet', style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text('Your teacher will share resources here.', style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                ])),
              ],
            );
          }

          // Group by subject
          final grouped = <String, List<Map<String, dynamic>>>{};
          for (final item in items) {
            final subject = (item['subject'] as String? ?? '').trim();
            final key = subject.isNotEmpty ? subject : 'General';
            grouped.putIfAbsent(key, () => []).add(item);
          }
          final subjects = grouped.keys.toList()..sort();

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            children: [
              // Hero banner
              LiquidGlassCard(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: cs.outlineVariant),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Materials', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                    const SizedBox(height: 4),
                    Text('${items.length} resource${items.length == 1 ? '' : 's'} from your teachers',
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ])),
                  Container(width: 46, height: 46,
                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.folder_rounded, size: 24, color: cs.onPrimaryContainer)),
                ]),
              ),
              const SizedBox(height: 20),

              // Subject sections
              for (final subject in subjects) ...[
                _SubjectHeader(subject: subject, cs: cs, theme: theme),
                const SizedBox(height: 8),
                for (final item in grouped[subject]!) ...[
                  _MaterialCard(item: item, cs: cs, theme: theme),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SubjectHeader extends StatelessWidget {
  const _SubjectHeader({required this.subject, required this.cs, required this.theme});
  final String subject;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Row(children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          subject,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
            letterSpacing: 0.3,
          ),
        ),
      ]),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.item, required this.cs, required this.theme});
  final Map<String, dynamic> item;
  final ColorScheme cs;
  final ThemeData theme;

  String _resolveUrl(String raw) {
    final u = raw.trim();
    if (u.isEmpty) return u;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    // Relative path — prepend API base
    final base = Env.apiBaseUrl.replaceAll(RegExp(r'/+$'), '').replaceAll(RegExp(r'/api$'), '');
    return '$base$u';
  }

  String get _url => _resolveUrl((item['url'] as String? ?? ''));
  bool get _hasUrl => _url.isNotEmpty;

  List<Map<String, dynamic>> get _allAttachments {
    final rawList = item['attachments'];
    final result = <Map<String, dynamic>>[];
    if (rawList is List) {
      for (final a in rawList) {
        if (a is Map && (a['url'] ?? '').toString().isNotEmpty) {
          final resolved = _resolveUrl((a['url'] ?? '').toString());
          result.add({...Map<String, dynamic>.from(a), 'url': resolved});
        }
      }
    }
    if (result.isEmpty && _url.isNotEmpty) {
      final mime = (item['mime'] as String? ?? '').toLowerCase();
      final type = mime.contains('pdf') || _url.toLowerCase().endsWith('.pdf')
          ? 'pdf'
          : _url.contains('/uploads/')
              ? 'file'
              : 'link';
      final name = _url.split('/').last.split('?').first;
      result.add({'url': _url, 'name': name, 'type': type});
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final title = (item['title'] as String? ?? '').trim();
    final description = (item['description'] as String? ?? '').trim();
    final courseName = (item['courseName'] as String? ?? '').trim();
    final teacherName = (item['teacherName'] as String? ?? '').trim();

    final meta = [
      if (courseName.isNotEmpty) courseName,
      if (teacherName.isNotEmpty) teacherName,
    ].join(' · ');

    final attachments = _allAttachments;

    return LiquidGlassCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      borderRadius: BorderRadius.circular(18),
      color: cs.surfaceContainerLow,
      border: Border.all(color: cs.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: attachments.isNotEmpty ? cs.primaryContainer : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                attachments.isNotEmpty
                    ? (attachments.first['type'] == 'link' ? Icons.link_rounded : Icons.insert_drive_file_rounded)
                    : Icons.folder_rounded,
                size: 20,
                color: attachments.isNotEmpty ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                title.isEmpty ? 'Untitled' : title,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(description, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(meta, style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ])),
          ]),
          if (attachments.isNotEmpty) ...[
            const SizedBox(height: 8),
            AttachmentPills(attachments: attachments),
          ],
        ],
      ),
    );
  }
}
