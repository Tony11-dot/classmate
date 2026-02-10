import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Announcements',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: const [
          Card(
            child: ListTile(
              title: Text(
                'School event (demo)',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text('Tomorrow 10:00 in the hall.'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(
                'Reminder (demo)',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text('Bring lab notebook to Physics.'),
            ),
          ),
        ],
      ),
    );
  }
}
