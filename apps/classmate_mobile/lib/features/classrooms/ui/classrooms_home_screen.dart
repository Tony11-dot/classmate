import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/classrooms_providers.dart';

class ClassroomsHomeScreen extends ConsumerWidget {
  const ClassroomsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(studentClassroomsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load classrooms'),
              const SizedBox(height: 8),
              Text('$e', maxLines: 6, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(studentClassroomsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.groups_outlined, size: 48),
                  const SizedBox(height: 10),
                  const Text('No classrooms yet'),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () => ref.invalidate(studentClassroomsProvider),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final c = items[i];
            final id = (c['id'] ?? '').toString();
            final title = (c['name'] ?? c['title'] ?? id).toString();
            final subtitle = (c['teacherName'] ?? c['teacherUserId'] ?? '')
                .toString();

            return Card(
              child: ListTile(
                leading: const Icon(Icons.class_),
                title: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: subtitle.isEmpty
                    ? null
                    : Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/classrooms/$id'),
              ),
            );
          },
        );
      },
    );
  }
}
