import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import 'schedule_api.dart';

final scheduleProvider =
    FutureProvider.family<List<ScheduleEntry>, DateTime>((ref, day) async {
  final api = ScheduleApi(ApiClient.instance);

  final from = DateTime(day.year, day.month, day.day);
  final to = from.add(const Duration(days: 1));

  return api.list(from: from, to: to);
});
