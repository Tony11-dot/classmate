import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/classrooms_providers.dart';
import '../providers/classrooms_repo_provider.dart';

class ClassroomDetailScreen extends ConsumerStatefulWidget {
  const ClassroomDetailScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<ClassroomDetailScreen> createState() =>
      _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends ConsumerState<ClassroomDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);
  final TextEditingController _chatCtl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _tabs.dispose();
    _chatCtl.dispose();
    super.dispose();
  }

  void _refreshAll() {
    ref.invalidate(classroomPeopleProvider(widget.courseId));
    ref.invalidate(
      classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
    );
    ref.invalidate(classroomAssignmentsProvider(widget.courseId));
    ref.invalidate(classroomMaterialsProvider(widget.courseId));
    ref.invalidate(classroomMeetingsProvider(widget.courseId));
  }

  Future<void> _sendChat() async {
    final t = _chatCtl.text.trim();
    if (t.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      final repo = ref.read(classroomsRepoProvider);
      await repo.sendChatText(widget.courseId, t);
      _chatCtl.clear();
      ref.invalidate(
        classroomChatProvider((id: widget.courseId, limit: 50, cursor: null)),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.courseId;

    final people = ref.watch(classroomPeopleProvider(id));
    final chat = ref.watch(
      classroomChatProvider((id: id, limit: 50, cursor: null)),
    );
    final asg = ref.watch(classroomAssignmentsProvider(id));
    final mats = ref.watch(classroomMaterialsProvider(id));
    final meets = ref.watch(classroomMeetingsProvider(id));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Classroom: $id',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: _refreshAll,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabs,
              isScrollable: true,
              tabs: const [
                Tab(text: 'People'),
                Tab(text: 'Chat'),
                Tab(text: 'Assignments'),
                Tab(text: 'Materials'),
                Tab(text: 'Meetings'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _jsonTab(people),
                  _chatTab(chat),
                  _jsonTab(asg),
                  _jsonTab(mats),
                  _jsonTab(meets),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jsonTab(AsyncValue<Map<String, dynamic>> v) {
    return v.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(
        child: Padding(padding: const EdgeInsets.all(16), child: Text('$e')),
      ),
      data: (m) => SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Text(m.toString()),
      ),
    );
  }

  Widget _chatTab(AsyncValue<Map<String, dynamic>> v) {
    return Column(
      children: [
        Expanded(
          child: v.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('$e'),
              ),
            ),
            data: (m) {
              final items = m['items'];
              final list = (items is List) ? items : const [];
              if (list.isEmpty) {
                return const Center(child: Text('No messages yet'));
              }
              return ListView.separated(
                reverse: true,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final msg = list[list.length - 1 - i];
                  final kind = (msg is Map ? (msg['kind'] ?? '') : '')
                      .toString();
                  final from = (msg is Map ? (msg['senderUserId'] ?? '') : '')
                      .toString();
                  final text = (msg is Map ? (msg['text'] ?? '') : '')
                      .toString();
                  return Card(
                    child: ListTile(
                      title: Text(text.isEmpty ? '(no text)' : text),
                      subtitle: Text('$from • $kind'),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatCtl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendChat(),
                  decoration: const InputDecoration(
                    hintText: 'Message…',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: _sending ? null : _sendChat,
                child: _sending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
