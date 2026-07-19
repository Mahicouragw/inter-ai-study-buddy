import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import 'quiz_screen.dart';
import 'subjects_screen.dart';

/// Pick a subject to start its MCQ quiz.
class QuizHomeScreen extends StatelessWidget {
  const QuizHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final subjects = subjectsForYear(state.year);
    return Scaffold(
      appBar: AppBar(title: const Text('Play Quizzes 🎯')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          for (final s in subjects)
            Card(
              child: ListTile(
                leading: Text(s.emoji, style: const TextStyle(fontSize: 30)),
                title: Text(s.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                    '${s.mcqs.length} built-in questions • Best: ${state.bestScores['${s.id}_quiz'] ?? 0}%'),
                trailing: FilledButton.tonal(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QuizScreen(subject: s)),
                  ),
                  child: const Text('Start'),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              state.hasKey
                  ? '✨ Inside every quiz you can also generate 5 fresh AI questions with your Gemini key.'
                  : 'Tip: add a free Gemini key in Settings to generate unlimited new quiz questions.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
