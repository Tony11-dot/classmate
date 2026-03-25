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

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(dmRepositoryProvider);
    final asyncUsers = ref.watch(dmUserCandidatesProvider);
    final cs = Theme.of(context).colorScheme;
    final query = searchCtl.text.trim().toLowerCase();

    return Scaffold(
      body: SafeArea(
        child: asyncUsers.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Failed to load students: $e')),
          data: (users) {
            final filtered = users
                .where((user) {
                  if (picked.contains(user.userId)) return false;
                  if (query.isEmpty) return true;
                  return user.fullName.toLowerCase().contains(query) ||
                      user.avatarText.toLowerCase().contains(query);
                })
                .toList(growable: false);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Create group',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickAvatar,
                        child: CircleAvatar(
                          radius: 36,
                          backgroundImage: avatarPath == null
                              ? null
                              : FileImage(File(avatarPath!)),
                          child: avatarPath == null
                              ? const Icon(Icons.camera_alt_rounded)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Choose a photo, name, and members.',
                        style: TextStyle(color: cs.onSurfaceVariant),
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
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: users
                        .where((u) => picked.contains(u.userId))
                        .map(
                          (u) => InputChip(
                            label: Text(u.fullName),
                            onDeleted: () {
                              setState(() {
                                picked.remove(u.userId);
                              });
                            },
                          ),
                        )
                        .toList(growable: false),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Students from your school',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                ...filtered.map((user) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundImage: user.avatarUrl == null
                          ? null
                          : NetworkImage(user.avatarUrl!),
                      child: user.avatarUrl == null
                          ? Text(user.avatarText)
                          : null,
                    ),
                    title: Text(user.fullName),
                    subtitle: const Text(
                      'Will receive an approval request before joining',
                    ),
                    trailing: const Icon(Icons.add_circle_outline_rounded),
                    onTap: () {
                      setState(() {
                        picked.add(user.userId);
                      });
                    },
                  );
                }),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: picked.isEmpty || _creating
                      ? null
                      : () async {
                          setState(() => _creating = true);
                          try {
                            await repo.createGroup(
                              title: title.text.trim(),
                              participantIds: picked.toList(),
                              avatarPath: avatarPath,
                            );
                            ref.invalidate(dmThreadsProvider);
                            if (!mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Group created. Members will need to approve before chatting.',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Create group failed: $e'),
                              ),
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
      ),
    );
  }
}
