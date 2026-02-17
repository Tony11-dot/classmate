import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'assignments_controller.dart';
import 'assignments_detail_sheet.dart';
import 'assignments_create_sheet.dart';

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(assignmentsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(assignmentsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(assignmentsProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Assignments',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        showDragHandle: true,
                        builder: (_) => const AssignmentsCreateSheet(),
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (st.loading) ...[
                const SizedBox(height: 24),
                const Center(child: CircularProgressIndicator()),
              ] else if (st.error != null) ...[
                const SizedBox(height: 12),
                Text(st.error!, style: const TextStyle(color: Colors.red)),
              ] else if (st.items.isEmpty) ...[
                const SizedBox(height: 24),
                const Text('No assignments yet. Tap + to create one.'),
              ] else ...[
                const SizedBox(height: 12),
                for (final a in st.items) ...[
                  _AssignmentCard(
                    title: a.title,
                    subtitle: a.description ?? 'No description',
                    meta: [
                      if (a.grade != null) 'Grade ${a.grade}',
                      if (a.subjectId != null) a.subjectId!,
                    ].join(' • '),
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) => AssignmentDetailSheet(
                        assignmentId: a.id,
                        title: a.title,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String meta;
  final VoidCallback onTap;

  const _AssignmentCard({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      color: Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  meta,
                  style: TextStyle(color: Theme.of(context).hintColor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
