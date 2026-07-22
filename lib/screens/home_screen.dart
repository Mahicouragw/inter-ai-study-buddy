import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
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
import 'accessibility_screen.dart';
import 'license_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = SupabaseConfig.client.auth.currentUser;
    final isOR = state.geminiKey.trim().startsWith('sk-or-');
    
    return Scaffold(
      appBar: AppBar(
        title: Semantics(header: true, child: Text('Inter AI Study Buddy 📚 ${isOR ? "• Claude Opus" : ""}')),
        actions: [
          Semantics(
            button: true,
            label: 'Accessibility guide, TalkBack help',
            child: IconButton(
              tooltip: 'TalkBack Guide',
              icon: const Icon(Icons.accessibility_new),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessibilityScreen())),
            ),
          ),
          Semantics(
            button: true,
            label: 'Settings',
            child: IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          ),
          Semantics(
            button: true,
            label: 'Logout, sign out from account',
            child: IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await SupabaseConfig.client.auth.signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: Semantics(
          label: 'Navigation drawer',
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                decoration: const BoxDecoration(color: Colors.deepPurple),
                accountName: Text(user?.userMetadata?['username'] ?? user?.email?.split('@')[0] ?? 'Student'),
                accountEmail: Text(user?.email ?? 'No email - offline mode'),
                currentAccountPicture: Semantics(
                  label: 'User avatar',
                  child: const CircleAvatar(child: Icon(Icons.person, size: 30)),
                ),
              ),
              Semantics(button: true, label: 'Home dashboard', child: ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Home'), onTap: () => Navigator.pop(context))),
              Semantics(button: true, label: 'Subjects and questions', child: ListTile(leading: const Icon(Icons.book_outlined), title: const Text('Subjects'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectsScreen())); })),
              Semantics(button: true, label: 'AI Tutor with Claude Opus', child: ListTile(leading: const Icon(Icons.smart_toy_outlined), title: Text('AI Tutor ${isOR ? "• Opus/Sonnet" : ""}'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const TutorScreen())); })),
              Semantics(button: true, label: 'Exam answer writer', child: ListTile(leading: const Icon(Icons.edit_note_outlined), title: const Text('Exam Answers'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamAnswerScreen())); })),
              const Divider(),
              Semantics(button: true, label: 'TalkBack and accessibility guide', child: ListTile(leading: const Icon(Icons.accessibility_new), title: const Text('TalkBack Guide ♿'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessibilityScreen())); })),
              Semantics(button: true, label: 'Licenses and privacy', child: ListTile(leading: const Icon(Icons.description_outlined), title: const Text('Licenses & Navigation'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const LicenseScreen())); })),
              Semantics(button: true, label: 'Settings for API key', child: ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())); })),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User info + Year selector
          Semantics(
            label: 'User logged in as ${user?.userMetadata?['username'] ?? "student"} with email ${user?.email ?? "offline"}',
            child: Card(
              color: Colors.deepPurple.shade50,
              child: ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text('Welcome, ${user?.userMetadata?['username'] ?? user?.email?.split('@')[0] ?? "Student"}! 👋'),
                subtitle: Text(user?.email ?? 'Offline mode - Supabase not connected'),
                trailing: isOR ? Chip(label: const Text('Opus', style: TextStyle(fontSize: 10)), backgroundColor: Colors.green.shade100) : null,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Telangana Intermediate • English Medium • Claude Opus/Sonnet via OpenRouter',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Semantics(
            label: 'Year selector, Inter 1st year or 2nd year',
            child: Row(children: [
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
          ),
          const SizedBox(height: 10),

          // Dashboard
          _DashboardCard(state: state),
          const SizedBox(height: 6),

          if (!state.hasKey)
            Semantics(
              label: 'Unlock live AI Tutor, needs OpenRouter or Gemini key',
              child: Card(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.key_outlined),
                  title: const Text('Unlock live AI Tutor (Claude Opus)'),
                  subtitle: const Text('Add OpenRouter key (sk-or-v1-...) for Claude Opus/Sonnet or Gemini key in Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Feature grid with TalkBack semantics
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _FeatureCard(emoji: '📘', title: 'Subjects & Questions', subtitle: 'Chapters, 2M / 5M / 10M Q&A, TSBIE PDFs', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubjectsScreen())), semanticLabel: 'Subjects and questions, chapters and official TSBIE PDFs, double tap to open'),
              _FeatureCard(emoji: '🃏', title: 'Flashcards', subtitle: 'Flip-card revision • priority & saved', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FlashcardsSubjectPicker())), semanticLabel: 'Flashcards, flip card revision'),
              _FeatureCard(emoji: '🔍', title: 'Search', subtitle: 'Find any question across subjects', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())), semanticLabel: 'Search, find any question'),
              _FeatureCard(emoji: '🔖', title: 'Saved Questions', subtitle: 'Your bookmarked tough questions', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen())), semanticLabel: 'Saved questions, bookmarked'),
              _FeatureCard(emoji: '📊', title: 'My Progress', subtitle: 'Streak, exam countdown, learned %', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProgressScreen())), semanticLabel: 'My progress, streak and exam countdown'),
              _FeatureCard(emoji: '🎯', title: 'Play Quizzes', subtitle: 'MCQ quizzes + AI-generated', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizHomeScreen())), semanticLabel: 'Play quizzes, MCQ'),
              _FeatureCard(emoji: '✍️', title: 'Exam Answers', subtitle: 'Model answers 2,5,10 marks, Claude Opus', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExamAnswerScreen())), semanticLabel: 'Exam answer writer, 2 5 10 marks, Claude Opus'),
              _FeatureCard(emoji: '🤖', title: 'AI Tutor & ELI5', subtitle: 'Claude Opus/Sonnet via OpenRouter 🎤', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TutorScreen())), semanticLabel: 'AI Tutor and ELI5, Claude Opus, double tap, voice input supported'),
              _FeatureCard(emoji: '🔤', title: 'Vocabulary', subtitle: 'Telugu meanings • flashcards', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VocabScreen())), semanticLabel: 'Vocabulary, Telugu meanings'),
              _FeatureCard(emoji: '♿', title: 'TalkBack Guide', subtitle: 'Accessibility, TalkBack help', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccessibilityScreen())), semanticLabel: 'TalkBack guide, accessibility help'),
              _FeatureCard(emoji: '📄', title: 'Licenses', subtitle: 'Licenses & Navigation guide', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LicenseScreen())), semanticLabel: 'Licenses and navigation guide'),
              _FeatureCard(emoji: '⚙️', title: 'Settings', subtitle: 'API key Opus/Sonnet, voice, theme', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())), semanticLabel: 'Settings, API key, voice, theme'),
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            label: 'Supabase secure storage info',
            child: const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('✓ Supabase Auth: Email, Username unique, Password, Confirm\n✓ Stored safely with RLS, bcrypt, verification email\n✓ TalkBack fully supported\n✓ Claude Opus/Sonnet via OpenRouter (sk-or-v1-...)'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
          label: 'Study dashboard. Streak ${state.studyStreak} days. ${days == null ? "Exam season." : "$days days to examinations."} ${(pct * 100).round()} percent learned.',
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Wrap(spacing: 8, runSpacing: 6, children: [
              Chip(avatar: const Text('🔥'), label: Text('${state.studyStreak} day streak')),
              Chip(avatar: const Text('⏳'), label: Text(days == null ? 'Exam season 🎉' : '$days days to exams')),
              if (state.geminiKey.trim().startsWith('sk-or-')) Chip(label: const Text('Claude Opus Active'), backgroundColor: Colors.green.shade100, avatar: const Icon(Icons.check, size: 16, color: Colors.green)),
            ]),
            const SizedBox(height: 10),
            Text('Inter ${state.year == 1 ? "1st" : "2nd"} year: $learned / $total questions learned (${(pct * 100).round()}%)', style: const TextStyle(fontWeight: FontWeight.w600)),
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
  final String semanticLabel;
  const _FeatureCard({required this.emoji, required this.title, required this.subtitle, required this.onTap, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall, maxLines: 2),
            ]),
          ),
        ),
      ),
    );
  }
}
