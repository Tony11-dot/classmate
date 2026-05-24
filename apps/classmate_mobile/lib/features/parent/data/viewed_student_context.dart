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
  return ref.watch(selectedChildProvider);
});
