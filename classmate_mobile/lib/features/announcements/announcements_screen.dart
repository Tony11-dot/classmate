import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('School'),
            subtitle: Text('Welcome to the pilot!'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Math Department'),
            subtitle: Text('Quiz Thursday'),
          ),
        ),
      ],
    );
  }
}
