import 'package:flutter/material.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool notify = true;
  String freq = 'Daily';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text(
              'Performance overview',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text('Attendance • assignments • grades • streaks'),
            trailing: FilledButton(
              onPressed: () {},
              child: const Text('Generate insight'),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: SwitchListTile(
            value: notify,
            onChanged: (v) => setState(() => notify = v),
            title: const Text('AI insights notifications'),
            subtitle: const Text('Let AI push helpful feedback automatically'),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            title: const Text('Insight frequency'),
            subtitle: Text(freq),
            trailing: DropdownButton<String>(
              value: freq,
              items: const [
                DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                DropdownMenuItem(
                  value: 'Only on request',
                  child: Text('Only on request'),
                ),
              ],
              onChanged: (v) => setState(() => freq = v ?? 'Daily'),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Card(
          child: ListTile(
            title: Text(
              'Next step',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'Wire real analytics + AI brain outputs from backend.',
            ),
          ),
        ),
      ],
    );
  }
}
