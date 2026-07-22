import 'package:flutter/material.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Licenses & Navigation 📄')),
      body: Semantics(
        label: 'License and navigation screen with app licenses and navigation guide',
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Semantics(header: true, child: const Text('App License', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('Inter AI Study Buddy\n© 2026 Mahicouragw\nEducational use for Telangana Intermediate students\n\nIncludes:\n• Flutter (BSD)\n• Supabase Flutter (MIT)\n• Provider (MIT)\n• HTTP (BSD)\n• Shared Preferences (BSD)\n• URL Launcher (BSD)\n• Flutter TTS (BSD)\n• Speech to Text (BSD)\n\nTSBIE PDFs are linked from official tgbie.cgg.gov.in, not re-hosted.\nAI via OpenRouter (GPT-4o, Claude Opus/Sonnet) or Gemini free tier.\n\nSupabase: Auth stored safely, RLS enabled, unique username/email, verification email, bcrypt passwords.\nOpenRouter API Key stored only on device, never uploaded.'),
              ),
            ),
            const SizedBox(height: 16),
            Semantics(header: true, child: const Text('Navigation Guide', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            _navTile(context, Icons.home_outlined, 'Home', 'Dashboard with streak, exam countdown, quick access'),
            _navTile(context, Icons.book_outlined, 'Subjects', '6 subjects: Commerce, Economics, Civics, Accountancy, English, Telugu'),
            _navTile(context, Icons.quiz_outlined, 'Quiz', 'MCQ quizzes per subject, best scores'),
            _navTile(context, Icons.smart_toy_outlined, 'AI Tutor', 'Doubt solver + ELI5 mode, voice input/output, powered by Claude Opus/Sonnet via OpenRouter'),
            _navTile(context, Icons.edit_note_outlined, 'Exam Writer', '2/5/10 marks model answers, offline bank + live AI'),
            _navTile(context, Icons.menu_book_outlined, 'Vocab', '110 words with Telugu meanings, flashcards, quiz'),
            _navTile(context, Icons.search, 'Search', 'Global search across all Q&A'),
            _navTile(context, Icons.bookmark_outline, 'Bookmarks', 'Saved tough questions'),
            _navTile(context, Icons.settings_outlined, 'Settings', 'API key (OpenRouter Claude Opus/Sonnet or Gemini), voice, theme, TalkBack guide, licenses'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => showLicensePage(context: context),
              child: const Text('View Full Flutter Licenses'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navTile(BuildContext context, IconData icon, String title, String desc) {
    return Semantics(
      button: true,
      label: '$title tab, $desc',
      child: Card(
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
