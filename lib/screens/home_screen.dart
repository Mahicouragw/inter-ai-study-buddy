import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import 'bookmarks_screen.dart';
import 'exam_answer_screen.dart';
import 'flashcards_screen.dart';
import 'progress_screen.dart';
import 'quiz_home_screen.dart';
import 'search_screen.dart';
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
          const SizedBox(height: 10),

          // ---- Study dashboard ----
          _DashboardCard(state: state),
          const SizedBox(height: 6),

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
                subtitle: 'Chapters, 2M / 5M / 10M Q&A, official TSBIE PDFs',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SubjectsScreen())),
              ),
              _FeatureCard(
                emoji: '🃏',
                title: 'Flashcards',
                subtitle: 'Flip-card revision • priority & saved sets',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FlashcardsSubjectPicker())),
              ),
              _FeatureCard(
                emoji: '🔍',
                title: 'Search',
                subtitle: 'Find any question across all subjects',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchScreen())),
              ),
              _FeatureCard(
                emoji: '🔖',
                title: 'Saved Questions',
                subtitle: 'Your bookmarked tough questions',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const BookmarksScreen())),
              ),
              _FeatureCard(
                emoji: '📊',
                title: 'My Progress',
                subtitle: 'Streak, exam countdown, learned %',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ProgressScreen())),
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
                emoji: '🤖',
                title: 'AI Tutor & ELI5',
                subtitle: 'Ask doubts by typing or talking 🎤',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const TutorScreen())),
              ),
              _FeatureCard(
                emoji: '🔤',
                title: 'Vocabulary',
                subtitle: 'Telugu meanings • flashcards',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const VocabScreen())),
              ),
              _FeatureCard(
                emoji: '⚙️',
                title: 'Settings',
                subtitle: 'Gemini key, voice, theme, official links',
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

/// Streak 🔥 + exam countdown ⏳ + year progress, all TalkBack-announced.
class _DashboardCard extends StatelessWidget {
  final AppState state;
  const _DashboardCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final subjects = subjectsForYear(state.year);
    var total = 0;
    var learned = 0;
    for (final s in subjects) {
      total += s.shortAnswers.length + s.essays.length;
      learned += state.learnedCountFor(s.id);
    }
    final pct = total == 0 ? 0.0 : learned / total;
    final days = state.daysToExam;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Semantics(
          label: 'Study dashboard. Streak ${state.studyStreak} days. '
              '${days == null ? "Exam season." : "$days days to examinations."} '
              '${(pct * 100).round()} percent of Inter ${state.year == 1 ? "1st" : "2nd"} year questions learned.',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 6, children: [
              Chip(
                avatar: const Text('🔥'),
                label: Text('${state.studyStreak} day streak'),
              ),
              Chip(
                avatar: const Text('⏳'),
                label: Text(days == null
                    ? 'Exam season 🎉'
                    : '$days days to exams'),
              ),
            ]),
            const SizedBox(height: 10),
            Text(
              'Inter ${state.year == 1 ? "1st" : "2nd"} year: $learned / $total questions learned '
              '(${(pct * 100).round()}%)',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: pct, minHeight: 8),
          ]),
        ),
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
