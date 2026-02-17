import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';

class Solution {
  final String id;
  final String text;
  int likes;

  Solution({required this.id, required this.text, required this.likes});

  factory Solution.fromJson(Map<String, dynamic> j) {
    return Solution(
      id: j['id'].toString(),
      text: (j['text'] ?? "Solution").toString(),
      likes: j['likes'] ?? 0,
    );
  }
}

final solutionsProvider =
    AsyncNotifierProvider<SolutionsController, List<Solution>>(
        SolutionsController.new);

class SolutionsController extends AsyncNotifier<List<Solution>> {
  @override
  Future<List<Solution>> build() async {
    try {
      final res = await ApiClient.instance.get('/solutions');
      if (res.data is! List) return [];
      return (res.data as List)
          .map((e) => Solution.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  void like(String id) {
    final list = List<Solution>.from(state.value ?? const <Solution>[]);
    final i = list.indexWhere((e) => e.id == id);
    if (i != -1) {
      list[i].likes++;
      state = AsyncData<List<Solution>>(list);
    }
  }
}

class SolutionsScreen extends ConsumerWidget {
  const SolutionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(solutionsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Error: $e")),
      data: (list) {
        if (list.isEmpty) {
          return Center(
            child: Text(
              "No solutions yet",
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            final s = list[i];

            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: cs.outline.withValues(alpha: 0.12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.text,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () =>
                            ref.read(solutionsProvider.notifier).like(s.id),
                      ),
                      Text("${s.likes}"),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(Icons.comment_outlined),
                        onPressed: () {},
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
