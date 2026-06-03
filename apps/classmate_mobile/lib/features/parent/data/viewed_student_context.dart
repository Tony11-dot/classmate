import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_session.dart';
import 'parent_repository.dart';

/// THE single source of truth for "whose data should the student-screen
/// providers fetch right now?" Returns null for self-view; returns the
/// selected child's id when the viewer is a PARENT and has picked a
/// child via `selectedChildProvider`.
///
/// Plumbed into every existing student-data provider so the parent
/// flow can reuse the student screens 1:1 — no UI duplication, just a
/// context check at the data layer.
final viewedStudentIdProvider = Provider<String?>((ref) {
  final session = ref.watch(authSessionProvider);
  if (session.primaryRole != 'PARENT') return null;
  final selected = ref.watch(selectedChildProvider);
  if (selected != null && selected.isNotEmpty) return selected;
  // No child explicitly picked yet (deep-link, fresh launch before the
  // picker runs) — fall back to the first linked child so parent data
  // screens never fall through to the STUDENT endpoints (which a parent
  // role can't hit → "Forbidden resource" / infinite load).
  return ref.watch(parentChildrenProvider).maybeWhen(
        data: (kids) => kids.isNotEmpty ? kids.first.studentId : null,
        orElse: () => null,
      );
});
