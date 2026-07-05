import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../data/teacher_mobile_repository.dart';

/// Snapshot of a resolved audience, reported up to the parent create-screen so
/// it can materialize the audience to an explicit student list at save time
/// when the teacher has removed individual students.
class AudienceResolution {
  const AudienceResolution({required this.all, required this.excluded});

  /// Every student the current selection (grades + cohorts + students) reaches.
  final List<TeacherStudent> all;

  /// Student ids the teacher removed via the X on a pill.
  final Set<String> excluded;

  /// Students who will actually receive the item (all − excluded).
  List<TeacherStudent> get effective =>
      all.where((s) => !excluded.contains(s.studentId)).toList(growable: false);

  bool get hasExclusions => excluded.isNotEmpty;
}

/// "Students who will see this" summary, shown below the audience block on the
/// teacher create screens. Resolves the current selection into a concrete
/// student list via the server (the authoritative expander), renders one pill
/// per student with an X to remove them, and reports the resolution upward.
class AudienceStudentsSummary extends ConsumerStatefulWidget {
  const AudienceStudentsSummary({
    super.key,
    this.targetType,
    this.cohortIds = const [],
    this.studentIds = const [],
    this.grades = const [],
    required this.onResolutionChanged,
  });

  final String? targetType;
  final List<String> cohortIds;
  final List<String> studentIds;
  final List<int> grades;

  /// Called whenever the resolved list or the excluded set changes.
  final ValueChanged<AudienceResolution> onResolutionChanged;

  @override
  ConsumerState<AudienceStudentsSummary> createState() =>
      _AudienceStudentsSummaryState();
}

class _AudienceStudentsSummaryState
    extends ConsumerState<AudienceStudentsSummary> {
  List<TeacherStudent> _students = const [];
  final Set<String> _excluded = {};
  bool _loading = false;
  Timer? _debounce;
  int _requestSeq = 0;

  bool get _hasSelection =>
      (widget.targetType ?? '').toUpperCase() == 'EVERYONE' ||
      widget.cohortIds.isNotEmpty ||
      widget.studentIds.isNotEmpty ||
      widget.grades.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant AudienceStudentsSummary old) {
    super.didUpdateWidget(old);
    if (!_listEq(old.cohortIds, widget.cohortIds) ||
        !_listEq(old.studentIds, widget.studentIds) ||
        !_intListEq(old.grades, widget.grades) ||
        old.targetType != widget.targetType) {
      // Drop exclusions for students no longer in scope is handled after the
      // re-resolve lands.
      _resolve();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _resolve() {
    _debounce?.cancel();
    if (!_hasSelection) {
      setState(() {
        _students = const [];
        _loading = false;
      });
      _emit();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      final seq = ++_requestSeq;
      setState(() => _loading = true);
      try {
        final repo = ref.read(teacherMobileRepositoryProvider);
        final result = await repo.resolveAudience(
          targetType: widget.targetType,
          cohortIds: widget.cohortIds,
          studentIds: widget.studentIds,
          grades: widget.grades,
        );
        if (!mounted || seq != _requestSeq) return;
        setState(() {
          _students = result;
          // Keep exclusions only for students still in scope.
          final ids = result.map((s) => s.studentId).toSet();
          _excluded.removeWhere((id) => !ids.contains(id));
          _loading = false;
        });
        _emit();
      } catch (_) {
        if (!mounted || seq != _requestSeq) return;
        setState(() => _loading = false);
      }
    });
  }

  void _emit() {
    widget.onResolutionChanged(
      AudienceResolution(all: _students, excluded: Set.of(_excluded)),
    );
  }

  void _remove(String id) {
    setState(() => _excluded.add(id));
    _emit();
  }

  void _restore(String id) {
    setState(() => _excluded.remove(id));
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l = AppLocalizations.of(context)!;

    if (!_hasSelection) return const SizedBox.shrink();

    final visible =
        _students.where((s) => !_excluded.contains(s.studentId)).toList();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
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
              Icon(Icons.people_alt_rounded, size: 16, color: cs.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _loading
                      ? l.audienceSummaryResolving
                      : l.audienceSummaryCount(visible.length),
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                ),
              ),
              if (_loading)
                SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
                ),
            ],
          ),
          if (!_loading && visible.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l.audienceSummaryEmpty,
                style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          if (visible.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: visible
                  .map((s) => _StudentPill(name: s.name, onRemove: () => _remove(s.studentId)))
                  .toList(),
            ),
          ],
          if (_excluded.isNotEmpty) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                for (final id in _excluded.toList()) {
                  _restore(id);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.undo_rounded, size: 14, color: cs.primary),
                    const SizedBox(width: 4),
                    Text(
                      l.audienceSummaryRestore(_excluded.length),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static bool _listEq(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _intListEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

class _StudentPill extends StatelessWidget {
  const _StudentPill({required this.name, required this.onRemove});
  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Semantics(
            button: true,
            label: l.a11yRemove,
            child: GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded, size: 15, color: cs.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
