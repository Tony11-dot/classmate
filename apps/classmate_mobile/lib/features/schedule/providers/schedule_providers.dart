import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/schedule_repository.dart';

final weekScheduleProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, weekOf) async {
      final repo = ref.watch(scheduleRepositoryProvider);
      return repo.getWeek(DateTime.parse(weekOf));
    });
