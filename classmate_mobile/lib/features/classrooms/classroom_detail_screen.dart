import 'package:flutter/material.dart';

class ClassroomDetailScreen extends StatefulWidget {
  const ClassroomDetailScreen({super.key, required this.title});
  final String title;

  @override
  State<ClassroomDetailScreen> createState() => _ClassroomDetailScreenState();
}

class _ClassroomDetailScreenState extends State<ClassroomDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabs = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: TabBar(
          controller: tabs,
          tabs: const [
            Tab(text: 'Chat'),
            Tab(text: 'Assignments'),
            Tab(text: 'Meetings'),
            Tab(text: 'Solutions'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabs,
        children: const [
          _ChatStub(),
          _AssignmentsStub(),
          _MeetingsStub(),
          _SolutionsStub(),
        ],
      ),
    );
  }
}

class _ChatStub extends StatelessWidget {
  const _ChatStub();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const [
              _Bubble(left: true, text: 'Reminder: quiz tomorrow.'),
              _Bubble(left: false, text: 'Got it ✅'),
              _Bubble(
                left: true,
                text:
                    'Send your questions here (images/voice supported in pilot).',
              ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.image_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mic_none_rounded),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Message…',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {},
                  child: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.left, required this.text});
  final bool left;
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: left ? cs.surfaceContainerHighest : cs.primaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text),
      ),
    );
  }
}

class _AssignmentsStub extends StatelessWidget {
  const _AssignmentsStub();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Worksheet 5'),
            subtitle: Text('Due: Thursday'),
          ),
        ),
        Card(
          child: ListTile(
            title: Text('Chapter 3 Quiz Prep'),
            subtitle: Text('Due: Sunday'),
          ),
        ),
      ],
    );
  }
}

class _MeetingsStub extends StatelessWidget {
  const _MeetingsStub();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Zoom Review'),
            subtitle: Text('Wed 18:00'),
          ),
        ),
      ],
    );
  }
}

class _SolutionsStub extends StatelessWidget {
  const _SolutionsStub();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Solutions tab: shows classroom-specific solutions + global subject feed.',
      ),
    );
  }
}
