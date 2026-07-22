import 'package:flutter/material.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Semantics(header: true, child: const Text('TalkBack & Accessibility ♿')),
      ),
      body: Semantics(
        label: 'Accessibility guide for Inter AI Study Buddy with TalkBack',
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Semantics(
              header: true,
              child: const Text('TalkBack Navigation Guide', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            const Text('This app is fully TalkBack accessible for visually impaired students. All buttons, fields have semantic labels.'),
            const SizedBox(height: 16),

            _section(
              title: '1. Enable TalkBack (Android)',
              icon: Icons.record_voice_over,
              content: '''
- Open Settings > Accessibility > TalkBack
- Turn On TalkBack
- Or hold Volume Up + Down for 3 seconds (shortcut)
- Explore by touch: Drag finger, TalkBack reads item
- Double-tap to activate button
- Swipe right: next item, left: previous
''',
            ),

            _section(
              title: '2. How to Use This App with TalkBack',
              icon: Icons.touch_app,
              content: '''
- Login: Email field announced as "Email field required", Password as "Password field"
- Signup: 4 fields announced individually: Email unique, Username unique, Password min 6 chars, Confirm must match
- After typing, TalkBack reads validation errors
- Home Screen: Bottom navigation items announced as "Home tab", "Subjects tab" etc.
- Tutor: Message bubbles announced, Send button "Send button double tap"
- Quiz: Options announced as "Option A, B, C"
- Flashcards: Flip announced
''',
            ),

            _section(
              title: '3. Voice Features (Built-in)',
              icon: Icons.mic,
              content: '''
- 🎤 Speak doubts: Mic button -> TalkBack says "Speak your doubt button" -> Tap -> Speak -> Text appears
- 🔊 Hear answers: Toggle "Voice replies" in Settings -> AI reads answers aloud via TTS
- 🔊 Listen button on every Q&A -> Reads question & answer
''',
            ),

            _section(
              title: '4. Keyboard Navigation (Computer/Chromebook)',
              icon: Icons.keyboard,
              content: '''
- Tab: Next field
- Shift+Tab: Previous
- Enter: Activate button
- All screens support focus order
''',
            ),

            _section(
              title: '5. Font Size & Display',
              icon: Icons.text_fields,
              content: '''
- App respects system font size (Settings > Display > Font size)
- Dark mode supported: Settings > Appearance > Light/Dark/Auto
- High contrast: Uses Material 3 theming
''',
            ),

            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: const Text('License & Navigation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Open Source Licenses'),
                subtitle: const Text('View all Flutter package licenses'),
                onTap: () => showLicensePage(context: context, applicationName: 'Inter AI Study Buddy', applicationVersion: 'v1.4.0', applicationLegalese: '© 2026 Mahicouragw - Educational use'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy - Supabase Storage'),
                subtitle: const Text('Data saved safely in Supabase, RLS protected, passwords bcrypt, API keys on device only'),
                onTap: () => showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Privacy'), content: const Text('Profiles stored in Supabase public.profiles with RLS, unique username/email checks, verification email required. API keys (OpenRouter/Gemini) stored only on device via SharedPreferences, never uploaded. Study progress, bookmarks, learned questions also local + optional Supabase sync.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))])),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.school_outlined),
                title: const Text('TSBIE Official Sources'),
                subtitle: const Text('All PDFs from tgbie.cgg.gov.in - official Board'),
                onTap: () {},
              ),
            ),

            const SizedBox(height: 20),
            Semantics(
              button: true,
              label: 'Test TalkBack, go back to home',
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.check),
                label: const Text('Got it, Back to App'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required IconData icon, required String content}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, size: 20), const SizedBox(width: 8), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)))]),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
