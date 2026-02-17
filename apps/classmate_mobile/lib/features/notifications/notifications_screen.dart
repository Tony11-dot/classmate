import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notifications_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stack) => Center(child: Text(e.toString())),
      data: (list) {
        if (list.isEmpty) {
          return const Center(child: Text("No notifications"));
        }

        return RefreshIndicator(
          onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (c, i) {
              final n = list[i];
              return Material(
                color: n.unread
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(18),
                child: ListTile(
                  title: Text(
                    n.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(n.body),
                  onTap: () {
                    if (n.unread) {
                      ref.read(notificationsProvider.notifier).markRead(n.id);
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
