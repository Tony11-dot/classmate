import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/teacher_mobile_repository.dart';

/// Three flavors share the same picker shape: only the fetch source,
/// "Create new" route, attach call, and labels differ.
enum ClassroomLibraryKind { material, assignment, meeting }

/// Bottom-sheet picker used by the classroom detail tabs (assignments /
/// materials / meetings) when the teacher taps the FAB.
///
/// Shape mirrors the period-attachments picker: a "Create new" entry
/// up top, then the teacher's library list minus anything already
/// attached to this classroom. Tapping a row pops with that library
/// item's id; tapping "Create new" pushes the standard add screen and
/// auto-pops with the new id (when the add screen returns one).
///
/// Pop value contract:
///   - String teacherXxxId  → caller should attach this id to the
///                            classroom and reload.
///   - null                  → user cancelled / dismissed.
class ClassroomLibraryPickerSheet extends ConsumerStatefulWidget {
  const ClassroomLibraryPickerSheet({
    super.key,
    required this.kind,
    required this.alreadyAttachedTeacherIds,
    this.prefillSubject,
    this.prefillCohortIds,
    this.prefillStudentIds,
  });

  final ClassroomLibraryKind kind;

  /// Teacher-library ids that already have a mirror in this classroom.
  /// Rendered greyed-out + non-tappable so the teacher can see what's
  /// already linked without being able to attach it twice.
  final Set<String> alreadyAttachedTeacherIds;

  /// Hint passed to the "Create new" flow so the new library item
  /// defaults to the classroom's subject. All editable in the add screen.
  final String? prefillSubject;

  /// Audience hints — cohort + individual-student ids — that the new
  /// library item should default to. Used so a material created from
  /// inside an exam/assignment auto-targets the same audience without
  /// the teacher having to reselect. Editable on the add screen.
  final List<String>? prefillCohortIds;
  final List<String>? prefillStudentIds;

  @override
  ConsumerState<ClassroomLibraryPickerSheet> createState() =>
      _ClassroomLibraryPickerSheetState();
}

class _ClassroomLibraryPickerSheetState
    extends ConsumerState<ClassroomLibraryPickerSheet> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = const [];
  String _query = '';

  String get _title => switch (widget.kind) {
        ClassroomLibraryKind.material => 'Add material',
        ClassroomLibraryKind.assignment => 'Add assignment',
        ClassroomLibraryKind.meeting => 'Add meeting',
      };

  String get _createNewLabel => switch (widget.kind) {
        ClassroomLibraryKind.material => 'Create new material',
        ClassroomLibraryKind.assignment => 'Create new assignment',
        ClassroomLibraryKind.meeting => 'Create new meeting',
      };

  String get _createNewRoute => switch (widget.kind) {
        ClassroomLibraryKind.material => '/teacher/materials/add',
        ClassroomLibraryKind.assignment => '/teacher/assignments/add',
        ClassroomLibraryKind.meeting => '/teacher/meetings/add',
      };

  IconData get _icon => switch (widget.kind) {
        ClassroomLibraryKind.material => Icons.description_rounded,
        ClassroomLibraryKind.assignment => Icons.assignment_rounded,
        ClassroomLibraryKind.meeting => Icons.video_call_rounded,
      };

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
  }

  Future<List<Map<String, dynamic>>> _fetch() {
    final repo = ref.read(teacherMobileRepositoryProvider);
    return switch (widget.kind) {
      ClassroomLibraryKind.material => repo.listTeacherMaterials(),
      ClassroomLibraryKind.assignment => repo.listTeacherAssignments(),
      ClassroomLibraryKind.meeting => repo.listTeacherMeetings(),
    };
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await _fetch();
      if (!mounted) return;
      setState(() {
        _items = list;
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

  Future<void> _createNew() async {
    // Push the standard add screen with a subject hint. Material's add
    // screen pops with the new id (auto-attach path); assignment + meeting
    // add screens pop with `true`, so we just refresh the list and the
    // teacher taps the new entry.
    final result = await context.push(
      _createNewRoute,
      extra: <String, dynamic>{
        if ((widget.prefillSubject ?? '').isNotEmpty)
          'subject': widget.prefillSubject,
        if ((widget.prefillCohortIds ?? const []).isNotEmpty)
          'cohortIds': widget.prefillCohortIds,
        if ((widget.prefillStudentIds ?? const []).isNotEmpty)
          'studentIds': widget.prefillStudentIds,
      },
    );
    if (!mounted) return;
    if (result is String && result.isNotEmpty && result != 'true') {
      Navigator.of(context).pop(result);
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? _items
        : _items.where((m) {
            final t = (m['title'] ?? '').toString().toLowerCase();
            final s = (m['subject'] ?? '').toString().toLowerCase();
            return t.contains(q) || s.contains(q);
          }).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _title,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.teacherMaterialSearchHint,
                  prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Padding(
                          padding: const EdgeInsets.all(20),
                          child: Center(
                            child: Text(_error!,
                                style: TextStyle(color: cs.error)),
                          ),
                        )
                      : ListView.separated(
                          controller: scrollCtrl,
                          padding:
                              const EdgeInsets.fromLTRB(12, 4, 12, 20),
                          itemCount: filtered.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 4),
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: _createNew,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: cs.primary
                                            .withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_rounded,
                                          color: cs.onPrimaryContainer),
                                      const SizedBox(width: 10),
                                      Text(
                                        _createNewLabel,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: cs.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            final m = filtered[i - 1];
                            final id = (m['id'] ?? '').toString();
                            final title =
                                (m['title'] ?? 'Untitled').toString();
                            final subj = (m['subject'] ?? '').toString();
                            final attached = widget
                                .alreadyAttachedTeacherIds
                                .contains(id);
                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: attached
                                  ? null
                                  : () => Navigator.pop(context, id),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: attached
                                      ? cs.surfaceContainerHighest
                                          .withValues(alpha: 0.4)
                                      : cs.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: cs.outlineVariant
                                          .withValues(alpha: 0.4)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(_icon, color: cs.primary),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: attached
                                                  ? cs.onSurfaceVariant
                                                  : cs.onSurface,
                                            ),
                                          ),
                                          if (subj.isNotEmpty)
                                            Text(subj,
                                                style: theme.textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                        color: cs
                                                            .onSurfaceVariant)),
                                        ],
                                      ),
                                    ),
                                    if (attached)
                                      Icon(Icons.check_circle_rounded,
                                          size: 18, color: cs.primary),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience wrapper: shows the sheet and returns the picked
/// teacher-library item id (or null if cancelled).
Future<String?> showClassroomLibraryPicker({
  required BuildContext context,
  required ClassroomLibraryKind kind,
  required Set<String> alreadyAttachedTeacherIds,
  String? prefillSubject,
  List<String>? prefillCohortIds,
  List<String>? prefillStudentIds,
}) {
  final cs = Theme.of(context).colorScheme;
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: cs.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ClassroomLibraryPickerSheet(
      kind: kind,
      alreadyAttachedTeacherIds: alreadyAttachedTeacherIds,
      prefillSubject: prefillSubject,
      prefillCohortIds: prefillCohortIds,
      prefillStudentIds: prefillStudentIds,
    ),
  );
}
