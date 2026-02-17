import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Attendance',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(14),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Text('Attendance dashboard (demo).'),
          ),
        ),
      ),
    );
  }
}
