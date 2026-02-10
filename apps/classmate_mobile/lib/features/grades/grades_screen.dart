import 'package:flutter/material.dart';

class GradesScreen extends StatelessWidget {
  const GradesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(title: Text('Math'), subtitle: Text('92')),
        ),
        Card(
          child: ListTile(title: Text('Physics'), subtitle: Text('88')),
        ),
        Card(
          child: ListTile(title: Text('English'), subtitle: Text('90')),
        ),
      ],
    );
  }
}
