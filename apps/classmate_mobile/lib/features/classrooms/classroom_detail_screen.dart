import 'package:flutter/material.dart';

class ClassroomDetailScreen extends StatelessWidget {
  final String classroomId;
  final String? title;
  const ClassroomDetailScreen({super.key, required this.classroomId, this.title});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title ?? 'Classroom'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Chat'),
              Tab(text: 'Assignments'),
              Tab(text: 'Meetings'),
              Tab(text: 'Solutions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PlaceholderTab(
              title: 'Chat',
              subtitle: 'Next: connect to classroom messages API',
              debug: 'classroomId=$classroomId',
            ),
            _PlaceholderTab(
              title: 'Assignments',
              subtitle: 'Next: connect to assignments list for this classroom',
              debug: 'classroomId=$classroomId',
            ),
            _PlaceholderTab(
              title: 'Meetings',
              subtitle: 'Next: connect to schedule/meetings for this classroom',
              debug: 'classroomId=$classroomId',
            ),
            _PlaceholderTab(
              title: 'Solutions',
              subtitle: 'Next: connect to solutions feed filtered by classroom subjects',
              debug: 'classroomId=$classroomId',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final String debug;
  const _PlaceholderTab({required this.title, required this.subtitle, required this.debug});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: t.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(debug, style: t.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
