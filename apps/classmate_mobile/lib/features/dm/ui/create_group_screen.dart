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
  final search = TextEditingController();
  final picked = <String>{};
  String? _groupPhotoPath;

  final candidates = const <Map<String, String>>[
    {'id': 'u-1', 'name': 'Ahmad K.'},
    {'id': 'u-2', 'name': 'Maya R.'},
    {'id': 'u-3', 'name': 'Lina T.'},
    {'id': 'u-4', 'name': 'Lina T.'},
    {'id': 'u-5', 'name': 'Yousef N.'},
    {'id': 'u-6', 'name': 'Mariam S.'},
    {'id': 'u-7', 'name': 'Rami H.'},
  ];

  @override
  void dispose() {
    title.dispose();
    search.dispose();
    super.dispose();
  }

  Future<void> _pickGroupPhoto() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    final path = pickedFile?.files.single.path;
    if (!mounted || path == null || path.trim().isEmpty) {
      return;
    }
    setState(() => _groupPhotoPath = path);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(dmRepositoryProvider);
    final cs = Theme.of(context).colorScheme;
    final q = search.text.trim().toLowerCase();

    final visibleCandidates = candidates
        .where((user) {
          if (q.isEmpty) {
            return true;
          }
          return (user['name'] ?? '').toLowerCase().contains(q);
        })
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Create group')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _pickGroupPhoto,
              child: Stack(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.28),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _groupPhotoPath == null
                        ? const Icon(Icons.groups_rounded, size: 36)
                        : Image.file(File(_groupPhotoPath!), fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: cs.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: title,
            decoration: const InputDecoration(
              labelText: 'Group name',
              hintText: 'Biology study squad',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Search students',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text(
                'Members',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                '${picked.length} selected',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...visibleCandidates.map((user) {
            final id = user['id']!;
            final name = user['name']!;
            final selected = picked.contains(id);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: cs.surface.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? cs.primary.withValues(alpha: 0.40)
                      : cs.outlineVariant.withValues(alpha: 0.22),
                ),
              ),
              child: CheckboxListTile(
                value: selected,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                secondary: CircleAvatar(
                  child: Text(
                    name
                        .split(' ')
                        .where((x) => x.trim().isNotEmpty)
                        .take(2)
                        .map((x) => x.trim()[0])
                        .join()
                        .toUpperCase(),
                  ),
                ),
                title: Text(name),
                subtitle: const Text('Same school'),
                onChanged: (v) {
                  setState(() {
                    if (v == true) {
                      picked.add(id);
                    } else {
                      picked.remove(id);
                    }
                  });
                },
              ),
            );
          }),
          if (visibleCandidates.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('No students match "${search.text.trim()}".'),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await repo.createGroup(
                title: title.text.trim(),
                participantIds: picked.toList(),
              );
              ref.invalidate(dmThreadsProvider);
              if (!mounted) return;
              navigator.pop();
            },
            icon: const Icon(Icons.group_add_rounded),
            label: const Text('Create group'),
          ),
          const SizedBox(height: 10),
          Text(
            'Group members should appear as pending until they approve on their side.',
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
