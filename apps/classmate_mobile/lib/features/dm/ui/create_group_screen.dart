import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dm_repository.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final title = TextEditingController();
  final picked = <String>{};

  final candidates = const <Map<String, String>>[
    {'id': 'u-1', 'name': 'Ahmad K.'},
    {'id': 'u-2', 'name': 'Maya R.'},
    {'id': 'u-3', 'name': 'Lina T.'},
  ];

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(dmRepositoryProvider);

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
            onPressed: () async {
              await repo.createGroup(
                title.text.trim(),
                picked.toList(growable: false),
              );
              if (!mounted) return;
              Navigator.of(context).pop();
            },
            child: const Text('Create group'),
          ),
        ],
      ),
    );
  }
}
