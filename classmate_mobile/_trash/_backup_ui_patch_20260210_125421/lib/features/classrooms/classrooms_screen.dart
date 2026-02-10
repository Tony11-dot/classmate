import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_store.dart';

class ClassroomsScreen extends StatelessWidget {
  const ClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'Classrooms',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        for (final c in DemoStore.classrooms)
          Card(
            child: ListTile(
              leading: const Icon(Icons.class_outlined),
              title: Text(
                c.name,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text('${c.teacher} • ${c.room}'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/classrooms/${c.id}'),
            ),
          ),
      ],
    );
  }
}
