import 'package:flutter/material.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grades')),
      body: const Center(
        child: Text(
          'Grades (wire to /api/student/grades, /api/teacher/*, /api/parent/grades)',
        ),
      ),
    );
  }
}
