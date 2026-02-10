import 'package:flutter/material.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lesson Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Students', style: TextStyle(fontWeight: FontWeight.w900)),
          _student('Alice'),
          _student('Bob'),
          const SizedBox(height: 20),
          const Text(
            'Lesson Notes',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const TextField(
            maxLines: 4,
            decoration: InputDecoration(hintText: 'What did we do today…'),
          ),
        ],
      ),
    );
  }

  Widget _student(String name) {
    return SwitchListTile(title: Text(name), value: true, onChanged: (_) {});
  }
}
