import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SolutionsBooksScreen extends StatelessWidget {
  const SolutionsBooksScreen({super.key});

  static const Map<String, List<Map<String, String>>> _booksBySubject =
      <String, List<Map<String, String>>>{
        'Mathematics': <Map<String, String>>[
          {'title': 'Algebra Basics', 'cover': '∑'},
          {'title': 'Geometry Essentials', 'cover': '△'},
          {'title': 'Functions & Graphs', 'cover': 'ƒ'},
        ],
        'Physics': <Map<String, String>>[
          {'title': 'Mechanics', 'cover': '⚛'},
          {'title': 'Electricity', 'cover': '⚡'},
          {'title': 'Waves & Optics', 'cover': '〰'},
        ],
        'Chemistry': <Map<String, String>>[
          {'title': 'Atoms & Bonds', 'cover': '🧪'},
          {'title': 'Reactions', 'cover': '⚗'},
        ],
        'Biology': <Map<String, String>>[
          {'title': 'Cells & Systems', 'cover': '🧬'},
          {'title': 'Genetics', 'cover': '🌿'},
        ],
        'Computer Science': <Map<String, String>>[
          {'title': 'Intro to Programming', 'cover': '</>'},
          {'title': 'Data Structures', 'cover': '{ }'},
        ],
      };

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final data = extra is Map
        ? Map<String, dynamic>.from(extra)
        : <String, dynamic>{};
    final subject = (data['subject'] ?? 'Subject').toString();

    final books =
        _booksBySubject[subject] ??
        <Map<String, String>>[
          {'title': '$subject Book 1', 'cover': '📘'},
          {'title': '$subject Book 2', 'cover': '📙'},
          {'title': '$subject Book 3', 'cover': '📗'},
        ];

    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(subject)),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          final title = (book['title'] ?? 'Book').toString();
          final cover = (book['cover'] ?? '📘').toString();

          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => context.push(
              '/solutions/pages',
              extra: <String, dynamic>{'subject': subject, 'book': title},
            ),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: cs.surfaceContainerLow.withValues(alpha: 0.88),
                border: Border.all(
                  color: cs.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              cs.primary.withValues(alpha: 0.22),
                              cs.secondary.withValues(alpha: 0.12),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cover,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to choose page and question',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
