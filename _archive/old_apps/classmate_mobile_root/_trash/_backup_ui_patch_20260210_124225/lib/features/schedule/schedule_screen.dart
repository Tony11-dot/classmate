import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime day = DateTime.now();

  void _pick() async {
    final d = await showDatePicker(
      context: context,
      initialDate: day,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (d != null) setState(() => day = d);
  }

  @override
  Widget build(BuildContext context) {
    final title = DateFormat("EEEE - d/M/yyyy").format(day);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () =>
                  setState(() => day = day.subtract(const Duration(days: 1))),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _pick,
                child: Center(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () =>
                  setState(() => day = day.add(const Duration(days: 1))),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _lesson(context, 'Computer Science', '10:00–10:45', 'Room 201'),
        _lesson(context, 'Math', '11:00–11:45', 'Room 105'),
      ],
    );
  }

  Widget _lesson(BuildContext c, String name, String time, String room) {
    return Card(
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('$time • $room'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => c.go('/lesson'),
      ),
    );
  }
}
