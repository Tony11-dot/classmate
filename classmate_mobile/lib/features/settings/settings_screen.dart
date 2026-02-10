import 'package:flutter/material.dart';
import '../../demo/demo_data.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: ListTile(
              title: const Text(
                'Reset demo',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Restores points, submissions, notifications.',
              ),
              trailing: const Icon(Icons.refresh_rounded),
              onTap: () {
                DemoStore.reset();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Demo reset.')));
              },
            ),
          ),
        ],
      ),
    );
  }
}
