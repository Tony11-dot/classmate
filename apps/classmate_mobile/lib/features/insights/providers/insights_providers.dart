import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/insights_repository.dart';

final insightsSnapshotProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(insightsRepositoryProvider);
  return repo.getInsightsSnapshot();
});
