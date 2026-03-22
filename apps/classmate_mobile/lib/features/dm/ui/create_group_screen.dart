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
  bool _creating = false;

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

  String _initialsFor(String name) {
    final parts = name
        .split(' ')
        .where((e) => e.trim().isNotEmpty)
        .take(2)
        .map((e) => e.trim()[0])
        .join()
        .toUpperCase();
    return parts.isEmpty ? 'GR' : parts;
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(dmRepositoryProvider);
    final cs = Theme.of(context).colorScheme;
    final query = searchCtl.text.trim().toLowerCase();
    final asyncCandidates = ref.watch(dmGroupCandidatesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create group')),
      body: asyncCandidates.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Could not load students.\n$e',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(dmGroupCandidatesProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (candidates) {
          final filtered = candidates
              .where((user) {
                if (query.isEmpty) return true;
                return user.fullName.toLowerCase().contains(query);
              })
              .toList(growable: false);

          final selectedUsers = candidates
              .where((u) => picked.contains(u.userId))
              .toList(growable: false);

          return ListView(
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
                  children: selectedUsers
                      .map(
                        (u) => InputChip(
                          avatar: CircleAvatar(
                            radius: 10,
                            child: Text(
                              u.avatarText.isEmpty
                                  ? _initialsFor(u.fullName)
                                  : u.avatarText,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          label: Text(u.fullName),
                          onDeleted: () =>
                              setState(() => picked.remove(u.userId)),
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
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    query.isEmpty
                        ? 'No students available yet.'
                        : 'No students match "$query".',
                  ),
                )
              else
                ...filtered.map((user) {
                  final selected = picked.contains(user.userId);
                  return CheckboxListTile(
                    value: selected,
                    title: Text(user.fullName),
                    subtitle: const Text(
                      'Will receive an approval request before joining',
                    ),
                    secondary: CircleAvatar(
                      child: Text(
                        user.avatarText.isEmpty
                            ? _initialsFor(user.fullName)
                            : user.avatarText,
                      ),
                    ),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          picked.add(user.userId);
                        } else {
                          picked.remove(user.userId);
                        }
                      });
                    },
                  );
                }),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: picked.isEmpty || _creating
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final messenger = ScaffoldMessenger.of(context);
                        setState(() => _creating = true);
                        try {
                          await repo.createGroup(
                            title: title.text.trim(),
                            participantIds: picked.toList(),
                            avatarPath: avatarPath,
                          );
                          if (!mounted) return;
                          ref.invalidate(dmThreadsProvider);
                          navigator.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Group created. Members will need to approve before chatting.',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(content: Text('Create group failed: $e')),
                          );
                        } finally {
                          if (mounted) {
                            setState(() => _creating = false);
                          }
                        }
                      },
                icon: const Icon(Icons.group_add_rounded),
                label: Text(_creating ? 'Creating...' : 'Create group'),
              ),
            ],
          );
        },
      ),
    );
  }
}
