import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../demo/demo_store.dart';

class ClassroomDetailScreen extends StatefulWidget {
  final String id;
  const ClassroomDetailScreen({super.key, required this.id});

  @override
  State<ClassroomDetailScreen> createState() => _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends State<ClassroomDetailScreen> {
  final msgCtrl = TextEditingController();
  final messages = <(bool me, String text)>[
    (false, 'Welcome! This is your class chat.'),
    (false, 'Teacher: Please submit the next assignment by tomorrow.'),
  ];

  void send() {
    final t = msgCtrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      messages.add((true, t));
      messages.add((false, '👍 Got it. I’ll reply in the meeting notes.'));
      msgCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = DemoStore.classrooms.firstWhere((x) => x.id == widget.id);
    final assigns = DemoStore.assignments
        .where((a) => a.classroomId == c.id)
        .toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            c.name,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
              Tab(icon: Icon(Icons.assignment_outlined), text: 'Assignments'),
              Tab(icon: Icon(Icons.video_call_outlined), text: 'Meetings'),
              Tab(icon: Icon(Icons.hub_outlined), text: 'Solutions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(14),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final m = messages[i];
                      final align = m.$1
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start;
                      final bg = m.$1
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest;
                      return Column(
                        crossAxisAlignment: align,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 340),
                            child: Card(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: bg,
                                ),
                                child: Text(m.$2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  minimum: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Photo sending: demo'),
                              ),
                            ),
                        icon: const Icon(Icons.photo_outlined),
                      ),
                      IconButton(
                        onPressed: () =>
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voice message: demo'),
                              ),
                            ),
                        icon: const Icon(Icons.mic_none_outlined),
                      ),
                      Expanded(
                        child: TextField(
                          controller: msgCtrl,
                          onSubmitted: (_) => send(),
                          decoration: const InputDecoration(
                            hintText: 'Message…',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(onPressed: send, child: const Text('Send')),
                    ],
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                for (final a in assigns)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.assignment_outlined),
                      title: Text(
                        a.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      subtitle: Text('Due: ${a.due} • Reward: +${a.reward}'),
                      trailing: a.submitted
                          ? const Icon(Icons.check_circle_rounded)
                          : null,
                      onTap: () {
                        setState(() => a.submitted = true);
                        DemoStore.user.points += a.reward;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Submitted. +${a.reward} points'),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(14),
              children: const [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.video_call_outlined),
                    title: Text(
                      'Weekly lesson review',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text('Thu 18:00 • Online (demo)'),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.video_call_outlined),
                    title: Text(
                      'Exam prep session',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: Text('Sun 20:00 • Online (demo)'),
                    trailing: Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const Text(
                  'Solutions Network',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.group_outlined),
                    title: const Text(
                      'Ask classmates',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: const Text(
                      'Post a question and get step-by-step help (demo).',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Posting: demo')),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.auto_fix_high_outlined),
                    title: const Text(
                      'AI-guided solution',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    subtitle: const Text(
                      'Tutor generates a path + quick quiz (demo).',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/solutions'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
