import 'package:flutter/material.dart';
import '../../core/session.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? email;
  String? name;
  String? role;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await Session.getEmail();
    final n = await Session.getName();
    final r = await Session.getRole();
    if (!mounted) return;
    setState(() {
      email = e;
      name = n;
      role = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('ClassMate')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome${name != null && name!.isNotEmpty ? ', $name' : ''}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              '${email ?? ''} ${role != null && role!.isNotEmpty ? '• $role' : ''}',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 18),

            // This is where we’ll place: schedule card + classrooms shortcuts + announcements preview.
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Next: Today schedule + announcements + classrooms preview.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
