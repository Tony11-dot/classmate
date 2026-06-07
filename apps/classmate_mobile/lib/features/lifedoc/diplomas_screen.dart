import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/auth_controller.dart';
import '../../core/http/cm_api.dart';
import '../../core/semester/school_semester.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/glass/liquid_glass_card.dart';
import '../../ui/widgets/semester_filter_bar.dart';
import '../teacher_mobile/data/teacher_mobile_repository.dart';
import '../../ui/widgets/cm_loading.dart';
import '../parent/data/parent_repository.dart';
import '../parent/data/viewed_student_context.dart';
import '../common/media/image_viewer_screen.dart';
import '../common/media/pdf_viewer_screen.dart';

// Public trigger so AppShell can open the create sheet
class _DiplomasTrigger extends Notifier<int> {
  @override
  int build() => 0;
  void increment() => state++;
}

final diplomasCreateTriggerProvider = NotifierProvider<_DiplomasTrigger, int>(_DiplomasTrigger.new);

class DiplomasScreen extends ConsumerStatefulWidget {
  const DiplomasScreen({super.key});

  @override
  ConsumerState<DiplomasScreen> createState() => _DiplomasScreenState();
}

class _DiplomasScreenState extends ConsumerState<DiplomasScreen> {
  List<Map<String, dynamic>> _diplomas = [];
  bool _loading = true;
  String? _error;
  bool _showingPrevious = false;
  SemesterWindow? _selectedPast;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  bool get _isTeacher => ref.read(authSessionProvider).isTeacherLike;

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final List<Map<String, dynamic>> diplomas;
      final viewedStudentId = ref.read(viewedStudentIdProvider);
      if (_isTeacher) {
        diplomas = await ref.read(teacherMobileRepositoryProvider).listDiplomas();
      } else if (viewedStudentId != null) {
        // Parent viewing a child's certificates → /parent/diplomas
        final raw = await ref.read(parentRepositoryProvider)
            .getChildFeed('/parent/diplomas', viewedStudentId);
        final list = (raw is Map ? raw['diplomas'] : raw) as List? ?? [];
        diplomas = list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        final session = ref.read(authSessionProvider);
        final api = CMApi(token: session.token);
        try {
          final raw = await api.getJson('/student/diplomas');
          final list = (raw is Map ? raw['diplomas'] : raw) as List? ?? [];
          diplomas = list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        } finally {
          api.dispose();
        }
      }
      if (!mounted) return;
      setState(() { _diplomas = diplomas; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _openDiplomaFiles(Map<String, dynamic> d) async {
    final attachments = d['attachments'];
    final List<dynamic> list = attachments is List ? attachments : const [];

    // Collect only openable URLs (server-hosted, not local device paths).
    final openable = <String>[];
    for (final att in list) {
      final url = (att is Map
          ? (att['url'] ?? att['fileUrl'] ?? '')
          : att
      ).toString().trim();
      if (url.isEmpty || url.startsWith('/') || url.startsWith('file:')) continue;
      final uri = Uri.tryParse(url);
      if (uri != null && uri.hasScheme) openable.add(url);
    }

    if (openable.isEmpty) {
      final l = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(list.isEmpty
            ? l.diplomasNoFilesAttached
            : l.diplomasFilesProcessing)),
      );
      return;
    }
    // Route in-app for the formats we can render natively, fall back to
    // the OS handler for anything else. Multiple files open in sequence
    // (each viewer pushes a fresh route).
    for (final url in openable) {
      final lower = url.toLowerCase();
      final isImage = lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.png') ||
          lower.endsWith('.webp') ||
          lower.endsWith('.gif');
      final isPdf = lower.endsWith('.pdf');
      if (isImage) {
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => ImageViewerScreen(url: url, title: AppLocalizations.of(context)!.diplomasScreenCertificate),
          ),
        );
      } else if (isPdf) {
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute<void>(
            builder: (_) => PdfViewerScreen(url: url, title: AppLocalizations.of(context)!.diplomasScreenCertificate),
          ),
        );
      } else {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _editDiploma(Map<String, dynamic> d) async {
    final id = d['id'] as String? ?? '';
    if (id.isEmpty) return;
    final titleCtrl = TextEditingController(text: d['title'] as String? ?? '');
    final subjectCtrl = TextEditingController(text: d['subject'] as String? ?? '');
    final notesCtrl = TextEditingController(text: d['notes'] as String? ?? '');
    // Date is editable too — earlier the only ways to change an
    // issued-at value were to re-create the certificate or hit the API
    // directly. Pre-fill from `issuedAt` (server) or today.
    final issuedRaw = (d['issuedAt'] ?? d['date'] ?? '').toString();
    DateTime issuedAt = DateTime.tryParse(issuedRaw) ?? DateTime.now();
    final cs = Theme.of(context).colorScheme;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 36, height: 4, alignment: Alignment.center,
                  decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(ctx)!.studentDiplomaEditTitle, style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(controller: titleCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.commonTitle, border: const OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: subjectCtrl, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.assignmentsSubjectLabel, border: const OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: notesCtrl, maxLines: 3, decoration: InputDecoration(labelText: AppLocalizations.of(ctx)!.commonNotes, border: const OutlineInputBorder())),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (sbCtx, sbSet) => OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: sbCtx,
                        initialDate: issuedAt,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) sbSet(() => issuedAt = picked);
                    },
                    icon: const Icon(Icons.event_rounded, size: 18),
                    label: Text(
                      AppLocalizations.of(ctx)!.diplomasScreenIssuedDate(DateFormat.yMMMd().format(issuedAt)),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(AppLocalizations.of(ctx)!.commonSave),
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );

    // Capture text THEN dispose — post-frame so the dismiss animation fully completes first
    final titleText = titleCtrl.text.trim();
    final subjectText = subjectCtrl.text.trim();
    final notesText = notesCtrl.text.trim();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      titleCtrl.dispose();
      subjectCtrl.dispose();
      notesCtrl.dispose();
    });

    if (saved != true) return;
    try {
      final api = ref.read(teacherMobileRepositoryProvider);
      await api.updateDiploma(id, {
        'title': titleText.isEmpty ? 'Certificate of Achievement' : titleText,
        'subject': subjectText.isEmpty ? null : subjectText,
        'notes': notesText.isEmpty ? null : notesText,
        'issuedAt': issuedAt.toUtc().toIso8601String(),
      });
      await _load();
    } catch (_) {}
  }

  Future<void> _delete(String id, String studentName) async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx)!.studentDiplomaDeleteTitle),
        content: Text(AppLocalizations.of(ctx)!.studentDiplomaDeleteConfirm(studentName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.classroomsForwardCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.teacherGradesDeleteAction)),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(teacherMobileRepositoryProvider).deleteDiploma(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = Localizations.localeOf(context).toString();

    final semWindow = ref.watch(currentSemesterWindowProvider);
    final visible = visibleForSemester<Map<String, dynamic>>(
      _diplomas,
      (d) => DateTime.tryParse((d['issuedAt'] ?? d['date'] ?? '').toString()),
      semWindow,
      _showingPrevious,
      _selectedPast,
    );

    ref.listen<int>(diplomasCreateTriggerProvider, (prev, next) {
      if ((next) > (prev ?? 0)) {
        context.push<bool>('/diplomas/create').then((_) {
          if (mounted) _load();
        });
      }
    });

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          // Hero banner
          LiquidGlassCard(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cs.outlineVariant),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.diplomasTitle, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, height: 1.1)),
                      const SizedBox(height: 4),
                      Text(l.diplomasIssuedCount(_diplomas.length), style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(14)),
                  child: Icon(Icons.workspace_premium_rounded, size: 26, color: cs.onPrimaryContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SemesterFilterBar(
            visible: semWindow != null,
            showingPrevious: _showingPrevious,
            onChanged: (v) => setState(() { _showingPrevious = v; if (!v) _selectedPast = null; }),
            selectedPast: _selectedPast,
            onPastChanged: (w) => setState(() => _selectedPast = w),
          ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LiquidGlassCard(
                color: cs.errorContainer,
                child: Row(
                  children: [
                    Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: TextStyle(color: cs.onErrorContainer))),
                    TextButton(onPressed: _load, child: Text(AppLocalizations.of(context)!.commonRetry)),
                  ],
                ),
              ),
            ),

          if (_loading && _diplomas.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CmLoading()))
          else if (visible.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.workspace_premium_outlined, size: 56, color: cs.primary),
                    const SizedBox(height: 16),
                    Text(
                      _isTeacher ? l.diplomasEmpty : l.diplomasScreenNoCertificatesReceived,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            )
          else
            ...(visible.map((d) {
              final id = d['id'] as String? ?? '';
              // Teacher view uses studentName; student view uses issuedBy (teacher name)
              final isTeacher = _isTeacher;
              final nameLabel = isTeacher
                  ? (d['studentName'] as String? ?? '')
                  : (d['issuedBy'] as String? ?? '');
              final title = d['title'] as String? ?? '';
              final subject = d['subject'] as String? ?? '';
              final grade = d['grade'] as String? ?? '';
              final distinction = d['distinction'] as String? ?? '';
              final issuedAt = d['issuedAt'] as String? ?? '';
              final dateStr = () {
                final dt = DateTime.tryParse(issuedAt);
                if (dt == null) return issuedAt.split('T').first;
                return DateFormat.yMMMd(locale).format(dt);
              }();

              final attachments = d['attachments'];
              final attachList = attachments is List ? attachments : const [];
              final hasFiles = attachList.isNotEmpty;

              final chipRow = Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (subject.isNotEmpty)
                    _DiplomaChip(label: subject, color: cs.primary, onColor: cs.onPrimary),
                  if (grade.isNotEmpty)
                    _DiplomaChip(label: grade, color: cs.tertiary, onColor: cs.onTertiary),
                  if (distinction.isNotEmpty)
                    _DiplomaChip(label: distinction, color: cs.tertiary, onColor: cs.onTertiary),
                  _DiplomaChip(
                    label: l.diplomasIssuedOn(dateStr),
                    color: cs.secondary,
                    onColor: cs.onSecondary,
                  ),
                  if (hasFiles)
                    _DiplomaChip(
                      label: l.diplomasScreenFileCount(attachList.length),
                      color: cs.surfaceContainerHighest,
                      onColor: cs.onSurfaceVariant,
                    ),
                ],
              );

              // Teacher card — explicit edit + delete buttons
              if (isTeacher) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LiquidGlassCard(
                    border: Border.all(color: cs.outlineVariant),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                color: cs.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.workspace_premium_rounded, size: 24, color: cs.onPrimaryContainer),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nameLabel, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                            // Edit button
                            IconButton(
                              icon: Icon(Icons.edit_rounded, size: 18, color: cs.primary),
                              tooltip: AppLocalizations.of(context)!.commonEdit,
                              onPressed: () => _editDiploma(d),
                              visualDensity: VisualDensity.compact,
                            ),
                            // Delete button
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, size: 18, color: cs.error),
                              tooltip: AppLocalizations.of(context)!.commonDelete,
                              onPressed: () => _delete(id, nameLabel),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        chipRow,
                      ],
                    ),
                  ),
                );
              }

              // Student card — tap to open files
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _openDiplomaFiles(d),
                  child: LiquidGlassCard(
                    border: Border.all(color: cs.outlineVariant),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.workspace_premium_rounded, size: 26, color: cs.onPrimaryContainer),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nameLabel, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(title, style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                              const SizedBox(height: 8),
                              chipRow,
                            ],
                          ),
                        ),
                        if (hasFiles)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(Icons.open_in_new_rounded, size: 16, color: cs.primary),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            })),
        ],
      ),
    );
  }
}

class _DiplomaChip extends StatelessWidget {
  const _DiplomaChip({required this.label, required this.color, required this.onColor});
  final String label;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: onColor)),
    );
  }
}

