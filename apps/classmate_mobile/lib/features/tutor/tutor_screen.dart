import 'package:flutter/material.dart';
import '../ai_tutor/ai_tutor_api.dart';
import '../../api/api_client.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  bool _sending = false;

  final controller = TextEditingController();
  final List<Map<String, String>> messages = [];

  Future<void> sendPreset(String text) async {
    controller.text = text;
    await send();
  }

  Future<void> send() async {
    if (_sending) return;

    final text = controller.text.trim();
    if (text.isEmpty) return;

    controller.clear();

    setState(() {
      messages.add({"role": "user", "text": text});
      _sending = true;
      messages.add({"role": "assistant", "text": "…"});
    });

    final api = AiTutorApi(ApiClient.instance);

    try {
      // build payload from existing chat (skip the typing bubble)
      final payload = messages
          .where((m) =>
              (m["role"] == "user" || m["role"] == "assistant") &&
              (m["text"] ?? "").toString().trim().isNotEmpty &&
              m["text"] != "…")
          .map((m) => {
                "role": (m["role"] ?? "user").toString(),
                "content": (m["text"] ?? "").toString(),
              })
          .toList();

      final reply = await api.chat(payload);

      if (!mounted) return;
      setState(() {
        messages.removeWhere((m) => m["role"] == "assistant" && m["text"] == "…");
        messages.add({"role": "assistant", "text": reply});
        _sending = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        messages.removeWhere((m) => m["role"] == "assistant" && m["text"] == "…");
        messages.add({"role": "assistant", "text": "⚠️ " + e.toString()});
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(
              "AI Tutor",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _QuickChip(
                                label: "About Tony",
                                onTap: () => sendPreset("Who is Tony Aboud? Who created ClassMate?"),
                              ),
                              _QuickChip(
                                label: "Study tips",
                                onTap: () => sendPreset("Give me 5 study tips for exams."),
                              ),
                              _QuickChip(
                                label: "Explain",
                                onTap: () => sendPreset("Explain this simply: F = ma."),
                              ),
                              _QuickChip(
                                label: "Quiz me",
                                onTap: () => sendPreset("Quiz me with 3 short questions about Newton's laws."),
                              ),
                            ],
                          ),
                        ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final m = messages[i];
                  final isUser = m["role"] == "user";

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? cs.primaryContainer
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        m["text"]!,
                        style: TextStyle(
                          color: isUser
                              ? cs.onPrimaryContainer
                              : cs.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: "Ask something...",
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: (_sending ? null : send),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
