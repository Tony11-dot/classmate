import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_client.dart';

class Classroom {
  final String id;
  final String name;
  final String? subtitle;

  Classroom({required this.id, required this.name, this.subtitle});

  factory Classroom.fromJson(Map<String, dynamic> j) {
    return Classroom(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? j['title'] ?? 'Classroom').toString(),
      subtitle: (j['subtitle'] ?? j['teacher'] ?? j['room'])?.toString(),
    );
  }
}

final classroomsProvider = AsyncNotifierProvider<ClassroomsController, List<Classroom>>(
  ClassroomsController.new,
);

class ClassroomsController extends AsyncNotifier<List<Classroom>> {
  @override
  Future<List<Classroom>> build() async {
    final res = await ApiClient.instance.get('/classrooms');
    final data = res.data;
    if (data is! List) return const [];
    return data.map((e) => Classroom.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => build());
  }
}

class ClassroomsScreen extends ConsumerStatefulWidget {
  const ClassroomsScreen({super.key});

  @override
  ConsumerState<ClassroomsScreen> createState() => _ClassroomsScreenState();
}

class _ClassroomsScreenState extends ConsumerState<ClassroomsScreen> {
  final q = TextEditingController();

  @override
  void dispose() {
    q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final async = ref.watch(classroomsProvider);
    final query = q.text.trim().toLowerCase();

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => _ErrorState(
        err: e.toString(),
        onRetry: () => ref.read(classroomsProvider.notifier).refresh(),
      ),
      data: (rows) {
        final filtered = query.isEmpty
            ? rows
            : rows.where((c) => c.name.toLowerCase().contains(query)).toList();

        return RefreshIndicator(
          onRefresh: () => ref.read(classroomsProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              Text(
                "Classrooms",
                style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: q,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "Search classrooms…",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.12)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.12)),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.meeting_room_outlined, size: 36, color: cs.onSurfaceVariant),
                        const SizedBox(height: 10),
                        Text(
                          rows.isEmpty ? "No classrooms yet" : "No results",
                          style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          rows.isEmpty
                              ? "Once you’re assigned to classrooms, they’ll show here."
                              : "Try a different search.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...filtered.map((c) => _ClassroomCard(c: c)),
            ],
          ),
        );
      },
    );
  }
}

class _ClassroomCard extends StatelessWidget {
  final Classroom c;
  const _ClassroomCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text(c.name)),
                  body: Center(
                    child: Text(
                      "Classroom ID: ${c.id}",
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            );
          },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outline.withValues(alpha: 0.12)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cs.primaryContainer.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.class_, color: cs.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface),
                    ),
                    if (c.subtitle != null && c.subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        c.subtitle!,
                        style: TextStyle(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String err;
  final VoidCallback onRetry;
  const _ErrorState({required this.err, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 34),
            const SizedBox(height: 10),
            Text(
              "Failed to load classrooms",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(err, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );
  }
}
