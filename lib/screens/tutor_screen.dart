import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import 'settings_screen.dart';

class _Msg {
  final String text;
  final bool isUser;
  _Msg(this.text, this.isUser);
}

/// Chat with the AI tutor: doubt solving + "Explain Like I'm 5" mode,
/// with voice input (mic) and read-aloud replies (TTS).
/// Now supports both Gemini (AIza...) and OpenRouter (sk-or-v1-...) keys.
class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [
    _Msg(
        'Namaste! 🙏 I am Sahay, your AI study buddy. Ask me any doubt from '
        'Commerce, Economics, Civics, Accountancy, Telugu or English. '
        'Tap 🧒 ELI5 to make me explain like you are 5 years old! '
        'Now powered by OpenRouter (GPT-4o/Claude/Gemini) or Gemini Free.',
        false),
  ];
  String _mode = 'doubt'; // or 'eli5'
  bool _sending = false;
  bool _micOn = false;

  static const _doubtSystem =
      'You are "Sahay", a friendly AI tutor for Telangana Intermediate students '
      '(CEC stream: Commerce, Economics, Civics, Accountancy plus Telugu & '
      'English, both 1st and 2nd year). Answer step by step in simple English '
      'with small examples from daily Indian life. Be encouraging. Keep answers '
      'focused and exam-oriented. If the student writes in Telugu or Hinglish, '
      'reply in the same language style.';

  static const _eli5System =
      'Explain the student\'s topic like they are 5 years old. Use very simple '
      'words, short sentences, and ONE fun everyday example (pocket money, '
      'cricket, chocolates, school playground). Avoid jargon completely. '
      'End with a one-line summary starting with "So remember: ".';

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  String _history() {
    final recent = _messages.length > 7
        ? _messages.sublist(_messages.length - 7)
        : _messages;
    return recent
        .map((m) => '${m.isUser ? "Student" : "Tutor"}: ${m.text}')
        .join('\n');
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    final state = context.read<AppState>();
    final speech = context.read<SpeechService>();
    setState(() {
      _messages.add(_Msg(text, true));
      _sending = true;
      _controller.clear();
    });
    _jumpToEnd();

    if (!state.hasKey) {
      setState(() {
        _messages.add(_Msg(
            'I need an API key to answer live. ⚙️ Go to Settings:\n'
            '• For OpenRouter (Recommended, GPT-4o/Claude): openrouter.ai/keys → create key (sk-or-v1-...)\n'
            '• For Gemini Free: aistudio.google.com → Get free key (AIza...)\n'
            'Paste it in Settings → Save. Meanwhile, browse Subjects for offline Q&A!',
            false));
        _sending = false;
      });
      _jumpToEnd();
      return;
    }

    try {
      final system = _mode == 'eli5' ? _eli5System : _doubtSystem;
      final prompt =
          'Conversation so far:\n${_history()}\n\nStudent asks: $text';
      final reply = await GeminiService()
          .generate(apiKey: state.geminiKey, prompt: prompt, system: system);
      setState(() => _messages.add(_Msg(reply, false)));
      if (state.ttsEnabled) speech.speak(reply);
    } catch (e) {
      setState(() => _messages.add(_Msg('⚠️ $e', false)));
    } finally {
      setState(() => _sending = false);
      _jumpToEnd();
    }
  }

  void _jumpToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _toggleMic() async {
    final speech = context.read<SpeechService>();
    if (_micOn) {
      await speech.stopListening();
      setState(() => _micOn = false);
      return;
    }
    final ok = await speech
        .listen((words) => setState(() => _controller.text = words));
    if (ok) {
      setState(() => _micOn = true);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Microphone not available. Check mic permission for the app.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isOR = state.geminiKey.trim().startsWith('sk-or-');
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Tutor 🤖 ${isOR ? "(GPT-4o)" : ""}'),
        actions: [
          IconButton(
            tooltip: state.ttsEnabled ? 'Turn off voice replies' : 'Turn on voice replies',
            icon: Icon(state.ttsEnabled
                ? Icons.volume_up_outlined
                : Icons.volume_off_outlined),
            onPressed: () => state.setTts(!state.ttsEnabled),
          ),
        ],
      ),
      body: Column(children: [
        // Mode chips
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(children: [
            ChoiceChip(
              label: const Text('💡 Doubt Solver'),
              selected: _mode == 'doubt',
              onSelected: (_) => setState(() => _mode = 'doubt'),
            ),
            const SizedBox(width: 10),
            ChoiceChip(
              label: const Text('🧒 ELI5 Mode'),
              selected: _mode == 'eli5',
              onSelected: (_) => setState(() => _mode = 'eli5'),
            ),
            if (isOR) ...[
              const SizedBox(width: 10),
              Chip(label: Text('OpenRouter GPT-4o', style: TextStyle(fontSize: 10)), backgroundColor: Colors.green.shade100),
            ],
          ]),
        ),
        if (!state.hasKey)
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.key_outlined),
              title: const Text('Live AI is locked'),
              subtitle: const Text('Add OpenRouter (sk-or-v1-...) or Gemini key.'),
              trailing: TextButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen())),
                child: const Text('Settings'),
              ),
            ),
          ),
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length + (_sending ? 1 : 0),
            itemBuilder: (context, i) {
              if (i == _messages.length) {
                return const _Bubble(text: 'Sahay is thinking… ✏️ (via OpenRouter/Gemini)', isUser: false);
              }
              final m = _messages[i];
              return _Bubble(text: m.text, isUser: m.isUser);
            },
          ),
        ),
        // Input row
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Row(children: [
              IconButton(
                tooltip: 'Speak your doubt',
                style: IconButton.styleFrom(
                  backgroundColor: _micOn
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                ),
                icon: Icon(_micOn ? Icons.mic : Icons.mic_none),
                onPressed: _toggleMic,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: _mode == 'eli5'
                        ? 'Topic to explain like you\'re 5…'
                        : 'Type or 🎤 speak your doubt… (GPT-4o/Claude/Gemini)',
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              IconButton.filled(
                onPressed: _sending ? null : _send,
                icon: const Icon(Icons.send),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _Bubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: isUser ? scheme.primaryContainer : scheme.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(text, style: const TextStyle(height: 1.4)),
      ),
    );
  }
}
