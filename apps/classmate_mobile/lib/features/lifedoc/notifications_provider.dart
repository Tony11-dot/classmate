import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'announcements_models.dart';
import 'announcements_provider.dart';
import 'notifications_api.dart';
import 'notifications_models.dart';

final persistedNotificationsProvider =
    FutureProvider<List<StudentNotificationItem>>((ref) async {
      final api = ref.watch(notificationsApiProvider);
      return api.list(limit: 100);
    });

final mergedNotificationsProvider =
    FutureProvider<List<StudentNotificationItem>>((ref) async {
      final persisted = await ref.watch(persistedNotificationsProvider.future);
      final announcements = ref.watch(announcementsProvider);

      final derived = announcements.map((item) {
        final severity = switch (item.severity) {
          AnnouncementSeverity.critical => StudentNotificationSeverity.critical,
          AnnouncementSeverity.warning => StudentNotificationSeverity.warning,
          AnnouncementSeverity.info => StudentNotificationSeverity.info,
        };

        return StudentNotificationItem(
          id: 'derived-${item.id}',
          title: item.title,
          body: item.body,
          source: item.source,
          createdAt: item.createdAt,
          severity: severity,
          isRead: false,
        );
      });

      final merged = <StudentNotificationItem>[...persisted, ...derived];

      final seen = <String>{};
      final unique = <StudentNotificationItem>[];
      for (final item in merged) {
        final key = '${item.title}|${item.body}|${item.source}';
        if (seen.add(key)) unique.add(item);
      }

      unique.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return unique;
    });
