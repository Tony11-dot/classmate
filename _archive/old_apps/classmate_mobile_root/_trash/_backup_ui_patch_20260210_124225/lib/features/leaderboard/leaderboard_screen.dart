import 'package:flutter/material.dart';
import '../../demo/demo_data.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = DemoStore.user.points;
    final items = [
      ("Maya", me + 40),
      ("Tony", me),
      ("Yousef", me - 15),
      ("Rana", me - 30),
    ];

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'Weekly leaderboard',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < items.length; i++)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('#${i + 1}')),
              title: Text(
                items[i].$1,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              trailing: Text(
                '${items[i].$2}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
      ],
    );
  }
}
