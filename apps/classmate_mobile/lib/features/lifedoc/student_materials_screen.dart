// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:classmate_mobile/ui/widgets/classmate_refresh.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/semester/school_semester.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/semester_filter_bar.dart';
import '../classrooms/providers/classrooms_repo_provider.dart';
import '../parent/data/parent_repository.dart';
import '../parent/data/viewed_student_context.dart';
import '../../ui/widgets/cm_loading.dart';
import '../../ui/widgets/attachment_pill.dart';
import '../../core/config/env.dart';

final studentMaterialsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) async {
    final viewedStudentId = ref.watch(viewedStudentIdProvider);
    if (viewedStudentId != null) {
      final raw = await ref.read(parentRepositoryProvider)
          .getChildFeed('/parent/materials', viewedStudentId);
      final list = raw is Map && raw['items'] is List ? raw['items'] as List : const [];
      return list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList(growable: false);
    }
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
  bool _showingPrevious = false;
  SemesterWindow? _selectedPast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;
    final materialsAsync = ref.watch(studentMaterialsProvider);

    return ClassMateRefreshIndicator(
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
                Text(l.studentMaterialsLoadError, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(AppLocalizations.of(context)!.commonErrorWith(e), style: TextStyle(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (items) {
          final semWindow = ref.watch(currentSemesterWindowProvider);
          final visible = visibleForSemester<Map<String, dynamic>>(
            items,
            (m) => DateTime.tryParse(
                (m['createdAt'] ?? m['publishedAt'] ?? m['date'] ?? '').toString()),
            semWindow,
            _showingPrevious,
            _selectedPast,
          );

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
                      Text(l.studentMaterialsTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                      const SizedBox(height: 4),
                      Text(l.studentMaterialsEmptyTitle, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
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
                  Text(l.studentMaterialsEmptyTitle, style: theme.textTheme.titleMedium?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(l.studentMaterialsEmptyHint, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                ])),
              ],
            );
          }

          // Group by subject
          final grouped = <String, List<Map<String, dynamic>>>{};
          for (final item in visible) {
            final subject = (item['subject'] as String? ?? '').trim();
            final key = subject.isNotEmpty ? subject : l.studentMaterialsGeneralSubject;
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
                    Text(l.studentMaterialsTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                    const SizedBox(height: 4),
                    Text(l.studentMaterialsResourceCount(items.length),
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ])),
                  Container(width: 46, height: 46,
                    decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.folder_rounded, size: 24, color: cs.onPrimaryContainer)),
                ]),
              ),
              const SizedBox(height: 20),

              SemesterFilterBar(
                visible: semWindow != null,
                showingPrevious: _showingPrevious,
                onChanged: (v) => setState(() { _showingPrevious = v; if (!v) _selectedPast = null; }),
                selectedPast: _selectedPast,
                onPastChanged: (w) => setState(() => _selectedPast = w),
              ),

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
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 2),
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
                title.isEmpty ? AppLocalizations.of(context)!.commonUntitled : title,
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
