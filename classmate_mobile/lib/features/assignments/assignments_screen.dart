import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';

final apiProvider = Provider<Api>((ref) => Api());

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});

  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  String? classroomId;
  List<dynamic> classrooms = [];
  List<dynamic> assignments = [];
  bool loading = true;
  String? err;

  @override
  void initState() {
    super.initState();
    Future.microtask(load);
  }

  Future<void> load() async {
    setState(() { loading = true; err = null; });
    final api = ref.read(apiProvider);

    try {
      final cls = await api.getAny('/classrooms');
      classrooms = (cls is List) ? cls : const [];

      classroomId ??= (classrooms.isNotEmpty ? (classrooms[0] as Map)['id']?.toString() : null);

      if (classroomId != null) {
        final a = await api.getAny('/assignments?classroomId=$classroomId');
        assignments = (a is List) ? a : const [];
      } else {
        assignments = const [];
      }
    } on ApiException catch (e) {
      err = e.message;
    } catch (e) {
      err = e.toString();
    } finally {
      if (mounted) setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignments', style: TextStyle(fontWeight: FontWeight.w900))),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (err != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x33FF0000)),
                ),
                child: Text(err!, style: const TextStyle(fontSize: 13)),
              ),

            Row(
              children: [
                const Text('Classroom:', style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: classroomId,
                    hint: const Text('Pick classroom'),
                    items: classrooms.map((c) {
                      final m = (c is Map) ? c : <String, dynamic>{};
                      final id = (m['id'] ?? '').toString();
                      final title = (m['title'] ?? m['name'] ?? 'Classroom').toString();
                      return DropdownMenuItem(value: id, child: Text(title, overflow: TextOverflow.ellipsis));
                    }).toList(),
                    onChanged: (v) async {
                      if (v == null || v.isEmpty) return;
                      setState(() { classroomId = v; });
                      await load();
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (loading) const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text('Loading…', style: TextStyle(fontSize: 13, color: Colors.black54)),
            ),

            const SizedBox(height: 8),

            ...assignments.map((a) {
              final m = (a is Map) ? a : <String, dynamic>{};
              final title = (m['title'] ?? 'Assignment').toString();
              final due = (m['dueAt'] ?? m['due'] ?? '').toString();
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0x22000000)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    if (due.isNotEmpty) const SizedBox(height: 6),
                    if (due.isNotEmpty) Text('Due: $due', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
