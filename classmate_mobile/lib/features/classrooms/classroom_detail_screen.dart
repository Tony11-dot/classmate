import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_data.dart';

class ClassroomDetailScreen extends StatelessWidget {
  final String id;
  const ClassroomDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final c = DemoStore.classrooms.firstWhere((x) => x.id == id);
    final a = DemoStore.assignments.where((x) => x.classroomId == id).toList();

    return Scaffold(
      appBar: AppBar(title: Text(c.name)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.teacher,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text('Room ${c.room} • ${c.time}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Assignments',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          for (final x in a)
            Card(
              child: ListTile(
                title: Text(
                  x.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Due: ${x.due} • Reward: +${x.reward}'),
                trailing: x.submitted
                    ? const Icon(Icons.check_circle_rounded)
                    : const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push('/assignments'),
              ),
            ),
        ],
      ),
    );
  }
}
