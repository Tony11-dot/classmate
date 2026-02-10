import 'package:flutter/material.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Math Worksheet'),
            subtitle: Text('Due Thursday'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Physics Lab Writeup'),
            subtitle: Text('Due Sunday'),
          ),
        ),
      ],
    );
  }
}
