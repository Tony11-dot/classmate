import 'package:flutter/material.dart';
import 'classroom_detail_screen.dart';

class ClassroomsScreen extends StatelessWidget {
  const ClassroomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = const [
      ('Math • 10B', 'Auto-joined • Teacher: Dana'),
      ('Physics • 10B', 'Auto-joined • Teacher: Sami'),
      ('CS • 10B', 'Auto-joined • Teacher: Rami'),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final (t, s) = items[i];
        return Card(
          child: ListTile(
            title: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(s),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClassroomDetailScreen(title: t),
              ),
            ),
          ),
        );
      },
    );
  }
}
