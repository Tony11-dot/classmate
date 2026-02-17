import 'package:flutter/material.dart';

import '../../ui/liquid_dropdown.dart';

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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insight frequency',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                LiquidDropdown<String>(
                  value: freq,
                  label: 'Frequency',
                  items: const [
                    DropdownMenuItem(
                      value: 'Daily',
                      child: Text('Daily', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Weekly',
                      child: Text('Weekly', overflow: TextOverflow.ellipsis),
                    ),
                    DropdownMenuItem(
                      value: 'Only on request',
                      child: Text(
                        'Only on request',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => freq = v ?? 'Daily'),
                ),
              ],
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
