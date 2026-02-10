import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Today'),
            subtitle: Text('Present • 4/4 classes'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('This week'),
            subtitle: Text('Attendance: 96%'),
          ),
        ),
      ],
    );
  }
}
