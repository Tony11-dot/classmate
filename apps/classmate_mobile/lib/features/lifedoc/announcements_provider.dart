import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../insights/providers/insights_providers.dart';
import 'announcements_models.dart';

final announcementsProvider = Provider<List<AnnouncementItem>>((ref) {
  final data = ref.watch(unifiedStudentInsightsProvider).value;

  if (data == null) return [];

  final now = DateTime.now();
  final list = <AnnouncementItem>[];

  final grades = data.grades;
  final attendance = data.attendance;

  // --- GRADES ---
  if ((grades?.average ?? 100) < 70) {
    list.add(
      AnnouncementItem(
        id: 'grade-risk',
        title: 'Grade risk detected',
        body: 'Your average dropped below 70. Immediate action recommended.',
        severity: AnnouncementSeverity.critical,
        source: 'grades',
        createdAt: now,
      ),
    );
  }

  if ((grades?.weakestSubject ?? '').isNotEmpty) {
    list.add(
      AnnouncementItem(
        id: 'weak-subject',
        title: 'Weak subject detected',
        body: '${grades!.weakestSubject} needs attention.',
        severity: AnnouncementSeverity.warning,
        source: 'grades',
        createdAt: now,
      ),
    );
  }

  // --- ATTENDANCE ---
  if ((attendance?.attendanceRate ?? 100) < 85) {
    list.add(
      AnnouncementItem(
        id: 'attendance-risk',
        title: 'Low attendance',
        body: 'Your attendance is dropping. This will impact grades.',
        severity: AnnouncementSeverity.critical,
        source: 'attendance',
        createdAt: now,
      ),
    );
  }

  if ((attendance?.late ?? 0) > 3) {
    list.add(
      AnnouncementItem(
        id: 'lateness',
        title: 'Repeated lateness',
        body: 'You have multiple late arrivals.',
        severity: AnnouncementSeverity.warning,
        source: 'attendance',
        createdAt: now,
      ),
    );
  }

  // --- FALLBACK ---
  if (list.isEmpty) {
    list.add(
      AnnouncementItem(
        id: 'all-good',
        title: 'All good',
        body: 'No major academic risks detected right now.',
        severity: AnnouncementSeverity.info,
        source: 'system',
        createdAt: now,
      ),
    );
  }

  return list;
});
