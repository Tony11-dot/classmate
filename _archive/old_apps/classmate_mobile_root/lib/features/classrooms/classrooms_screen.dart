import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_data.dart';

class ClassroomsScreen extends StatelessWidget {
  const ClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final classes = DemoStore.classrooms;
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const SizedBox(height: 6),
        const Text(
          'Your classrooms',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (final c in classes)
          Card(
            child: ListTile(
              title: Text(
                c.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${c.teacher} • ${c.room} • ${c.time}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/classrooms/${c.id}'),
            ),
          ),
      ],
    );
  }
}
