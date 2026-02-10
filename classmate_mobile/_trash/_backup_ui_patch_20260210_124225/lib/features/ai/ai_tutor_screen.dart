import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "../../ui/adaptive.dart";
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../demo/demo_store.dart';

class AITutorScreen extends StatefulWidget {
  const AITutorScreen({super.key});
  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> {
  final ctrl = TextEditingController();
  final msgs = <(bool me, String text)>[
    (
      false,
      "Hey Tony — I’m your Classmate AI Tutor.\nTell me what you want to study and I’ll guide you step-by-step.",
    ),
  ];

  void send() {
    final t = ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      msgs.add((true, t));
      msgs.add((false, DemoStore.fakeTutorReply(t)));
      ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: msgs.length,
            itemBuilder: (_, i) {
              final m = msgs[i];
              final align = m.$1
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start;
              final bg = m.$1
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest;
              return Column(
                crossAxisAlignment: align,
                children: [
                  ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 340),
                        child: AdaptiveCard(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: bg,
                            ),
                            child: Text(m.$2),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 160.ms)
                      .slideY(begin: 0.06, end: 0),
                  const SizedBox(height: 10),
                ],
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  onSubmitted: (_) => send(),
                  decoration: const InputDecoration(hintText: 'Ask the tutor…'),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(onPressed: send, child: const Text('Send')),
            ],
          ),
        ),
      ],
    );
  }
}
