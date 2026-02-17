import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_client.dart';
import 'assignments_api.dart';

class AssignmentSubmitSheet extends ConsumerStatefulWidget {
  final String assignmentId;
  const AssignmentSubmitSheet({super.key, required this.assignmentId});

  @override
  ConsumerState<AssignmentSubmitSheet> createState() =>
      _AssignmentSubmitSheetState();
}

class _AssignmentSubmitSheetState extends ConsumerState<AssignmentSubmitSheet> {
  final text = TextEditingController();
  final mediaUrl = TextEditingController();
  bool saving = false;
  String? err;

  @override
  void dispose() {
    text.dispose();
    mediaUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Submit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: text,
              decoration: const InputDecoration(labelText: 'Text'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: mediaUrl,
              decoration: const InputDecoration(
                labelText: 'Image URL (temporary)',
              ),
            ),
            if (err != null) ...[
              const SizedBox(height: 10),
              Text(err!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        setState(() {
                          saving = true;
                          err = null;
                        });
                        try {
                          final nav = Navigator.of(context);
                          final api = AssignmentsApi(ApiClient.instance);
                          await api.submit(
                            assignmentId: widget.assignmentId,
                            text: text.text.trim().isEmpty
                                ? null
                                : text.text.trim(),
                            mediaUrl: mediaUrl.text.trim().isEmpty
                                ? null
                                : mediaUrl.text.trim(),
                          );
                          if (mounted) nav.pop();
                        } catch (e) {
                          setState(() => err = e.toString());
                        } finally {
                          if (mounted) setState(() => saving = false);
                        }
                      },
                child: Text(saving ? 'Submitting…' : 'Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
