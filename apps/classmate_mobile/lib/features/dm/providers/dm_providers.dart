import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dm_repository.dart';
import '../domain/dm_models.dart';

final dmThreadsProvider = FutureProvider<List<DmThread>>((ref) async {
  final repo = ref.watch(dmRepositoryProvider);
  return repo.listThreads();
});

final dmMessagesProvider = FutureProvider.family<List<DmMessage>, String>((
  ref,
  threadId,
) async {
  final repo = ref.watch(dmRepositoryProvider);
  return repo.listMessages(threadId);
});
