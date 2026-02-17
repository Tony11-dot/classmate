import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final list = DemoStore.assignments;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assignments',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          for (final a in list)
            Card(
              child: ListTile(
                leading: const Icon(Icons.assignment_outlined),
                title: Text(
                  a.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text('Due: ${a.due} • Reward: +${a.reward}'),
                trailing: a.submitted
                    ? const Icon(Icons.check_circle_rounded)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
