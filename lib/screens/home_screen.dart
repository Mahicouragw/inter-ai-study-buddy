import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import 'exam_answer_screen.dart';
import 'quiz_home_screen.dart';
import 'settings_screen.dart';
import 'subjects_screen.dart';
import 'tutor_screen.dart';
import 'vocab_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inter AI Study Buddy 📚'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Year selector ----
          Text('Telangana Intermediate • English Medium',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(children: [
            ChoiceChip(
              label: const Text('Inter 1st Year'),
              avatar: state.year == 1 ? const Icon(Icons.check, size: 18) : null,
              selected: state.year == 1,
              onSelected: (_) => state.setYear(1),
            ),
            const SizedBox(width: 10),
            ChoiceChip(
              label: const Text('Inter 2nd Year'),
              avatar: state.year == 2 ? const Icon(Icons.check, size: 18) : null,
              selected: state.year == 2,
              onSelected: (_) => state.setYear(2),
            ),
          ]),
          const SizedBox(height: 8),
          if (!state.hasKey)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: ListTile(
                leading: const Icon(Icons.key_outlined),
                title: const Text('Unlock the live AI Tutor (free)'),
                subtitle: const Text(
                    'Add a free Google Gemini key in Settings to chat, ELI5 & generate answers.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ),
          const SizedBox(height: 8),
          // ---- Feature grid ----
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _FeatureCard(
                emoji: '📘',
                title: 'Subjects & Questions',
                subtitle: 'Chapters, 2M / 5M / 10M Q&A, official PDFs',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SubjectsScreen())),
              ),
              _FeatureCard(
                emoji: '🤖',
                title: 'AI Tutor & ELI5',
                subtitle: 'Ask doubts by typing or talking 🎤',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TutorScreen())),
              ),
              _FeatureCard(
                emoji: '🎯',
                title: 'Play Quizzes',
                subtitle: 'MCQ quizzes + AI-generated questions',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const QuizHomeScreen())),
              ),
              _FeatureCard(
                emoji: '✍️',
                title: 'Exam Answers',
                subtitle: 'Model answers for 2, 5 & 10 marks',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ExamAnswerScreen())),
              ),
              _FeatureCard(
                emoji: '🔤',
                title: 'Vocabulary',
                subtitle: '60 words • Telugu meanings • flashcards',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const VocabScreen())),
              ),
              _FeatureCard(
                emoji: '⚙️',
                title: 'Settings',
                subtitle: 'Gemini key, voice, data sources',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }
}
