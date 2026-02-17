import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'assignments_controller.dart';
import 'assignments_submit_sheet.dart';

class AssignmentDetailSheet extends ConsumerWidget {
  final String assignmentId;
  final String title;

  const AssignmentDetailSheet({
    super.key,
    required this.assignmentId,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsAsync = ref.watch(assignmentSubmissionsProvider(assignmentId));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 6,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      showDragHandle: true,
                      builder: (_) =>
                          AssignmentSubmitSheet(assignmentId: assignmentId),
                    );
                    ref.invalidate(assignmentSubmissionsProvider(assignmentId));
                  },
                  icon: const Icon(Icons.upload),
                  label: const Text('Submit'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: subsAsync.when(
                data: (subs) {
                  if (subs.isEmpty) {
                    return const Center(child: Text('No submissions yet.'));
                  }
                  return ListView.separated(
                    itemCount: subs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final s = subs[i];
                      return Material(
                        borderRadius: BorderRadius.circular(18),
                        color: Theme.of(context).cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Student: ${s.studentUserId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if ((s.text ?? '').isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(s.text!),
                              ],
                              if ((s.mediaUrl ?? '').isNotEmpty) ...[
                                const SizedBox(height: 10),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.network(
                                    s.mediaUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
