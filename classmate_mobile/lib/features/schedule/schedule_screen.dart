import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/api_client.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime day = DateTime.now();
  bool apiOk = false;

  @override
  void initState() {
    super.initState();
    _ping();
  }

  Future<void> _ping() async {
    try {
      final r = await ApiClient.instance.get('/health');
      setState(() => apiOk = (r.data is Map) && (r.data['ok'] == true));
    } catch (_) {
      setState(() => apiOk = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2032, 12, 31),
      initialDate: day,
    );
    if (picked != null) setState(() => day = picked);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEEE - d/M/yyyy');
    final title = df.format(day);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () =>
                    setState(() => day = day.subtract(const Duration(days: 1))),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _pickDate,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () =>
                    setState(() => day = day.add(const Duration(days: 1))),
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),

          _Card(
            child: Row(
              children: [
                Icon(apiOk ? Icons.check_circle : Icons.error_outline),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(apiOk ? 'API connected' : 'API not reachable'),
                ),
                TextButton(onPressed: _ping, child: const Text('Retry')),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              children: const [
                _ScheduleTile(
                  time: '08:00',
                  title: 'Math',
                  subtitle: 'Room 203 • Homework check',
                ),
                _ScheduleTile(
                  time: '09:50',
                  title: 'English',
                  subtitle: 'Room 114 • Reading',
                ),
                _ScheduleTile(
                  time: '11:20',
                  title: 'Physics',
                  subtitle: 'Lab • Experiment',
                ),
                _ScheduleTile(
                  time: '13:10',
                  title: 'CS',
                  subtitle: 'Room 305 • Project work',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );
  }
}

class _ScheduleTile extends StatelessWidget {
  const _ScheduleTile({
    required this.time,
    required this.title,
    required this.subtitle,
  });
  final String time;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
