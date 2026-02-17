import 'package:flutter/material.dart';
import '../../demo/demo_data.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});
  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  @override
  Widget build(BuildContext context) {
    final list = DemoStore.assignments;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'To do',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        for (final a in list)
          Card(
            child: ListTile(
              title: Text(
                a.title,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('Due: ${a.due} • Reward: +${a.reward}'),
              trailing: a.submitted
                  ? const Icon(Icons.check_circle_rounded)
                  : FilledButton(
                      onPressed: () {
                        setState(() {
                          a.submitted = true;
                          DemoStore.user.points += a.reward;
                          DemoStore.notifications.insert(
                            0,
                            DemoNotification(
                              id: DateTime.now().millisecondsSinceEpoch
                                  .toString(),
                              title: "Submitted",
                              body:
                                  "You earned +${a.reward} points for ${a.title}.",
                              time: "now",
                            ),
                          );
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Submitted! +${a.reward} points'),
                          ),
                        );
                      },
                      child: const Text('Submit'),
                    ),
            ),
          ),
      ],
    );
  }
}
