import 'package:flutter/material.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Grades',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(14),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Text('Grades dashboard (demo).'),
          ),
        ),
      ),
    );
  }
}
