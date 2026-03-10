import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SolutionsSubjectScreen extends StatefulWidget {
  const SolutionsSubjectScreen({super.key});

  @override
  State<SolutionsSubjectScreen> createState() => _SolutionsSubjectScreenState();
}

class _SolutionsSubjectScreenState extends State<SolutionsSubjectScreen> {
  final TextEditingController _searchCtl = TextEditingController();

  static const List<String> _subjects = <String>[
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Computer Science',
    'Arabic',
    'Hebrew',
    'English',
    'History',
    'Geography',
    'Religion',
  ];

  @override
  void dispose() {
    _searchCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final q = _searchCtl.text.trim().toLowerCase();
    final items = _subjects
        .where((s) => q.isEmpty || s.toLowerCase().contains(q))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose subject')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          TextField(
            controller: _searchCtl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search subjects',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.45),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final subject in items) ...[
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.push(
                '/solutions/books',
                extra: <String, dynamic>{'subject': subject},
              ),
              child: Ink(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: cs.surfaceContainerLow.withValues(alpha: 0.8),
                  border: Border.all(
                    color: cs.outlineVariant.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        subject,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
