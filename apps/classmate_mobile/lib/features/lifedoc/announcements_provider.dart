import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../insights/providers/insights_providers.dart';
import '../solutions/providers/solutions_flow_provider.dart';
import 'announcements_models.dart';

final announcementsProvider = Provider<List<AnnouncementItem>>((ref) {
  final unified = ref
      .watch(unifiedStudentInsightsProvider)
      .maybeWhen(data: (v) => v, orElse: () => null);
  final solutions = ref.watch(solutionsFlowProvider).allSolutions;

  final grades = unified?.grades;
  final attendance = unified?.attendance;
  final practice = unified?.practice;

  final now = DateTime.now();
  final list = <AnnouncementItem>[];

  final avg = grades?.average;
  if (avg != null && avg < 70) {
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

  final weakest = (grades?.weakestSubject ?? '').trim();
  if (weakest.isNotEmpty) {
    list.add(
      AnnouncementItem(
        id: 'weak-subject',
        title: 'Weak subject detected',
        body: '$weakest needs attention.',
        severity: AnnouncementSeverity.warning,
        source: 'grades',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    );
  }

  final rate = attendance?.attendanceRate;
  if (rate != null && rate < 85) {
    list.add(
      AnnouncementItem(
        id: 'attendance-risk',
        title: 'Low attendance',
        body: 'Your attendance is dropping. This will impact grades.',
        severity: AnnouncementSeverity.critical,
        source: 'attendance',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
    );
  }

  final late = attendance?.late ?? 0;
  if (late > 3) {
    list.add(
      AnnouncementItem(
        id: 'lateness',
        title: 'Repeated lateness',
        body: 'You have multiple late arrivals.',
        severity: AnnouncementSeverity.warning,
        source: 'attendance',
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    );
  }

  if (practice != null && practice.weakTopics.isNotEmpty) {
    final weak = practice.weakTopics.first;
    list.add(
      AnnouncementItem(
        id: 'practice-weak-topic',
        title: 'Practice weakness found',
        body:
            '${weak.topicLabel} in ${weak.subject} is dragging your momentum.',
        severity: AnnouncementSeverity.warning,
        source: 'practice',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
    );
  }

  final delta = practice?.trend?.deltaAccuracy;
  if (delta != null && delta <= -6) {
    list.add(
      AnnouncementItem(
        id: 'practice-drop',
        title: 'Practice trend dropped',
        body:
            'Your recent practice is below your baseline. Slow down and rebuild.',
        severity: AnnouncementSeverity.warning,
        source: 'practice',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    );
  }

  if (solutions.isNotEmpty) {
    final latest = [...solutions]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final item = latest.first;
    list.add(
      AnnouncementItem(
        id: 'solutions-activity-${item.id}',
        title: 'Solutions activity is live',
        body:
            'Your solution space is active on page ${item.pageNumber}, question ${item.questionNumber}. Check peer work or upload yours.',
        severity: AnnouncementSeverity.info,
        source: 'solutions',
        createdAt: item.createdAt,
      ),
    );
  }

  if (list.isEmpty) {
    list.add(
      AnnouncementItem(
        id: 'all-good',
        title: 'All good',
        body: 'No major academic risks detected right now.',
        severity: AnnouncementSeverity.info,
        source: 'system',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
    );
  }

  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list;
});
