import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';
import '../services/app_state.dart';

const _links = [
  NamedLink('🌐 TOSS Inter Textbooks (official page)',
      'https://www.telanganaopenschool.org/Intertextbooks.aspx'),
  NamedLink('📝 TOSS Model Papers & Blue Prints',
      'https://www.telanganaopenschool.org/Inter_Model_QP_Blueprint.aspx'),
  NamedLink('🏫 TSBIE - Board of Intermediate Education', 'https://bie.tg.nic.in/'),
  NamedLink('🔑 Google AI Studio - free Gemini key',
      'https://aistudio.google.com/app/apikey'),
];

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _keyController;

  @override
  void initState() {
    super.initState();
    _keyController =
        TextEditingController(text: context.read<AppState>().geminiKey);
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings ⚙️')),
      body: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
        // ---- Gemini key ----
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.key,
                    color: state.hasKey ? Colors.green : Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      state.hasKey
                          ? 'AI Tutor is ACTIVE ✅'
                          : 'Live AI needs a free Gemini key',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 8),
              const Text(
                  '1. Open aistudio.google.com → sign in → "Get API key" (free)\n'
                  '2. Copy the key and paste it below\n'
                  '3. It is saved ONLY on this phone - never uploaded anywhere'),
              const SizedBox(height: 10),
              TextField(
                controller: _keyController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Gemini API key',
                  hintText: 'AIza…',
                  prefixIcon: Icon(Icons.vpn_key_outlined),
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                FilledButton.icon(
                  onPressed: () {
                    state.setGeminiKey(_keyController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Key saved on device ✅')));
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Key'),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () => launchUrl(
                      Uri.parse('https://aistudio.google.com/app/apikey'),
                      mode: LaunchMode.externalApplication),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Get free key'),
                ),
              ]),
            ]),
          ),
        ),

        // ---- Voice ----
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.record_voice_over_outlined),
            title: const Text('Voice replies (read answers aloud)'),
            subtitle: const Text('AI tutor reads its answers to you'),
            value: state.ttsEnabled,
            onChanged: state.setTts,
          ),
        ),

        // ---- Official sources ----
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Text('Official free sources used by this app',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        for (final l in _links)
          Card(
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.link),
              title: Text(l.label),
              trailing: const Icon(Icons.open_in_new, size: 18),
              onTap: () => launchUrl(Uri.parse(l.url),
                  mode: LaunchMode.externalApplication),
            ),
          ),

        // ---- Data / about ----
        Card(
          child: Column(children: [
            const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('Inter AI Study Buddy v1.0'),
              subtitle: Text(
                  'Courses: Commerce • Economics • Civics • Accountancy • '
                  'Telugu • English (Inter 1st & 2nd year, English medium).\n'
                  'Textbook PDFs are linked (not re-hosted) from official '
                  'Government of Telangana websites.'),
            ),
            TextButton.icon(
              onPressed: () async {
                final sure = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Reset the app?'),
                    content: const Text(
                        'This clears your API key, quiz scores and learned words.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset')),
                    ],
                  ),
                );
                if (sure == true) {
                  await state.clearAll();
                  _keyController.clear();
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Reset app data'),
            ),
          ]),
        ),
      ]),
    );
  }
}
