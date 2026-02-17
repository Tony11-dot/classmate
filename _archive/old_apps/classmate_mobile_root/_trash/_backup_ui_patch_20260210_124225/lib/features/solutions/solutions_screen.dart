import 'package:flutter/material.dart';
import '../../demo/demo_store.dart';

class SolutionsScreen extends StatefulWidget {
  const SolutionsScreen({super.key});
  @override
  State<SolutionsScreen> createState() => _SolutionsScreenState();
}

class _SolutionsScreenState extends State<SolutionsScreen> {
  final steps = <(String title, String body, int reward, bool done)>[
    (
      'Quick win: Submit one assignment',
      'Pick the easiest task and submit to gain points fast.',
      20,
      false,
    ),
    ('Physics prep', '12 minutes formulas + 6 practice questions.', 15, false),
    (
      'Math sprint',
      'Derivative drills: 10 questions, check answers.',
      18,
      false,
    ),
    (
      'Teacher feedback loop',
      'Ask tutor for 3 mistakes you make most.',
      10,
      false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solutions')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text(
            'Guided plan (demo)',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < steps.length; i++)
            Card(
              child: ListTile(
                leading: steps[i].$4
                    ? const Icon(Icons.check_circle_rounded)
                    : const Icon(Icons.radio_button_unchecked),
                title: Text(
                  steps[i].$1,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                subtitle: Text('${steps[i].$2}\nReward: +${steps[i].$3}'),
                isThreeLine: true,
                trailing: steps[i].$4
                    ? null
                    : FilledButton(
                        onPressed: () {
                          setState(() {
                            steps[i] = (
                              steps[i].$1,
                              steps[i].$2,
                              steps[i].$3,
                              true,
                            );
                            DemoStore.user.points += steps[i].$3;
                            DemoStore.notifications.insert(
                              0,
                              DemoNotification(
                                id: DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                                title: 'Solution completed',
                                body:
                                    'You earned +${steps[i].$3} points: ${steps[i].$1}',
                                time: 'now',
                              ),
                            );
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Completed! +${steps[i].$3} points',
                              ),
                            ),
                          );
                        },
                        child: const Text('Complete'),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
