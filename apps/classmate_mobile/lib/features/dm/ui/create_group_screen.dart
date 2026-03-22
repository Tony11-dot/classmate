import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/dm_repository.dart';
import '../providers/dm_providers.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final title = TextEditingController();
  final searchCtl = TextEditingController();
  final picked = <String>{};
  String? avatarPath;

  final candidates = const <Map<String, String>>[
    {'id': 'u-1', 'name': 'Ahmad K.'},
    {'id': 'u-2', 'name': 'Maya R.'},
    {'id': 'u-3', 'name': 'Lina T.'},
    {'id': 'u-4', 'name': 'Yousef H.'},
    {'id': 'u-5', 'name': 'Sama A.'},
    {'id': 'u-6', 'name': 'Raneen M.'},
    {'id': 'u-7', 'name': 'Tariq N.'},
    {'id': 'u-8', 'name': 'Jana S.'},
  ];

  @override
  void dispose() {
    title.dispose();
    searchCtl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    final path = pickedFile?.files.single.path;
    if (path == null || path.trim().isEmpty) return;
    setState(() => avatarPath = path);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(dmRepositoryProvider);
    final cs = Theme.of(context).colorScheme;
    final query = searchCtl.text.trim().toLowerCase();

    final filtered = candidates
        .where((user) {
          if (query.isEmpty) return true;
          return user['name']!.toLowerCase().contains(query);
        })
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Create group')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickAvatar,
                  child: CircleAvatar(
                    radius: 34,
                    backgroundImage: avatarPath == null
                        ? null
                        : FileImage(File(avatarPath!)),
                    child: avatarPath == null
                        ? const Icon(Icons.camera_alt_rounded)
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tap to choose a group photo',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: title,
                  decoration: const InputDecoration(
                    labelText: 'Group name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchCtl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Search students from your school...',
                    prefixIcon: Icon(Icons.search_rounded),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (picked.isNotEmpty) ...[
            Text(
              'Selected (${picked.length})',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: candidates
                  .where((u) => picked.contains(u['id']))
                  .map(
                    (u) => InputChip(
                      label: Text(u['name']!),
                      onDeleted: () => setState(() => picked.remove(u['id']!)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            'Students from your school',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          ...filtered.map((user) {
            final id = user['id']!;
            final selected = picked.contains(id);
            return CheckboxListTile(
              value: selected,
              title: Text(user['name']!),
              subtitle: const Text(
                'Will receive an approval request before joining',
              ),
              secondary: CircleAvatar(
                child: Text(
                  user['name']!
                      .split(' ')
                      .where((e) => e.trim().isNotEmpty)
                      .take(2)
                      .map((e) => e[0])
                      .join()
                      .toUpperCase(),
                ),
              ),
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
          FilledButton.icon(
            onPressed: picked.isEmpty
                ? null
                : () async {
                    final navigator = Navigator.of(context);
                    await repo.createGroup(
                      title: title.text.trim(),
                      participantIds: picked.toList(),
                    );
                    if (!mounted) return;
                    ref.invalidate(dmThreadsProvider);
                    navigator.pop();
                  },
            icon: const Icon(Icons.group_add_rounded),
            label: const Text('Create group'),
          ),
        ],
      ),
    );
  }
}
