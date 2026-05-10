// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../ui/glass/liquid_glass_card.dart';
import '../data/teacher_mobile_repository.dart';
import '../../../ui/widgets/cm_loading.dart';
import '../../../ui/widgets/attachment_pill.dart';

class _MaterialsTrigger extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

final materialsAddTriggerProvider = NotifierProvider<_MaterialsTrigger, int>(_MaterialsTrigger.new);

class TeacherMaterialsScreen extends ConsumerStatefulWidget {
  const TeacherMaterialsScreen({super.key});

  @override
  ConsumerState<TeacherMaterialsScreen> createState() =>
      _TeacherMaterialsScreenState();
}

class _TeacherMaterialsScreenState
    extends ConsumerState<TeacherMaterialsScreen> {
  List<Map<String, dynamic>> _materials = [];
  bool _loading = true;
  String? _error;
  String? _filterCourseId;
  List<TeacherCourse> _courses = [];

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
      final repo = ref.read(teacherMobileRepositoryProvider);
      final results = await Future.wait([
        repo.fetchTeacherMaterials(),
        repo.fetchClassrooms(),
      ]);
      if (!mounted) return;
      setState(() {
        _materials = results[0] as List<Map<String, dynamic>>;
        _courses = results[1] as List<TeacherCourse>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _courseIdOf(Map<String, dynamic> m) =>
      (m['_courseId'] as String?) ?? (m['courseId'] as String?) ?? '';

  List<Map<String, dynamic>> get _filteredMaterials {
    if (_filterCourseId == null) return _materials;
    return _materials
        .where((m) => _courseIdOf(m) == _filterCourseId)
        .toList();
  }

  Future<void> _openUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    if (trimmed.startsWith('/') || trimmed.startsWith('file:')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This file is not available — re-upload it to share.')),
      );
      return;
    }
    Uri? uri = Uri.tryParse(trimmed);
    if (uri != null && !uri.hasScheme && trimmed.contains('.')) {
      uri = Uri.tryParse('https://$trimmed');
    }
    if (uri == null || !uri.hasScheme) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open: $trimmed')),
      );
    }
  }

  Future<void> _delete(String id, String courseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete material?'),
        content: const Text(
            'This will permanently remove the material from this course.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(teacherMobileRepositoryProvider)
          .deleteTeacherMaterial(id);
      if (!mounted) return;
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _addMaterial() async {
    if (_courses.isEmpty) return;
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _CoursePickerSheet(courses: _courses),
    );
    if (selected == null || !mounted) return;
    await context.push('/teacher/classroom/$selected/material/add');
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final filtered = _filteredMaterials;

    ref.listen<int>(materialsAddTriggerProvider, (prev, next) {
      if ((next) > (prev ?? 0)) _addMaterial();
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            // ── Hero banner ────────────────────────────────────────────────
            LiquidGlassCard(
              borderRadius: BorderRadius.circular(28),
              border:
                  Border.all(color: cs.tertiary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Materials',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900, height: 1.1),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_materials.length} material${_materials.length == 1 ? '' : 's'} · ${_courses.length} course${_courses.length == 1 ? '' : 's'}',
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: cs.tertiary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.share_rounded,
                            size: 24, color: cs.onTertiary),
                      ),
                    ],
                  ),
                  if (_courses.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // "All" chip
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: const Text('All'),
                              selected: _filterCourseId == null,
                              onSelected: (_) =>
                                  setState(() => _filterCourseId = null),
                              selectedColor:
                                  cs.tertiary,
                              checkmarkColor: cs.onTertiary,
                              side: BorderSide(
                                  color: _filterCourseId == null
                                      ? cs.tertiary
                                      : cs.outlineVariant
                                          .withValues(alpha: 0.4)),
                            ),
                          ),
                          ..._courses.map((course) {
                            final active = _filterCourseId == course.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  course.subject.isNotEmpty
                                      ? course.subject
                                      : course.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                selected: active,
                                onSelected: (_) => setState(() =>
                                    _filterCourseId =
                                        active ? null : course.id),
                                selectedColor:
                                    cs.tertiary,
                                checkmarkColor: cs.onTertiary,
                                side: BorderSide(
                                    color: active
                                        ? cs.tertiary
                                        : cs.outlineVariant
                                            .withValues(alpha: 0.4)),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Error ──────────────────────────────────────────────────────
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: LiquidGlassCard(
                  color: cs.errorContainer,
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(_error!,
                              style: TextStyle(color: cs.onErrorContainer))),
                      TextButton(
                          onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                ),
              ),

            // ── Loading ────────────────────────────────────────────────────
            if (_loading && _materials.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: const CmLoading(),
                ),
              )

            // ── Empty ──────────────────────────────────────────────────────
            else if (!_loading && filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.insert_link_rounded,
                          size: 48,
                          color: cs.onSurfaceVariant),
                      const SizedBox(height: 16),
                      Text(
                        _filterCourseId != null
                            ? 'No materials for this course.'
                            : 'No materials yet.\nTap + to share one.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )

            // ── Material cards ─────────────────────────────────────────────
            else
              ...filtered.map((material) {
                final id = (material['id'] as String?) ?? '';
                final courseId = _courseIdOf(material);
                final title = (material['title'] as String?) ?? '';
                final description = (material['description'] as String?) ?? '';
                final url = (material['url'] as String?) ?? '';
                final mime = (material['mime'] as String?) ?? '';
                // Build full attachment list from attachments array + url fallback
                final rawAttachments = material['attachments'] is List ? material['attachments'] as List : <dynamic>[];
                String _inferType(String u, String m) {
                  if (m.toLowerCase().contains('pdf') || u.toLowerCase().endsWith('.pdf')) return 'pdf';
                  if (u.contains('/uploads/')) return 'file';
                  if (m.toLowerCase().startsWith('image/') || RegExp(r'\.(png|jpg|jpeg|gif|webp)$', caseSensitive: false).hasMatch(u)) return 'image';
                  return 'link';
                }
                final allAttachments = <Map<String, dynamic>>[
                  for (final a in rawAttachments)
                    if (a is Map && (a['url'] ?? '').toString().isNotEmpty)
                      Map<String, dynamic>.from(a),
                  if (rawAttachments.isEmpty && url.isNotEmpty)
                    {'url': url, 'name': url.split('/').last, 'type': _inferType(url, mime)},
                ];
                final courseName =
                    (material['_courseName'] as String?) ?? '';
                final subject = (material['_subject'] as String?) ?? '';

                final isPdf = mime.toLowerCase().contains('pdf');

                final courseLabel = subject.isNotEmpty
                    ? (courseName.isNotEmpty && courseName != subject
                        ? '$subject · $courseName'
                        : subject)
                    : courseName;

                // Truncate URL for display
                String displayUrl = url;
                if (displayUrl.length > 40) {
                  displayUrl = '${displayUrl.substring(0, 37)}…';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Dismissible(
                    key: ValueKey('material_$id'),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      await _delete(id, courseId);
                      return false; // _load() handles list update
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Icon(Icons.delete_outline_rounded,
                          color: cs.onErrorContainer),
                    ),
                    child: LiquidGlassCard(
                        border: Border.all(
                            color:
                                cs.outlineVariant),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Leading icon box
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: cs.tertiary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isPdf
                                    ? Icons.picture_as_pdf_rounded
                                    : Icons.insert_link_rounded,
                                size: 22,
                                color: cs.onTertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Middle content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (courseLabel.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      courseLabel,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                  if (description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: cs.onSurfaceVariant
                                                  .withValues(alpha: 0.8)),
                                    ),
                                  ],
                                  if (allAttachments.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    AttachmentPills(attachments: allAttachments),
                                  ],
                                ],
                              ),
                            ),
                            // Trailing — delete button only (pills handle opening)
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, size: 20, color: cs.error),
                              onPressed: () => _delete(id, courseId),
                              tooltip: 'Delete',
                              style: IconButton.styleFrom(
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(36, 36),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                );
              }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMaterial,
        tooltip: 'Add material',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

// ── Course picker bottom sheet ─────────────────────────────────────────────────

class _CoursePickerSheet extends StatelessWidget {
  const _CoursePickerSheet({required this.courses});

  final List<TeacherCourse> courses;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: LiquidGlassCard(
        borderRadius: BorderRadius.circular(22),
        padding: EdgeInsets.zero,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select a Course',
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                  itemCount: courses.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: cs.outlineVariant,
                  ),
                  itemBuilder: (ctx, i) {
                    final course = courses[i];
                    final label = course.subject.isNotEmpty
                        ? (course.name.isNotEmpty && course.name != course.subject
                            ? '${course.subject} · ${course.name}'
                            : course.subject)
                        : course.name;
                    return ListTile(
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cs.tertiary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.menu_book_rounded,
                            size: 18, color: cs.onTertiary),
                      ),
                      title: Text(
                        label,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      onTap: () =>
                          Navigator.of(context).pop<String>(course.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
