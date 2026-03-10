import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SolutionsPagesScreen extends StatefulWidget {
  const SolutionsPagesScreen({super.key});

  @override
  State<SolutionsPagesScreen> createState() => _SolutionsPagesScreenState();
}

class _SolutionsPagesScreenState extends State<SolutionsPagesScreen> {
  final TextEditingController _pageCtl = TextEditingController(text: '1');
  final TextEditingController _questionCtl = TextEditingController(text: '1');

  @override
  void dispose() {
    _pageCtl.dispose();
    _questionCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final data = extra is Map
        ? Map<String, dynamic>.from(extra)
        : <String, dynamic>{};
    final subject = (data['subject'] ?? 'Subject').toString();
    final book = (data['book'] ?? 'Book').toString();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(book)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: cs.surfaceContainerLow.withValues(alpha: 0.88),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  book,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _pageCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Page',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    filled: true,
                    fillColor: cs.surface,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _questionCtl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Question number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    filled: true,
                    fillColor: cs.surface,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      '/solutions/questions',
                      extra: <String, dynamic>{
                        'subject': subject,
                        'book': book,
                        'page': _pageCtl.text.trim(),
                        'question': _questionCtl.text.trim(),
                      },
                    ),
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Apply and view solutions'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
