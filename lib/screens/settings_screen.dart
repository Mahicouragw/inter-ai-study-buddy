import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models.dart';
import '../services/app_state.dart';

const _links = [
  NamedLink('🏛️ TSBIE — Board of Intermediate Education (official website)',
      'https://tgbie.cgg.gov.in/'),
  NamedLink('📄 TSBIE model question papers page — all subjects',
      'https://tgbie.cgg.gov.in/modelQuestionPapers.do'),
  NamedLink('🔑 Google AI Studio - free Gemini key',
      'https://aistudio.google.com/app/apikey'),
  NamedLink('🌐 OpenRouter - 300+ models via one key (Recommended)',
      'https://openrouter.ai/keys'),
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

  bool _isOpenRouterKey(String key) => key.trim().startsWith('sk-or-v1-') || key.trim().startsWith('sk-or-');
  bool _isGeminiKey(String key) => key.trim().startsWith('AIza');

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentKey = state.geminiKey.trim();
    final isOR = _isOpenRouterKey(currentKey);
    final isGem = _isGeminiKey(currentKey);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Settings ⚙️')),
      body: ListView(padding: const EdgeInsets.symmetric(vertical: 8), children: [
        // ---- AI key ----
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
                          ? isOR 
                              ? 'AI Tutor ACTIVE via OpenRouter ✅ (GPT-4o/Claude)'
                              : isGem
                                  ? 'AI Tutor ACTIVE via Gemini ✅'
                                  : 'AI Tutor ACTIVE ✅'
                          : 'Live AI needs API key',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
              ]),
              const SizedBox(height: 8),
              const Text(
                  '✨ NEW: Now supports OpenRouter (sk-or-v1-...) - one key for 300+ models including GPT-4o, Claude 3.5, Gemini 2.0!\n\n'
                  'Option 1 - OpenRouter (Recommended):\n'
                  '1. Open openrouter.ai/keys → sign in → Create key (free credits)\n'
                  '2. Copy key starting with sk-or-v1-...\n'
                  '3. Paste below → works for all AI models\n\n'
                  'Option 2 - Gemini Free:\n'
                  '1. Open aistudio.google.com → Get API key (free)\n'
                  '2. Copy key starting with AIza...\n'
                  '3. Paste below\n\n'
                  'Key saved ONLY on this phone - never uploaded.'),
              const SizedBox(height: 10),
              TextField(
                controller: _keyController,
                obscureText: true,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'API Key (Gemini AIza... or OpenRouter sk-or-v1-...)',
                  hintText: 'sk-or-v1-... or AIza...',
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  helperText: _keyController.text.trim().startsWith('sk-or-v1-') 
                      ? '✅ OpenRouter key detected - will use GPT-4o-mini' 
                      : _keyController.text.trim().startsWith('AIza')
                          ? '✅ Gemini key detected'
                          : 'Enter OpenRouter or Gemini key',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 10),
              Row(children: [
                FilledButton.icon(
                  onPressed: () {
                    state.setGeminiKey(_keyController.text);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                          _isOpenRouterKey(_keyController.text) 
                              ? 'OpenRouter key saved ✅ (GPT-4o enabled)' 
                              : 'Gemini key saved ✅'
                        )));
                    setState(() {});
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Key'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(spacing: 8, children: [
                    TextButton.icon(
                      onPressed: () => launchUrl(
                          Uri.parse('https://openrouter.ai/keys'),
                          mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Get OpenRouter'),
                    ),
                    TextButton.icon(
                      onPressed: () => launchUrl(
                          Uri.parse('https://aistudio.google.com/app/apikey'),
                          mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('Get Gemini'),
                    ),
                  ]),
                ),
              ]),
              if (state.hasKey) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(
                      isOR 
                          ? 'Using OpenRouter → Model: openai/gpt-4o-mini (fast, cheap, smart). You can change model in code to anthropic/claude-3.5-sonnet for reasoning or google/gemini-2.0-flash for speed.'
                          : 'Using Gemini → Model auto-fallback: gemini-2.5-flash, gemini-2.0-flash, gemini-1.5-flash',
                      style: const TextStyle(fontSize: 11),
                    )),
                  ]),
                ),
              ],
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

        // ---- Theme ----
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Appearance',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('Auto')),
                  ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light')),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark')),
                ],
                selected: {state.themeMode},
                onSelectionChanged: (s) => state.setThemeMode(s.first),
              ),
            ]),
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
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Inter AI Study Buddy v1.4.0 - OpenRouter Update'),
              subtitle: const Text(
                  'Courses: Commerce • Economics • Civics • Accountancy • '
                  'Telugu • English (Inter 1st & 2nd year, English medium).\n'
                  'Model papers & study material open directly from the '
                  'official Telangana Board of Intermediate Education (TSBIE) '
                  '— no third-party websites.\n'
                  'New in v1.4.0: OpenRouter support (sk-or-v1-...), GPT-4o-mini, Claude, Gemini 2.0 via one key, flashcards, search, bookmarks, learned tracker, '
                  'streak, exam countdown & dark mode.'),
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
                  setState(() {});
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
