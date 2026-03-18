import 'package:flutter/material.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final title = TextEditingController();
  final picked = <String>{};

  final candidates = const <Map<String, String>>[
    {'id': 'u-1', 'name': 'Ahmad K.'},
    {'id': 'u-2', 'name': 'Maya R.'},
    {'id': 'u-3', 'name': 'Lina T.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create group')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: title,
            decoration: const InputDecoration(labelText: 'Group name'),
          ),
          const SizedBox(height: 16),
          const Text('Members', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...candidates.map((user) {
            final id = user['id']!;
            return CheckboxListTile(
              value: picked.contains(id),
              title: Text(user['name']!),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    picked.add(id);
                  } else {
                    picked.remove(id);
                  }
                });
              },
            );
          }),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Create group'),
          ),
        ],
      ),
    );
  }
}
