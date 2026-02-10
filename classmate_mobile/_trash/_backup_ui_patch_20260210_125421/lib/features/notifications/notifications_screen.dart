import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final list = DemoStore.notifications;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          for (final n in list)
            Card(
              child: ListTile(
                title: Text(
                  n.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text('${n.body}\n${n.time}'),
                isThreeLine: true,
                trailing: n.seen
                    ? const Icon(Icons.done_all_rounded)
                    : const Icon(Icons.circle, size: 10),
                onTap: () => setState(() => n.seen = true),
              ),
            ),
        ],
      ),
    );
  }
}
