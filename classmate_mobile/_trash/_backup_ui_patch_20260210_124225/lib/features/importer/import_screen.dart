import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_download_outlined),
              title: const Text(
                'Sync from Google Classroom (demo)',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: const Text(
                'Adds schedule items + assignments and shows notifications.',
              ),
              trailing: FilledButton(
                onPressed: () {
                  final n = DemoStore.importFromGoogleClassroomMock();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Imported $n items.')));
                },
                child: const Text('Sync'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
