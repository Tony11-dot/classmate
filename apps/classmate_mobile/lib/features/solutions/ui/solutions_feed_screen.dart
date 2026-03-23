import 'package:flutter/material.dart';
import 'package:classmate_mobile/features/solutions/ui/filter/solutions_questions_screen.dart';

class SolutionsFeedScreen extends StatelessWidget {
  const SolutionsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solutions')),
      body: const Center(child: Text('Solutions Feed Coming Next 🚀')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SolutionsQuestionsScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
