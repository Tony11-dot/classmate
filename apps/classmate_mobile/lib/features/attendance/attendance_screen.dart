import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../ui/liquid_dropdown.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime? day;
  String subject = 'All';
  String teacher = 'All';

  final subjects = const ['All', 'Math', 'Physics', 'English', 'CS'];
  final teachers = const ['All', 'Mr. Smith', 'Ms. Lina', 'Dr. Cohen'];

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE • d/M');

    // TODO: API-driven attendance rows
    final rows = <Map<String, String>>[
      {
        'day': '2026-02-10',
        'subject': 'Math',
        'teacher': 'Mr. Smith',
        'status': 'Present',
      },
      {
        'day': '2026-02-10',
        'subject': 'Physics',
        'teacher': 'Dr. Cohen',
        'status': 'Late',
      },
      {
        'day': '2026-02-09',
        'subject': 'English',
        'teacher': 'Ms. Lina',
        'status': 'Absent',
      },
    ];

    final filtered = rows.where((r) {
      final okSubject = subject == 'All' || r['subject'] == subject;
      final okTeacher = teacher == 'All' || r['teacher'] == teacher;
      final okDay =
          day == null || r['day'] == DateFormat('yyyy-MM-dd').format(day!);
      return okSubject && okTeacher && okDay;
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: day ?? DateTime.now(),
                    firstDate: DateTime(2025, 1, 1),
                    lastDate: DateTime(2030, 12, 31),
                  );
                  if (picked != null) setState(() => day = picked);
                },
                icon: const Icon(Icons.today),
                label: Text(day == null ? 'Any day' : df.format(day!)),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: day == null ? null : () => setState(() => day = null),
              icon: const Icon(Icons.close),
              tooltip: 'Clear day',
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: LiquidDropdown<String>(
                value: subject,
                label: 'Subject',
                items: [
                  for (final s in subjects)
                    DropdownMenuItem(
                      value: s,
                      child: Text(s, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => subject = v ?? 'All'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: LiquidDropdown<String>(
                value: teacher,
                label: 'Teacher',
                items: [
                  for (final t in teachers)
                    DropdownMenuItem(
                      value: t,
                      child: Text(t, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) => setState(() => teacher = v ?? 'All'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        for (final r in filtered)
          Card(
            child: ListTile(
              title: Text('${r['subject']} • ${r['status']}'),
              subtitle: Text('${r['teacher']} • ${r['day']}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('TODO: open detailed attendance record'),
                  ),
                );
              },
            ),
          ),
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: Text(
                'No results for selected filters',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
      ],
    );
  }
}
