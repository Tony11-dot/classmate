import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  child: Text(
                    'TA',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tony Aboud',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ClassMate Founder • CS/CE student at Technion',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: const [
              ListTile(
                leading: Icon(Icons.sports_tennis),
                title: Text('Interests'),
                subtitle: Text('Tennis • Physics • Mathematics • AI'),
              ),
              Divider(height: 1),
              ListTile(
                leading: Icon(Icons.school),
                title: Text('Mission'),
                subtitle: Text(
                  'A modern school OS that feels clean, fast, and actually useful.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
